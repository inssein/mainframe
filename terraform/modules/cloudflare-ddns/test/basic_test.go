package test

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"io"
	"log"
	"net"
	"net/http"
	"os/exec"
	"strings"
	"testing"
	"time"
)

type CloudflareRequest struct {
	Type    string `json:"page"`
	Name    string `json:"name"`
	Content string `json:"content"`
	Proxied bool   `json:"proxied"`
	TTL     int    `json:"ttl"`
}

func TestBasic(t *testing.T) {
	t.Parallel()

	// keep track of how many times the webhook gets called
	webhookHits := 0

	// setup webhook server - start the server in a goroutine so that it doesn't block
	go startWebhookServer(t, &webhookHits, getPublicIP())

	// options for k8s and terraform
	namespaceName := strings.ToLower(random.UniqueId())
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic/",
		Vars: map[string]interface{}{
			"namespace_name": namespaceName,
			"cf_url":         fmt.Sprintf("http://%s:%s", getLocalIP(), "8080"),
		},
	}
	kubeOptions := k8s.NewKubectlOptions("", "", namespaceName)

	// create the namespace
	defer k8s.DeleteNamespace(t, kubeOptions, namespaceName)
	k8s.CreateNamespace(t, kubeOptions, namespaceName)

	// apply terraform
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// validate webhook gets called
	validateWebhook(t, &webhookHits)
}

func startWebhookServer(t *testing.T, webhookHits *int, ipAddress string) {
	const addr = ":8080"
	const path = "/client/v4/zones/9d13d3a6329627faab9c0a409f67a748/dns_records/3b51e921281be3e25c8a9838ec0efcfc"
	const pathDoesNotMatch = "Request path does not match."
	const nameDoesNotMatch = "Request name does not match."
	const contentDoesNotMatch = "Request content does not match."
	const authDoesNotMatch = "Authorization header does not match."
	const typeDoesNotMatch = "Content-Type does not match."

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// increment counter for webhook hits
		*webhookHits++

		// parse request json
		requestJson, _ := io.ReadAll(r.Body)
		var request CloudflareRequest
		_ = json.Unmarshal(requestJson, &request)

		// ensure content is what we expect to send to cloudflare
		assert.Equal(t, path, r.URL.Path, pathDoesNotMatch)
		assert.Equal(t, "subdomain.example.com", request.Name, nameDoesNotMatch)
		assert.Equal(t, ipAddress, request.Content, contentDoesNotMatch)
		assert.Equal(t, "Bearer SECRET", r.Header.Get("Authorization"), authDoesNotMatch)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"), typeDoesNotMatch)
	})

	log.Fatal(http.ListenAndServe(addr, nil))
}

// would have been much neater to do something like
// k8s.WaitUntilJobSucceed(t, options, "cloudflare-ddns-identifier", 10, 10*time.Second)
// but because it is a cronjob, it has a unique suffix
func validateWebhook(t *testing.T, webhookHits *int) {
	maxRetries := 20
	timeBetweenRetries := 10 * time.Second

	retry.DoWithRetry(
		t,
		"Waiting for webhook to get called by k8s",
		maxRetries,
		timeBetweenRetries,
		func() (string, error) {
			if *webhookHits != 1 {
				return "", errors.New("webhook not yet accessed")
			}

			return "Webhook called with the correct data", nil
		},
	)
}

func getLocalIP() string {
	addresses, err := net.InterfaceAddrs()

	if err != nil {
		return ""
	}

	for _, address := range addresses {
		if ipNet, ok := address.(*net.IPNet); ok && !ipNet.IP.IsLoopback() {
			if ipNet.IP.To4() != nil {
				return ipNet.IP.String()
			}
		}
	}

	return ""
}

// would have preferred to curl icanhazip / ifconfig.co, but they don't seem to work inside
// github actions as they are hosted behind cloudflare (cloudflare puts them behind a please wait page)
func getPublicIP() string {
	ipAddressCommand := exec.Command("dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")
	ipAddress, _ := ipAddressCommand.Output()

	return strings.TrimSuffix(string(ipAddress), "\n")
}

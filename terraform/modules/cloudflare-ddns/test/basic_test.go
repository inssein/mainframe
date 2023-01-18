package test

import (
	"errors"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"io"
	"log"
	"net"
	"net/http"
	"os/exec"
	"strings"
	"testing"
	"time"
)

func TestBasic(t *testing.T) {
	t.Parallel()

	maxRetries := 20
	timeBetweenRetries := 10 * time.Second
	accessed, matches := false, false

	// grab external ip address
	ipAddressCommand := exec.Command("dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")
	ipAddress, _ := ipAddressCommand.Output()
	cleanedIpAddress := strings.TrimSuffix(string(ipAddress), "\n")

	// setup webhook server
	mux := http.NewServeMux()
	mux.HandleFunc(
		fmt.Sprintf("/client/v4/zones/%s/dns_records/%s", "9d13d3a6329627faab9c0a409f67a748", "3b51e921281be3e25c8a9838ec0efcfc"),
		func(w http.ResponseWriter, r *http.Request) {
			accessed = true
			request, _ := io.ReadAll(r.Body)
			body := fmt.Sprintf("{\"type\":\"A\",\"name\":\"%s\",\"content\":\"%s\",\"proxied\":true,\"ttl\":1}", "subdomain.example.com", cleanedIpAddress)
			contentType := r.Header.Get("Content-Type")
			authorization := r.Header.Get("Authorization")

			// leaving log statements to help debug if it breaks
			fmt.Printf("Request received: %s-\n", string(request))
			fmt.Printf(" - Body to match: %s-\n", body)
			fmt.Printf(" - Content-Type to match: %s-\n", contentType)
			fmt.Printf(" - Authorization to match: %s-\n", authorization)

			matches = authorization == "Bearer SECRET" && contentType == "application/json" && body == string(request)
		})

	// start the server in a goroutine so that it doesn't block
	go func() {
		log.Fatal(http.ListenAndServe(":8080", mux))
	}()

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
	retry.DoWithRetry(
		t,
		"Waiting for webhook to get called by k8s",
		maxRetries,
		timeBetweenRetries,
		func() (string, error) {
			if !accessed {
				return "", errors.New("webhook not yet accessed")
			}

			// todo: if there was no match, no point in waiting
			// figure out how to exit from here
			if !matches {
				return "", errors.New("webhook did not match")
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

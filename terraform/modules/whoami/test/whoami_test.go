package test

import (
	"fmt"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"strings"
	"testing"
	"time"
)

func TestBasicWhoami(t *testing.T) {
	t.Parallel()

	namespaceName := strings.ToLower(random.UniqueId())
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic/",
		Vars: map[string]interface{}{
			"namespace_name": namespaceName,
		},
	}
	kubeOptions := k8s.NewKubectlOptions("", "", namespaceName)

	// create the namespace
	defer k8s.DeleteNamespace(t, kubeOptions, namespaceName)
	k8s.CreateNamespace(t, kubeOptions, namespaceName)

	// apply terraform
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// ensure we get a 200 back from the service
	validateWhoami(t, kubeOptions)
}

func validateWhoami(t *testing.T, options *k8s.KubectlOptions) {
	maxRetries := 10
	timeBetweenRetries := 3 * time.Second
	podSelector := metav1.ListOptions{LabelSelector: "app=whoami"}

	// wait until service is up and the correct amount of pods are up
	k8s.WaitUntilServiceAvailable(t, options, "whoami", 10, 1*time.Second)
	k8s.WaitUntilNumPodsCreated(t, options, podSelector, 2, maxRetries, timeBetweenRetries)

	// test service
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		serviceUrl(t, options),
		nil,
		maxRetries,
		timeBetweenRetries,
		func(statusCode int, body string) bool {
			isOk := statusCode == 200
			isNginx := strings.Contains(body, "GET /bar HTTP/1.1")
			return isOk && isNginx
		},
	)
}

func serviceUrl(t *testing.T, options *k8s.KubectlOptions) string {
	ingress := k8s.GetIngress(t, options, "whoami")
	return fmt.Sprintf("http://%s/bar", ingress.Status.LoadBalancer.Ingress[0].IP)
}

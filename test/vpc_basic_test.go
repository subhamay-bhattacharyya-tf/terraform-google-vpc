package test

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// vpcConfig mirrors the structure of examples/vpc/basic/vpc_config.json.
type vpcConfig struct {
	Name                         string      `json:"name"`
	Project                      string      `json:"project"`
	Description                  string      `json:"description"`
	AutoCreateSubnetworks        bool        `json:"auto_create_subnetworks"`
	RoutingMode                  string      `json:"routing_mode"`
	DeleteDefaultRoutesOnCreate  bool        `json:"delete_default_routes_on_create"`
	Subnets                      []subnetCfg `json:"subnets"`
}

type subnetCfg struct {
	Name                   string `json:"name"`
	Region                 string `json:"region"`
	IPCIDRRange            string `json:"ip_cidr_range"`
	Description            string `json:"description"`
	PrivateIPGoogleAccess  bool   `json:"private_ip_google_access"`
}

// TestVpcBasic creates a real VPC + subnet via the root module, asserts outputs,
// and destroys on teardown.
func TestVpcBasic(t *testing.T) {
	t.Parallel()

	projectID := mustEnv(t, "GOOGLE_CLOUD_PROJECT")
	unique := strings.ToLower(random.UniqueId())

	vpcName    := fmt.Sprintf("tt-vpc-%s", unique)
	subnetName := fmt.Sprintf("tt-subnet-%s", unique)

	cfg := vpcConfig{
		Name:                        vpcName,
		Project:                     projectID,
		Description:                 "Terratest VPC",
		AutoCreateSubnetworks:       false,
		RoutingMode:                 "REGIONAL",
		DeleteDefaultRoutesOnCreate: false,
		Subnets: []subnetCfg{
			{
				Name:                  subnetName,
				Region:                "us-central1",
				IPCIDRRange:           "10.99.0.0/20",
				Description:           "Terratest subnet",
				PrivateIPGoogleAccess: true,
			},
		},
	}

	cfgJSON, err := json.Marshal(cfg)
	require.NoError(t, err)

	// Write vpc_config.json to a temp dir alongside the root module.
	tmpCfgPath := fmt.Sprintf("/tmp/vpc_config_%s.json", unique)
	require.NoError(t, os.WriteFile(tmpCfgPath, cfgJSON, 0600))
	defer os.Remove(tmpCfgPath)

	tfOptions := &terraform.Options{
		TerraformDir: "..",
		NoColor:      true,
		Vars: map[string]interface{}{
			"vpc_config": cfg,
		},
	}

	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	time.Sleep(5 * time.Second)

	outputVPCName := terraform.Output(t, tfOptions, "vpc_name")
	require.Equal(t, vpcName, outputVPCName)

	outputSelfLink := terraform.Output(t, tfOptions, "vpc_self_link")
	require.Contains(t, outputSelfLink, vpcName)

	outputVPCID := terraform.Output(t, tfOptions, "vpc_id")
	require.NotEmpty(t, outputVPCID)
}

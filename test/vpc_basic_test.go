package test

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// vpcConfig mirrors the structure of examples/vpc/basic/vpc_config.json.
type vpcConfig struct {
	Name                        string      `json:"name"`
	Project                     string      `json:"project"`
	Description                 string      `json:"description"`
	AutoCreateSubnetworks       bool        `json:"auto_create_subnetworks"`
	RoutingMode                 string      `json:"routing_mode"`
	DeleteDefaultRoutesOnCreate bool        `json:"delete_default_routes_on_create"`
	Subnets                     []subnetCfg `json:"subnets"`
}

type subnetCfg struct {
	Name                  string        `json:"name"`
	Region                string        `json:"region"`
	IPCIDRRange           string        `json:"ip_cidr_range"`
	Description           string        `json:"description"`
	PrivateIPGoogleAccess bool          `json:"private_ip_google_access"`
	SecondaryIPRanges     []interface{} `json:"secondary_ip_ranges"`
}

// TestVpcBasic creates a real VPC + subnet via the root module, asserts outputs,
// and destroys on teardown.
func TestVpcBasic(t *testing.T) {
	t.Parallel()

	projectID := mustEnv(t, "GOOGLE_CLOUD_PROJECT")
	unique := strings.ToLower(random.UniqueId())

	vpcName := fmt.Sprintf("tt-vpc-%s", unique)
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
				SecondaryIPRanges:     []interface{}{},
			},
		},
	}

	// Serialize vpc_config into a .tfvars.json file. Passing a complex object
	// via Vars map causes Terratest to produce invalid HCL; VarFiles + JSON is
	// the correct approach for object-type variables.
	tfvarsJSON, err := json.Marshal(map[string]interface{}{"vpc_config": cfg})
	require.NoError(t, err)

	tfvarsPath := filepath.Join(t.TempDir(), "test.tfvars.json")
	require.NoError(t, os.WriteFile(tfvarsPath, tfvarsJSON, 0600))

	tfOptions := &terraform.Options{
		TerraformDir: "..",
		NoColor:      true,
		VarFiles:     []string{tfvarsPath},
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

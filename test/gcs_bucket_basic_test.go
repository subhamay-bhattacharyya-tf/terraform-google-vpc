package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestGCSBucketBasic tests creating a basic GCS bucket.
func TestGCSBucketBasic(t *testing.T) {
	t.Parallel()

	retrySleep := 5 * time.Second
	unique := strings.ToLower(random.UniqueId())
	bucketName := fmt.Sprintf("tt-gcs-basic-%s", unique)
	projectID := mustEnv(t, "GOOGLE_CLOUD_PROJECT")

	tfOptions := &terraform.Options{
		TerraformDir: "..",
		NoColor:      true,
		Vars: map[string]interface{}{
			"bucket_name": bucketName,
			"project_id":  projectID,
			"location":    "US",
		},
	}

	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	time.Sleep(retrySleep)

	outputBucketName := terraform.Output(t, tfOptions, "bucket_name")
	require.Equal(t, bucketName, outputBucketName)

	outputProject := terraform.Output(t, tfOptions, "bucket_project")
	require.Equal(t, projectID, outputProject)
}

// File: test/helpers_test.go
package test

import (
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// mustEnv retrieves a required environment variable, failing the test if absent.
func mustEnv(t *testing.T, key string) string {
	t.Helper()
	v := strings.TrimSpace(os.Getenv(key))
	require.NotEmpty(t, v, "Missing required environment variable %s", key)
	return v
}

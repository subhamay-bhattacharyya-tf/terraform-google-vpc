# Terraform Template Specification

Generate these files in the `/` directory:

**main.tf:** _(delegate to `tf-mod-main` skill)_

- GCP VPC using `google_compute_network` (resource label: `this`)
- GCP subnets using `google_compute_subnetwork` with `for_each` over `var.vpc_config.subnets` keyed by subnet name
- Dynamic block for `secondary_ip_range` inside each subnet resource
- Follow the GCP provider reference and core authoring patterns from the `tf-mod-main` skill

**locals.tf:**

Decode the JSON config at the call site — no locals needed in the root module itself. The module receives the already-decoded `vpc_config` object directly. If a local is needed for derived values (e.g., subnet map construction), define it here:

```hcl
locals {
  subnets_by_name = { for s in var.vpc_config.subnets : s.name => s }
}
```

**variables.tf:** _(delegate to `tf-mod-vars` skill)_

Use the `tf-mod-vars` skill to author this file. Apply the GCP provider reference and validation patterns. The variable schema is:

| Variable | Type | Required | Notes |
| --- | --- | --- | --- |
| `vpc_config` | `object` | Yes | See attribute table below |

`vpc_config` top-level attributes:

| Attribute | Type | Required | Default | Validation |
| --- | --- | --- | --- | --- |
| `name` | `string` | Yes | — | Lowercase letters, digits, hyphens; max 63 chars |
| `project` | `string` | Yes | — | Valid GCP project ID format |
| `description` | `string` | No | `""` | — |
| `auto_create_subnetworks` | `bool` | No | `false` | Must be `false` when subnets are defined |
| `routing_mode` | `string` | No | `"REGIONAL"` | One of: `REGIONAL`, `GLOBAL` |
| `delete_default_routes_on_create` | `bool` | No | `false` | — |
| `subnets` | `list(object)` | Yes | — | Must have at least one entry |

`vpc_config.subnets[*]` attributes:

| Attribute | Type | Required | Default | Validation |
| --- | --- | --- | --- | --- |
| `name` | `string` | Yes | — | Lowercase letters, digits, hyphens; max 63 chars |
| `region` | `string` | Yes | — | Valid GCP region string |
| `ip_cidr_range` | `string` | Yes | — | Valid CIDR notation |
| `description` | `string` | No | `""` | — |
| `private_ip_google_access` | `bool` | No | `true` | — |
| `secondary_ip_ranges` | `list(object)` | No | `[]` | Each entry: `range_name` (string) + `ip_cidr_range` (string, valid CIDR) |

**outputs.tf:**

- Outputs for all standard GCP VPC and subnet attributes:
  - `vpc_id` — `google_compute_network.this.id`
  - `vpc_name` — `google_compute_network.this.name`
  - `vpc_self_link` — `google_compute_network.this.self_link`
  - `vpc_gateway_ipv4` — `google_compute_network.this.gateway_ipv4`
  - `subnets` — list of objects via `values(google_compute_subnetwork.this)`, each containing `id`, `name`, `self_link`, `region`, `ip_cidr_range`, `gateway_address`

**versions.tf:**

- Versions.tf should be in the following format

```hcl

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.23.0"
    }
  }
}

provider "google" {
  project = var.vpc_config.project
}
```

**examples/:** _(delegate to `tf-mod-examples` skill)_

Use the `tf-mod-examples` skill to scaffold the full example matrix. Each example must be a self-contained, independently validatable Terraform configuration under `examples/vpc/<name>/` with its own `main.tf`, `vpc_config.json`, and `README.md`. The `main.tf` loads the JSON file via `jsondecode(file("${path.module}/vpc_config.json"))`.

**test/:**

- `test/vpc_basic_test.go`: Terratest that creates the real VPC + subnets, asserts all outputs match the JSON input values, and destroys on teardown.
- `test/helpers_test.go`: Shared test helpers (GCP project lookup, retry logic).

**package.json:**

- `github/workflows/ci.yaml`: This is the CI Pipeline. Add all the tests in the terratest job.

Ensure the name is always the repository name.

**package-lock.json:**

Ensure the name is always the repository name.

**CONTRIBUTING.md:**

Ensure in the CONTRIBUTING.md, Reporting Issues must always links to the current repository.

**README.md:** _(delegate to `tf-mod-readme` skill)_

Use the `tf-mod-readme` skill to generate this file. The skill will:

- Auto-resolve the repository name from the current git root
- Check and create the gist badge file if missing
- Populate all badge URLs pointing to the current repository
- Produce terraform-docs-compatible inputs/outputs tables
- Follow markdownlint rules (MD060 table column style)

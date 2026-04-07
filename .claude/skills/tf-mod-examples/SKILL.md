---
name: tf-mod-examples
description: >
  Generates Terraform module example configurations covering all meaningful
  combinations of vpc_config input options for the terraform-google-vpc module.
  Use this skill when the user asks to generate examples, scaffold example
  directories, create JSON input combinations, or produce a complete examples/
  folder for the VPC module. Trigger when the user says "generate all examples",
  "scaffold examples", "create example combinations", or "fill in the examples
  directory". Also trigger when the user shares a variables.tf and asks for
  example usage across all options.
---

# Terraform Module Examples — Generator Skill

This skill generates a complete `examples/vpc/` directory tree for the
`terraform-google-vpc` module by reading `variables.tf` and producing one
standalone example per meaningful feature combination. Each example loads its
`vpc_config` from a `vpc_config.json` file via `jsondecode(file(...))`.

---

## How to Use This Skill

1. Read `variables.tf` (and `versions.tf` if present) from the current module root.
2. Identify every optional field in `vpc_config` and `vpc_config.subnets[*]` and enumerate its allowed values from `validation` blocks or type annotations.
3. Derive the example matrix using the rules below.
4. Write each example as a self-contained directory under `examples/vpc/<name>/` with its own `main.tf`, `vpc_config.json`, and `README.md`.

---

## Step 1 — Enumerate Axes

For each optional field in the root `vpc_config` object and its `subnets` entries, record:

| Axis | Values |
|---|---|
| `routing_mode` | `REGIONAL`, `GLOBAL` |
| `auto_create_subnetworks` | `false` (always; required when subnets defined) |
| `delete_default_routes_on_create` | `true`, `false` |
| `private_ip_google_access` | `true`, `false` |
| `secondary_ip_ranges` | absent, present (pods + services ranges) |
| number of subnets | single, multiple (multi-region) |

---

## Step 2 — Example Matrix

Do **not** generate the full cartesian product. Instead produce these named
examples, each exercising a distinct capability or realistic deployment pattern:

| Directory | Purpose | Key axes exercised |
|---|---|---|
| `basic/` | Single subnet, all defaults | minimal `vpc_config`, one subnet, no secondary ranges |
| `with-secondary-ranges/` | GKE-style subnet with pod/service ranges | `secondary_ip_ranges` on one subnet |
| `with-private-google-access/` | Subnet with Private Google Access enabled | `private_ip_google_access = true` |
| `with-global-routing/` | VPC with global dynamic routing | `routing_mode = GLOBAL` |
| `with-multiple-subnets/` | Multi-region deployment | two or more subnets in different regions |
| `with-delete-default-routes/` | Delete default internet route on creation | `delete_default_routes_on_create = true` |
| `complete/` | All features on | global routing, multiple subnets, secondary ranges, private Google access, delete default routes |

---

## Step 3 — File Structure per Example

Each example directory must contain exactly these three files:

```
examples/vpc/<name>/
├── main.tf            # module call block only — loads vpc_config from JSON
├── vpc_config.json    # concrete JSON input for this example
└── README.md          # one-paragraph description + usage snippet
```

### `main.tf` template

```hcl
locals {
  vpc_config = jsondecode(file("${path.module}/vpc_config.json"))
}

module "vpc" {
  source = "../../../"

  vpc_config = local.vpc_config
}
```

Include a `versions.tf` that mirrors the root module's `versions.tf` (same `required_version` and `required_providers` block, no `provider` block — the root module sets the provider).

### `vpc_config.json` template (basic)

```json
{
  "name": "example-vpc",
  "project": "my-gcp-project",
  "description": "Example VPC",
  "auto_create_subnetworks": false,
  "routing_mode": "REGIONAL",
  "delete_default_routes_on_create": false,
  "subnets": [
    {
      "name": "example-subnet",
      "region": "us-central1",
      "ip_cidr_range": "10.0.0.0/20",
      "description": "Primary subnet",
      "private_ip_google_access": true,
      "secondary_ip_ranges": []
    }
  ]
}
```

For the `with-secondary-ranges` example, populate `secondary_ip_ranges`:

```json
"secondary_ip_ranges": [
  { "range_name": "pods",     "ip_cidr_range": "10.48.0.0/14" },
  { "range_name": "services", "ip_cidr_range": "10.52.0.0/20" }
]
```

### `README.md` template

```markdown
# <Example Title>

One sentence describing what this example demonstrates.

## Usage

\`\`\`bash
terraform init -backend=false
terraform validate
\`\`\`
```

---

## Step 4 — Validation Rules

After writing all files:

1. Run `terraform fmt -recursive examples/` to format all generated `.tf` files.
2. Run `terraform init -backend=false && terraform validate` inside each example directory and report any errors.
3. Fix any errors before returning.

---

## Step 5 — Output Summary

After all files are written and validated, print a table:

| Example | Files written | Validated |
|---|---|---|
| `basic/` | 3 | ✓ |
| ... | ... | ... |

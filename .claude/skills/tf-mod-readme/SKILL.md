---
name: tf-mod-readme
description: >
  Generates and standardizes README.md files for Terraform modules following
  a consistent structure: title, overview, usage block, requirements,
  inputs/outputs tables, resources, examples, notes/caveats, contributing,
  and license. Use this skill whenever a user asks to create, write, scaffold,
  update, or improve a README for a Terraform module — even if they phrase it
  as "document my module", "add docs to this tf module", "standardize our
  module READMEs", or "what should a Terraform README look like". Also trigger
  when the user shares a .tf file or module directory and asks for
  documentation. Produces terraform-docs-compatible tables and applies
  required/optional/conditional tagging to each section.
disable-model-invocation: true
---

> **Auto-resolve:** Before generating any output, derive `<repository-name>` by running `basename $(git rev-parse --show-toplevel)` in the current working directory. Use the result everywhere `<repository-name>` appears below. Do not prompt the user for it.

> **Gist badge setup:** Before writing the README, check whether the file `<repository-name>.json` exists in gist `476e6e7583432e960e6de16d5223e6a3` by running:
> ```bash
> gh gist view 476e6e7583432e960e6de16d5223e6a3 --files
> ```
> If `<repository-name>.json` is **not listed**, create it by writing a temporary file and adding it to the gist:
> ```bash
> printf '{\n  "schemaVersion": 1,\n  "label": "status",\n  "message": "in progress",\n  "color": "yellow",\n  "style": "flat"\n}' > /tmp/<repository-name>.json
> gh gist edit 476e6e7583432e960e6de16d5223e6a3 --add /tmp/<repository-name>.json
> ```
> Only then proceed to generate the README. The badge URL remains `https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/476e6e7583432e960e6de16d5223e6a3/raw/<repository-name>.json?` regardless.

# terraform-<provider>-<module-name>


![Release](https://github.com/subhamay-bhattacharyya-tf/<repository-name>/actions/workflows/ci.yaml/badge.svg)&nbsp;![GCP](https://img.shields.io/badge/GCP-4285F4?logo=googlecloud&logoColor=white)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-tf/<repository-name>)&nbsp;![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-623CE4?logo=anthropic&logoColor=white)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/476e6e7583432e960e6de16d5223e6a3/raw/<repository-name>.json?)&nbsp;![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.3-blue)&nbsp;![Provider Version](https://img.shields.io/badge/google-%3E%3D7.23-blue)

One-line summary of what this module provisions.

---

## Overview

2–4 sentences describing the purpose of the module, the primary resources it
creates, and the problem it solves. Avoid repeating the title. Focus on the
"why" and what AWS/GCP/Azure resources are managed.

**Example:**
This module creates a production-ready VPC on AWS including public and private
subnets across multiple availability zones. It provisions an Internet Gateway,
NAT Gateways, and route tables following AWS best practices for network
isolation.

---

## Usage

```hcl
locals {
  vpc_config = jsondecode(file("${path.module}/vpc_config.json"))
}

module "<module_name>" {
  source  = "org/<module-name>/google"
  version = "~> 1.0"

  vpc_config = local.vpc_config
}
```

Where `vpc_config.json` contains:

```json
{
  "name": "prod-vpc",
  "project": "my-gcp-project",
  "description": "Production VPC",
  "auto_create_subnetworks": false,
  "routing_mode": "REGIONAL",
  "delete_default_routes_on_create": false,
  "subnets": [
    {
      "name": "prod-subnet-primary",
      "region": "us-central1",
      "ip_cidr_range": "10.0.0.0/20",
      "private_ip_google_access": true,
      "secondary_ip_ranges": [
        { "range_name": "pods",     "ip_cidr_range": "10.48.0.0/14" },
        { "range_name": "services", "ip_cidr_range": "10.52.0.0/20" }
      ]
    }
  ]
}
```

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| google    | >= 7.23.0 |

**Additional prerequisites:**
- GCP credentials with the following permissions: `compute.networks.create`, `compute.subnetworks.create`, `compute.networks.delete`, `compute.subnetworks.delete`
- Workload Identity Federation configured for CI (see CI section below)

---

## Inputs

<!-- AUTO-GENERATED by terraform-docs — do not edit manually -->

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc\_config | Configuration object for the VPC and its subnets — loaded from a JSON file at the call site | `object(...)` | n/a | **yes** |

---

## Outputs

<!-- AUTO-GENERATED by terraform-docs — do not edit manually -->

| Name | Description |
|------|-------------|
| vpc\_id | Fully-qualified resource ID of the VPC |
| vpc\_name | Name of the VPC |
| vpc\_self\_link | Self-link URI of the VPC |
| vpc\_gateway\_ipv4 | Gateway IPv4 address assigned to the VPC |
| subnets | List of subnet objects — each containing `id`, `name`, `self_link`, `region`, `ip_cidr_range`, `gateway_address` |

---

## Resources

| Name | Type |
|------|------|
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

---

## Examples


> Each example is a standalone, runnable Terraform configuration stored in
> `examples/<name>/` with its own `README.md` and terraform validation.

---

## Notes & Caveats

> **Destructive operation:** Destroying this module deletes the VPC and all subnets.
> Ensure no GCE instances, GKE clusters, or other resources are still attached to the network before running `terraform destroy`.

- **`auto_create_subnetworks` must be `false`** — the module manages subnets explicitly via `for_each`; enabling auto-creation conflicts with explicit subnet definitions.
- **`delete_default_routes_on_create = true`** removes the `0.0.0.0/0` default route on VPC creation. Set this only for fully air-gapped or custom-routed VPCs — incorrect use blocks all internet egress.
- **Secondary IP ranges** must not overlap with the subnet's primary CIDR or with each other. Overlapping ranges cause apply-time errors from the GCP API.
- **`private_ip_google_access = true`** is recommended for all subnets — it allows VMs without external IPs to reach Google APIs (GCS, Artifact Registry, etc.) over internal routes.
- **`routing_mode = GLOBAL`** advertises dynamic routes to Cloud Routers in all regions. Use this only when you have multi-region Cloud Router/VPN topologies.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for full guidelines.

```bash
# Quick start
git clone git@github.com:subhamay-bhattacharyya-tf/<repository-name>.git
cd <repository-name>
terraform fmt -recursive
terraform validate
```

1. Fork the repository and create a feature branch (`git checkout -b feat/my-feature`)
2. Run `terraform fmt`, `terraform validate`, and `terraform-docs .`
3. Add or update tests under `test/` (Terratest)
4. Open a pull request against `main` with a clear description of changes

---

## CI / Workload Identity Federation Setup

The Terratest job authenticates to GCP via [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) (service account impersonation). If the job fails with `Permission 'iam.serviceAccounts.getAccessToken' denied`, grant the WIF pool principal the required IAM binding:

```bash
gcloud iam service-accounts add-iam-policy-binding \
    "<service-account-email>" \
    --project="<gcp-project-id>" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/<project-number>/locations/global/workloadIdentityPools/<pool-name>/attribute.repository/<github-org>/<repository-name>"
```

The three repository variables required by the CI workflow are:

| Variable | Description |
| --- | --- |
| `GCP_PROJECT_ID` | GCP project ID passed as `GOOGLE_CLOUD_PROJECT` to Terratest |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full WIF provider resource name |
| `GCP_SERVICE_ACCOUNT` | Service account email to impersonate |

---

## License

MIT © 2026 Your Organization — see [LICENSE](../../../LICENSE) for full terms.

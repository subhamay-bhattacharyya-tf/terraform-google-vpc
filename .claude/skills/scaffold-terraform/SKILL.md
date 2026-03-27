---
name: scaffold-terraform
description: Generate complete Terraform Google Module for provisioning a GCS bucket with the given specifications
disable-model-invocation: true
---

Generate a complete Terraform Google Module for provisioning a GCS bucket with the given specifications:

Use $ARGUMENTS for optional overrides:
- $0 = GCP region (default: us-central1)
- $1 = GCP Project name (default: portfolio-site)

## What to Generate

Read `template-spec.md` in this skill folder for the full iterraform module specification.

Generate all files in the `/` directory following the template spec.

## After Generation

- [ ] List all files created
- [ ] Show a summary of resources that will be provisioned
- [ ] Remind the engineer to review the files and run `/tf-plan` when ready

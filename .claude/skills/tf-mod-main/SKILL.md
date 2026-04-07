---
name: tf-mod-main
description: >
  Use this skill whenever working with Terraform module main.tf files across
  any cloud provider — including AWS, GCP, Azure, Snowflake, or custom modules.
  Trigger this skill when the user wants to: write or generate a main.tf for a
  child module; understand how resources reference variables; use count or
  for_each conditionally; wire data sources to resources; configure depends_on
  or lifecycle blocks; add SSE/encryption, access policies, or IAM to a
  resource; create folder/key placeholders inside a bucket or storage resource;
  debug plan/apply errors in a module's resource blocks; or review and extend
  an existing main.tf. Also trigger when the user pastes a main.tf and asks
  how it works, how to extend it, or how to fix it — regardless of whether
  they mention "skill" or "main.tf" by name.
---

# Terraform Module Main — Universal Skill

This skill covers best practices for authoring and extending `main.tf` files
in Terraform child modules across **any provider** (AWS, GCP, Azure, Snowflake,
and beyond). It documents universal patterns and provider-specific resource
blocks with annotated examples.

---

## How to Use This Skill

1. **If a `main.tf` was provided** → identify the resource types, spot the
   `count`/`for_each` patterns and data source wiring, then jump to the
   relevant [Provider Reference](provider-reference.md) section.
2. **If writing a new main.tf** → follow [Core Authoring Patterns](core-authoring-patterns.md).
3. **If adding a feature to an existing resource** → check
   [Common Resource Extensions](common-resource-extensions.md).
4. **If debugging a plan/apply error** → check [Common Mistakes](common-mistakes.md).

---

## Core Authoring Patterns

### Single vs Conditional Resource (`count`)

Use `count = 0` or `count = 1` to make an entire resource optional based on
a variable flag or null check.

```hcl
# Only create if variable is non-null
resource "aws_s3_bucket_policy" "this" {
  count  = var.s3_config.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.s3_config.bucket_policy
}
```

> ⚠️ Reference conditional resources with `[0]`: `aws_s3_bucket_policy.this[0].id`

### Multiple Resources from a Map (`for_each`)

Use `for_each` on a `toset()` or map to create one resource per item.

```hcl
# One object per folder key
resource "aws_s3_object" "bucket_keys" {
  for_each = toset(var.s3_config.bucket_keys)
  bucket   = aws_s3_bucket.this.id
  key      = "${each.value}/"
  source   = "/dev/null"
}
```

> ⚠️ `for_each` keys must be known at plan time — do not use computed/dynamic values as keys.

### Data Sources

Use `data` blocks to look up existing infrastructure (KMS keys, VPCs, AMIs,
etc.) rather than hardcoding IDs.

```hcl
data "aws_kms_alias" "this" {
  count = var.s3_config.kms_key_alias != null ? 1 : 0
  name  = "alias/${var.s3_config.kms_key_alias}"
}

# Reference in resource:
kms_master_key_id = data.aws_kms_alias.this[0].target_key_id
```

### `depends_on` — Explicit Ordering

Use `depends_on` when Terraform cannot infer the dependency from a reference
(e.g., a policy that requires public access block to be applied first).

```hcl
resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.this.id
  policy     = var.s3_config.bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.this]
}
```

### `lifecycle` Blocks

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.s3_config.bucket_name

  lifecycle {
    prevent_destroy       = true   # blocks accidental destroy
    ignore_changes        = [tags] # ignore tag drift
    create_before_destroy = false  # default; set true for zero-downtime replacements
  }
}
```

### Naming Convention for `this`

Child modules that manage a single logical resource use `this` as the resource
label. This keeps references clean (`aws_s3_bucket.this.id`) and signals that
the module is purpose-built for one resource type.

---

## Common Resource Extensions

### Adding Tags / Labels

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.s3_config.bucket_name
  tags   = merge(
    { Name = var.s3_config.bucket_name },
    var.s3_config.tags
  )
}
```

### Adding a Lifecycle Rule

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.s3_config.lifecycle_days != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-objects"
    status = "Enabled"
    expiration {
      days = var.s3_config.lifecycle_days
    }
  }
}
```

### Adding CORS

```hcl
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.s3_config.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.s3_config.cors_rules
    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}
```

### Dynamic Blocks

Use `dynamic` blocks for repeated nested configuration that varies in count.

```hcl
dynamic "rule" {
  for_each = var.s3_config.lifecycle_rules
  content {
    id     = rule.value.id
    status = rule.value.enabled ? "Enabled" : "Disabled"
    expiration {
      days = rule.value.expiration_days
    }
  }
}
```

---

## Common Mistakes

- **Referencing a `count` resource without `[0]`.** If a resource uses
  `count`, always reference it as `resource.label[0].attr`, not `resource.label.attr`.
- **Using a computed value as a `for_each` key.** Keys must be known before
  apply. Use static strings from variables, not resource output attributes.
- **Missing `depends_on` for policy/IAM resources.** Policies attached to
  resources that haven't finished creating will fail — add explicit `depends_on`.
- **KMS key alias prefix.** Always prefix the alias variable with `"alias/"`:
  `name = "alias/${var.kms_key_alias}"`. Omitting it returns a not-found error.
- **`prevent_destroy` blocking pipeline teardown.** Don't set `prevent_destroy = true`
  in modules used in ephemeral/dev environments — it blocks `terraform destroy`.
- **`source = "/dev/null"` for folder placeholders.** This is Linux-specific.
  For cross-platform compatibility, use `content = ""` instead of `source`.

---

## Provider Reference

Jump to the relevant section for provider-specific resource blocks, attribute
names, and complete annotated examples.

- [AWS](aws.md)
- [GCP](gcp.md)
- [Azure](azure.md)
- [Snowflake](snowflake.md)

---

## AWS

### AWS S3 Bucket Module — Full Annotated Example

This is the canonical child module pattern for an S3 bucket with optional
encryption, versioning, public access block, bucket policy, and folder
placeholder objects.

```hcl
# -----------------------------------------------------------------------------
# modules/s3-bucket/main.tf
# -----------------------------------------------------------------------------

# Look up existing KMS key by alias — only if kms_key_alias is provided
data "aws_kms_alias" "this" {
  count = var.s3_config.kms_key_alias != null ? 1 : 0
  name  = "alias/${var.s3_config.kms_key_alias}"
}

# Core bucket resource
resource "aws_s3_bucket" "this" {
  bucket = var.s3_config.bucket_name
  tags = merge(
    { Name = var.s3_config.bucket_name },
    var.s3_config.tags
  )
}

# Versioning — toggles Enabled/Suspended from boolean variable
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.s3_config.versioning ? "Enabled" : "Suspended"
  }
}

# Public access block — always enforced (all four settings hardcoded to true)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy — conditional on variable being non-null
# depends_on ensures public access block is applied first
resource "aws_s3_bucket_policy" "this" {
  count      = var.s3_config.bucket_policy != null ? 1 : 0
  bucket     = aws_s3_bucket.this.id
  policy     = var.s3_config.bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.this]
}

# Server-side encryption — SSE-S3 or SSE-KMS based on sse_algorithm variable
# bucket_key_enabled is set only for KMS (reduces API call costs)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.s3_config.sse_algorithm != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_config.sse_algorithm
      kms_master_key_id = var.s3_config.sse_algorithm == "aws:kms" ? data.aws_kms_alias.this[0].target_key_id : null
    }
    bucket_key_enabled = var.s3_config.sse_algorithm == "aws:kms" ? true : null
  }
}

# Folder placeholders — creates an empty object with trailing slash per key
# Use content = "" instead of source = "/dev/null" for cross-platform support
resource "aws_s3_object" "bucket_keys" {
  for_each = toset(var.s3_config.bucket_keys)
  bucket   = aws_s3_bucket.this.id
  key      = "${each.value}/"
  content  = ""
}
```

### SSE Algorithm Values

| Value | Encryption Type | KMS Key Required |
|---|---|---|
| `"AES256"` | SSE-S3 (AWS-managed) | No |
| `"aws:kms"` | SSE-KMS (CMK) | Yes — via `kms_key_alias` |
| `null` | No encryption configured | No |

### Common AWS S3 Resource Extensions

**Lifecycle configuration:**
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.s3_config.lifecycle_days != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.s3_config.lifecycle_days
    }
  }
}
```

**Bucket notification (SNS/SQS/Lambda):**
```hcl
resource "aws_s3_bucket_notification" "this" {
  count  = var.s3_config.notification_queue_arn != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  queue {
    queue_arn = var.s3_config.notification_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}
```

**Replication (cross-region):**
```hcl
resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.s3_config.replication_destination_arn != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.s3_config.replication_role_arn

  rule {
    id     = "replicate-all"
    status = "Enabled"
    destination {
      bucket        = var.s3_config.replication_destination_arn
      storage_class = "STANDARD"
    }
  }
}
```

---

## GCP

### Google VPC + Subnets Module — Annotated Example

```hcl
# -----------------------------------------------------------------------------
# modules/vpc/main.tf
# -----------------------------------------------------------------------------

# VPC network — single resource, label "this"
resource "google_compute_network" "this" {
  name                            = var.vpc_config.name
  project                         = var.vpc_config.project
  description                     = var.vpc_config.description
  auto_create_subnetworks         = var.vpc_config.auto_create_subnetworks
  routing_mode                    = var.vpc_config.routing_mode
  delete_default_routes_on_create = var.vpc_config.delete_default_routes_on_create
}

# Subnets — one resource per entry in vpc_config.subnets, keyed by subnet name
resource "google_compute_subnetwork" "this" {
  for_each = { for s in var.vpc_config.subnets : s.name => s }

  name                     = each.value.name
  project                  = var.vpc_config.project
  region                   = each.value.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access

  # Secondary ranges — zero or more alias IP ranges (e.g. GKE pods/services)
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  depends_on = [google_compute_network.this]
}
```

### VPC Routing Mode Values

| Value | Description |
|---|---|
| `REGIONAL` | Dynamic routes are only advertised to routers in the same region (default) |
| `GLOBAL` | Dynamic routes are advertised to all Cloud Routers in all regions |

### Secondary IP Range Use Cases

| Range Name Convention | Purpose |
|---|---|
| `pods` | GKE Pod CIDR — must not overlap with node or service ranges |
| `services` | GKE Service (ClusterIP) CIDR |
| Any custom name | Application-specific alias IP ranges |

### VPC-Specific `lifecycle` Notes

- **`prevent_destroy = true`** — Avoid on VPCs in dev/test environments; GCP will block deletion if subnets still exist, which can leave Terraform in a broken state.
- **`delete_default_routes_on_create`** — Set `true` only when you manage all routing manually (e.g., fully air-gapped VPCs). Incorrect use blocks all internet egress.

### `depends_on` for Subnets

Always add `depends_on = [google_compute_network.this]` on the subnet resource. GCP's API sometimes returns the network ID before the network is fully ready; the explicit dependency prevents intermittent 404s on subnet creation.

---

## Azure

### Azure Storage Account Module — Annotated Example

```hcl
# -----------------------------------------------------------------------------
# modules/azure-storage/main.tf
# -----------------------------------------------------------------------------

# Look up existing resource group
data "azurerm_resource_group" "this" {
  name = var.storage_config.resource_group_name
}

# Core storage account
resource "azurerm_storage_account" "this" {
  name                      = var.storage_config.name
  resource_group_name       = data.azurerm_resource_group.this.name
  location                  = data.azurerm_resource_group.this.location
  account_tier              = var.storage_config.account_tier
  account_replication_type  = var.storage_config.account_replication_type
  enable_https_traffic_only = var.storage_config.enable_https_traffic_only
  min_tls_version           = var.storage_config.min_tls_version
  tags                      = var.storage_config.tags

  # Customer-managed key encryption — only when key_vault_key_id is set
  dynamic "identity" {
    for_each = var.storage_config.key_vault_key_id != null ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  blob_properties {
    delete_retention_policy {
      days = var.storage_config.blob_delete_retention_days
    }
  }
}

# Private containers — one per entry in containers list
resource "azurerm_storage_container" "this" {
  for_each = {
    for c in var.storage_config.containers : c.name => c
  }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.access_type
}

# Network rules — conditional on network_rules being provided
resource "azurerm_storage_account_network_rules" "this" {
  count                = var.storage_config.network_rules != null ? 1 : 0
  storage_account_id   = azurerm_storage_account.this.id
  default_action       = var.storage_config.network_rules.default_action
  ip_rules             = var.storage_config.network_rules.ip_rules
  virtual_network_subnet_ids = var.storage_config.network_rules.subnet_ids
  bypass               = var.storage_config.network_rules.bypass
}
```

### Azure Account Tier vs Replication Matrix

| Tier | Valid Replication Types |
|---|---|
| `Standard` | `LRS`, `ZRS`, `GRS`, `RAGRS`, `GZRS`, `RAGZRS` |
| `Premium` | `LRS`, `ZRS` only |

---

## Snowflake

### Snowflake Table Module — Annotated Example

```hcl
# -----------------------------------------------------------------------------
# modules/snowflake-table/main.tf
# -----------------------------------------------------------------------------

resource "snowflake_table" "this" {
  for_each = var.table_configs

  database            = each.value.database
  schema              = each.value.schema
  name                = each.value.name
  comment             = each.value.comment
  cluster_by          = each.value.cluster_by
  data_retention_days = each.value.data_retention_time_in_days
  change_tracking     = each.value.change_tracking

  # One column block per entry in the columns list
  dynamic "column" {
    for_each = each.value.columns
    content {
      name     = column.value.name
      type     = column.value.type
      nullable = column.value.nullable
      comment  = column.value.comment

      dynamic "default" {
        for_each = column.value.default != null ? [column.value.default] : []
        content {
          constant = default.value
        }
      }

      dynamic "identity" {
        for_each = column.value.autoincrement != null ? [column.value.autoincrement] : []
        content {
          start_num = identity.value.start
          step_num  = identity.value.increment
        }
      }
    }
  }

  # Primary key constraint — conditional
  dynamic "primary_key" {
    for_each = each.value.primary_key != null ? [each.value.primary_key] : []
    content {
      name = primary_key.value.name
      keys = primary_key.value.keys
    }
  }
}

# Table grants — one resource per role per table
resource "snowflake_table_grant" "this" {
  for_each = {
    for pair in flatten([
      for table_key, tbl in var.table_configs : [
        for grant in tbl.grants : {
          table_key  = table_key
          role_name  = grant.role_name
          privileges = grant.privileges
        }
      ]
    ]) : "${pair.table_key}/${pair.role_name}" => pair
  }

  database_name = var.table_configs[each.value.table_key].database
  schema_name   = var.table_configs[each.value.table_key].schema
  table_name    = snowflake_table.this[each.value.table_key].name
  privilege     = each.value.privileges[0]   # one resource per privilege if needed
  roles         = [each.value.role_name]
}
```

### Key Snowflake Resource Attributes

| Attribute | Notes |
|---|---|
| `data_retention_days` | Maps to `data_retention_time_in_days` in the variable |
| `change_tracking` | Enables Snowflake CDC streams on the table |
| `cluster_by` | List of column expressions; avoid over-clustering small tables |
| `identity` block | Replaces `autoincrement`; use `start_num` and `step_num` |
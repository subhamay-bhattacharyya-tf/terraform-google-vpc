# With Delete Default Routes Example

Demonstrates a fully air-gapped VPC with `delete_default_routes_on_create = true`, removing the `0.0.0.0/0` default internet route at VPC creation time.

## Usage

```bash
terraform init -backend=false
terraform validate
```

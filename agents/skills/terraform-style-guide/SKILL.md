---
name: terraform-style-guide
description: Generate Terraform HCL code following consistent conventions.
---

# Terraform Style Guide (Agent Friendly)

Purpose: produce clear, consistent Terraform HCL with safe defaults.

## Agent usage

Use this skill when generating, editing, or reviewing Terraform code.
Follow repo conventions if they conflict with this guide.

## File naming

- Resource file: `${resource}.tf` for the primary concern (e.g. `iam.tf` for IAM resources). Use `${resource}__${discriminator}.tf` when splitting by concern or scope.
- Split large files: `${resource_type}__${resource_name}.tf`.
- Module-only file: `module__${module_name}.tf`.
- Meta files use `_` prefix:
  - `_providers.tf`, `_variables.tf`, `_outputs.tf`, `_locals.tf`.
- Split large meta files: `_file__concept.tf`.
- Multi-cloud: `${provider}__${resource}.tf`.
- Config tfvars: `factory/config/${asset}.tfvars`.

## Resource naming

- Use lowercase with underscores.
- Use descriptive, singular nouns (exclude resource type).
- Default to `main` when there is only one instance.

### Buckets

Format: `${project_name}-${bucket_descriptor}-${access_modifier}`.

- `bucket_descriptor`: alphanumeric + dashes.
- `access_modifier`: `private` or `public`.

### Projects

Format:

```
name = ${type}-${name}-${environment}
id   = ${type}-${identifier}-${environment}
```

- `environment`: `dev`, `test`, `qa`, `prod`, `deploy` (use `deploy` for special projects).

## Formatting

- Indent with two spaces (no tabs).
- Align equals signs within a block.
- Use multi-line maps for more than one key.
- Separate top-level blocks with one blank line.
- Separate nested blocks with one blank line. The exception is when grouping related blocks of the same type, such as multiple `provisioner` blocks within a resource.
- Avoid grouping blocks of different types together unless the types are a semantic family (for example `root_block_device`, `ebs_block_device`, `ephemeral_block_device`).

## Argument ordering (within a block)

Meta-arguments are: `count`, `depends_on`, `for_each`, `lifecycle`, `provider`, `provisioner`.

Order blocks exactly in this sequence and insert blank lines between groups:

1. Meta-arguments: `provider`
2. Meta-arguments: `for_each` or `count`
3. Required arguments
4. Optional arguments
5. Meta-arguments: `provisioner`
6. Meta-arguments: `depends_on`
7. Meta-arguments: `lifecycle`

Use this layout:

```hcl
resource "test" "my_test" {
  provider = <...>
  for_each = <...> # or count = <...>

  # required arguments

  # optional arguments

  provisioner "local-exec" {
    # ...
  }

  depends_on = [<...>]
  lifecycle {
    # ...
  }
}
```

## Code generation flow

1. `_providers.tf`: provider config + version constraints.
2. Define data sources before dependent resources.
3. Create resources in dependency order.
4. `_variables.tf`: all configurable values.
5. `_outputs.tf`: key outputs.

## Variables and outputs

- Variables must include `type` and `description`.
- Group related variables into an `object()` with explicit fields and types.
- Prefer `map(object())` and `list(object())` over `map(map())` and `list(map())`.
- Avoid `null` values in variables; use `optional(type, default_value)` for defaults inside objects.
- Add `validation` blocks when constraints are known.
- Outputs must include `description`.
- Mark secrets with `sensitive = true`.

## Dynamic resources

- Prefer `for_each` for multiple instances.
- Use `count` only for conditional creation.

## Security

- Enable encryption at rest when supported.
- Use least-privilege IAM.
- Enable logging/monitoring where available.
- Never hardcode credentials or secrets.

## Versioning

- Pin `required_version` and provider versions.
- Prefer `>= x.y.z, < a.b.c` for new constraints, but do not change existing configurations.

Common operators:
- `= 1.0.0`
- `>= 1.0.0`
- `~> 1.0`
- `>= 1.0, < 2.0`

## Version control

Never commit:
- `terraform.tfstate`, `terraform.tfstate.backup`
- `.terraform/`
- `*.tfplan`

Always commit:
- All `.tf` files
- `.terraform.lock.hcl`

## Validation

Run before committing:

```bash
terraform fmt -recursive
terraform validate
```

Optional tools:
- `tflint`
- `checkov` or `tfsec`

## Review checklist

- File naming matches this guide.
- Formatting with `terraform fmt`.
- `terraform validate` passes.
- Variables and outputs documented.
- Naming rules followed.
- Versions pinned.
- Sensitive values marked.
- No secrets in code.
- Argument ordering consistent.

## Exceptions

If you deviate from this guide, document the reason in code comments and in your response.

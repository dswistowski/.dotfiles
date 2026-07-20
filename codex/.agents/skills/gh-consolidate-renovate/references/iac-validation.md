# IaC Validation

Use these checks for the `waycore/iac` repository after consolidating Renovate updates.

## Local checks

Run the closest available equivalent of the GitHub Actions workflow:

```bash
terraform fmt -check -recursive .
terraform init -backend=false
terraform validate
```

Run `terraform init -backend=false` and `terraform validate` separately in:

- `environments/production`
- `environments/staging`

Run Sentinel tests from the `sentinel` directory when the Sentinel CLI is available:

```bash
sentinel test
```

If `just` is available, run:

```bash
just format
```

Then confirm no generated Terraform directories or lockfiles are accidentally committed.

## CI parity

The repository's `IaC Lint` workflow checks:

- Terraform formatting with `terraform fmt -check -recursive .`
- `terraform init -backend=false` and `terraform validate` in production
- `terraform init -backend=false` and `terraform validate` in staging
- Sentinel policy tests through `hashicorp/sentinel-github-actions`

Report any local command that cannot run because a binary is missing, then rely on GitHub Actions for that check after pushing.

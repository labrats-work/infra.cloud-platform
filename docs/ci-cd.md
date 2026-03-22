# CI/CD Pipeline

## Overview

This repository uses GitHub Actions for CI validation and FluxCD for continuous delivery to the cluster. The pipeline enforces quality gates before changes reach production.

## GitHub Actions Workflows

### Validate (`.github/workflows/validate.yml`)

Runs on every pull request and push to `main`. Three parallel jobs:

| Job | What It Checks |
|-----|---------------|
| **YAML Validation** | All `.yaml` and `.yml` files have valid syntax |
| **Terraform Validation** | All Terraform configurations in `clouds/` are valid |
| **Security Scan** | Scans for hardcoded secrets, tokens, and credentials |

**Runner:** `k8s-hetzner-arc` (self-hosted runner on the Hetzner cluster via Actions Runner Controller)

### Running Checks Locally

Before pushing, run checks locally with Make:

```bash
# Run all validation checks
make validate

# Validate only Terraform
make validate-terraform

# Validate only Kubernetes manifests
make validate-kubernetes

# Lint YAML files (requires yamllint)
make lint
```

See `Makefile` for all available targets (`make help`).

## Continuous Delivery with FluxCD

All production changes flow through FluxCD:

```
Git commit → GitHub Actions validates → Merged to main → FluxCD detects → Applies to cluster
```

FluxCD polls the Git repository every 1 minute by default. To force immediate reconciliation:

```bash
flux reconcile source git flux-system
```

See [FluxCD Operations Runbook](runbooks/flux-operations.md) for more.

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production — FluxCD deploys from this branch |
| `feat/*` | Feature development |
| `fix/*` | Bug fixes |
| `docs/*` | Documentation changes |
| `chore/*` | Maintenance, CI, tooling |

All changes require a PR with passing CI checks before merging to `main`.

## Secrets in CI

CI workflows do not require access to production secrets. Terraform validation runs with `-backend=false` and does not require cloud credentials. SOPS-encrypted secrets are not decrypted in CI.

## Self-Hosted Runner

The `k8s-hetzner-arc` runner is managed by [Actions Runner Controller](https://github.com/actions/actions-runner-controller) deployed on the Hetzner cluster. If CI jobs are not starting, check:

```bash
kubectl get pods -n arc-runners
kubectl get runners -n arc-runners
```

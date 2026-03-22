# Claude Context: infra.cloud-platform

## Overview
Multi-cloud Kubernetes platform monorepo. Cloud-agnostic platform layer with provider-specific implementations.

## Repository Structure

### clouds/
Cloud-specific infrastructure (Terraform, Ansible). Each cloud has its own directory.
- `hetzner/` - Active implementation
- `aws/`, `gcp/` - Planned

### platform/
Cloud-agnostic Kubernetes resources. These deploy identically on any cluster.
- `shared/` - Base configs, CRDs, RBAC
- `infrastructure/` - Ingress, cert-manager, DNS, Flux
- `observability/` - Prometheus, Grafana, Loki
- `security/` - SOPS, policies, network policies
- `apps/` - Demo applications

### tools/
Shared scripts, Makefiles, CI helpers.

### docs/
Architecture docs, ADRs, cloud-specific guides, runbooks.

## Conventions
- Terraform modules in `clouds/<provider>/terraform/modules/`
- Kustomize bases in `platform/`, overlays per-cloud if needed
- All secrets encrypted with SOPS + AGE
- No hardcoded IPs, tokens, or credentials anywhere
- Semantic versioning, conventional commits
- CI runners: `k8s-hetzner-arc`

## Tooling
- `make help` — list all available Makefile targets
- `make validate` — validate Terraform configs and Kubernetes manifests
- `make lint` — lint YAML files with yamllint
- `make hetzner-plan` / `make hetzner-apply` — Terraform plan/apply for Hetzner
- `make flux-check` — check Flux reconciliation status
- `make flux-reconcile` — force Flux reconciliation

## Important
This is a PUBLIC repository. Never commit secrets, credentials, or sensitive infrastructure details.

# Cloud Platform

> Multi-cloud Kubernetes platform with GitOps automation, infrastructure as code, and production-grade observability.

---

## Overview

A monorepo for managing cloud-native Kubernetes platforms across multiple cloud providers. The architecture separates **cloud-specific infrastructure** (provisioning, networking) from a **cloud-agnostic platform layer** (services, observability, security), enabling consistent operations across any provider.

**Current:** Hetzner Cloud
**Roadmap:** AWS EKS, GCP GKE

## Architecture Principles

- **Cloud-Agnostic Platform Layer** -- Platform services run identically on any Kubernetes cluster
- **Infrastructure as Code** -- All infrastructure defined in Terraform and Ansible
- **GitOps with FluxCD** -- Declarative, version-controlled deployments with automated reconciliation
- **Unified Observability** -- Consistent monitoring, logging, and alerting across all clouds
- **Security-First** -- SOPS encryption, RBAC, network policies, pod security standards
- **Cost-Aware** -- Right-sized infrastructure with documented cost analysis per provider

## Cloud Providers

| Provider | Status | Description |
|----------|--------|-------------|
| **Hetzner Cloud** | Active | Production cluster with Longhorn storage, Traefik ingress |
| **AWS EKS** | Planned | Managed Kubernetes with cloud-native integrations |
| **GCP GKE** | Planned | Managed Kubernetes with Anthos service mesh |

## Repository Structure

```
infra.cloud-platform/
├── clouds/                     # Cloud-specific infrastructure
│   ├── hetzner/                # Hetzner Cloud implementation
│   │   ├── terraform/          # Cluster provisioning
│   │   └── ansible/            # Node configuration
│   ├── aws/                    # AWS implementation (planned)
│   └── gcp/                    # GCP implementation (planned)
│
├── platform/                   # Cloud-agnostic platform layer
│   ├── shared/                 # Base Kubernetes configs, RBAC, CRDs
│   ├── infrastructure/         # Ingress, cert-manager, DNS, Flux
│   ├── observability/          # Prometheus, Grafana, Loki
│   ├── security/               # SOPS, policies, network policies
│   └── apps/                   # Demo applications
│
├── tools/                      # Scripts, Makefiles, CI helpers
├── docs/                       # Architecture docs, ADRs, runbooks
└── .github/workflows/          # CI/CD validation pipelines
```

## Platform Components

### Infrastructure Services
| Component | Purpose | Status |
|-----------|---------|--------|
| Traefik | Ingress controller and load balancing | Active |
| cert-manager | Automated TLS certificate management | Active |
| External DNS | Automated DNS record management | Planned |
| FluxCD | GitOps continuous delivery | Active |

### Observability Stack
| Component | Purpose | Status |
|-----------|---------|--------|
| Prometheus | Metrics collection and alerting | Active |
| Grafana | Dashboards and visualization | Active |
| Loki | Log aggregation | Planned |

### Security
| Component | Purpose | Status |
|-----------|---------|--------|
| SOPS + AGE | Secret encryption at rest | Active |
| Network Policies | Pod-to-pod traffic control | Active |
| Pod Security Standards | Container hardening | Active |
| RBAC | Role-based access control | Active |

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.10
- [Ansible](https://www.ansible.com/) >= 2.15
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28
- [Flux CLI](https://fluxcd.io/docs/installation/) >= 2.0
- [SOPS](https://github.com/getsops/sops) >= 3.8
- [Helm](https://helm.sh/) >= 3.13

### Deploy Hetzner Cluster

```bash
# 1. Provision infrastructure
cd clouds/hetzner/terraform/cluster
terraform init && terraform apply

# 2. Configure nodes
cd ../../ansible
ansible-playbook site.yml

# 3. Bootstrap Flux
flux bootstrap github \
  --owner=labrats-work \
  --repository=infra.cloud-platform \
  --path=platform/shared/base
```

See [docs/clouds/hetzner.md](docs/clouds/hetzner.md) for the complete guide.

## Documentation

### Architecture
- [Architecture Overview](docs/architecture/overview.md)
- [Cloud Abstraction Strategy](docs/architecture/cloud-abstraction.md)
- [Architecture Decision Records](docs/decisions/)

### Operations
- [CI/CD Pipeline](docs/ci-cd.md)
- [Hetzner Cloud Guide](docs/clouds/hetzner.md)
- [Cluster Operations Runbook](docs/runbooks/cluster-operations.md)
- [FluxCD Operations Runbook](docs/runbooks/flux-operations.md)
- [Incident Response Runbook](docs/runbooks/incident-response.md)

## Makefile Targets

Run `make help` to see all available targets:

| Target | Description |
|--------|-------------|
| `make validate` | Run all validation checks |
| `make validate-terraform` | Validate Terraform configurations |
| `make validate-kubernetes` | Validate Kubernetes manifests |
| `make lint` | Lint YAML files |
| `make hetzner-plan` | Terraform plan for Hetzner |
| `make hetzner-apply` | Terraform apply for Hetzner |
| `make flux-check` | Check Flux reconciliation status |
| `make flux-reconcile` | Force Flux reconciliation |

## Cost Analysis

| Provider | Nodes | Config | Monthly Cost |
|----------|-------|--------|-------------|
| **Hetzner** | 3x CPX21 | 3 vCPU, 4GB RAM each | ~EUR 25 |
| **AWS EKS** | 3x t3.medium | 2 vCPU, 4GB RAM each | ~$150 |
| **GCP GKE** | 3x e2-medium | 2 vCPU, 4GB RAM each | ~$120 |

Hetzner provides exceptional value for development and small production workloads.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is **source-available**. You may view the code for reference and educational purposes. All other rights are reserved. See [LICENSE](LICENSE) for details.

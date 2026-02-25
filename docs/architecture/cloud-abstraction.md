# Cloud Abstraction Strategy

## Problem

Running Kubernetes across multiple cloud providers introduces complexity. Each provider has different APIs, networking models, storage drivers, and managed service offerings. Without careful abstraction, platform operations become fragmented and error-prone.

## Approach

We use a **two-layer architecture** to balance cloud-specific optimizations with operational consistency.

### Layer 1: Cloud Infrastructure (`clouds/`)

Each cloud provider has its own directory containing:
- **Terraform** for provisioning compute, networking, and cloud services
- **Ansible** for node-level configuration (where applicable)
- **Provider-specific storage** and networking integrations

This layer is intentionally different per provider. We leverage each cloud's strengths rather than forcing a lowest-common-denominator approach.

### Layer 2: Platform Services (`platform/`)

The platform layer contains Kubernetes-native resources that run identically on any conformant cluster:
- Ingress, certificates, DNS
- Monitoring, logging, alerting
- Security policies and RBAC
- Application deployments

This layer uses **Kustomize** with optional per-cloud overlays for the rare cases where platform resources need cloud-specific adjustments (e.g., storage class names, load balancer annotations).

## Trade-offs

| Decision | Benefit | Cost |
|----------|---------|------|
| Separate cloud/platform layers | Clean abstraction, easy to add clouds | Some duplication in cloud configs |
| Kustomize over Helm (platform) | Transparent, auditable, GitOps-native | More verbose than Helm values |
| Cloud-native storage per provider | Best performance per cloud | Storage configs aren't portable |
| Single ingress controller (Traefik) | Consistent routing everywhere | Miss cloud-native LB features |

## Adding a New Cloud Provider

1. Create `clouds/<provider>/` directory
2. Write Terraform to provision a conformant Kubernetes cluster
3. Configure storage driver and networking
4. Point FluxCD at the shared `platform/` manifests
5. Add cloud-specific Kustomize overlays if needed
6. Document provider-specific decisions in `docs/clouds/<provider>.md`

The platform layer deploys automatically once FluxCD connects to the new cluster.

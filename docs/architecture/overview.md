# Architecture Overview

## Design Philosophy

This platform follows a layered architecture that cleanly separates cloud-specific infrastructure from cloud-agnostic platform services. This separation enables:

- **Portability:** Platform services deploy identically on any Kubernetes cluster
- **Consistency:** Same observability, security, and operational patterns across clouds
- **Flexibility:** Swap cloud providers without re-engineering the platform layer

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Applications                          │
│              (Demo apps, workloads)                       │
├─────────────────────────────────────────────────────────┤
│                  Platform Layer                          │
│   ┌──────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │ Ingress  │ │ Observability│ │  Security    │       │
│   │ Traefik  │ │ Prometheus   │ │ SOPS/AGE     │       │
│   │ cert-mgr │ │ Grafana      │ │ Net Policies │       │
│   │ ext-DNS  │ │ Loki         │ │ RBAC         │       │
│   └──────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────┤
│                   GitOps (FluxCD)                        │
│          Declarative, version-controlled                 │
├───────────┬──────────────────┬──────────────────────────┤
│  Hetzner  │      AWS EKS     │       GCP GKE            │
│  Cloud    │    (Planned)     │     (Planned)            │
│           │                  │                          │
│ Terraform │   Terraform      │    Terraform             │
│ Ansible   │   EKS Module     │    GKE Module            │
│ Longhorn  │   EBS CSI        │    PD CSI                │
└───────────┴──────────────────┴──────────────────────────┘
```

## Cloud Abstraction Strategy

### What's Cloud-Specific (in `clouds/`)
- Compute provisioning (VMs, managed K8s)
- Networking (VPCs, subnets, firewalls)
- Storage drivers (Longhorn, EBS, PD)
- Load balancers (cloud-native)
- DNS zones (provider-specific)
- Node configuration and hardening

### What's Cloud-Agnostic (in `platform/`)
- Ingress controller (Traefik)
- TLS certificates (cert-manager)
- Monitoring and alerting (Prometheus + Grafana)
- Log aggregation (Loki)
- Secret management (SOPS + AGE)
- Network policies
- RBAC and pod security
- Application deployments

## GitOps Workflow

```
Developer → Git Push → FluxCD detects change → Reconciles cluster state
                              ↓
                    Kustomize builds manifests
                              ↓
                    Kubernetes applies resources
                              ↓
                    Health checks verify rollout
```

All changes flow through Git. No manual `kubectl apply` in production.

## Security Model

1. **Encryption at Rest:** All secrets encrypted with SOPS + AGE before committing
2. **RBAC:** Least-privilege access for all service accounts
3. **Network Policies:** Default deny with explicit allow rules
4. **Pod Security:** Non-root containers, read-only filesystems, no privilege escalation
5. **Supply Chain:** Pinned image versions, no `latest` tags

## Monitoring Strategy

- **Metrics:** Prometheus scrapes all services, custom dashboards in Grafana
- **Logs:** Structured logging with Loki aggregation
- **Alerts:** PrometheusRule resources for critical conditions
- **Health:** Liveness and readiness probes on all workloads

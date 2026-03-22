# ADR-004: FluxCD for GitOps Continuous Delivery

## Status

Accepted

## Context

We need a GitOps controller to continuously reconcile the desired state defined in Git with the actual state in the cluster. The two primary options in the CNCF ecosystem are FluxCD and ArgoCD.

## Decision

Use **FluxCD v2** as the GitOps controller for this platform.

## Rationale

| Criterion | FluxCD | ArgoCD |
|-----------|--------|--------|
| Operational footprint | Lightweight, runs as controllers | Requires its own database (Redis) and UI server |
| Multi-tenancy | Native via namespaced Kustomizations | Requires AppProject configuration |
| Secret management | Native SOPS integration | Requires external plugin |
| Kustomize support | Native, first-class | Supported but ArgoCD favors Helm |
| CLI experience | `flux` CLI is focused and scriptable | `argocd` CLI, but UI is the primary interface |
| Scale | Well-suited for single/small cluster setups | Better for managing many clusters via a single control plane |

FluxCD's native SOPS support and lightweight footprint align better with our GitOps-first, minimal-tooling philosophy. It does not require a dedicated UI or database, reducing operational complexity.

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| ArgoCD | Heavier operational footprint; SOPS requires additional plugin setup |
| Manual `kubectl apply` | Not GitOps, no automated reconciliation or drift detection |
| Helm-only CD | No drift detection; Helm releases diverge from Git state over time |

## Consequences

- All deployments flow through Git; no manual `kubectl apply` in production
- FluxCD must be bootstrapped before any platform components deploy
- The `flux-system` namespace is critical infrastructure — protect it with RBAC
- Flux uses service account credentials stored as a Kubernetes secret; rotate on team changes
- Health checks and readiness gates must be defined to prevent partial rollouts

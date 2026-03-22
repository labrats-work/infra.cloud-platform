# Flux Operations Runbook

GitOps procedures for FluxCD management.

## Prerequisites

- `flux` CLI installed and configured
- Write access to this repository

---

## Status Checks

### Check overall Flux health

```bash
flux check
```

### Get all Flux resources

```bash
flux get all -A
```

### List sources

```bash
flux get sources git -A
flux get sources helm -A
```

### List kustomizations

```bash
flux get kustomizations -A
```

---

## Reconciliation

### Force reconcile the main source

```bash
flux reconcile source git flux-system
```

### Force reconcile a kustomization

```bash
flux reconcile kustomization <name>
```

### Force reconcile a HelmRelease

```bash
flux reconcile helmrelease <name> -n <namespace>
```

---

## Debugging Failures

### Check kustomization errors

```bash
flux get kustomizations -A
kubectl describe kustomization <name> -n flux-system
```

### Check HelmRelease errors

```bash
flux get helmreleases -A
kubectl describe helmrelease <name> -n <namespace>
```

### View Flux controller logs

```bash
# Source controller
kubectl logs -n flux-system -l app=source-controller --tail=50

# Kustomize controller
kubectl logs -n flux-system -l app=kustomize-controller --tail=50

# Helm controller
kubectl logs -n flux-system -l app=helm-controller --tail=50
```

---

## Bootstrap

### Bootstrap Flux on a new cluster

```bash
flux bootstrap github \
  --owner=labrats-work \
  --repository=infra.cloud-platform \
  --path=platform/shared/base \
  --personal=false
```

### Verify bootstrap succeeded

```bash
flux check
flux get kustomizations
```

---

## Suspend and Resume

### Suspend reconciliation (e.g. during maintenance)

```bash
flux suspend kustomization <name>
flux suspend helmrelease <name> -n <namespace>
```

### Resume reconciliation

```bash
flux resume kustomization <name>
flux resume helmrelease <name> -n <namespace>
```

> Always resume reconciliation after maintenance. Leaving resources suspended causes configuration drift.

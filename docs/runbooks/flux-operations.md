# Runbook: FluxCD Operations

Operational procedures for managing GitOps reconciliation with FluxCD.

## Checking Reconciliation Status

### View All Flux Resources

```bash
flux get all -A
```

### Check Specific Resource Types

```bash
flux get sources git -A
flux get kustomizations -A
flux get helmreleases -A
```

### Check Flux System Health

```bash
flux check
kubectl get pods -n flux-system
```

## Forcing Reconciliation

### Reconcile All Sources

```bash
flux reconcile source git flux-system
```

### Reconcile a Specific Kustomization

```bash
flux reconcile kustomization <name> -n flux-system
```

### Reconcile a Specific HelmRelease

```bash
flux reconcile helmrelease <name> -n <namespace>
```

## Troubleshooting Failed Reconciliations

### View Reconciliation Events

```bash
kubectl describe kustomization <name> -n flux-system
kubectl describe helmrelease <name> -n <namespace>
```

### View Flux Controller Logs

```bash
# Source controller (fetches manifests from Git/Helm repos)
kubectl logs -n flux-system deploy/source-controller

# Kustomize controller (applies Kustomizations)
kubectl logs -n flux-system deploy/kustomize-controller

# Helm controller (manages HelmReleases)
kubectl logs -n flux-system deploy/helm-controller

# Notification controller (sends alerts)
kubectl logs -n flux-system deploy/notification-controller
```

### Common Issues

**Reconciliation stuck:**
```bash
# Suspend and resume to force a fresh reconciliation
flux suspend kustomization <name>
flux resume kustomization <name>
```

**Git source not updating:**
```bash
# Check if Flux can reach the Git repository
flux get sources git flux-system -n flux-system
kubectl describe gitrepository flux-system -n flux-system
```

**SOPS decryption failure:**
```bash
# Verify the AGE secret is present
kubectl get secret sops-age -n flux-system
# Check kustomize-controller logs for decryption errors
kubectl logs -n flux-system deploy/kustomize-controller | grep -i sops
```

**HelmRelease upgrade failure:**
```bash
# Check for failed helm release
helm list -A | grep -v deployed
# View helm release history
helm history <release-name> -n <namespace>
# Rollback if needed
helm rollback <release-name> -n <namespace>
```

## Bootstrapping Flux on a New Cluster

```bash
flux bootstrap github \
  --owner=labrats-work \
  --repository=infra.cloud-platform \
  --branch=main \
  --path=platform/shared/base \
  --personal=false \
  --token-auth
```

After bootstrap, apply SOPS age key secret so Flux can decrypt secrets:

```bash
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/path/to/age.key
```

## Suspending Reconciliation

Use suspend when you need to make manual changes to the cluster without Flux reverting them:

```bash
# Suspend
flux suspend kustomization <name>

# Make your manual changes...

# Resume when done
flux resume kustomization <name>
```

**Important:** Always resume reconciliation after manual changes. Update the manifests in Git to reflect any permanent changes.

## Updating Flux Itself

```bash
flux check --pre
flux install --export > /tmp/flux-install.yaml
# Review changes
kubectl diff -f /tmp/flux-install.yaml
kubectl apply -f /tmp/flux-install.yaml
```

Or re-run `flux bootstrap` with the updated Flux CLI version.

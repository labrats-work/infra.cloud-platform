# Cluster Operations Runbook

Common operational procedures for the Kubernetes platform.

## Prerequisites

- `kubectl` configured with cluster access
- `flux` CLI installed
- `helm` CLI installed

---

## Node Operations

### Check node status

```bash
kubectl get nodes -o wide
```

### Drain a node for maintenance

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Uncordon a node after maintenance

```bash
kubectl uncordon <node-name>
```

---

## Workload Troubleshooting

### Check pod status across all namespaces

```bash
kubectl get pods -A --field-selector=status.phase!=Running
```

### Describe a failing pod

```bash
kubectl describe pod <pod-name> -n <namespace>
```

### View pod logs

```bash
kubectl logs <pod-name> -n <namespace> --tail=100
kubectl logs <pod-name> -n <namespace> --previous   # crashed container
```

### Restart a deployment

```bash
kubectl rollout restart deployment/<name> -n <namespace>
```

---

## Storage (Longhorn — Hetzner)

### Check Longhorn volume health

```bash
kubectl get volumes -n longhorn-system
```

### List Longhorn replicas

```bash
kubectl get replicas -n longhorn-system
```

---

## Certificates (cert-manager)

### List all certificates

```bash
kubectl get certificates -A
```

### Check certificate status

```bash
kubectl describe certificate <name> -n <namespace>
```

### Force certificate renewal

```bash
kubectl delete secret <tls-secret-name> -n <namespace>
# cert-manager will re-issue automatically
```

---

## Ingress (Traefik)

### List all ingress routes

```bash
kubectl get ingressroutes -A
```

### Check Traefik logs

```bash
kubectl logs -n traefik -l app.kubernetes.io/name=traefik --tail=50
```

---

## Emergency Procedures

### Cluster unreachable via Flux

If the cluster cannot be reconciled by Flux, you can apply manifests directly:

```bash
# Only for emergencies — prefer GitOps in normal operations
kubectl apply -k platform/shared/base
kubectl apply -k platform/infrastructure
```

Restore Flux reconciliation as soon as the cluster is accessible.

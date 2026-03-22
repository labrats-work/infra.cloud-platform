# Runbook: Cluster Operations

Common operational procedures for managing the Kubernetes cluster.

## Node Management

### Check Node Status

```bash
kubectl get nodes -o wide
```

### Drain a Node for Maintenance

```bash
# Cordon to prevent new pods from scheduling
kubectl cordon <node-name>

# Evict all pods gracefully
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --grace-period=60

# After maintenance, uncordon
kubectl uncordon <node-name>
```

### Check Node Resource Usage

```bash
kubectl top nodes
kubectl describe node <node-name>
```

## Pod Operations

### Get Logs from a Pod

```bash
# Current logs
kubectl logs -n <namespace> <pod-name>

# Previous container instance (useful after crash)
kubectl logs -n <namespace> <pod-name> --previous

# Follow logs in real time
kubectl logs -n <namespace> <pod-name> -f
```

### Execute Into a Pod

```bash
kubectl exec -it -n <namespace> <pod-name> -- /bin/sh
```

### Restart a Deployment

```bash
kubectl rollout restart deployment/<name> -n <namespace>
```

### Check Pod Events

```bash
kubectl describe pod -n <namespace> <pod-name>
```

## Storage Operations

### Check Longhorn Storage Health

```bash
# View all Longhorn volumes
kubectl get volumes -n longhorn-system

# Check Longhorn nodes
kubectl get nodes -n longhorn-system

# Access Longhorn UI (via port-forward)
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8000:80
# Then open http://localhost:8000
```

### Check PVC Status

```bash
kubectl get pvc -A
kubectl describe pvc <name> -n <namespace>
```

## Cluster Upgrades

### Kubernetes Version Upgrade (Hetzner)

1. Update the Kubernetes version in Terraform configuration
2. Run `terraform plan` to review changes
3. Apply changes to control plane first: `terraform apply -target=hcloud_server.<control-plane>`
4. Drain and upgrade worker nodes one at a time
5. Verify cluster health after each node: `kubectl get nodes`

### Platform Component Upgrades

Platform components are managed by FluxCD. To upgrade:

1. Update the version/image tag in the relevant manifest under `platform/`
2. Commit and push — FluxCD will reconcile automatically
3. Monitor with: `flux get all -A`

## Resource Quotas and Limits

### View Resource Usage by Namespace

```bash
kubectl top pods -A
kubectl resource-quota -A
```

### Check for OOMKilled Pods

```bash
kubectl get pods -A | grep OOMKilled
kubectl describe pod -n <namespace> <pod-name> | grep -A5 "Last State"
```

## Certificate Management

### Check Certificate Status

```bash
kubectl get certificates -A
kubectl get certificaterequests -A
```

### Force Certificate Renewal

```bash
kubectl annotate certificate <name> -n <namespace> \
  cert-manager.io/issue-temporary-certificate="true" --overwrite
```

### Debug Certificate Issues

```bash
kubectl describe certificate <name> -n <namespace>
kubectl describe certificaterequest <name> -n <namespace>
kubectl logs -n cert-manager deploy/cert-manager
```

## Ingress Operations

### List All Ingress Routes

```bash
# Traefik IngressRoutes
kubectl get ingressroutes -A

# Standard Ingress objects
kubectl get ingress -A
```

### Check Traefik Status

```bash
kubectl get pods -n traefik
kubectl logs -n traefik deploy/traefik
```

### Access Traefik Dashboard (port-forward)

```bash
kubectl port-forward -n traefik svc/traefik-dashboard 9000:9000
# Then open http://localhost:9000/dashboard/
```

# Runbook: Incident Response

Triage and remediation steps for common platform incidents.

## Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| P1 | Production down, all users affected | Immediate |
| P2 | Degraded service, partial impact | < 1 hour |
| P3 | Non-critical component down | < 4 hours |
| P4 | Minor issue, workaround available | Next business day |

## Initial Triage

```bash
# 1. Check cluster nodes
kubectl get nodes

# 2. Check failing pods across all namespaces
kubectl get pods -A | grep -v Running | grep -v Completed

# 3. Check recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -30

# 4. Check Flux reconciliation status
flux get all -A | grep -v True

# 5. Check ingress/load balancer
kubectl get pods -n traefik
kubectl get svc -n traefik
```

## Cluster Not Reachable

1. Check if Hetzner cloud is experiencing an outage (status.hetzner.com)
2. Verify the load balancer is healthy in Hetzner console
3. Check if nodes are running in Hetzner console
4. If nodes are down, restart via Hetzner console or Terraform

## Node NotReady

```bash
# Check node conditions
kubectl describe node <node-name> | grep -A10 "Conditions:"

# Check kubelet logs on the node (requires SSH access)
ssh root@<node-ip> journalctl -u kubelet -n 50
```

**Common causes:**
- Network plugin failure: check CNI pod logs
- Disk pressure: check disk usage (`df -h` on node)
- Memory pressure: check for OOMKill events
- Kubelet crash: restart kubelet with `systemctl restart kubelet`

## Pod CrashLoopBackOff

```bash
# Get crash logs
kubectl logs -n <namespace> <pod-name> --previous

# Describe pod for events
kubectl describe pod -n <namespace> <pod-name>
```

**Common causes:**
- Misconfigured environment variables or secrets
- Liveness probe too aggressive — check probe settings
- Missing ConfigMap or Secret — check referenced volumes
- OOMKilled — increase memory limits

## Certificate Expired

```bash
# Check certificate validity
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# Check cert-manager logs
kubectl logs -n cert-manager deploy/cert-manager

# Force renewal
kubectl delete certificaterequest -n <namespace> <name>
```

If Let's Encrypt rate limits are hit, use staging issuer temporarily and contact Let's Encrypt.

## Disk Pressure / Longhorn Volume Issues

```bash
# Check Longhorn volume health
kubectl get volumes -n longhorn-system

# Check node disk usage (SSH into node)
df -h
du -sh /var/lib/longhorn/*
```

If a volume is degraded:
1. Open Longhorn UI: `kubectl port-forward -n longhorn-system svc/longhorn-frontend 8000:80`
2. Check replica health and rebuild if needed
3. Never delete volumes without backing up data first

## Flux Stuck / Not Reconciling

See [flux-operations.md](flux-operations.md) for detailed steps.

Quick fix:
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

## Secret Decryption Failure

If SOPS-encrypted secrets cannot be decrypted:

```bash
# Verify AGE key secret exists
kubectl get secret sops-age -n flux-system

# If missing, restore from secure backup
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/path/to/age.key
```

**Never store AGE private keys in Git or unencrypted locations.**

## Escalation

If an incident cannot be resolved with these runbooks:

1. Check cloud provider status pages
2. Review recent commits for changes that may have caused the issue (`git log --oneline -20`)
3. Roll back recent Terraform changes if infrastructure-related
4. Suspend Flux and investigate manually if reconciliation is causing issues

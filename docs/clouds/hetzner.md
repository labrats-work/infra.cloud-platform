# Hetzner Cloud Implementation

## Why Hetzner

- **Cost:** 60-80% cheaper than AWS/GCP for equivalent compute
- **Performance:** Dedicated vCPUs, NVMe storage, low-latency European DCs
- **Simplicity:** Straightforward API, no vendor lock-in complexity
- **Privacy:** EU-based, GDPR-compliant data centers

## Cluster Specification

| Resource | Configuration |
|----------|--------------|
| **Nodes** | 3x CPX21 (3 vCPU, 4GB RAM, 80GB NVMe) |
| **Location** | Falkenstein, Germany (fsn1) |
| **Network** | Private network 10.0.0.0/16 |
| **Storage** | Longhorn distributed storage |
| **OS** | Ubuntu 22.04 LTS |
| **K8s Version** | 1.29.x |

## Architecture

```
Internet
    │
    ▼
┌─────────────┐
│  Hetzner LB  │  (TCP/443, TCP/80)
└──────┬──────┘
       │
  ┌────┴────┐
  │ Private  │
  │ Network  │
  │10.0.0/16│
  └────┬────┘
       │
  ┌────┼────────────┐
  │    │             │
  ▼    ▼             ▼
┌────┐┌────┐     ┌────┐
│ N1 ││ N2 │     │ N3 │
│CP  ││WRK │     │WRK │
└────┘└────┘     └────┘
```

- **N1:** Control plane node
- **N2, N3:** Worker nodes
- Traffic enters via Hetzner Load Balancer → Traefik ingress → services

## Provisioning

### Terraform Resources

| Resource | Purpose |
|----------|---------|
| `hcloud_server` | Kubernetes nodes |
| `hcloud_network` | Private network |
| `hcloud_network_subnet` | Node subnet |
| `hcloud_firewall` | Ingress/egress rules |
| `hcloud_load_balancer` | External traffic entry point |

### Ansible Playbooks

| Playbook | Purpose |
|----------|---------|
| `site.yml` | Full node setup |
| `k8s-install.yml` | Kubernetes installation |
| `hardening.yml` | Security hardening |

## Full Deployment Guide

### Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.10
- [Ansible](https://www.ansible.com/) >= 2.15
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28
- [Flux CLI](https://fluxcd.io/docs/installation/) >= 2.0
- [SOPS](https://github.com/getsops/sops) >= 3.8
- [age](https://github.com/FiloSottile/age) >= 1.1
- Hetzner Cloud API token with read/write permissions
- GitHub personal access token (for Flux bootstrap)

### Step 1: Provision Infrastructure

```bash
cd clouds/hetzner/terraform/cluster

# Set your Hetzner API token
export HCLOUD_TOKEN=<your-hetzner-api-token>

terraform init
terraform plan
terraform apply
```

Terraform will output the node IPs. Save them for Ansible.

### Step 2: Configure Nodes

```bash
cd clouds/hetzner/ansible

# Update inventory with node IPs from Terraform output
# Then run the full site setup
ansible-playbook -i inventory site.yml
```

This installs and configures Kubernetes on all nodes.

### Step 3: Configure kubectl

After Ansible completes, fetch the kubeconfig from the control plane:

```bash
scp root@<control-plane-ip>:/etc/kubernetes/admin.conf ~/.kube/config-hetzner
export KUBECONFIG=~/.kube/config-hetzner

# Verify cluster access
kubectl get nodes
```

### Step 4: Prepare SOPS Secret Management

```bash
# Generate AGE key (keep the private key safe — back it up securely)
age-keygen -o age.key

# Store the public key in .sops.yaml at the repository root
# (public key is safe to commit)

# Create the SOPS secret in the cluster
kubectl create namespace flux-system
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=age.key
```

### Step 5: Bootstrap FluxCD

```bash
flux bootstrap github \
  --owner=labrats-work \
  --repository=infra.cloud-platform \
  --branch=main \
  --path=platform/shared/base \
  --personal=false
```

Flux will install itself and start reconciling the platform manifests.

### Step 6: Verify Platform Deployment

```bash
# Watch Flux reconcile all components
flux get all -A

# Check that all pods are running
kubectl get pods -A

# Verify ingress is working
kubectl get ingressroutes -A
```

## Cost Breakdown

| Item | Monthly Cost |
|------|-------------|
| 3x CPX21 servers | EUR 22.17 |
| Load balancer | EUR 5.39 |
| Private network | Free |
| **Total** | **~EUR 28/month** |

## Operational Notes

- **Node SSH access:** Nodes are accessible via SSH on port 22 from trusted IPs only (enforced by Hetzner firewall)
- **kubeconfig:** The admin kubeconfig should be stored securely; rotate if compromised
- **Longhorn backups:** Configure Longhorn backup target (S3 or NFS) for persistent volume backups
- **AGE key backup:** The AGE private key must be backed up outside of Git. Loss of this key means loss of access to all encrypted secrets.

## Scaling

To add a worker node:

1. Increment the worker count in `clouds/hetzner/terraform/cluster/main.tf`
2. Run `terraform apply`
3. Run `ansible-playbook -i inventory k8s-install.yml --limit <new-node-ip>`
4. Verify the node joins: `kubectl get nodes`

## Related

- [Architecture Overview](../architecture/overview.md)
- [FluxCD Operations Runbook](../runbooks/flux-operations.md)
- [Cluster Operations Runbook](../runbooks/cluster-operations.md)
- [Secret Management ADR](../decisions/003-secret-management.md)

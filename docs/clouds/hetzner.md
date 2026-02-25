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

## Cost Breakdown

| Item | Monthly Cost |
|------|-------------|
| 3x CPX21 servers | EUR 22.17 |
| Load balancer | EUR 5.39 |
| Private network | Free |
| **Total** | **~EUR 28/month** |

## Deployment

See the main [Quick Start](../../README.md#quick-start) guide.

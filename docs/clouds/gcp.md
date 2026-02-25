# GCP GKE Implementation

> Status: Planned

## Approach

- GKE Autopilot or Standard cluster with Terraform
- Persistent Disk CSI for storage
- GCE Ingress or Traefik for traffic management
- Same platform layer as Hetzner and AWS

## Planned Specification

| Resource | Configuration |
|----------|--------------|
| **Cluster** | GKE 1.29 |
| **Nodes** | 3x e2-medium (2 vCPU, 4GB RAM) |
| **Region** | europe-west1 (Belgium) |
| **Storage** | Persistent Disk SSD |

## Estimated Cost

~$120/month (GKE management fee + nodes + storage)

# AWS EKS Implementation

> Status: Planned

## Approach

- Managed EKS cluster with Terraform `eks` module
- EBS CSI driver for persistent storage
- AWS Load Balancer Controller for ingress
- Same platform layer as Hetzner

## Planned Specification

| Resource | Configuration |
|----------|--------------|
| **Cluster** | EKS 1.29 |
| **Nodes** | 3x t3.medium (2 vCPU, 4GB RAM) |
| **Region** | eu-central-1 (Frankfurt) |
| **Storage** | EBS gp3 |

## Estimated Cost

~$150/month (EKS control plane + nodes + storage)

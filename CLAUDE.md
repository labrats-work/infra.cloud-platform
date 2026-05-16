# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Multi-cloud Kubernetes platform monorepo. Cloud-agnostic platform layer with provider-specific implementations.

**This is a PUBLIC repository.** Never commit secrets, credentials, or sensitive infrastructure details. This is a deviation from the workspace-wide "private by default" — be deliberate about what goes in here.

## Structure

```
clouds/
  hetzner/   — Active implementation (Terraform + Ansible)
  aws/, gcp/ — Planned
platform/    — Cloud-agnostic K8s resources (shared, infrastructure, observability, security, apps)
tools/       — Shared scripts, Makefiles, CI helpers
docs/        — Architecture docs, ADRs, runbooks
```

## Conventions

- Terraform modules in `clouds/<provider>/terraform/modules/`
- Kustomize bases in `platform/`, overlays per-cloud if needed

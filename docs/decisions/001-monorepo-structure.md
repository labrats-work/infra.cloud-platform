# ADR-001: Monorepo for Multi-Cloud Platform

## Status

Accepted

## Context

We need to manage Kubernetes infrastructure across multiple cloud providers while maintaining a consistent platform layer. Two main approaches exist:

1. **Monorepo:** Single repository with cloud-specific and platform directories
2. **Multi-repo:** Separate repositories per cloud provider and shared platform

## Decision

We chose a **monorepo** structure with clear separation between `clouds/` (provider-specific) and `platform/` (cloud-agnostic).

## Rationale

- **Atomic changes:** A single PR can update both infrastructure and platform
- **Shared tooling:** CI/CD, linting, and validation run once for everything
- **Discoverability:** Everything is in one place; no cross-repo navigation
- **Consistency:** Easier to enforce patterns and conventions
- **Refactoring:** Moving code between layers is a simple file move

## Consequences

- Repository size will grow as clouds are added
- Need clear ownership boundaries via CODEOWNERS
- CI must be smart about running only affected checks

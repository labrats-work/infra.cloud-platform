# ADR-002: Two-Layer Cloud Abstraction

## Status

Accepted

## Context

Running on multiple clouds requires deciding how much to abstract away provider differences. Options range from full abstraction (Crossplane, Cluster API) to no abstraction (copy-paste per cloud).

## Decision

Use a **two-layer approach**: cloud-specific infrastructure in `clouds/` with Terraform/Ansible, and cloud-agnostic platform services in `platform/` with Kustomize.

## Rationale

- **Pragmatic:** Avoids over-engineering with heavyweight abstraction layers
- **Transparent:** Each cloud's infrastructure is readable and auditable
- **Flexible:** Can leverage cloud-native features without compromise
- **Portable:** Platform layer deploys on any conformant cluster
- **Incremental:** New clouds can be added without refactoring existing ones

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| Crossplane | Too much abstraction for current scale |
| Cluster API | Complex to operate, limits provider flexibility |
| Full Terraform abstraction | Forces lowest-common-denominator approach |

## Consequences

- Some configuration duplication across clouds (acceptable trade-off)
- Cloud-specific Kustomize overlays needed occasionally
- Clear documentation required for what belongs in each layer

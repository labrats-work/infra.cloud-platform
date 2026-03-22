# ADR-003: SOPS + AGE for Secret Management

## Status

Accepted

## Context

Kubernetes secrets must be stored in Git for GitOps workflows to work end-to-end. Storing plaintext secrets in a public repository is not acceptable. We need a secret management approach that:

- Integrates naturally with GitOps (secrets live in Git)
- Works without a central secret store or vault service
- Supports multiple key holders (team members)
- Has a minimal operational footprint

## Decision

Use **SOPS** (Secrets OPerationS) with **AGE** encryption keys to encrypt secrets before committing to Git. FluxCD's built-in SOPS decryption support handles decryption at apply time.

## Rationale

| Requirement | How SOPS+AGE Meets It |
|-------------|----------------------|
| Git-native | Encrypted files committed directly to Git |
| No vault service | AGE key stored only in cluster (k8s secret) and secure backup |
| Multi-key support | SOPS `.sops.yaml` can list multiple AGE public keys |
| FluxCD integration | Native SOPS support in kustomize-controller |
| Simple tooling | `sops` CLI + `age-keygen`, no complex infrastructure |

## Alternatives Considered

| Option | Rejected Because |
|--------|-----------------|
| HashiCorp Vault | Requires a highly-available Vault cluster; operational overhead outweighs benefits at current scale |
| External Secrets Operator + AWS Secrets Manager | Cloud-specific, introduces vendor dependency, additional cost |
| Sealed Secrets | Controller-managed keys create operational risk; key backup is non-trivial |
| Plain Kubernetes Secrets | Not safe for public Git repositories |

## Implementation

1. Generate AGE key: `age-keygen -o age.key`
2. Store public key in `.sops.yaml` at repo root
3. Store private key in cluster: `kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=age.key`
4. Configure `kustomize-controller` to use SOPS decryption (via Flux bootstrap or `decryption` field in Kustomization)
5. Encrypt secrets before committing: `sops -e -i secret.yaml`

## Consequences

- AGE private key must be backed up securely outside Git (loss means loss of access to all encrypted secrets)
- All contributors with legitimate secret access need their AGE public key added to `.sops.yaml`
- Secret rotation requires re-encrypting files with `sops rotate`
- Works without network access to external secret providers

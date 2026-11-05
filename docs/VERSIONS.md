# Verified versions

Verified on 2026-11-05 before implementing contracts.

| Component | Version | Verification |
| --- | --- | --- |
| OpenZeppelin Stellar Contracts | `v0.8.0` (`ddc327eb92d63709436da3a8455f641c2d5476c5`) | Latest stable Git tag in the upstream repository |
| `stellar-access` | `=0.8.0` | Workspace package at the pinned tag |
| `stellar-contract-utils` | `=0.8.0` | Workspace package at the pinned tag |
| `stellar-macros` | `=0.8.0` | Workspace package at the pinned tag |
| `stellar-tokens` | `=0.8.0` | Workspace package at the pinned tag |
| `soroban-sdk` | `=28.0.0` | OpenZeppelin `v0.8.0` workspace dependency |
| Stellar CLI | `26.1.0` | `stellar --version` |
| Rust | `1.94.1` | `rustc --version` |
| Cargo | `1.94.1` | `cargo --version` |

## Verified upstream shape

OpenZeppelin `v0.8.0` provides these RWA examples:

- token;
- compliance and seven compliance modules;
- identity verifier;
- identity registry storage;
- identity contracts;
- claim-topic/trusted-issuer registry and claim issuer.

The current token constructor accepts `name`, `symbol`, `admin`, `manager`,
`compliance`, and `identity_verifier`. Initial supply is minted after deployment
through the manager-gated `mint` function.

The identity verifier constructor depends on identity-registry storage and the
claim-topic/trusted-issuer registry. The fixture therefore includes those
upstream prerequisites instead of replacing identity verification with custom
logic.

## Verified operations

- Compliance modules are registered with `add_module_to` and removed with
  `remove_module_from`, once per `ComplianceHook`.
- The token changes compliance with `set_compliance`.
- The token pauses with `pause` and resumes with `unpause`.
- Roles are assigned through the OpenZeppelin `AccessControl` implementation's
  `grant_role` function.
- Deployment constructor arguments follow `stellar contract deploy ... --
  --argument value` with Stellar CLI 26.1.0.
- OpenZeppelin no longer supplies an `Upgradeable` derive. Upgradeability is
  available by implementing `stellar_contract_utils::upgradeable::Upgradeable`
  and guarding its `upgrade` function with project-specific authorization.

## Build policy

Deployable artifacts are built with `stellar contract build`, which targets
`wasm32v1-none`. Plain `cargo build` is not used for deployable WASM.


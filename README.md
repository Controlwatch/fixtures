# ControlWatch fixtures

Testnet-only Soroban contracts and deployment scripts for exercising
ControlWatch against an OpenZeppelin RWA token control surface.

The contracts follow the OpenZeppelin Stellar Contracts `v0.8.0` examples and
use exact crate pins. The deployed baseline contains:

- an RWA token;
- a compliance contract;
- an identity verifier;
- identity-registry storage;
- a claim-topic and trusted-issuer registry; and
- a transfer-allow compliance module named `module-a`.

The token is bound to the compliance and identity-registry contracts. The
module is deployed but deliberately not registered in the baseline, allowing a
later mutation to produce one unambiguous module-added change.

## Prerequisites

- Rust `1.94.1` with the `wasm32v1-none` target;
- Stellar CLI `26.1.0` or newer;
- Bash; and
- access to Stellar testnet.

The resolved versions and upstream API decisions are recorded in
[`docs/VERSIONS.md`](docs/VERSIONS.md).

## Build and test

Deployable WASM must be built with Stellar CLI:

```bash
stellar contract build
```

Run the contract tests and Clippy checks with:

```bash
cargo test --workspace --release
cargo clippy --workspace --all-targets --release -- -D warnings
```

The release profile is used for tests because it also avoids a Windows GNU
debug-linker export limit in the Soroban host dependency graph.

## Deploy a baseline

Optionally copy `.env.example` to `.env` and adjust the identity aliases or RPC
URL. The scripts refuse to run unless the network and passphrase are testnet.

```bash
cp .env.example .env
bash scripts/setup-testnet.sh
bash scripts/deploy-baseline.sh
```

`setup-testnet.sh` stores signing identities in the Stellar CLI secure store and
funds them through testnet Friendbot. Secret keys are never written to this
repository.

`deploy-baseline.sh` builds and deploys the contracts, binds the token to its
periphery contracts, prints a delimited address block, and writes
`fixtures.json`. That generated file contains public contract IDs and identity
aliases only; it is intentionally ignored by Git.

## Baseline behavior

The baseline is intended for control-surface inspection and change detection.
It does not register `module-a`, seed investor claims, or mint supply. Those
actions belong to explicit mutation or scenario scripts so each observed
change has one cause.

This repository is testnet-only. It must not be configured with mainnet keys or
used to deploy these fixtures to mainnet.

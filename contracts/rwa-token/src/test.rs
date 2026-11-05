extern crate std;

use soroban_sdk::{
    Address, Env, MuxedAddress, String, contract, contractimpl, panic_with_error, symbol_short,
    testutils::Address as _,
};
use stellar_tokens::rwa::{
    IdentityVerifier, RWAError,
    compliance::{AccountSnapshot, TransferKind},
};

use crate::contract::{RWATokenContract, RWATokenContractClient};

#[contract]
struct MockIdentityVerifier;

#[contractimpl]
impl IdentityVerifier for MockIdentityVerifier {
    fn verify_identity(env: &Env, account: &Address) {
        let denied: Option<Address> = env.storage().persistent().get(&symbol_short!("denied"));
        if denied.as_ref() == Some(account) {
            panic_with_error!(env, RWAError::IdentityVerificationFailed);
        }
    }

    fn recovery_target(_env: &Env, _old_account: &Address) -> Option<Address> {
        None
    }

    fn set_claim_topics_and_issuers(
        _env: &Env,
        _claim_topics_and_issuers: Address,
        _operator: Address,
    ) {
    }
}

#[contract]
struct MockCompliance;

#[contractimpl]
impl MockCompliance {
    pub fn transferred(
        _env: Env,
        _from: AccountSnapshot,
        _to: AccountSnapshot,
        _amount: i128,
        _kind: TransferKind,
        _token: Address,
    ) {
    }

    pub fn created(_env: Env, _to: AccountSnapshot, _amount: i128, _token: Address) {}

    pub fn destroyed(_env: Env, _from: AccountSnapshot, _amount: i128, _token: Address) {}
}

fn create_token(env: &Env) -> (RWATokenContractClient<'_>, Address, Address, Address) {
    let admin = Address::generate(env);
    let manager = Address::generate(env);
    let identity_verifier = env.register(MockIdentityVerifier, ());
    let compliance = env.register(MockCompliance, ());
    let token = env.register(
        RWATokenContract,
        (
            String::from_str(env, "ControlWatch Fixture"),
            String::from_str(env, "CWF"),
            admin.clone(),
            manager.clone(),
            compliance.clone(),
            identity_verifier.clone(),
        ),
    );

    (
        RWATokenContractClient::new(env, &token),
        admin,
        manager,
        identity_verifier,
    )
}

#[test]
fn constructor_sets_control_surface() {
    let env = Env::default();
    let (client, admin, _manager, identity_verifier) = create_token(&env);

    assert_eq!(client.get_admin(), Some(admin));
    assert_eq!(client.identity_verifier(), identity_verifier);
    assert_eq!(
        client.name(),
        String::from_str(&env, "ControlWatch Fixture")
    );
    assert!(!client.paused());
}

#[test]
#[should_panic(expected = "Error(Contract, #304)")]
fn transfer_is_rejected_when_identity_verifier_rejects() {
    let env = Env::default();
    env.mock_all_auths();
    let (client, admin, manager, identity_verifier) = create_token(&env);
    let rejected_recipient = Address::generate(&env);

    client.mint(&admin, &100, &manager);
    env.as_contract(&identity_verifier, || {
        env.storage()
            .persistent()
            .set(&symbol_short!("denied"), &rejected_recipient);
    });

    client.transfer(&admin, MuxedAddress::from(rejected_recipient), &10);
}

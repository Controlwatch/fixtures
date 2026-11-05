extern crate std;

use soroban_sdk::{Address, Env, testutils::Address as _};

use crate::contract::{IdentityVerifierContract, IdentityVerifierContractClient};

#[test]
fn constructor_stores_identity_dependencies() {
    let env = Env::default();
    let admin = Address::generate(&env);
    let manager = Address::generate(&env);
    let identity_registry_storage = Address::generate(&env);
    let claim_topics_and_issuers = Address::generate(&env);

    let contract_id = env.register(
        IdentityVerifierContract,
        (
            &admin,
            &manager,
            &identity_registry_storage,
            &claim_topics_and_issuers,
        ),
    );
    let client = IdentityVerifierContractClient::new(&env, &contract_id);

    assert_eq!(
        client.identity_registry_storage(),
        identity_registry_storage
    );
    assert_eq!(client.claim_topics_and_issuers(), claim_topics_and_issuers);
}

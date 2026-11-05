extern crate std;

use soroban_sdk::{Address, Env, testutils::Address as _};

use crate::contract::{IdentityRegistryContract, IdentityRegistryContractClient};

#[test]
fn constructor_starts_with_no_linked_tokens() {
    let env = Env::default();
    let admin = Address::generate(&env);
    let manager = Address::generate(&env);

    let contract_id = env.register(IdentityRegistryContract, (&admin, &manager));
    let client = IdentityRegistryContractClient::new(&env, &contract_id);

    assert_eq!(client.linked_tokens().len(), 0);
}

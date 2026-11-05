extern crate std;

use soroban_sdk::{Address, Env, Symbol, testutils::Address as _};

use crate::contract::{ComplianceContract, ComplianceContractClient};

#[test]
fn constructor_sets_admin_and_manager_role() {
    let env = Env::default();
    let admin = Address::generate(&env);
    let manager = Address::generate(&env);

    let contract_id = env.register(ComplianceContract, (&admin, &manager));
    let client = ComplianceContractClient::new(&env, &contract_id);

    assert_eq!(client.get_admin(), Some(admin));
    assert!(
        client
            .has_role(&manager, &Symbol::new(&env, "manager"))
            .is_some()
    );
    assert_eq!(client.linked_tokens().len(), 0);
}

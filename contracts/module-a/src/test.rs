extern crate std;

use soroban_sdk::{Address, Env, String, testutils::Address as _};

use crate::contract::{ModuleAContract, ModuleAContractClient};

#[test]
fn constructor_creates_configurable_transfer_allow_module() {
    let env = Env::default();
    env.mock_all_auths();
    let admin = Address::generate(&env);
    let manager = Address::generate(&env);
    let token = Address::generate(&env);
    let user = Address::generate(&env);

    let contract_id = env.register(ModuleAContract, (&admin, &manager));
    let client = ModuleAContractClient::new(&env, &contract_id);

    assert_eq!(client.name(), String::from_str(&env, "TransferAllowModule"));
    assert!(!client.is_user_allowed(&token, &user));

    client.allow_user(&token, &user, &manager);

    assert!(client.is_user_allowed(&token, &user));
}

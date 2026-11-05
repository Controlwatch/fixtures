extern crate std;

use soroban_sdk::{Address, Env, testutils::Address as _};

use crate::contract::{ClaimTopicsAndIssuersContract, ClaimTopicsAndIssuersContractClient};

#[test]
fn constructor_creates_configurable_claim_topic_registry() {
    let env = Env::default();
    env.mock_all_auths();
    let admin = Address::generate(&env);
    let manager = Address::generate(&env);

    let contract_id = env.register(ClaimTopicsAndIssuersContract, (&admin, &manager));
    let client = ClaimTopicsAndIssuersContractClient::new(&env, &contract_id);

    assert_eq!(client.get_claim_topics().len(), 0);
    client.add_claim_topic(&1, &manager);
    assert_eq!(client.get_claim_topics().get(0), Some(1));
}

//! Transfer-allow fixture based on the OpenZeppelin v0.8.0 example.

use soroban_sdk::{Address, Env, String, Symbol, Vec, contract, contractimpl, symbol_short};
use stellar_access::access_control::{self as access_control, AccessControl};
use stellar_macros::{only_admin, only_role};
use stellar_tokens::rwa::compliance::{
    AccountSnapshot, TransferKind,
    modules::{
        ComplianceModule,
        storage::{self as compliance_storage},
        transfer_allow::{TransferAllow, storage as transfer_allow},
    },
};

const MANAGER_ROLE: Symbol = symbol_short!("manager");

#[contract]
pub struct ModuleAContract;

#[contractimpl]
impl ModuleAContract {
    pub fn __constructor(e: &Env, admin: Address, manager: Address) {
        access_control::set_admin(e, &admin);
        access_control::grant_role_no_auth(e, &manager, &MANAGER_ROLE, &admin);
    }
}

#[contractimpl(contracttrait)]
impl AccessControl for ModuleAContract {}

#[contractimpl(contracttrait)]
impl TransferAllow for ModuleAContract {
    #[only_role(operator, "manager")]
    fn allow_user(e: &Env, token: Address, user: Address, operator: Address) {
        transfer_allow::allow_user(e, &token, &user);
    }

    #[only_role(operator, "manager")]
    fn disallow_user(e: &Env, token: Address, user: Address, operator: Address) {
        transfer_allow::disallow_user(e, &token, &user);
    }

    #[only_role(operator, "manager")]
    fn batch_allow_users(e: &Env, token: Address, users: Vec<Address>, operator: Address) {
        transfer_allow::batch_allow_users(e, &token, &users);
    }

    #[only_role(operator, "manager")]
    fn batch_disallow_users(e: &Env, token: Address, users: Vec<Address>, operator: Address) {
        transfer_allow::batch_disallow_users(e, &token, &users);
    }
}

#[contractimpl(contracttrait)]
impl ComplianceModule for ModuleAContract {
    fn on_transfer(
        e: &Env,
        from: AccountSnapshot,
        to: AccountSnapshot,
        _amount: i128,
        kind: TransferKind,
        token: Address,
    ) {
        transfer_allow::on_transfer(e, &from.address, &to.address, &kind, &token);
    }

    fn on_created(_e: &Env, _to: AccountSnapshot, _amount: i128, _token: Address) {}

    fn on_destroyed(_e: &Env, _from: AccountSnapshot, _amount: i128, _token: Address) {}

    fn name(e: &Env) -> String {
        String::from_str(e, "TransferAllowModule")
    }

    #[only_admin]
    fn set_compliance_address(e: &Env, token: Address, compliance: Address, _operator: Address) {
        compliance_storage::set_compliance_address(e, &token, &compliance);
    }
}

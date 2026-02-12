#[allow(unused_type_parameter, unused_field)]
module ferra_damm::rewarder {
    use std::type_name::TypeName;
    use std::option::Option;

    use sui::object::{ID, UID};
    use sui::bag::Bag;
    use sui::balance::Balance;
    use sui::tx_context::TxContext;

    use ferra_damm::config::GlobalConfig;

    friend ferra_damm::pool;

    // Error codes
    const E_TOO_MANY_REWARDERS: u64 = 501;
    const E_REWARDER_ALREADY_EXISTS: u64 = 502;
    const E_INVALID_TIME: u64 = 503;
    const E_INSUFFICIENT_BALANCE: u64 = 504;
    const E_REWARDER_NOT_FOUND: u64 = 505;

    // Structs
    struct RewarderManager has store {
        rewarders: vector<Rewarder>,
        points_released: u128,
        points_growth_global: u128,
        last_updated_time: u64,
    }

    struct Rewarder has copy, drop, store {
        reward_coin: TypeName,
        emissions_per_ms: u128,
        growth_global: u128,
    }

    struct RewarderGlobalVault has store, key {
        id: UID,
        balances: Bag,
    }

    // Events
    struct RewarderInitEvent has copy, drop {
        global_vault_id: ID,
    }

    struct DepositEvent has copy, drop, store {
        reward_type: TypeName,
        deposit_amount: u64,
        after_amount: u64,
    }

    struct EmergentWithdrawEvent has copy, drop, store {
        reward_type: TypeName,
        withdraw_amount: u64,
        after_amount: u64,
    }

    public(friend) fun new(): RewarderManager { abort 0 }

    public(friend) fun add_rewarder<CoinType>(_manager: &mut RewarderManager) { abort 0 }

    public(friend) fun settle(
        _manager: &mut RewarderManager,
        _liquidity: u128,
        _current_time: u64,
    ) { abort 0 }

    public(friend) fun update_emission<CoinType>(
        _vault: &RewarderGlobalVault,
        _manager: &mut RewarderManager,
        _liquidity: u128,
        _new_emissions: u128,
        _current_time: u64,
    ) { abort 0 }

    public(friend) fun borrow_mut_rewarder<CoinType>(
        _manager: &mut RewarderManager,
    ): &mut Rewarder { abort 0 }

    public(friend) fun withdraw_reward<CoinType>(
        _vault: &mut RewarderGlobalVault,
        _amount: u64,
    ): Balance<CoinType> { abort 0 }

    // Public functions
    public fun deposit_reward<CoinType>(
        _global_config: &GlobalConfig,
        _vault: &mut RewarderGlobalVault,
        _reward: Balance<CoinType>,
    ): u64 { abort 0 }

    public fun emergent_withdraw<CoinType>(
        _global_config: &GlobalConfig,
        _vault: &mut RewarderGlobalVault,
        _amount: u64,
        _ctx: &mut TxContext,
    ) { abort 0 }

    // Read functions
    public fun balance_of<CoinType>(_vault: &RewarderGlobalVault): u64 { abort 0 }

    public fun balances(_vault: &RewarderGlobalVault): &Bag { abort 0 }

    public fun borrow_rewarder<CoinType>(_manager: &RewarderManager): &Rewarder { abort 0 }

    public fun rewarder_index<CoinType>(_manager: &RewarderManager): Option<u64> { abort 0 }

    public fun rewarders(_manager: &RewarderManager): vector<Rewarder> { abort 0 }

    public fun rewards_growth_global(_manager: &RewarderManager): vector<u128> { abort 0 }

    public fun points_growth_global(_manager: &RewarderManager): u128 { abort 0 }

    public fun points_released(_manager: &RewarderManager): u128 { abort 0 }

    public fun last_update_time(_manager: &RewarderManager): u64 { abort 0 }

    public fun emissions_per_ms(_rewarder: &Rewarder): u128 { abort 0 }

    public fun growth_global(_rewarder: &Rewarder): u128 { abort 0 }

    public fun reward_coin(_rewarder: &Rewarder): TypeName { abort 0 }

}
#[allow(unused_type_parameter, unused_field)]
module ferra_damm::config {
    use sui::object::UID;
    use sui::vec_map::VecMap;
    use sui::vec_set::VecSet;
    use std::type_name::TypeName;
    use sui::object::ID;
    use sui::tx_context::TxContext;

    const MAX_PROTOCOL_FEE_RATE: u64 = 3000;
    const VERSION: u64 = 1;

    // Error codes
    const E_TICK_SPACING_NOT_FOUND: u64 = 201;
    const E_FEE_RATE_TOO_HIGH: u64 = 202;
    const E_PROTOCOL_FEE_RATE_TOO_HIGH: u64 = 203;
    const E_PACKAGE_VERSION_MISMATCH: u64 = 204;
    const E_INVALID_ROLE: u64 = 205;
    const E_INVALID_VERSION: u64 = 206;
    const E_INVALID_TICK_SPACING: u64 = 207;

    // Structs
    struct FeeTier has copy, drop, store {
        tick_spacing: u32,
        fee_rate: u64,
        fee_scheduler: FeeScheduler,
        dynamic_fee: DynamicFee,
    }

    struct LinearFeeScheduler has copy, drop, store {
        cliff_fee_numerator: u64,
        period_frequency: u64,
        number_of_period: u16,
        reduction_factor: u64,
    }

    struct ExponentialFeeScheduler has copy, drop, store {
        cliff_fee_numerator: u64,
        period_frequency: u64,
        number_of_period: u16,
        reduction_factor: u64,
    }

    struct FeeScheduler has copy, drop, store {
        linear: LinearFeeScheduler,
        exponential: ExponentialFeeScheduler,
    }

    struct DynamicFee has copy, drop, store {
        filter_period: u16,
        decay_period: u16,
        reduction_factor: u16,
        variable_fee_control: u32,
        max_volatility_accumulator: u32,
    }

    struct GlobalConfig has store, key {
        id: UID,
        protocol_fee_rate: u64,
        flash_loan_enable: bool,
        pause: bool,
        fee_tiers: VecMap<u32, FeeTier>,
        allow_create_pair: bool,
        package_version: u64,
        quote_asset_whitelist: VecSet<TypeName>,
    }

    // Events
    struct InitConfigEvent has copy, drop {
        global_config_id: ID,
    }

    struct UpdateFeeRateEvent has copy, drop {
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    struct AddWhitelistTokenEvent has copy, drop {
        token: TypeName,
    }

    struct RemoveWhitelistTokenEvent has copy, drop {
        token: TypeName,
    }

    struct AddFeeTierEvent has copy, drop {
        tick_spacing: u32,
        fee_rate: u64,
        fee_scheduler: FeeScheduler,
        dynamic_fee: DynamicFee,
    }

    struct UpdateFeeTierEvent has copy, drop {
        tick_spacing: u32,
        old_fee_rate: u64,
        new_fee_rate: u64,
        fee_scheduler: FeeScheduler,
        dynamic_fee: DynamicFee,
    }

    struct DeleteFeeTierEvent has copy, drop {
        tick_spacing: u32,
        fee_rate: u64,
    }

    struct SetRolesEvent has copy, drop {
        member: address,
        roles: u128,
    }

    struct AddRoleEvent has copy, drop {
        member: address,
        role: u8,
    }

    struct RemoveRoleEvent has copy, drop {
        member: address,
        role: u8,
    }

    struct RemoveMemberEvent has copy, drop {
        member: address,
    }

    struct SetPackageVersion has copy, drop {
        new_version: u64,
        old_version: u64,
    }

    public fun fee_tier_exists(_config: &GlobalConfig, _tick_spacing: u32): bool { abort 0 }

    public fun fee_rate(_fee_tier: &FeeTier): u64 { abort 0 }

    public fun fee_tiers(_config: &GlobalConfig): &VecMap<u32, FeeTier> { abort 0 }

    public fun get_fee_rate(_tick_spacing: u32, _config: &GlobalConfig): u64 { abort 0 }

    public fun get_protocol_fee_rate(_config: &GlobalConfig): u64 { abort 0 }

    public fun get_dynamic_fee_config(_config: &GlobalConfig, _tick_spacing: u32): DynamicFee { abort 0 }

    public fun get_filter_period(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun get_decay_period(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun get_reduction_factor(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun get_variable_fee_control(_config: &GlobalConfig, _tick_spacing: u32): u32 { abort 0 }

    public fun get_max_volatility_accumulator(_config: &GlobalConfig, _tick_spacing: u32): u32 { abort 0 }

    public fun filter_period(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun decay_period(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun reduction_factor(_config: &GlobalConfig, _tick_spacing: u32): u16 { abort 0 }

    public fun variable_fee_control(_config: &GlobalConfig, _tick_spacing: u32): u32 { abort 0 }

    public fun max_volatility_accumulator(_config: &GlobalConfig, _tick_spacing: u32): u32 { abort 0 }

    public fun linear_fee_scheduler(_config: &GlobalConfig, _tick_spacing: u32): (u64, u16, u64, u64) { abort 0 }

    public fun exponential_fee_scheduler(_config: &GlobalConfig, _tick_spacing: u32): (u64, u16, u64, u64) { abort 0 }

    public fun get_fund_receiver(_config: &GlobalConfig): address { abort 0 }

    public fun get_reward_receiver(_config: &GlobalConfig): address { abort 0 }

    public fun max_protocol_fee_rate(): u64 {
        MAX_PROTOCOL_FEE_RATE
    }

    public fun package_version(): u64 {
        VERSION
    }

    public fun protocol_fee_rate(_config: &GlobalConfig): u64 { abort 0 }

    public fun tick_spacing(_fee_tier: &FeeTier): u32 { abort 0 }

    public fun global_paused(_config: &GlobalConfig): bool { abort 0 }

    public fun flash_loan_enable(_config: &GlobalConfig): bool { abort 0 }

    public fun get_allow_create_pair(_config: &GlobalConfig): bool { abort 0 }

    public fun is_in_whitelist<CoinType>(_config: &GlobalConfig): bool { abort 0 }

    public fun whitelist_tokens(_config: &GlobalConfig): &VecSet<TypeName> { abort 0 }

    // Role checks
    public fun check_config_role(_config: &GlobalConfig, _addr: address) { abort 0 }

    public fun is_config_role(_config: &GlobalConfig, _addr: address): bool { abort 0 }

    public fun check_pool_manager_role(_config: &GlobalConfig, _addr: address) { abort 0 }

    public fun check_reward_role(_config: &GlobalConfig, _addr: address) { abort 0 }

    public fun check_upgrade_role(_config: &GlobalConfig, _addr: address) { abort 0 }

    public fun checked_package_version(_config: &GlobalConfig) { abort 0 }

    // Write functions
    public fun add_update_fee_tier(
        _config: &mut GlobalConfig,
        _tick_spacing: u32,
        _fee_rate: u64,
        _linear_cliff_fee_numerator: u64,
        _linear_number_of_period: u16,
        _linear_period_frequency: u64,
        _linear_reduction_factor: u64,
        _exponential_cliff_fee_numerator: u64,
        _exponential_number_of_period: u16,
        _exponential_period_frequency: u64,
        _exponential_reduction_factor: u64,
        _filter_period: u16,
        _decay_period: u16,
        _reduction_factor: u16,
        _variable_fee_control: u32,
        _max_volatility_accumulator: u32,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun delete_fee_tier(_config: &mut GlobalConfig, _tick_spacing: u32, _ctx: &TxContext) { abort 0 }

    public fun add_whitelist_token<CoinType>(_config: &mut GlobalConfig, _ctx: &TxContext) { abort 0 }

    public fun delete_whitelist_token<CoinType>(_config: &mut GlobalConfig, _ctx: &TxContext) { abort 0 }

    public fun set_allow_create_pair(_config: &mut GlobalConfig, _allowed: bool, _ctx: &TxContext) { abort 0 }

    public fun set_default_upgrade_cap_id(_config: &mut GlobalConfig, _cap_id: address, _ctx: &TxContext) { abort 0 }

    public fun set_pause(_config: &mut GlobalConfig, _pause: bool, _ctx: &TxContext) { abort 0 }

    public fun set_flash_loan_enable(_config: &mut GlobalConfig, _enable: bool, _ctx: &TxContext) { abort 0 }

    public fun update_package_version(_config: &mut GlobalConfig, _new_version: u64, _ctx: &TxContext) { abort 0 }

    public fun update_protocol_fee_rate(_config: &mut GlobalConfig, _fee_rate: u64, _ctx: &TxContext) { abort 0 }
}
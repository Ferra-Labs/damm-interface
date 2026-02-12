#[allow(unused_type_parameter, unused_field)]
module ferra_damm::factory {
    use std::option::Option;
    use std::string::String;
    use std::type_name::TypeName;
    use sui::clock::Clock;
    use sui::coin::Coin;
    use sui::object::{ID, UID};

    use move_stl::linked_table::LinkedTable;
    use sui::tx_context::TxContext;

    use ferra_damm::config::GlobalConfig;
    use ferra_damm::position::Position;

    const FEE_SCHEDULER_MODE_LINEAR: u8 = 0;
    const FEE_SCHEDULER_MODE_EXPONENTIAL: u8 = 1;

    // Error codes
    const E_NOT_IN_WHITELIST: u64 = 301;
    const E_INVALID_PRICE_RANGE: u64 = 302;
    const E_SAME_COIN_TYPES: u64 = 303;
    const E_INSUFFICIENT_COIN_B: u64 = 304;
    const E_INSUFFICIENT_COIN_A: u64 = 305;
    const E_INVALID_COIN_TYPE_ORDER: u64 = 306;
    const E_POOL_ALREADY_EXISTS: u64 = 307;
    const E_INVALID_AMOUNT: u64 = 308;
    const E_GLOBAL_PAUSED: u64 = 309;
    const E_INVALID_PARAMS: u64 = 310;

    // Structs
    struct PoolSimpleInfo has copy, drop, store {
        pool_id: ID,
        pool_key: ID,
        coin_type_a: TypeName,
        coin_type_b: TypeName,
        tick_spacing: u32,
    }

    struct Pools has key, store {
        id: UID,
        list: LinkedTable<ID, PoolSimpleInfo>,
        index: u64,
    }

    // Events
    struct InitFactoryEvent has copy, drop {
        pools_id: ID,
    }

    struct CreatePoolEvent has copy, drop {
        pool_id: ID,
        coin_type_a: String,
        coin_type_b: String,
        tick_spacing: u32,
        initialize_price: u128,
        fee_scheduler_enabled: bool,
        fee_scheduler_mode: Option<u8>,
        dynamic_fee_enabled: bool,
        activation_timestamp: u64,
        collect_fee_mode: u8,
        is_quote_y: bool,
    }

    #[allow(lint(share_owned))]
    public fun create_pool<CoinTypeA, CoinTypeB>(
        _global_config: &GlobalConfig,
        _pools: &mut Pools,
        _tick_spacing: u32,
        _initialize_price: u128,
        _tick_lower: u32,
        _tick_upper: u32,
        _url: String,
        _coin_a: Coin<CoinTypeA>,
        _coin_b: Coin<CoinTypeB>,
        _is_fixed_a: bool,
        _collect_fee_mode: u8,
        _is_quote_y: bool,
        _fee_scheduler_mode: u8,
        _enable_fee_scheduler: bool,
        _enable_dynamic_fee: bool,
        _activation_timestamp: u64,
        _clock: &Clock,
        _ctx: &mut TxContext,
    ): (Position, Coin<CoinTypeA>, Coin<CoinTypeB>) { abort 0 }

    public fun fetch_pools(
        _pools: &Pools,
        _start: vector<ID>,
        _limit: u64,
    ): vector<PoolSimpleInfo> { abort 0 }

    public fun index(_pools: &Pools): u64 { abort 0 }

    public fun coin_types(_pool_info: &PoolSimpleInfo): (TypeName, TypeName) { abort 0 }

    public fun new_pool_key<CoinTypeA, CoinTypeB>(
        _tick_spacing: u32,
        _collect_fee_mode: u8,
        _fee_scheduler_mode: u8,
        _enable_fee_scheduler: bool,
        _enable_dynamic_fee: bool,
    ): ID { abort 0 }

    public fun pool_id(_pool_info: &PoolSimpleInfo): ID { abort 0 }

    public fun pool_key(_pool_info: &PoolSimpleInfo): ID { abort 0 }

    public fun pool_simple_info(_pools: &Pools, _key: ID): &PoolSimpleInfo { abort 0 }

    public fun tick_spacing(_pool_info: &PoolSimpleInfo): u32 { abort 0 }

}
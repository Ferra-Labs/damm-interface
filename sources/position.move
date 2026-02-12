#[allow(unused_type_parameter, unused_field)]
module ferra_damm::position {
    use integer_mate::i32::I32;
    use move_stl::linked_table::LinkedTable;
    use std::string::String;
    use std::type_name::TypeName;
    use sui::clock::Clock;
    use sui::object::{ID, UID};
    use sui::tx_context::TxContext;

    friend ferra_damm::pool;

    // Error codes
    const E_MATH_OVERFLOW: u64 = 601;
    const E_REWARD_OVERFLOW: u64 = 602;
    const E_POINTS_OVERFLOW: u64 = 603;
    const E_POSITION_NOT_FOUND: u64 = 606;
    const E_LIQUIDITY_OVERFLOW: u64 = 608;
    const E_INSUFFICIENT_LIQUIDITY: u64 = 609;
    const E_REWARD_INDEX_OUT_OF_BOUNDS: u64 = 610;
    const E_POSITION_LOCKED: u64 = 611;

    struct POSITION has drop {}

    // Structs
    struct PositionManager has store {
        tick_spacing: u32,
        position_index: u64,
        positions: LinkedTable<ID, PositionInfo>,
    }

    struct PositionInfo has copy, drop, store {
        position_id: ID,
        liquidity: u128,
        tick_lower_index: I32,
        tick_upper_index: I32,
        fee_growth_inside_a: u128,
        fee_growth_inside_b: u128,
        fee_owned_a: u64,
        fee_owned_b: u64,
        points_owned: u128,
        points_growth_inside: u128,
        rewards: vector<PositionReward>,
    }

    struct Position has key, store {
        id: UID,
        pool: ID,
        index: u64,
        coin_type_a: TypeName,
        coin_type_b: TypeName,
        name: String,
        description: String,
        url: String,
        tick_lower_index: I32,
        tick_upper_index: I32,
        liquidity: u128,
        lock_until: u64,
    }

    struct PositionReward has copy, drop, store {
        growth_inside: u128,
        amount_owned: u64,
    }

    fun init(_witness: POSITION, _ctx: &mut TxContext) { abort 0 }

    public(friend) fun new(_tick_spacing: u32, _ctx: &mut TxContext): PositionManager { abort 0 }

    public(friend) fun open_position<CoinTypeA, CoinTypeB>(
        _manager: &mut PositionManager,
        _pool_id: ID,
        _pool_index: u64,
        _icon_url: String,
        _tick_lower_index: I32,
        _tick_upper_index: I32,
        _ctx: &mut TxContext,
    ): Position { abort 0 }

    public(friend) fun close_position(
        _manager: &mut PositionManager,
        _position: Position,
    ) { abort 0 }

    public(friend) fun increase_liquidity(
        _manager: &mut PositionManager,
        _position: &mut Position,
        _delta_liquidity: u128,
        _fee_growth_inside_a: u128,
        _fee_growth_inside_b: u128,
        _points_growth_inside: u128,
        _rewards_growth_inside: vector<u128>,
    ): u128 { abort 0 }

    public(friend) fun decrease_liquidity(
        _manager: &mut PositionManager,
        _position: &mut Position,
        _delta_liquidity: u128,
        _fee_growth_inside_a: u128,
        _fee_growth_inside_b: u128,
        _points_growth_inside: u128,
        _rewards_growth_inside: vector<u128>,
        _clock: &Clock,
    ): u128 { abort 0 }

    public(friend) fun update_fee(
        _manager: &mut PositionManager,
        _position_id: ID,
        _fee_growth_a: u128,
        _fee_growth_b: u128,
    ): (u64, u64) { abort 0 }

    public(friend) fun update_and_reset_fee(
        _manager: &mut PositionManager,
        _position_id: ID,
        _fee_growth_a: u128,
        _fee_growth_b: u128,
    ): (u64, u64) { abort 0 }

    public(friend) fun reset_fee(
        _manager: &mut PositionManager,
        _position_id: ID,
    ): (u64, u64) { abort 0 }

    public(friend) fun update_points(
        _manager: &mut PositionManager,
        _position_id: ID,
        _points_growth: u128,
    ): u128 { abort 0 }

    public(friend) fun update_rewards(
        _manager: &mut PositionManager,
        _position_id: ID,
        _rewards_growth: vector<u128>,
    ): vector<u64> { abort 0 }

    public(friend) fun update_and_reset_rewards(
        _manager: &mut PositionManager,
        _position_id: ID,
        _rewards_growth: vector<u128>,
        _reward_index: u64,
    ): u64 { abort 0 }

    public(friend) fun reset_rewarder(
        _manager: &mut PositionManager,
        _position_id: ID,
        _reward_index: u64,
    ): u64 { abort 0 }

    public(friend) fun rewards_amount_owned(
        _manager: &PositionManager,
        _position_id: ID,
    ): vector<u64> { abort 0 }

    public(friend) fun lock_position(_position: &mut Position, _lock_until_timestamp: u64) { abort 0 }

    public(friend) fun get_lock_until(_position: &Position): u64 { abort 0 }

    // Read functions
    public fun is_empty(_position_info: &PositionInfo): bool { abort 0 }

    public fun borrow_position_info(_manager: &PositionManager, _position_id: ID): &PositionInfo { abort 0 }

    public fun fetch_positions(
        _manager: &PositionManager,
        _start_positions: vector<ID>,
        _limit: u64,
    ): vector<PositionInfo> { abort 0 }

    public fun is_position_exist(_manager: &PositionManager, _position_id: ID): bool { abort 0 }

    public fun inited_rewards_count(_manager: &PositionManager, _position_id: ID): u64 { abort 0 }

    // Position NFT accessors
    public fun pool_id(_position: &Position): ID { abort 0 }

    public fun index(_position: &Position): u64 { abort 0 }

    public fun name(_position: &Position): String { abort 0 }

    public fun description(_position: &Position): String { abort 0 }

    public fun url(_position: &Position): String { abort 0 }

    public fun tick_range(_position: &Position): (I32, I32) { abort 0 }

    public fun liquidity(_position: &Position): u128 { abort 0 }

    // PositionInfo accessors
    public fun info_position_id(_position_info: &PositionInfo): ID { abort 0 }

    public fun info_liquidity(_position_info: &PositionInfo): u128 { abort 0 }

    public fun info_tick_range(_position_info: &PositionInfo): (I32, I32) { abort 0 }

    public fun info_fee_growth_inside(_position_info: &PositionInfo): (u128, u128) { abort 0 }

    public fun info_fee_owned(_position_info: &PositionInfo): (u64, u64) { abort 0 }

    public fun info_points_owned(_position_info: &PositionInfo): u128 { abort 0 }

    public fun info_points_growth_inside(_position_info: &PositionInfo): u128 { abort 0 }

    public fun info_rewards(_position_info: &PositionInfo): &vector<PositionReward> { abort 0 }

    public fun reward_amount_owned(_reward: &PositionReward): u64 { abort 0 }

    public fun reward_growth_inside(_reward: &PositionReward): u128 { abort 0 }
}
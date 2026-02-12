#[allow(unused_field)]
module ferra_damm::tick {
    use std::option::Option;
    use sui::tx_context::TxContext;

    use integer_mate::i32::I32;
    use integer_mate::i128::I128;

    use move_stl::skip_list::SkipList;
    use move_stl::option_u64::OptionU64;

    friend ferra_damm::pool;

    // Error codes
    const E_LIQUIDITY_OVERFLOW: u64 = 700;
    const E_INSUFFICIENT_LIQUIDITY: u64 = 701;
    const E_INVALID_TICK_SCORE: u64 = 702;
    const E_TICK_NOT_FOUND: u64 = 703;

    // Structs
    struct TickManager has store {
        tick_spacing: u32,
        ticks: SkipList<Tick>,
    }

    struct Tick has copy, drop, store {
        index: I32,
        sqrt_price: u128,
        liquidity_net: I128,
        liquidity_gross: u128,
        fee_growth_outside_a: u128,
        fee_growth_outside_b: u128,
        points_growth_outside: u128,
        rewards_growth_outside: vector<u128>,
    }

    public(friend) fun new(
        _tick_spacing: u32,
        _seed: u64,
        _ctx: &mut TxContext,
    ): TickManager { abort 0 }

    public(friend) fun increase_liquidity(
        _tick_manager: &mut TickManager,
        _current_tick: I32,
        _tick_lower: I32,
        _tick_upper: I32,
        _amount: u128,
        _fee_growth_global_a: u128,
        _fee_growth_global_b: u128,
        _points_growth_global: u128,
        _rewards_growth_global: vector<u128>,
    ) { abort 0 }

    public(friend) fun decrease_liquidity(
        _tick_manager: &mut TickManager,
        _current_tick: I32,
        _tick_lower: I32,
        _tick_upper: I32,
        _amount: u128,
        _fee_growth_global_a: u128,
        _fee_growth_global_b: u128,
        _points_growth_global: u128,
        _rewards_growth_global: vector<u128>,
    ) { abort 0 }

    public(friend) fun cross_by_swap(
        _tick_manager: &mut TickManager,
        _tick_idx: I32,
        _a2b: bool,
        _liquidity: u128,
        _fee_growth_global_a: u128,
        _fee_growth_global_b: u128,
        _points_growth_global: u128,
        _rewards_growth_global: vector<u128>,
    ): u128 { abort 0 }

    public(friend) fun try_borrow_tick(
        _tick_manager: &TickManager,
        _tick_idx: I32,
    ): Option<Tick> { abort 0 }

    // Read functions
    public fun borrow_tick(_tick_manager: &TickManager, _tick_idx: I32): &Tick { abort 0 }

    public fun borrow_tick_for_swap(
        _tick_manager: &TickManager,
        _node_id: u64,
        _a2b: bool,
    ): (&Tick, OptionU64) { abort 0 }

    public fun first_score_for_swap(
        _tick_manager: &TickManager,
        _tick_idx: I32,
        _a2b: bool,
    ): OptionU64 { abort 0 }

    public fun fetch_ticks(
        _tick_manager: &TickManager,
        _start: vector<u32>,
        _limit: u64,
    ): vector<Tick> { abort 0 }

    public fun get_fee_in_range(
        _current_tick: I32,
        _fee_growth_global_a: u128,
        _fee_growth_global_b: u128,
        _tick_lower_opt: Option<Tick>,
        _tick_upper_opt: Option<Tick>,
    ): (u128, u128) { abort 0 }

    public fun get_points_in_range(
        _current_tick: I32,
        _points_growth_global: u128,
        _tick_lower_opt: Option<Tick>,
        _tick_upper_opt: Option<Tick>,
    ): u128 { abort 0 }

    public fun get_rewards_in_range(
        _current_tick: I32,
        _rewards_growth_global: vector<u128>,
        _tick_lower_opt: Option<Tick>,
        _tick_upper_opt: Option<Tick>,
    ): vector<u128> { abort 0 }

    public fun get_reward_growth_outside(_tick: &Tick, _index: u64): u128 { abort 0 }

    // Tick accessors
    public fun index(_tick: &Tick): I32 { abort 0 }

    public fun sqrt_price(_tick: &Tick): u128 { abort 0 }

    public fun liquidity_net(_tick: &Tick): I128 { abort 0 }

    public fun liquidity_gross(_tick: &Tick): u128 { abort 0 }

    public fun fee_growth_outside(_tick: &Tick): (u128, u128) { abort 0 }

    public fun points_growth_outside(_tick: &Tick): u128 { abort 0 }

    public fun rewards_growth_outside(_tick: &Tick): &vector<u128> { abort 0 }

    public fun tick_spacing(_tick_manager: &TickManager): u32 { abort 0 }

    public fun tick_count(_tick_manager: &TickManager): u64 { abort 0 }
}
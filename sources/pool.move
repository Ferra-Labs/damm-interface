#[allow(unused_type_parameter, unused_field)]
module ferra_damm::pool {
    use std::string::String;
    use std::type_name::TypeName;
    use sui::balance::Balance;
    use sui::clock::Clock;
    use sui::object::{ID, UID};
    use sui::tx_context::TxContext;
    use sui::vec_set::VecSet;

    use integer_mate::i32::I32;

    use ferra_damm::config::GlobalConfig;
    use ferra_damm::position::{Position, PositionManager, PositionInfo};
    use ferra_damm::rewarder::{RewarderManager, RewarderGlobalVault};
    use ferra_damm::tick::{Tick, TickManager};
    use ferra_damm::pair_parameter_helper::PairParameters;

    friend ferra_damm::factory;

    struct POOL has drop {}

    const MAX_LOCK_TIME: u64 = 5315360000000;
    const PENDING_ADD_LIQUIDITY_KEY: vector<u8> = b"pending_add_liquidity";
    const TIMESTAMP_DIVISOR: u64 = 1000;

    // Error codes
    const E_INVALID_AMOUNT: u64 = 400;
    const E_LIQUIDITY_OVERFLOW: u64 = 401;
    const E_LIQUIDITY_ZERO: u64 = 403;
    const E_INSUFFICIENT_AMOUNT: u64 = 405;
    const E_SWAP_AMOUNT_IN_OVERFLOW: u64 = 406;
    const E_SWAP_AMOUNT_OUT_OVERFLOW: u64 = 407;
    const E_SWAP_FEE_AMOUNT_OVERFLOW: u64 = 408;
    const E_POOL_TICK_OUT_OF_RANGE: u64 = 410;
    const E_POOL_ID_MISMATCH: u64 = 412;
    const E_POOL_PAUSED: u64 = 413;
    const E_REWARDER_NOT_FOUND: u64 = 417;
    const E_SWAP_ZERO_OUTPUT: u64 = 418;
    const E_POSITION_POOL_MISMATCH: u64 = 419;
    const E_INVALID_LOCK_TIME: u64 = 423;
    const E_POSITION_LOCKED: u64 = 424;
    const E_FLASH_LOAN_PAUSED: u64 = 430;
    const E_PENDING_ADD_LIQUIDITY: u64 = 431;
    const E_NOT_WHITELISTED: u64 = 432;
    const E_MAX_TOTAL_FEE_EXCEEDED: u64 = 433;
    const E_NO_PERMISSION: u64 = 434;
    const E_CLIFF_FEE_BELOW_BASE_FEE: u64 = 435;

    // Structs

    struct Pool<phantom CoinTypeA, phantom CoinTypeB> has key, store {
        id: UID,
        creator: address,
        parameters: PairParameters,
        coin_a: Balance<CoinTypeA>,
        coin_b: Balance<CoinTypeB>,
        liquidity: u128,
        whitelisted: VecSet<address>,
        collect_fee_mode: u8,
        is_quote_y: bool,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        fee_protocol_coin_a: u64,
        fee_protocol_coin_b: u64,
        tick_manager: TickManager,
        rewarder_manager: RewarderManager,
        position_manager: PositionManager,
        is_pause: bool,
        index: u64,
        url: String,
    }

    struct SwapResult has copy, drop {
        amount_in: u64,
        amount_out: u64,
        atob: bool,
        collect_fee_on_input: bool,
        fee_amount: u64,
        base_fee: u64,
        dynamic_fee: u64,
        steps: u64,
    }

    struct FlashSwapReceipt<phantom CoinTypeA, phantom CoinTypeB> {
        pool_id: ID,
        a2b: bool,
        pay_amount: u64,
    }

    struct AddLiquidityReceipt<phantom CoinTypeA, phantom CoinTypeB> {
        pool_id: ID,
        amount_a: u64,
        amount_b: u64,
    }

    struct FlashLoanReceipt {
        pool_id: ID,
        loan_a: bool,
        amount: u64,
        fee_amount: u64,
    }

    struct CalculatedSwapResult has copy, drop, store {
        amount_in: u64,
        amount_out: u64,
        atob: bool,
        collect_fee_on_input: bool,
        fee_amount: u64,
        base_fee: u64,
        dynamic_fee: u64,
        before_sqrt_price: u128,
        after_sqrt_price: u128,
        is_exceed: bool,
        step_results: vector<SwapStepResult>,
    }

    struct SwapStepResult has copy, drop, store {
        current_sqrt_price: u128,
        target_sqrt_price: u128,
        current_liquidity: u128,
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64,
        remainder_amount: u64,
    }

    // Events
    struct StaticFeeParametersSetEvent has copy, drop {
        sender: address,
        filter_period: u16,
        decay_period: u16,
        reduction_factor: u16,
        variable_fee_control: u32,
        max_volatility_accumulator: u32,
        cliff_fee_numerator: u64,
        scheduler_number_of_period: u16,
        scheduler_period_frequency: u64,
        scheduler_reduction_factor: u64,
    }

    struct OpenPositionEvent has copy, drop, store {
        pool: ID,
        tick_lower: I32,
        tick_upper: I32,
        position: ID,
    }

    struct ClosePositionEvent has copy, drop, store {
        pool: ID,
        position: ID,
    }

    struct LockPositionEvent has copy, drop, store {
        pool: ID,
        position: ID,
        lock_until: u64,
    }

    struct AddLiquidityEvent has copy, drop, store {
        pool: ID,
        position: ID,
        tick_lower: I32,
        tick_upper: I32,
        liquidity: u128,
        after_liquidity: u128,
        amount_a: u64,
        amount_b: u64,
    }

    struct RemoveLiquidityEvent has copy, drop, store {
        pool: ID,
        position: ID,
        tick_lower: I32,
        tick_upper: I32,
        liquidity: u128,
        after_liquidity: u128,
        amount_a: u64,
        amount_b: u64,
    }

    struct SwapEvent has copy, drop, store {
        atob: bool,
        pool: ID,
        amount_in: u64,
        amount_out: u64,
        fee_a: u64,
        fee_b: u64,
        base_fee: u64,
        dynamic_fee: u64,
        collect_fee_on_input: bool,
        vault_a_amount: u64,
        vault_b_amount: u64,
        before_sqrt_price: u128,
        after_sqrt_price: u128,
        steps: u64,
    }

    struct CollectProtocolFeeEvent has copy, drop, store {
        pool: ID,
        amount_a: u64,
        amount_b: u64,
    }

    struct CollectFeeEvent has copy, drop, store {
        pool: ID,
        position: ID,
        amount_a: u64,
        amount_b: u64,
    }

    struct UpdateFeeRateEvent has copy, drop, store {
        pool: ID,
        old_fee_rate: u64,
        new_fee_rate: u64,
    }

    struct UpdateEmissionEvent has copy, drop, store {
        pool: ID,
        rewarder_type: TypeName,
        emissions_per_ms: u128,
    }

    struct AddRewarderEvent has copy, drop, store {
        pool: ID,
        rewarder_type: TypeName,
    }

    struct CollectRewardEvent has copy, drop, store {
        position: ID,
        pool: ID,
        rewarder_type: TypeName,
        amount: u64,
    }

    struct FlashLoanEvent has copy, drop, store {
        pool: ID,
        loan_a: bool,
        amount: u64,
        fee_amount: u64,
        vault_a_amount: u64,
        vault_b_amount: u64,
    }

    struct DynamicFeeParametersSetEvent has copy, drop {
        pool: ID,
        enabled: bool,
        filter_period: u16,
        decay_period: u16,
        reduction_factor: u16,
        variable_fee_control: u32,
        max_volatility_accumulator: u32,
    }

    struct ForcedDecayEvent has copy, drop {
        pool: ID,
        sender: address,
        tick_reference: I32,
        volatility_reference: u32,
    }

    // Friend: Pool creation (called by factory)
    public(friend) fun new<CoinTypeA, CoinTypeB>(
        _tick_spacing: u32,
        _initial_sqrt_price: u128,
        _fee_rate: u64,
        _url: String,
        _index: u64,
        _activation_timestamp: u64,
        _collect_fee_mode: u8,
        _is_quote_y: bool,
        _enabled_dynamic_fee: bool,
        _filter_period: u16,
        _decay_period: u16,
        _reduction_factor: u16,
        _variable_fee_control: u32,
        _max_volatility_accumulator: u32,
        _fee_scheduler_mode: u8,
        _enabled_fee_scheduler: bool,
        _cliff_fee_numerator: u64,
        _scheduler_number_of_period: u16,
        _scheduler_period_frequency: u64,
        _scheduler_reduction_factor: u64,
        _clock: &Clock,
        _ctx: &mut TxContext,
    ): Pool<CoinTypeA, CoinTypeB> { abort 0 }

    // Position lifecycle
    public fun open_position<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _tick_lower: u32,
        _tick_upper: u32,
        _ctx: &mut TxContext,
    ): Position { abort 0 }

    public fun close_position<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: Position,
    ) { abort 0 }

    public fun lock_position<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &mut Position,
        _lock_until: u64,
        _clock: &Clock,
    ) { abort 0 }

    // Liquidity management
    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &mut Position,
        _delta_liquidity: u128,
        _clock: &Clock,
    ): AddLiquidityReceipt<CoinTypeA, CoinTypeB> { abort 0 }

    public fun add_liquidity_fix_coin<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &mut Position,
        _amount: u64,
        _is_fixed_a: bool,
        _clock: &Clock,
    ): AddLiquidityReceipt<CoinTypeA, CoinTypeB> { abort 0 }

    public fun add_liquidity_pay_amount<CoinTypeA, CoinTypeB>(
        _receipt: &AddLiquidityReceipt<CoinTypeA, CoinTypeB>,
    ): (u64, u64) { abort 0 }

    public fun repay_add_liquidity<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _coin_a: Balance<CoinTypeA>,
        _coin_b: Balance<CoinTypeB>,
        _receipt: AddLiquidityReceipt<CoinTypeA, CoinTypeB>,
    ) { abort 0 }

    public fun remove_liquidity<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &mut Position,
        _liquidity_amount: u128,
        _clock: &Clock,
    ): (Balance<CoinTypeA>, Balance<CoinTypeB>) { abort 0 }

    // Flash swap
    public fun flash_swap<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _a2b: bool,
        _by_amount_in: bool,
        _amount: u64,
        _sqrt_price_limit: u128,
        _clock: &Clock,
        _ctx: &TxContext,
    ): (Balance<CoinTypeA>, Balance<CoinTypeB>, FlashSwapReceipt<CoinTypeA, CoinTypeB>) { abort 0 }

    public fun repay_flash_swap<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _coin_a: Balance<CoinTypeA>,
        _coin_b: Balance<CoinTypeB>,
        _receipt: FlashSwapReceipt<CoinTypeA, CoinTypeB>,
    ) { abort 0 }

    public fun swap_pay_amount<CoinTypeA, CoinTypeB>(
        _receipt: &FlashSwapReceipt<CoinTypeA, CoinTypeB>,
    ): u64 { abort 0 }

    // Flash loan
    public fun flash_loan<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _is_coin_a: bool,
        _amount: u64,
        _clock: &Clock,
    ): (Balance<CoinTypeA>, Balance<CoinTypeB>, FlashLoanReceipt) { abort 0 }

    public fun repay_flash_loan<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _coin_a: Balance<CoinTypeA>,
        _coin_b: Balance<CoinTypeB>,
        _receipt: FlashLoanReceipt,
    ) { abort 0 }

    // Fee collection
    public fun collect_fee<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &Position,
        _recalculate: bool,
    ): (Balance<CoinTypeA>, Balance<CoinTypeB>) { abort 0 }

    public fun collect_protocol_fee<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _ctx: &mut TxContext,
    ) { abort 0 }

    // Rewards
    public fun initialize_rewarder<CoinTypeA, CoinTypeB, RewardCoin>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun update_emission<CoinTypeA, CoinTypeB, RewardCoin>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _rewarder_vault: &RewarderGlobalVault,
        _emissions_per_ms: u128,
        _clock: &Clock,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun collect_reward<CoinTypeA, CoinTypeB, RewardCoin>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position: &Position,
        _rewarder_vault: &mut RewarderGlobalVault,
        _recalculate: bool,
        _clock: &Clock,
    ): Balance<RewardCoin> { abort 0 }

    // Calculate & update (fee, points, rewards)
    public fun calculate_and_update_fee<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): (u64, u64) { abort 0 }

    public fun calculate_and_update_points<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
        _clock: &Clock,
    ): u128 { abort 0 }

    public fun calculate_and_update_reward<CoinTypeA, CoinTypeB, RewardCoin>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
        _clock: &Clock,
    ): u64 { abort 0 }

    public fun calculate_and_update_rewards<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
        _clock: &Clock,
    ): vector<u64> { abort 0 }

    // Swap simulation (read-only)
    public fun calculate_swap_result<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _a2b: bool,
        _by_amount_in: bool,
        _amount: u64,
        _clock: &Clock,
    ): CalculatedSwapResult { abort 0 }

    public fun calculate_swap_result_step_results(
        _calculated_result: &CalculatedSwapResult,
    ): &vector<SwapStepResult> { abort 0 }

    public fun calculated_swap_result_after_sqrt_price(
        _calculated_result: &CalculatedSwapResult,
    ): u128 { abort 0 }

    public fun calculated_swap_result_amount_in(
        _calculated_result: &CalculatedSwapResult,
    ): u64 { abort 0 }

    public fun calculated_swap_result_amount_out(
        _calculated_result: &CalculatedSwapResult,
    ): u64 { abort 0 }

    public fun calculated_swap_result_fee_amount(
        _calculated_result: &CalculatedSwapResult,
    ): u64 { abort 0 }

    public fun calculated_swap_result_is_exceed(
        _calculated_result: &CalculatedSwapResult,
    ): bool { abort 0 }

    public fun calculated_swap_result_step_swap_result(
        _calculated_result: &CalculatedSwapResult,
        _step_index: u64,
    ): &SwapStepResult { abort 0 }

    public fun calculated_swap_result_steps_length(
        _calculated_result: &CalculatedSwapResult,
    ): u64 { abort 0 }

    public fun step_swap_result_amount_in(_result: &SwapStepResult): u64 { abort 0 }

    public fun step_swap_result_amount_out(_result: &SwapStepResult): u64 { abort 0 }

    public fun step_swap_result_current_liquidity(_result: &SwapStepResult): u128 { abort 0 }

    public fun step_swap_result_current_sqrt_price(_result: &SwapStepResult): u128 { abort 0 }

    public fun step_swap_result_fee_amount(_result: &SwapStepResult): u64 { abort 0 }

    public fun step_swap_result_remainder_amount(_result: &SwapStepResult): u64 { abort 0 }

    public fun step_swap_result_target_sqrt_price(_result: &SwapStepResult): u128 { abort 0 }

    // Read functions
    public fun liquidity<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): u128 { abort 0 }

    public fun current_tick_index<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): I32 { abort 0 }

    public fun current_sqrt_price<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): u128 { abort 0 }

    public fun get_total_fee_rate<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _current_timestamp: u64,
    ): u64 { abort 0 }

    public fun get_pair_parameters<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): &PairParameters { abort 0 }

    public fun balances<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): (&Balance<CoinTypeA>, &Balance<CoinTypeB>) { abort 0 }

    public fun fees_growth_global<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): (u128, u128) { abort 0 }

    public fun protocol_fee<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): (u64, u64) { abort 0 }

    public fun is_pause<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): bool { abort 0 }

    public fun index<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): u64 { abort 0 }

    public fun url<CoinTypeA, CoinTypeB>(_pool: &Pool<CoinTypeA, CoinTypeB>): String { abort 0 }

    public fun tick_manager<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): &TickManager { abort 0 }

    public fun rewarder_manager<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): &RewarderManager { abort 0 }

    public fun position_manager<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
    ): &PositionManager { abort 0 }

    // Position read helpers
    public fun borrow_position_info<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): &PositionInfo { abort 0 }

    public fun fetch_positions<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _start: vector<ID>,
        _limit: u64,
    ): vector<PositionInfo> { abort 0 }

    public fun is_position_exist<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): bool { abort 0 }

    public fun get_position_amounts<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): (u64, u64) { abort 0 }

    public fun get_position_fee<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): (u64, u64) { abort 0 }

    public fun get_position_points<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): u128 { abort 0 }

    public fun get_position_reward<CoinTypeA, CoinTypeB, RewardCoin>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): u64 { abort 0 }

    public fun get_position_rewards<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _position_id: ID,
    ): vector<u64> { abort 0 }

    // Tick range queries
    public fun get_fee_in_tick_range<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _tick_lower: I32,
        _tick_upper: I32,
    ): (u128, u128) { abort 0 }

    public fun get_fee_rewards_points_in_tick_range<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _tick_lower: I32,
        _tick_upper: I32,
    ): (u128, u128, vector<u128>, u128) { abort 0 }

    public fun get_points_in_tick_range<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _tick_lower: I32,
        _tick_upper: I32,
    ): u128 { abort 0 }

    public fun get_rewards_in_tick_range<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _tick_lower: I32,
        _tick_upper: I32,
    ): vector<u128> { abort 0 }

    public fun get_liquidity_from_amount(
        _tick_lower: I32,
        _tick_upper: I32,
        _current_tick: I32,
        _current_sqrt_price: u128,
        _amount: u64,
        _is_fixed_a: bool,
    ): (u128, u64, u64) { abort 0 }

    // Tick read helpers
    public fun borrow_tick<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _tick_index: I32,
    ): &Tick { abort 0 }

    public fun fetch_ticks<CoinTypeA, CoinTypeB>(
        _pool: &Pool<CoinTypeA, CoinTypeB>,
        _start: vector<u32>,
        _limit: u64,
    ): vector<Tick> { abort 0 }

    // Admin functions
    public fun pause<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun unpause<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun update_fee_rate<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _new_fee_rate: u64,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun update_position_url<CoinTypeA, CoinTypeB>(
        _config: &GlobalConfig,
        _pool: &mut Pool<CoinTypeA, CoinTypeB>,
        _new_url: String,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun enable_fee_scheduler<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun disable_fee_scheduler<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun enable_dynamic_fee<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun disable_dynamic_fee<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _ctx: &TxContext,
    ) { abort 0 }

    public fun add_whitelist<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _users: vector<address>,
        _ctx: &mut TxContext,
    ) { abort 0 }

    public fun remove_whitelist<X, Y>(
        _config: &GlobalConfig,
        _pool: &mut Pool<X, Y>,
        _users: vector<address>,
        _ctx: &mut TxContext,
    ) { abort 0 }
}
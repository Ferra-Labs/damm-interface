module ferra_damm::pair_parameter_helper {
    use integer_mate::i32::{Self, I32};

    struct PairParameters has store, copy, drop {
        // Static fee parameters
        fee_rate: u64,
        current_sqrt_price: u128,
        current_tick_index: I32,
        tick_spacing: u32,
        activation_timestamp: u64, // When pool activates
        // Fee scheduler(base fee)
        fee_scheduler_mode: u8,
        enabled_fee_scheduler: bool,
        cliff_fee_numerator: u64,
        number_of_period: u16,
        period_frequency: u64,
        fee_scheduler_reduction_factor: u64,
        // Dynamic fee parameters
        enabled_dynamic_fee: bool,
        filter_period: u16,
        decay_period: u16,
        reduction_factor: u16,
        variable_fee_control: u32,
        max_volatility_accumulator: u32,
        // Dynamic parameters (change frequently)
        volatility_accumulator: u32,
        volatility_reference: u32,
        id_reference: I32,
        time_of_last_update: u64,
    }
}
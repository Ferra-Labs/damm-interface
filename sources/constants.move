module ferra_damm::constants {
    const PRECISION: u64 = 1_000_000_000;
    // 10^9 = 1e9
    public fun precision(): u64 { PRECISION }
}
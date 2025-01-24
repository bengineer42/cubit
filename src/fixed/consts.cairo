use fixed::fixed::types::Fixed;

pub trait FixedConstsTrait<Mag> {
    const ONE_MAG: Mag;
    const HALF_MAG: Mag;
    const SQRT_MAG: Mag;
    const TWO_MAG: Mag;
    const PI_MAG: Mag;
    const HALF_PI_MAG: Mag;
    const LN_2_MAG: Mag;
    const LOG10_2_MAG: Mag;
    const I_LN_2_MAG: Mag;
    const I_LOG10_2_MAG: Mag;
    const LOG2_TS_FACTORS: [Mag; 9];
    const EXP2_TS_FACTORS: [Mag; 8];

    const ONE: Fixed<Mag>;
    const TWO: Fixed<Mag>;
    const PI: Fixed<Mag>;
    const HALF_PI: Fixed<Mag>;
}

trait FixedOpsConsts<Mag> {
    const LN_FACTOR: Mag;
    const LOG10_FACTOR: Mag;
    const EXP_FACTOR: Mag;
    const LOG2_TS_FACTORS: [Mag; 8];
    const EXP2_TS_FACTORS: [Mag; 8];
}

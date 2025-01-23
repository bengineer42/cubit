use fixed::types::fixed::Fixed;

pub trait FixedConstsTrait<Mag> {
    const ONE_MAG: Mag;
    const HALF_MAG: Mag;
    const SQRT_MAG: Mag;
    const TWO_MAG: Mag;
    const PI_MAG: Mag;
    const HALF_PI_MAG: Mag;

    const ONE: Fixed<Mag>;
    const TWO: Fixed<Mag>;
    const PI: Fixed<Mag>;
    const HALF_PI: Fixed<Mag>;
}

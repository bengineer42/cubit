use core::num::traits::{WideMul, Sqrt};

use fixed::fixed::types::Fixed;
use fixed::fixed::types::{FixedMagMul, FixedMagDiv, FixedMagSqrt};

pub impl FixedMagDivImpl<
    Mag,
    const ONE_MAG: Mag,
    +WideMul<Mag, Mag>,
    +Drop<Mag>,
    +Drop<WideMul::<Mag, Mag>::Target>,
    +Into<Mag, WideMul::<Mag, Mag>::Target>,
    +TryInto<WideMul::<Mag, Mag>::Target, Mag>,
    +Div<WideMul::<Mag, Mag>::Target>,
> of FixedMagDiv<Mag> {
    fn fixed_mag_div(self: Mag, rhs: Mag) -> Mag {
        match (self.wide_mul(ONE_MAG) / rhs.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        }
    }
}

pub impl FixedMagMulImpl<
    Mag,
    const ONE_MAG: Mag,
    +WideMul<Mag, Mag>,
    +Drop<Mag>,
    +Drop<WideMul::<Mag, Mag>::Target>,
    +Into<Mag, WideMul::<Mag, Mag>::Target>,
    +TryInto<WideMul::<Mag, Mag>::Target, Mag>,
    +Div<WideMul::<Mag, Mag>::Target>,
> of FixedMagMul<Mag> {
    fn fixed_mag_mul(self: Mag, rhs: Mag) -> Mag {
        match (self.wide_mul(rhs) / ONE_MAG.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        }
    }
}


pub impl FixedMagSqrtImpl<
    Mag, const SQRT_ONE: Mag, +Sqrt<Mag>, +Mul<Mag>, +Into<Sqrt::<Mag>::Target, Mag>,
> of FixedMagSqrt<Mag> {
    fn fixed_mag_sqrt(self: Mag) -> Mag {
        self.sqrt().into() * SQRT_ONE
    }
}

impl FixedOne<
    Mag, const ONE_MAG: Mag, +PartialEq<@Mag>, +Drop<Mag>,
> of core::num::traits::One<Fixed<Mag>> {
    fn one() -> Fixed<Mag> {
        Fixed { mag: ONE_MAG, sign: false }
    }

    fn is_one(self: @Fixed<Mag>) -> bool {
        (self.mag == @ONE_MAG) && !*self.sign
    }

    fn is_non_one(self: @Fixed<Mag>) -> bool {
        !Self::is_one(self)
    }
}

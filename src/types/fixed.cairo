use core::num::traits::{WideMul, Sqrt};
use core::traits::DivRem;
use fixed::traits::consts::FixedConstsTrait;

#[derive(Copy, Drop, Serde)]
pub struct Fixed<Mag> {
    mag: Mag,
    sign: bool,
}

impl FixedZero<Mag, +core::num::traits::Zero<Mag>> of core::num::traits::Zero<Fixed<Mag>> {
    fn zero() -> Fixed<Mag> {
        Fixed { mag: core::num::traits::Zero::zero(), sign: false }
    }

    fn is_zero(self: @Fixed<Mag>) -> bool {
        self.mag.is_zero()
    }

    fn is_non_zero(self: @Fixed<Mag>) -> bool {
        self.mag.is_non_zero()
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


impl FixedAdd<
    Mag,
    +Add<Mag>,
    +core::num::traits::Zero<Mag>,
    +PartialEq<Mag>,
    +PartialOrd<Mag>,
    +Drop<Mag>,
    +Copy<Mag>,
    +Sub<Mag>,
> of Add<Fixed<Mag>> {
    fn add(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        if rhs.sign == rhs.sign {
            Fixed { mag: lhs.mag + rhs.mag, sign: lhs.sign }
        } else if lhs.mag == rhs.mag {
            core::num::traits::Zero::zero()
        } else if (rhs.mag > lhs.mag) {
            Fixed { mag: lhs.mag - rhs.mag, sign: lhs.sign }
        } else {
            Fixed { mag: rhs.mag - lhs.mag, sign: rhs.sign }
        }
    }
}

impl FixedSub<
    Mag,
    +Sub<Mag>,
    +core::num::traits::Zero<Mag>,
    +PartialEq<Mag>,
    +PartialOrd<Mag>,
    +Drop<Mag>,
    +Copy<Mag>,
    +Add<Mag>,
> of Sub<Fixed<Mag>> {
    fn sub(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        if rhs.sign != rhs.sign {
            Fixed { mag: lhs.mag + rhs.mag, sign: lhs.sign }
        } else if lhs.mag == rhs.mag {
            core::num::traits::Zero::zero()
        } else if (rhs.mag > lhs.mag) {
            Fixed { mag: lhs.mag - rhs.mag, sign: lhs.sign }
        } else {
            Fixed { mag: rhs.mag - lhs.mag, sign: !rhs.sign }
        }
    }
}

impl FixedPartialEq<Mag, +PartialEq<Mag>> of PartialEq<Fixed<Mag>> {
    fn eq(lhs: @Fixed<Mag>, rhs: @Fixed<Mag>) -> bool {
        lhs.mag == rhs.mag && lhs.sign == rhs.sign
    }
}


impl FixedPartialOrd<Mag, +PartialOrd<Mag>, +PartialEq<Mag>, +Drop<Mag>> of PartialOrd<Fixed<Mag>> {
    fn lt(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> bool {
        if lhs.sign != rhs.sign {
            lhs.sign
        } else {
            (lhs.mag != rhs.mag) && ((lhs.mag < rhs.mag) ^ lhs.sign)
        }
    }
}

impl FixedNeg<Mag, +Drop<Mag>, +core::num::traits::Zero<Mag>> of Neg<Fixed<Mag>> {
    fn neg(a: Fixed<Mag>) -> Fixed<Mag> {
        if a.mag.is_zero() {
            return a;
        } else {
            Fixed { mag: a.mag, sign: !a.sign }
        }
    }
}

impl FixedAddAssign<Mag, +Add<Fixed<Mag>>> of core::ops::AddAssign<Fixed<Mag>, Fixed<Mag>> {
    fn add_assign(ref self: Fixed<Mag>, rhs: Fixed<Mag>) {
        self = self + rhs;
    }
}

impl FixedSubAssign<Mag, +Sub<Fixed<Mag>>> of core::ops::SubAssign<Fixed<Mag>, Fixed<Mag>> {
    fn sub_assign(ref self: Fixed<Mag>, rhs: Fixed<Mag>) {
        self = self - rhs;
    }
}

impl FixedMulAssign<Mag, +Mul<Fixed<Mag>>> of core::ops::MulAssign<Fixed<Mag>, Fixed<Mag>> {
    fn mul_assign(ref self: Fixed<Mag>, rhs: Fixed<Mag>) {
        self = self * rhs;
    }
}

impl FixedDivAssign<Mag, +Div<Fixed<Mag>>> of core::ops::DivAssign<Fixed<Mag>, Fixed<Mag>> {
    fn div_assign(ref self: Fixed<Mag>, rhs: Fixed<Mag>) {
        self = self / rhs;
    }
}
// impl FixedSqrt<Mag, const SQRT_ONE: Mag, +core::num::traits::Sqrt<Mag>, +Drop<Mag>,
// +Into<core::num::traits::Sqrt::<Mag>::Target, Mag>> of core::num::traits::Sqrt<Fixed<Mag>> {
//     type Target = Fixed<Mag>;

//     fn sqrt(self: Fixed<Mag>) -> Fixed<Mag> {
//         assert(!self.sign, 'must be positive');
//         Fixed { mag: self.mag.sqrt().into() * SQRT_ONE, sign: false }
//     }
// }



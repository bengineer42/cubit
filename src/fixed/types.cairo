use core::num::traits::{WideMul, Sqrt};
use core::traits::DivRem;
use fixed::fixed::consts::FixedConstsTrait;

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

pub impl FixedMul<Mag, +FixedMagMul<Mag>, +Drop<Mag>> of Mul<Fixed<Mag>> {
    fn mul(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        Fixed { mag: FixedMagMul::fixed_mag_mul(lhs.mag, rhs.mag), sign: lhs.sign != rhs.sign }
    }
}

pub impl FixedDiv<Mag, +FixedMagDiv<Mag>, +Drop<Mag>> of Div<Fixed<Mag>> {
    fn div(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        Fixed { mag: FixedMagDiv::fixed_mag_div(lhs.mag, rhs.mag), sign: lhs.sign != rhs.sign }
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

impl FixedSqrt<Mag, +FixedMagSqrt<Mag>, +Drop<Mag>> of core::num::traits::Sqrt<Fixed<Mag>> {
    type Target = Fixed<Mag>;

    fn sqrt(self: Fixed<Mag>) -> Fixed<Mag> {
        assert(!self.sign, 'must be positive');
        Fixed { mag: self.mag.fixed_mag_sqrt(), sign: false }
    }
}

pub trait FixedMagMul<Mag> {
    fn fixed_mag_mul(self: Mag, rhs: Mag) -> Mag;
}

pub trait FixedMagDiv<Mag> {
    fn fixed_mag_div(self: Mag, rhs: Mag) -> Mag;
}

pub trait FixedMagSqrt<Mag> {
    fn fixed_mag_sqrt(self: Mag) -> Mag;
}

pub trait FixedSqrtTrait<Mag> {
    fn fixed_sqrt(self: Fixed<Mag>) -> Fixed<Mag>;
}

pub impl FixedSqrtImpl<Mag, +FixedMagSqrt<Mag>, +Drop<Mag>> of FixedSqrtTrait<Mag> {
    fn fixed_sqrt(self: Fixed<Mag>) -> Fixed<Mag> {
        assert(!self.sign, 'must be positive');
        Fixed { mag: FixedMagSqrt::fixed_mag_sqrt(self.mag), sign: false }
    }
}

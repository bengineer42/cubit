use core::num::traits::{WideMul, Sqrt, Zero, One};
use core::ops::MulAssign;

use fixed::fixed::traits::{LutTrait, FixedTrait};
use fixed::fixed::consts::FixedConstsTrait;
use fixed::fixed::types::{Fixed, FixedSqrtTrait};
use fixed::fixed::types::FixedMagMul;
use fixed::fixed::ops::FixedMagOpsTrait;

use fixed::utils::{felt_abs, felt_sign};

pub impl FixedImpl<
    Mag,
    impl Consts: FixedConstsTrait<Mag>,
    +LutTrait<Mag>,
    +Div<Fixed<Mag>>,
    +FixedSqrtTrait<Mag>,
    +PartialEq<Mag>,
    +PartialOrd<Mag>,
    +Zero<Mag>,
    +One<Mag>,
    +TryInto<Mag, NonZero<Mag>>,
    +Into<Mag, u256>,
    +Into<Mag, felt252>,
    +TryInto<u256, Mag>,
    +TryInto<felt252, Mag>,
    +Add<Mag>,
    +Sub<Mag>,
    +Mul<Mag>,
    +MulAssign<Mag, Mag>,
    +Div<Mag>,
    +DivRem<Mag>,
    +FixedMagMul<Mag>,
    +WideMul<Mag, Mag>,
    +Drop<Mag>,
    +Copy<Mag>,
    +FixedMagOpsTrait<Mag>,
> of FixedTrait<Mag>{
    fn new(mag: Mag, sign: bool) -> Fixed<Mag> {
        Fixed { mag, sign }
    }
    fn new_unscaled(
        mag: Mag, sign: bool,
    ) -> Fixed<Mag> {
        Fixed { mag: mag * Consts::ONE_MAG, sign }
    }
    fn from_felt(
        val: felt252,
    ) -> Fixed<Mag> {
        Self::new(felt_abs(val).try_into().unwrap(), felt_sign(val))
    }
    fn from_unscaled_felt(
        val: felt252,
    ) -> Fixed<Mag> {
        Self::from_felt(val * Consts::ONE_MAG.into())
    }
    fn from_decimal(
        val: u256, places: u8,
    ) -> Fixed<
        Mag,
    > {
        let mut pow: u8 = 1;
        for _ in 0..places {
            pow *= 10;
        };
        let mag = (val * Consts::ONE_MAG.into() / pow.into()).try_into().unwrap();
        Fixed { mag, sign: false }
    }

    // Casters
    fn to_decimal(
        self: Fixed<Mag>, places: u8,
    ) -> u256 {
        assert(!self.sign, 'Negative value');
        let mut value: u256 = self.mag.into();
        for _ in 0..places {
            value *= 10;
        };
        value / Consts::ONE_MAG.into()
    }
    fn split(
        self: Fixed<Mag>,
    ) -> (Mag, Mag) {
        DivRem::div_rem(self.mag, Consts::ONE_MAG.try_into().unwrap())
    }

    // // Math
    fn abs(self: Fixed<Mag>) -> Fixed<Mag> {
        Fixed { mag: self.mag, sign: false }
    }
    fn ceil(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            self
        } else if self.sign {
            Fixed { mag: div, sign: true }
        } else {
            Fixed { mag: div + Consts::ONE_MAG, sign: false }
        }
    }
    fn exp(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        Self::exp2(Fixed { mag: self.mag.fixed_mag_mul(Consts::I_LN_2_MAG), sign: self.sign })
    }
    fn exp2(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        if (self.mag.is_zero()) {
            return Consts::ONE;
        }
        let (int_part, frac_part) = Self::split(self);

        let mut mag =int_part.lut_exp2();
        if frac_part.is_non_zero() {
            let [f1, f2, f3, f4, f5, f6, f7, f8] = Consts::EXP2_TS_FACTORS;

            let r8 = frac_part.fixed_mag_mul(f8);
            let r7 = (r8 + f7).fixed_mag_mul(frac_part);
            let r6 = (r7 + f6).fixed_mag_mul(frac_part);
            let r5 = (r6 + f5).fixed_mag_mul(frac_part);
            let r4 = (r5 + f4).fixed_mag_mul(frac_part);
            let r3 = (r4 + f3).fixed_mag_mul(frac_part);
            let r2 = (r3 + f2).fixed_mag_mul(frac_part);
            let r1 = (r2 + f1).fixed_mag_mul(frac_part);

            mag *= (r1 + Consts::ONE_MAG)
        };

        if self.sign {
            mag.mag_inverse();
        };

        Fixed{ mag, sign:false}
    }
    fn floor(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            self
        } else if self.sign {
            Fixed { mag: div + Consts::ONE_MAG, sign: true }
        } else {
            Fixed { mag: div, sign: false }
        }
    }
    fn ln(self: Fixed<Mag>) -> Fixed<Mag>{
        let Fixed{ mag, sign } = Self::log2(self);
        Fixed { mag: mag.fixed_mag_mul(Consts::LN_2_MAG), sign }
    }
    fn log2(self: Fixed<Mag>) -> Fixed<Mag>{
        self.assert_positive();
        let mag = self.mag;
        if mag == Consts::ONE_MAG {
            Zero::zero()
        } else if mag < Consts::ONE_MAG {
            Fixed { mag: mag.mag_inverse().mag_log2(), sign:true}
        } else {
            Fixed { mag: mag.mag_log2(), sign:false}
        }
        
    }
    fn log10(self: Fixed<Mag>) -> Fixed<Mag>{
        let Fixed{ mag, sign } = Self::log2(self);
        Fixed { mag: mag.fixed_mag_mul(Consts::LOG10_2_MAG), sign }
    }
    fn pow(self: Fixed<Mag>, b: Fixed<Mag>) -> Fixed<Mag>;
    fn round(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        let mag = div + match rem >= Consts::HALF_MAG {
            true => One::one(),
            false => Zero::zero(),
        };
        Self::new_unscaled(mag, self.sign)
    }
    fn inverse(
        self: Fixed<Mag>,
    ) -> Fixed<Mag>{
        Fixed { mag: self.mag.mag_inverse(), sign: self.sign }
     }

    // Trigonometry
    fn acos(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = self;
        let root = Self::asin((Consts::ONE - val * val).fixed_sqrt());
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn acos_fast(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = self;
        let root = Self::asin_fast((Consts::ONE - val * val).fixed_sqrt());
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn asin(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan((Consts::ONE - val * val).fixed_sqrt()),
        }
    }
    fn asin_fast(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan_fast((Consts::ONE - val * val).fixed_sqrt()),
        }
    }
    fn atan(self: Fixed<Mag>) -> Fixed<Mag>;
    fn atan_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn cos(self: Fixed<Mag>) -> Fixed<Mag> {
        Self::sin(Consts::HALF_PI - self)
    }
    fn cos_fast(self: Fixed<Mag>) -> Fixed<Mag> {
        Self::sin_fast(Consts::HALF_PI - self)
    }
    fn sin(self: Fixed<Mag>) -> Fixed<Mag>;
    fn sin_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn tan(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin(self) / cos
    }
    fn tan_fast(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos_fast(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin_fast(self) / cos
    }

    // Hyperbolic
    fn acosh(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        Self::ln(self + (self * self - Consts::ONE).fixed_sqrt())
    }
    fn asinh(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        Self::ln(self + (self * self + Consts::ONE).fixed_sqrt())
    }
    fn atanh(
        self: Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        Self::ln((Consts::ONE + self) / (Consts::ONE - self)) / Consts::TWO
    }
    fn cosh(
        self: Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea + (Consts::ONE / ea)) / Consts::TWO
    }
    fn sinh(
        self: Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea - (Consts::ONE / ea)) / Consts::TWO
    }
    fn tanh(
        self: Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        let iea = Consts::ONE / ea;
        (ea - iea) / (ea + iea)
    }
}

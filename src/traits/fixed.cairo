use core::num::traits::{Zero, One};
use core::num::traits::{WideMul, Sqrt};

use fixed::utils::{felt_abs, felt_sign};
use fixed::types::fixed::Fixed;
use fixed::traits::consts::FixedConstsTrait;

pub trait FixedTrait<
    Mag,
    impl Consts: FixedConstsTrait<Mag>,
    +Add<Mag>,
    +Sub<Mag>,
    +Mul<Mag>,
    +Div<Mag>,
    +DivRem<Mag>,
    +Add<Fixed<Mag>>,
    +Sub<Fixed<Mag>>,
    +Mul<Fixed<Mag>>,
    +Div<Fixed<Mag>>,
    +PartialEq<Mag>,
    +PartialOrd<Mag>,
    +Zero<Mag>,
    +One<Mag>,
    +Sqrt<Mag>,
    +TryInto<Mag, NonZero<Mag>>,
    +Sqrt<Fixed<Mag>>,
    +Into<Sqrt::<Fixed<Mag>>::Target, Fixed<Mag>>,
    +Into<Mag, u256>,
    +Into<Mag, felt252>,
    +TryInto<u256, Mag>,
    +TryInto<felt252, Mag>,
> {
    // Constructors
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
        self: @Fixed<Mag>, places: u8,
    ) -> u256 {
        assert(!*self.sign, 'Negative value');
        let mut value: u256 = (*self.mag).into();
        for _ in 0..places {
            value *= 10;
        };
        value / Consts::ONE_MAG.into()
    }
    fn split(
        self: @Fixed<Mag>,
    ) -> (Mag, Mag) {
        DivRem::div_rem(*self.mag, Consts::ONE_MAG.try_into().unwrap())
    }

    // // Math
    fn abs(self: @Fixed<Mag>) -> Fixed<Mag> {
        Fixed { mag: *self.mag, sign: false }
    }
    fn ceil(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            *self
        } else if *self.sign {
            Fixed { mag: div, sign: true }
        } else {
            Fixed { mag: div + Consts::ONE_MAG, sign: false }
        }
    }
    fn exp(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn exp2(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn floor(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            *self
        } else if *self.sign {
            Fixed { mag: div + Consts::ONE_MAG, sign: true }
        } else {
            Fixed { mag: div, sign: false }
        }
    }
    fn ln(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn log2(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn log10(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn pow(self: @Fixed<Mag>, b: Fixed<Mag>) -> Fixed<Mag>;
    fn round(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        let mag = div + match rem >= Consts::HALF_MAG {
            true => One::one(),
            false => Zero::zero(),
        };
        Self::new_unscaled(mag, *self.sign)
    }

    // Trigonometry
    fn acos(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = Self::asin(@((Consts::ONE - val * val).sqrt().into()));
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn acos_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = Self::asin_fast(@((Consts::ONE - val * val).sqrt().into()));
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn asin(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan(@((Consts::ONE - val * val).sqrt().into())),
        }
    }
    fn asin_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan_fast(@((Consts::ONE - val * val).sqrt().into())),
        }
    }
    fn atan(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn atan_fast(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn cos(self: @Fixed<Mag>) -> Fixed<Mag> {
        Self::sin(@(Consts::HALF_PI - *self))
    }
    fn cos_fast(self: @Fixed<Mag>) -> Fixed<Mag> {
        Self::sin_fast(@(Consts::HALF_PI - *self))
    }
    fn sin(self: @Fixed<Mag>) -> Fixed<Mag>; //
    fn sin_fast(self: @Fixed<Mag>) -> Fixed<Mag>; //
    fn tan(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin(self) / cos
    }
    fn tan_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos_fast(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin_fast(self) / cos
    }

    // Hyperbolic
    fn acosh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = (val * val - Consts::ONE).sqrt().into();
        Self::ln(@(val + root))
    }
    fn asinh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = (val * val + Consts::ONE).sqrt().into();
        Self::ln(@(val + root))
    }
    fn atanh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let ln_val = (Consts::ONE + val) / (Consts::ONE - val);
        Self::ln(@(ln_val)) / Consts::TWO
    }
    fn cosh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea + (Consts::ONE / ea)) / Consts::TWO
    }
    fn sinh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea - (Consts::ONE / ea)) / Consts::TWO
    }
    fn tanh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        let iea = Consts::ONE / ea;
        (ea - iea) / (ea + iea)
    }
}

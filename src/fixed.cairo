use core::num::traits::{One, Zero};
use cubit::utils::{felt_abs, felt_sign};

trait FixedTrait<Fixed> {
    type Mag;

    fn ZERO() -> Fixed;
    fn ONE() -> Fixed;

    // Constructors
    fn new(mag: Self::Mag, sign: bool) -> Fixed;
    fn new_unscaled(mag: Self::Mag, sign: bool) -> Fixed;
    fn from_felt(val: felt252) -> Fixed;
    fn from_unscaled_felt(val: felt252) -> Fixed;
    // fn from_decimal(val: u256, places: u8) -> Fixed;
    // fn to_decimal(self: Fixed, places: u8) -> u256;

    // // Math
    fn abs(self: Fixed) -> Fixed;
    fn ceil(self: Fixed) -> Fixed;
    fn exp(self: Fixed) -> Fixed;
    fn exp2(self: Fixed) -> Fixed;
    fn floor(self: Fixed) -> Fixed;
    fn ln(self: Fixed) -> Fixed;
    fn log2(self: Fixed) -> Fixed;
    fn log10(self: Fixed) -> Fixed;
    fn pow(self: Fixed, b: Fixed) -> Fixed;
    fn round(self: Fixed) -> Fixed;
    fn sqrt(self: Fixed) -> Fixed;

    // Trigonometry
    fn acos(self: Fixed) -> Fixed;
    fn acos_fast(self: Fixed) -> Fixed;
    fn asin(self: Fixed) -> Fixed;
    fn asin_fast(self: Fixed) -> Fixed;
    fn atan(self: Fixed) -> Fixed;
    fn atan_fast(self: Fixed) -> Fixed;
    fn cos(self: Fixed) -> Fixed;
    fn cos_fast(self: Fixed) -> Fixed;
    fn sin(self: Fixed) -> Fixed;
    fn sin_fast(self: Fixed) -> Fixed;
    fn tan(self: Fixed) -> Fixed;
    fn tan_fast(self: Fixed) -> Fixed;

    // Hyperbolic
    fn acosh(self: Fixed) -> Fixed;
    fn asinh(self: Fixed) -> Fixed;
    fn atanh(self: Fixed) -> Fixed;
    fn cosh(self: Fixed) -> Fixed;
    fn sinh(self: Fixed) -> Fixed;
    fn tanh(self: Fixed) -> Fixed;
}


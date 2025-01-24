use fixed::fixed::types::{Fixed, FixedSqrtTrait};
use fixed::fixed::types::FixedMagMul;
use fixed::fixed::consts::FixedConstsTrait;

trait LutTrait<T> {
    fn lut_msb(self: T) -> (T, T);
    fn lut_exp2(self: T) -> T;
    fn lut_sin(self: T) -> (T, T, T);
    fn lut_atan(self: T) -> (T, T, T);
}


pub trait FixedMagOpsTrait<Mag> {
    fn mag_exp(self: Mag) -> Mag;
    fn mag_exp2(self: Mag) -> Mag;
    fn mag_ln(self: Mag) -> Mag;
    fn mag_log2(self: Mag) -> Mag;
    fn mag_log10(self: Mag) -> Mag;
    fn mag_pow(self: Mag, b: Mag) -> Mag;
}

pub trait FixedOpsTrait<Mag> {
    fn exp(self: Fixed<Mag>) -> Fixed<Mag>;
    fn exp2(self: Fixed<Mag>) -> Fixed<Mag>;
    fn ln(self: Fixed<Mag>) -> Fixed<Mag>;
    fn log2(self: Fixed<Mag>) -> Fixed<Mag>;
    fn log10(self: Fixed<Mag>) -> Fixed<Mag>;
    fn pow(self: Fixed<Mag>, exp: Fixed<Mag>) -> Fixed<Mag>;
}

pub trait FixedTrait<Mag> {
    // Constructors
    fn new(mag: Mag, sign: bool) -> Fixed<Mag>;
    fn new_unscaled(mag: Mag, sign: bool) -> Fixed<Mag>;
    fn from_felt(val: felt252) -> Fixed<Mag>;
    fn from_unscaled_felt(val: felt252) -> Fixed<Mag>;
    fn from_decimal(val: u256, places: u8) -> Fixed<Mag>;

    // Casters
    fn to_decimal(self: Fixed<Mag>, places: u8) -> u256;
    fn split(self: Fixed<Mag>) -> (Mag, Mag);

    // // Math
    fn abs(self: Fixed<Mag>) -> Fixed<Mag>;
    fn ceil(self: Fixed<Mag>) -> Fixed<Mag>;
    fn exp(self: Fixed<Mag>) -> Fixed<Mag>;
    fn exp2(self: Fixed<Mag>) -> Fixed<Mag>;
    fn floor(self: Fixed<Mag>) -> Fixed<Mag>;
    fn ln(self: Fixed<Mag>) -> Fixed<Mag>;
    fn log2(self: Fixed<Mag>) -> Fixed<Mag>;
    fn log10(self: Fixed<Mag>) -> Fixed<Mag>;
    fn pow(self: Fixed<Mag>, b: Fixed<Mag>) -> Fixed<Mag>;
    fn round(self: Fixed<Mag>) -> Fixed<Mag>;
    fn inverse(self: Fixed<Mag>) -> Fixed<Mag>;

    // Trigonometry
    fn acos(self: Fixed<Mag>) -> Fixed<Mag>;
    fn acos_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn asin(self: Fixed<Mag>) -> Fixed<Mag>;
    fn asin_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn atan(self: Fixed<Mag>) -> Fixed<Mag>;
    fn atan_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn cos(self: Fixed<Mag>) -> Fixed<Mag>;
    fn cos_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn sin(self: Fixed<Mag>) -> Fixed<Mag>;
    fn sin_fast(self: Fixed<Mag>) -> Fixed<Mag>;
    fn tan(self: Fixed<Mag>) -> Fixed<Mag>;
    fn tan_fast(self: Fixed<Mag>) -> Fixed<Mag>;

    // Hyperbolic
    fn acosh(self: Fixed<Mag>) -> Fixed<Mag>;
    fn asinh(self: Fixed<Mag>) -> Fixed<Mag>;
    fn atanh(self: Fixed<Mag>) -> Fixed<Mag>;
    fn cosh(self: Fixed<Mag>) -> Fixed<Mag>;

    fn sinh(self: Fixed<Mag>) -> Fixed<Mag>;
    fn tanh(self: Fixed<Mag>) -> Fixed<Mag>;
}

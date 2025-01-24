use fixed::fixed::consts::FixedConstsTrait;
use fixed::fixed::types::Fixed;
use fixed::fixed::traits::FixedTrait;
use fixed::fixed::implementations;

use super::lut::FP64X64Lut;

type fp64x64 = Fixed<u128>;

pub impl FP64X64Consts of FixedConstsTrait<u128> {
    const ONE_MAG: u128 = 18446744073709551616;
    const HALF_MAG: u128 = 9223372036854775808;
    const SQRT_MAG: u128 = 4294967296;
    const TWO_MAG: u128 = 36893488147419103232;
    const PI_MAG: u128 = 57952155664616982739;
    const HALF_PI_MAG: u128 = 28976077832308491370;

    const ONE: Fixed<u128> = Fixed { mag: Self::ONE_MAG, sign: false };
    const TWO: Fixed<u128> = Fixed { mag: Self::TWO_MAG, sign: false };
    const PI: Fixed<u128> = Fixed { mag: Self::PI_MAG, sign: false };
    const HALF_PI: Fixed<u128> = Fixed { mag: Self::HALF_PI_MAG, sign: false };
}

pub impl FP64X64One = implementations::FixedOne<u128, FP64X64Consts::ONE_MAG>;
pub impl PF64X64MagMul = implementations::FixedMagMulImpl<u128, FP64X64Consts::ONE_MAG>;
pub impl PF64X64MagDiv = implementations::FixedMagDivImpl<u128, FP64X64Consts::ONE_MAG>;
pub impl PF64X64MagSqrt = implementations::FixedMagSqrtImpl<u128, FP64X64Consts::SQRT_MAG>;

pub impl FP64X64 = implementations::FixedImpl<u128>;


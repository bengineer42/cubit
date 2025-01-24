use fixed::fixed::consts::FixedConstsTrait;
use fixed::fixed::types::Fixed;
use fixed::fixed::traits::FixedTrait;
use fixed::fixed::implementations;

use super::lut::FP32X32Lut;

type fp32x32 = Fixed<u64>;

impl FP32X32Consts of FixedConstsTrait<u64> {
    const ONE_MAG: u64 = 4294967296;
    const HALF_MAG: u64 = 2147483648;
    const SQRT_MAG: u64 = 65536;
    const TWO_MAG: u64 = 8589934592;
    const PI_MAG: u64 = 13493037705;
    const HALF_PI_MAG: u64 = 6746518852;

    const ONE: fp32x32 = Fixed { mag: Self::ONE_MAG, sign: false };
    const TWO: fp32x32 = Fixed { mag: Self::TWO_MAG, sign: false };
    const PI: fp32x32 = Fixed { mag: Self::PI_MAG, sign: false };
    const HALF_PI: fp32x32 = Fixed { mag: Self::HALF_PI_MAG, sign: false };
}

pub impl FP32X32One = implementations::FixedOne<u64, FP32X32Consts::ONE_MAG>;
pub impl PF32X32MagMul = implementations::FixedMagMulImpl<u64, FP32X32Consts::ONE_MAG>;
pub impl PF32X32MagDiv = implementations::FixedMagDivImpl<u64, FP32X32Consts::ONE_MAG>;
pub impl PF32X32MagSqrt = implementations::FixedMagSqrtImpl<u64, FP32X32Consts::SQRT_MAG>;

impl FP32X32 of FixedTrait<u64> {
    fn exp(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn exp2(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn ln(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn log2(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn log10(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn pow(self: @fp32x32, b: fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn atan(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn atan_fast(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn sin(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
    fn sin_fast(self: @fp32x32) -> fp32x32 {
        Fixed { mag: 0, sign: false }
    }
}


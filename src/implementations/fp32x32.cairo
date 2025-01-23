use core::ops::{AddAssign, SubAssign, MulAssign, DivAssign};
use core::num::traits::{WideMul, Sqrt};
use core::num::traits::{Zero, One};

use starknet::storage_access::StorePacking;

use fixed::types::fixed::{Fixed, FixedOne};
use fixed::traits::FixedTrait;
use fixed::traits::consts::FixedConstsTrait;

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

impl FP32X32One = FixedOne<u64, 4294967296>;

impl FP32X32Mul of Mul<fp32x32> {
    fn mul(lhs: fp32x32, rhs: fp32x32) -> fp32x32 {
        let mag = match (lhs.mag.wide_mul(rhs.mag) / FP32X32Consts::ONE_MAG.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        };
        Fixed { mag, sign: lhs.sign ^ rhs.sign }
    }
}

impl FP32X32Div of Div<fp32x32> {
    fn div(lhs: fp32x32, rhs: fp32x32) -> fp32x32 {
        let mag = match (lhs.mag.wide_mul(FP32X32Consts::ONE_MAG) / rhs.mag.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        };
        Fixed { mag, sign: lhs.sign ^ rhs.sign }
    }
}

impl FP32X32Sqrt of Sqrt<fp32x32> {
    type Target = fp32x32;
    fn sqrt(self: fp32x32) -> fp32x32 {
        assert(!self.sign, 'must be positive');

        Fixed { mag: self.mag.sqrt().into() * FP32X32Consts::SQRT_MAG, sign: false }
    }
}


impl FP32X32 of FixedTrait<u64> {
    fn exp(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn exp2(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn ln(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn log2(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn log10(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn pow(self: @fp32x32, b: fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn atan(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn atan_fast(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn sin(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn sin_fast(self: @fp32x32) -> fp32x32 {
        Fixed { mag: Zero::zero(), sign: false }
    }
}


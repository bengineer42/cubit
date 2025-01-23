use core::num::traits::{WideMul, Sqrt};
use core::num::traits::{Zero, One};

use starknet::storage_access::StorePacking;

use fixed::traits::arith;
use fixed::types::fixed::{Fixed, FixedOne};
use fixed::traits::FixedTrait;
use fixed::traits::consts::FixedConstsTrait;

type fp64x64 = Fixed<u128>;

impl FP64X64Consts of FixedConstsTrait<u128> {
    const ONE_MAG: u128 = 18446744073709551616;
    const HALF_MAG: u128 = 9223372036854775808;
    const SQRT_MAG: u128 = 4294967296;
    const TWO_MAG: u128 = 36893488147419103232;
    const PI_MAG: u128 = 57952155664616982739;
    const HALF_PI_MAG: u128 = 28976077832308491370;

    const ONE: fp64x64 = Fixed { mag: Self::ONE_MAG, sign: false };
    const TWO: fp64x64 = Fixed { mag: Self::TWO_MAG, sign: false };
    const PI: fp64x64 = Fixed { mag: Self::PI_MAG, sign: false };
    const HALF_PI: fp64x64 = Fixed { mag: Self::HALF_PI_MAG, sign: false };
}

impl FP64X64One = FixedOne<u128, FP64X64Consts::ONE_MAG>;
impl FP64X64Mul = arith::FixedMul<u128, FP64X64Consts::ONE_MAG>;
// impl FP64X64Div = arith::FixedDiv<u128, FP64X64Consts::ONE_MAG>;

// impl FP64X64Mul of Mul<fp64x64> {
//     fn mul(lhs: fp64x64, rhs: fp64x64) -> fp64x64 {
//         let mag = match (lhs.mag.wide_mul(rhs.mag) / FP64X64Consts::ONE_MAG.into()).try_into() {
//             Option::Some(mag) => mag,
//             Option::None => panic!("Overflow error"),
//         };
//         Fixed { mag, sign: lhs.sign ^ rhs.sign }
//     }
// }

impl FP64X64Div of Div<fp64x64> {
    fn div(lhs: fp64x64, rhs: fp64x64) -> fp64x64 {
        let mag = match (lhs.mag.wide_mul(FP64X64Consts::ONE_MAG) / rhs.mag.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        };
        Fixed { mag, sign: lhs.sign ^ rhs.sign }
    }
}

impl FP64X64Sqrt of Sqrt<fp64x64> {
    type Target = fp64x64;
    fn sqrt(self: fp64x64) -> fp64x64 {
        assert(!self.sign, 'must be positive');

        Fixed { mag: self.mag.sqrt().into() * FP64X64Consts::SQRT_MAG, sign: false }
    }
}

impl FP64X64 of FixedTrait<u128> {
    fn exp(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn exp2(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn ln(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn log2(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn log10(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn pow(self: @fp64x64, b: fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn atan(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn atan_fast(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn sin(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
    fn sin_fast(self: @fp64x64) -> fp64x64 {
        Fixed { mag: Zero::zero(), sign: false }
    }
}


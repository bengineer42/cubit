use core::ops::{AddAssign, SubAssign, MulAssign, DivAssign, Rem};
use fixed::types::Fixed;
use fixed::traits::FixedTrait;
use fixed::traits::consts::FixedConstsTrait;

impl FP64X64Consts of FixedConstsTrait<u128> {
    const ONE_MAG: u128 = 1 << 64;
    const ZERO_MAG: u128 = 0;
    const HALF_MAG: u128 = 1 << 63;
    const SQRT_MAG: u128 = 0x1A827999FCEF32B8 << 32;
    const SQRT2_MAG: u128 = 0x2D413CCC3A3A7C32 << 32;
    const E_MAG: u128 = 0x2B7E151628AED2A6 << 32;
    const TWO_MAG: u128 = 2 << 64;
    const PI_MAG: u128 = 0x3243F6A8885A308D << 32;
    const HALF_PI_MAG: u128 = 0x1921FB54442D1846 << 32;
    const PI_512THS_MAG: u128 = 0x3F877ACD7A2F1A9F << 32;
    const PI_SQUARED_MAG: u128 = 0xC90FDAA22168C234 << 32;

    const ONE: Fixed<u128> = Fixed { mag: Self::ONE_MAG, sign: false };
    const TWO: Fixed<u128> = Fixed { mag: Self::TWO_MAG, sign: false };
    const PI: Fixed<u128> = Fixed { mag: Self::PI_MAG, sign: false };
    const HALF_PI: Fixed<u128> = Fixed { mag: Self::HALF_PI_MAG, sign: false };
} 

impl FP64X64 of FixedTrait<u128, >
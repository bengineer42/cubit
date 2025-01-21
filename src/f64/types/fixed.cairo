use core::debug::PrintTrait;

use core::integer::{U128DivRem, u128_as_non_zero};
use core::option::OptionTrait;
use core::result::{ResultTrait, ResultTraitImpl};
use core::traits::{TryInto, Into};

use starknet::storage_access::StorePacking;

use cubit::fixed::FixedTrait;
use cubit::utils;
use cubit::f64::math::{ops, hyp, trig};
use cubit::f128::{f128, Fixed128, ONE_u128};

// CONSTANTS

const TWO: u64 = 8589934592; // 2 ** 33
const ONE: u64 = 4294967296; // 2 ** 32
const HALF: u64 = 2147483648; // 2 ** 31
const MAX_u64: u128 = 18_446_744_073_709_551_615; //2**64 - 1

// STRUCTS

#[derive(Copy, Drop, Serde)]
struct f64 {
    mag: u64,
    sign: bool
}

impl Fixed64 of FixedTrait<f64> {
    type Mag = u64;
    fn ZERO() -> f64 {
        return core::num::traits::Zero::zero();
    }

    fn ONE() -> f64 {
        return core::num::traits::One::one();
    }

    fn new(mag: u64, sign: bool) -> f64 {
        return f64 { mag: mag, sign: sign };
    }

    fn new_unscaled(mag: u64, sign: bool) -> f64 {
        return f64 { mag: mag * ONE, sign: sign };
    }

    fn from_felt(val: felt252) -> f64 {
        let mag = core::integer::u64_try_from_felt252(utils::felt_abs(val)).unwrap();
        return Self::new(mag, utils::felt_sign(val));
    }

    fn from_unscaled_felt(val: felt252) -> f64 {
        return Self::from_felt(val * ONE.into());
    }

    fn abs(self: f64) -> f64 {
        return ops::abs(self);
    }

    fn acos(self: f64) -> f64 {
        return trig::acos(self);
    }

    fn acos_fast(self: f64) -> f64 {
        return trig::acos_fast(self);
    }

    fn acosh(self: f64) -> f64 {
        return hyp::acosh(self);
    }

    fn asin(self: f64) -> f64 {
        return trig::asin(self);
    }

    fn asin_fast(self: f64) -> f64 {
        return trig::asin_fast(self);
    }

    fn asinh(self: f64) -> f64 {
        return hyp::asinh(self);
    }

    fn atan(self: f64) -> f64 {
        return trig::atan(self);
    }

    fn atan_fast(self: f64) -> f64 {
        return trig::atan_fast(self);
    }

    fn atanh(self: f64) -> f64 {
        return hyp::atanh(self);
    }

    fn ceil(self: f64) -> f64 {
        return ops::ceil(self);
    }

    fn cos(self: f64) -> f64 {
        return trig::cos(self);
    }

    fn cos_fast(self: f64) -> f64 {
        return trig::cos_fast(self);
    }

    fn cosh(self: f64) -> f64 {
        return hyp::cosh(self);
    }

    fn floor(self: f64) -> f64 {
        return ops::floor(self);
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: f64) -> f64 {
        return ops::exp(self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: f64) -> f64 {
        return ops::exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: f64) -> f64 {
        return ops::ln(self);
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: f64) -> f64 {
        return ops::log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: f64) -> f64 {
        return ops::log10(self);
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: f64, b: f64) -> f64 {
        return ops::pow(self, b);
    }

    fn round(self: f64) -> f64 {
        return ops::round(self);
    }

    fn sin(self: f64) -> f64 {
        return trig::sin(self);
    }

    fn sin_fast(self: f64) -> f64 {
        return trig::sin_fast(self);
    }

    fn sinh(self: f64) -> f64 {
        return hyp::sinh(self);
    }

    // Calculates the square root of a fixed point value
    // x must be positive
    fn sqrt(self: f64) -> f64 {
        return ops::sqrt(self);
    }

    fn tan(self: f64) -> f64 {
        return trig::tan(self);
    }

    fn tan_fast(self: f64) -> f64 {
        return trig::tan_fast(self);
    }

    fn tanh(self: f64) -> f64 {
        return hyp::tanh(self);
    }
}

impl FixedPrint of PrintTrait<f64> {
    fn print(self: f64) {
        self.sign.print();
        self.mag.print();
    }
}

impl Fixed64IntoFixed128 of Into<f64, f128> {
    fn into(self: f64) -> f128 {
        return Fixed128::new(self.mag.into() * ONE.into(), self.sign);
    }
}

// Into a raw felt without unscaling
impl FixedIntoFelt252 of Into<f64, felt252> {
    fn into(self: f64) -> felt252 {
        let mag_felt = self.mag.into();

        if self.sign {
            return mag_felt * -1;
        } else {
            return mag_felt * 1;
        }
    }
}

impl FixedTryIntoU128 of TryInto<f64, u128> {
    fn try_into(self: f64) -> Option<u128> {
        if self.sign {
            return Option::None(());
        } else {
            // Unscale the magnitude and round down
            return Option::Some((self.mag / ONE).into());
        }
    }
}

impl FixedTryIntoU64 of TryInto<f64, u64> {
    fn try_into(self: f64) -> Option<u64> {
        if self.sign {
            return Option::None(());
        } else {
            // Unscale the magnitude and round down
            return Option::Some(self.mag / ONE);
        }
    }
}

impl FixedTryIntoU32 of TryInto<f64, u32> {
    fn try_into(self: f64) -> Option<u32> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
        }
    }
}

impl FixedTryIntoU16 of TryInto<f64, u16> {
    fn try_into(self: f64) -> Option<u16> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
        }
    }
}

impl FixedTryIntoU8 of TryInto<f64, u8> {
    fn try_into(self: f64) -> Option<u8> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
        }
    }
}

impl U8IntoFixed of Into<u8, f64> {
    fn into(self: u8) -> f64 {
        Fixed64::new_unscaled(self.into(), false)
    }
}

impl U16IntoFixed of Into<u16, f64> {
    fn into(self: u16) -> f64 {
        Fixed64::new_unscaled(self.into(), false)
    }
}

impl U32IntoFixed of Into<u32, f64> {
    fn into(self: u32) -> f64 {
        Fixed64::new_unscaled(self.into(), false)
    }
}

impl U64IntoFixed of Into<u64, f64> {
    fn into(self: u64) -> f64 {
        Fixed64::new_unscaled(self.into(), false)
    }
}

impl U128TryIntoFixed of TryInto<u128, f64> {
    fn try_into(self: u128) -> Option<f64> {
        if self > 18_446_744_073_709_551_615 {
            return Option::None(());
        } else {
            return Option::Some(Fixed64::new_unscaled(self.try_into().unwrap(), false));
        }
    }
}

impl U256TryIntoFixed of TryInto<u256, f64> {
    fn try_into(self: u256) -> Option<f64> {
        if self.high > 0 {
            return Option::None(());
        } else {
            return Option::Some(Fixed64::new_unscaled(self.try_into().unwrap(), false));
        }
    }
}

impl I8IntoFixed of Into<i8, f64> {
    fn into(self: i8) -> f64 {
        if 0 <= self {
            return Fixed64::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return Fixed64::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I16IntoFixed of Into<i16, f64> {
    fn into(self: i16) -> f64 {
        if 0 <= self {
            return Fixed64::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return Fixed64::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I32IntoFixed of Into<i32, f64> {
    fn into(self: i32) -> f64 {
        if 0 <= self {
            return Fixed64::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return Fixed64::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I64IntoFixed of Into<i64, f64> {
    fn into(self: i64) -> f64 {
        if 0 <= self {
            return Fixed64::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return Fixed64::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I128TryIntoFixed of TryInto<i128, f64> {
    fn try_into(self: i128) -> Option<f64> {
        let sign = self < 0;
        let value: u128 = if sign {
            (-self).try_into().unwrap()
        } else {
            self.try_into().unwrap()
        };
        if value > MAX_u64 {
            return Option::None(());
        } else {
            return Option::Some(Fixed64::new_unscaled(value.try_into().unwrap(), sign));
        }
    }
}

impl FixedPartialEq of PartialEq<f64> {
    #[inline(always)]
    fn eq(lhs: @f64, rhs: @f64) -> bool {
        return ops::eq(lhs, rhs);
    }

    #[inline(always)]
    fn ne(lhs: @f64, rhs: @f64) -> bool {
        return ops::ne(lhs, rhs);
    }
}

impl FixedAdd of Add<f64> {
    fn add(lhs: f64, rhs: f64) -> f64 {
        return ops::add(lhs, rhs);
    }
}

impl FixedAddAssign of core::ops::AddAssign<f64, f64> {
    #[inline(always)]
    fn add_assign(ref self: f64, rhs: f64) {
        self = Add::add(self, rhs);
    }
}

impl FixedSub of Sub<f64> {
    fn sub(lhs: f64, rhs: f64) -> f64 {
        return ops::sub(lhs, rhs);
    }
}

impl FixedSubAssign of core::ops::SubAssign<f64, f64> {
    #[inline(always)]
    fn sub_assign(ref self: f64, rhs: f64) {
        self = Sub::sub(self, rhs);
    }
}

impl FixedMul of Mul<f64> {
    fn mul(lhs: f64, rhs: f64) -> f64 {
        return ops::mul(lhs, rhs);
    }
}

impl FixedMulAssign of core::ops::MulAssign<f64, f64> {
    #[inline(always)]
    fn mul_assign(ref self: f64, rhs: f64) {
        self = Mul::mul(self, rhs);
    }
}

impl FixedDiv of Div<f64> {
    fn div(lhs: f64, rhs: f64) -> f64 {
        return ops::div(lhs, rhs);
    }
}

impl FixedDivAssign of core::ops::DivAssign<f64, f64> {
    #[inline(always)]
    fn div_assign(ref self: f64, rhs: f64) {
        self = Div::div(self, rhs);
    }
}

impl FixedPartialOrd of PartialOrd<f64> {
    #[inline(always)]
    fn ge(lhs: f64, rhs: f64) -> bool {
        return ops::ge(lhs, rhs);
    }

    #[inline(always)]
    fn gt(lhs: f64, rhs: f64) -> bool {
        return ops::gt(lhs, rhs);
    }

    #[inline(always)]
    fn le(lhs: f64, rhs: f64) -> bool {
        return ops::le(lhs, rhs);
    }

    #[inline(always)]
    fn lt(lhs: f64, rhs: f64) -> bool {
        return ops::lt(lhs, rhs);
    }
}

impl FixedNeg of Neg<f64> {
    #[inline(always)]
    fn neg(a: f64) -> f64 {
        return ops::neg(a);
    }
}

impl FixedRem of Rem<f64> {
    #[inline(always)]
    fn rem(lhs: f64, rhs: f64) -> f64 {
        return ops::rem(lhs, rhs);
    }
}

impl PackFixed of StorePacking<f64, felt252> {
    fn pack(value: f64) -> felt252 {
        let MAX_MAG_PLUS_ONE = 0x10000000000000000; // 2**64
        let packed_sign = MAX_MAG_PLUS_ONE * value.sign.into();
        value.mag.into() + packed_sign
    }

    fn unpack(value: felt252) -> f64 {
        let value_u128: u128 = value.try_into().unwrap();
        let (q, r) = U128DivRem::div_rem(value_u128, u128_as_non_zero(0x10000000000000000));
        let mag: u64 = r.try_into().unwrap();
        let sign: bool = q.into() == 1;
        f64 { mag: mag, sign: sign }
    }
}

impl FixedZero of core::num::traits::Zero<f64> {
    fn zero() -> f64 {
        f64 { mag: 0, sign: false }
    }
    #[inline(always)]
    fn is_zero(self: @f64) -> bool {
        *self.mag == 0
    }
    #[inline(always)]
    fn is_non_zero(self: @f64) -> bool {
        !self.is_zero()
    }
}

// One trait implementations
impl FixedOne of core::num::traits::One<f64> {
    fn one() -> f64 {
        f64 { mag: ONE, sign: false }
    }
    #[inline(always)]
    fn is_one(self: @f64) -> bool {
        *self == Self::one()
    }
    #[inline(always)]
    fn is_non_one(self: @f64) -> bool {
        !self.is_one()
    }
}

#[cfg(test)]
mod tests {
    use super::{Fixed64, f128, ONE_u128};

    #[test]
    fn test_into_f128() {
        let a = Fixed64::new_unscaled(42, true);
        let b: f128 = a.into();
        assert(b.mag == 42 * ONE_u128, 'invalid conversion');
    }

    fn test_reverse_try() {
        let a = Fixed64::new_unscaled(42, false);
        let b = Fixed64::new_unscaled(42, true);
        assert(42_u64.into() == a, 'invalid conversion from u64');
        assert(42_u32.into() == a, 'invalid conversion from u32');
        assert(42_u16.into() == a, 'invalid conversion from u16');
        assert(42_u8.into() == a, 'invalid conversion from u8');

        assert(42_i64.into() == a, 'invalid conversion from i64');
        assert(42_i32.into() == a, 'invalid conversion from i32');
        assert(42_i16.into() == a, 'invalid conversion from i16');
        assert(42_i8.into() == a, 'invalid conversion from i8');

        assert((-42_i64).into() == b, 'invalid conversion from - i64');
        assert((-42_i32).into() == b, 'invalid conversion from - i32');
        assert((-42_i16).into() == b, 'invalid conversion from - i16');
        assert((-42_i8).into() == b, 'invalid conversion from - i8');
    }

    fn test_reverse_try_into() {
        let mut a = Fixed64::new_unscaled(42, false);
        let b = Fixed64::new_unscaled(42, true);
        assert(a == 42_u256.try_into().unwrap(), 'conversion from invalid u256');
        assert(42_u128.try_into().unwrap() == a, 'invalid conversion from u128');
        assert(42_i128.try_into().unwrap() == a, 'invalid conversion from i128');
        assert((-42_i128).try_into().unwrap() == b, 'invalid conversion from - i128');
    }
}

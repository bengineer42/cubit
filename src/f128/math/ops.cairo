use core::debug::PrintTrait;
use core::option::OptionTrait;
use core::result::{ResultTrait, ResultTraitImpl};
use core::traits::{Into, TryInto};
use core::integer;
use core::num::traits::{WideMul, Sqrt};
use core::integer::{u256_safe_div_rem, u256_as_non_zero};

use cubit::f128::math::lut;
use cubit::f128::types::fixed::{
    HALF_u128, MAX_u128, ONE_u128, ONE_u256, SQRT_ONE_u128, f128, FixedInto, Fixed128, FixedAdd,
    FixedDiv, FixedMul, FixedNeg
};

// PUBLIC

fn abs(a: f128) -> f128 {
    return Fixed128::new(a.mag, false);
}

fn add(a: f128, b: f128) -> f128 {
    if a.sign == b.sign {
        return Fixed128::new(a.mag + b.mag, a.sign);
    }

    if a.mag == b.mag {
        return Fixed128::ZERO();
    }

    if (a.mag > b.mag) {
        return Fixed128::new(a.mag - b.mag, a.sign);
    } else {
        return Fixed128::new(b.mag - a.mag, b.sign);
    }
}

fn ceil(a: f128) -> f128 {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if rem_u128 == 0 {
        return a;
    } else if !a.sign {
        return Fixed128::new_unscaled(div_u128 + 1, false);
    } else if div_u128 == 0 {
        return Fixed128::new_unscaled(0, false);
    } else {
        return Fixed128::new_unscaled(div_u128, true);
    }
}

fn div(a: f128, b: f128) -> f128 {
    let a_u256 = a.mag.wide_mul(ONE_u128);
    let b_u256 = b.mag.into();
    let res_u256 = a_u256 / b_u256;

    assert(res_u256.high == 0, 'result overflow');

    // Re-apply sign
    return Fixed128::new(res_u256.low, a.sign ^ b.sign);
}

fn eq(a: @f128, b: @f128) -> bool {
    return (*a.mag == *b.mag) && (*a.sign == *b.sign);
}

// Calculates the natural exponent of x: e^x
fn exp(a: f128) -> f128 {
    return exp2(Fixed128::new(26613026195688644984, false) * a);
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: f128) -> f128 {
    if (a.mag == 0) {
        return Fixed128::ONE();
    }

    let (int_part, frac_part) = _split_unsigned(a);
    let int_res = Fixed128::new_unscaled(lut::exp2(int_part), false);
    let mut res_u = int_res;

    if frac_part != 0 {
        let frac_fixed = Fixed128::new(frac_part, false);
        let r8 = Fixed128::new(41691949755436, false) * frac_fixed;
        let r7 = (r8 + Fixed128::new(231817862090993, false)) * frac_fixed;
        let r6 = (r7 + Fixed128::new(2911875592466782, false)) * frac_fixed;
        let r5 = (r6 + Fixed128::new(24539637786416367, false)) * frac_fixed;
        let r4 = (r5 + Fixed128::new(177449490038807528, false)) * frac_fixed;
        let r3 = (r4 + Fixed128::new(1023863119786103800, false)) * frac_fixed;
        let r2 = (r3 + Fixed128::new(4431397849999009866, false)) * frac_fixed;
        let r1 = (r2 + Fixed128::new(12786308590235521577, false)) * frac_fixed;
        res_u = res_u * (r1 + Fixed128::ONE());
    }

    if (a.sign) {
        return Fixed128::ONE() / res_u;
    } else {
        return res_u;
    }
}

fn exp2_int(exp: u128) -> f128 {
    return Fixed128::new_unscaled(lut::exp2(exp), false);
}

fn floor(a: f128) -> f128 {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if rem_u128 == 0 {
        return a;
    } else if !a.sign {
        return Fixed128::new_unscaled(div_u128, false);
    } else {
        return Fixed128::new_unscaled(div_u128 + 1, true);
    }
}

fn ge(a: f128, b: f128) -> bool {
    if a.sign != b.sign {
        return !a.sign;
    } else {
        return (a.mag == b.mag) || ((a.mag > b.mag) ^ a.sign);
    }
}

fn gt(a: f128, b: f128) -> bool {
    if a.sign != b.sign {
        return !a.sign;
    } else {
        return (a.mag != b.mag) && ((a.mag > b.mag) ^ a.sign);
    }
}

fn le(a: f128, b: f128) -> bool {
    if a.sign != b.sign {
        return a.sign;
    } else {
        return (a.mag == b.mag) || ((a.mag < b.mag) ^ a.sign);
    }
}

// Calculates the natural logarithm of x: ln(x)
// self must be greater than zero
fn ln(a: f128) -> f128 {
    return Fixed128::new(12786308645202655660, false) * log2(a); // ln(2) = 0.693...
}

// Calculates the binary logarithm of x: log2(x)
// self must be greather than zero
fn log2(a: f128) -> f128 {
    assert(!a.sign, 'must be positive');

    if (a.mag == ONE_u128) {
        return Fixed128::ZERO();
    } else if (a.mag < ONE_u128) {
        // Compute true inverse binary log if 0 < x < 1
        let div = Fixed128::ONE() / a;
        return -log2(div);
    }

    let (msb, div) = lut::msb(a.mag / ONE_u128);
    let norm = a / Fixed128::new_unscaled(div, false);

    let r8 = Fixed128::new(167660832607149504, true) * norm;
    let r7 = (r8 + Fixed128::new(2284550827067371376, false)) * norm;
    let r6 = (r7 + Fixed128::new(13804762162529339368, true)) * norm;
    let r5 = (r6 + Fixed128::new(48676798788932142400, false)) * norm;
    let r4 = (r5 + Fixed128::new(110928274989790216568, true)) * norm;
    let r3 = (r4 + Fixed128::new(171296190111888966192, false)) * norm;
    let r2 = (r3 + Fixed128::new(184599081115266689944, true)) * norm;
    let r1 = (r2 + Fixed128::new(150429590981271126408, false)) * norm;
    return r1 + Fixed128::new(63187350828072553424, true) + Fixed128::new_unscaled(msb, false);
}

// Calculates the base 10 log of x: log10(x)
// self must be greater than zero
fn log10(a: f128) -> f128 {
    return Fixed128::new(5553023288523357132, false) * log2(a); // log10(2) = 0.301...
}

fn lt(a: f128, b: f128) -> bool {
    if a.sign != b.sign {
        return a.sign;
    } else {
        return (a.mag != b.mag) && ((a.mag < b.mag) ^ a.sign);
    }
}

fn mul(a: f128, b: f128) -> f128 {
    let res_u256 = a.mag.wide_mul(b.mag);
    let (scaled_u256, _) = u256_safe_div_rem(res_u256, u256_as_non_zero(ONE_u256));

    assert(scaled_u256.high == 0, 'result overflow');

    // Re-apply sign
    return Fixed128::new(scaled_u256.low, a.sign ^ b.sign);
}

#[derive(Copy, Drop, Serde)]
struct f64 {
    mag: u64,
    sign: bool
}

fn mul_64(a: f64, b: f64) -> f64 {
    let prod_u128 = a.mag.wide_mul(b.mag);
    return f64 { mag: (prod_u128 / SQRT_ONE_u128).try_into().unwrap(), sign: a.sign ^ b.sign };
}

fn ne(a: @f128, b: @f128) -> bool {
    return (*a.mag != *b.mag) || (*a.sign != *b.sign);
}

fn neg(a: f128) -> f128 {
    if a.mag == 0 {
        return a;
    } else if !a.sign {
        return Fixed128::new(a.mag, !a.sign);
    } else {
        return Fixed128::new(a.mag, false);
    }
}

// Calclates the value of x^y and checks for overflow before returning
// self is a fixed point value
// b is a fixed point value
fn pow(a: f128, b: f128) -> f128 {
    let (_div_u128, rem_u128) = _split_unsigned(b);

    // use the more performant integer pow when y is an int
    if (rem_u128 == 0) {
        return pow_int(a, b.mag / ONE_u128, b.sign);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    return exp(b * ln(a));
}

// Calclates the value of a^b and checks for overflow before returning
fn pow_int(a: f128, b: u128, sign: bool) -> f128 {
    let mut x = a;
    let mut n = b;

    if sign {
        x = Fixed128::ONE() / x;
    }

    if n == 0 {
        return Fixed128::ONE();
    }

    let mut y = Fixed128::ONE();
    let two = integer::u128_as_non_zero(2);

    loop {
        if n <= 1 {
            break;
        }

        let (div, rem) = integer::u128_safe_divmod(n, two);

        if rem == 1 {
            y = x * y;
        }

        x = x * x;
        n = div;
    };

    return x * y;
}

fn rem(a: f128, b: f128) -> f128 {
    return a - floor(a / b) * b;
}

fn round(a: f128) -> f128 {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (HALF_u128 <= rem_u128) {
        return Fixed128::new(ONE_u128 * (div_u128 + 1), a.sign);
    } else {
        return Fixed128::new(ONE_u128 * div_u128, a.sign);
    }
}

// Calculates the square root of a fixed point value
// x must be positive
fn sqrt(a: f128) -> f128 {
    assert(!a.sign, 'must be positive');
    let res_u128 = a.mag.sqrt().into() * ONE_u128 / SQRT_ONE_u128;
    return Fixed128::new(res_u128, false);
}

fn sub(a: f128, b: f128) -> f128 {
    return add(a, -b);
}

// Ignores sign and always returns false
fn _split_unsigned(a: f128) -> (u128, u128) {
    return integer::u128_safe_divmod(a.mag, integer::u128_as_non_zero(ONE_u128));
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use cubit::f128::test::helpers::assert_precise;
    use cubit::f128::types::fixed::{ONE, HALF};

    use cubit::f128::math::trig::HALF_PI_u128;
    use cubit::f128::math::trig::PI_u128;

    use super::{Fixed128, ONE_u128, lut, exp2_int};

    #[test]
    fn test_into() {
        let a = Fixed128::from_unscaled_felt(5);
        assert(a.into() == 5 * ONE, 'invalid result');
    }

    #[test]
    fn test_try_into_u128() {
        // Positive unscaled
        let a = Fixed128::new_unscaled(5, false);
        assert(a.try_into().unwrap() == 5_u128, 'invalid result');

        // Positive scaled
        let b = Fixed128::new(5 * ONE_u128, false);
        assert(b.try_into().unwrap() == 5_u128, 'invalid result');

        let c = Fixed128::new(PI_u128, false);
        assert(c.try_into().unwrap() == 3_u128, 'invalid result');

        // Zero
        let d = Fixed128::new_unscaled(0, false);
        assert(d.try_into().unwrap() == 0_u128, 'invalid result');
    }

    #[test]
    #[should_panic]
    fn test_negative_try_into_u128() {
        let a = Fixed128::new_unscaled(1, true);
        let _a: u128 = a.try_into().unwrap();
    }

    #[test]
    #[should_panic]
    fn test_overflow_large() {
        let too_large = 0x100000000000000000000000000000000;
        Fixed128::from_felt(too_large);
    }

    #[test]
    #[should_panic]
    fn test_overflow_small() {
        let too_small = -0x100000000000000000000000000000000;
        Fixed128::from_felt(too_small);
    }

    #[test]
    #[available_gas(1000000)]
    fn test_acos() {
        let a = Fixed128::ONE();
        assert(a.acos().into() == 0, 'invalid one');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_asin() {
        let a = Fixed128::ONE();
        assert(a.asin().into() == 28976077832308491370, 'invalid one'); // PI / 2
    }

    #[test]
    #[available_gas(2000000)]
    fn test_atan() {
        let a = Fixed128::new(2 * ONE_u128, false);

        // use `DEFAULT_PRECISION`
        assert_precise(a.atan(), 20423289048683266000, 'invalid two', Option::None(()));

        // use `custom_precision`
        assert_precise(
            a.atan(), 20423289048683266000, 'invalid two', Option::Some(184467440737)
        ); // 1e-8
    }

    #[test]
    fn test_ceil() {
        let a = Fixed128::from_felt(53495557813757699680); // 2.9
        assert(a.ceil().into() == 3 * ONE, 'invalid pos decimal');
    }

    #[test]
    fn test_floor() {
        let a = Fixed128::from_felt(53495557813757699680); // 2.9
        assert(a.floor().into() == 2 * ONE, 'invalid pos decimal');
    }

    #[test]
    fn test_round() {
        let a = Fixed128::from_felt(53495557813757699680); // 2.9
        assert(a.round().into() == 3 * ONE, 'invalid pos decimal');
    }

    #[test]
    #[should_panic]
    fn test_sqrt_fail() {
        let a = Fixed128::from_unscaled_felt(-25);
        a.sqrt();
    }

    #[test]
    fn test_sqrt() {
        let a = Fixed128::from_unscaled_felt(0);
        assert(a.sqrt().into() == 0, 'invalid zero root');
    }

    #[test]
    #[available_gas(100000)]
    fn test_msb() {
        let a = Fixed128::new_unscaled(4503599627370495, false);
        let (msb, div) = lut::msb(a.mag / ONE_u128);
        assert(msb == 51, 'invalid msb');
        assert(div == 2251799813685248, 'invalid msb ceil');
    }

    #[test]
    #[available_gas(600000)] // 260k
    fn test_pow() {
        let a = Fixed128::new_unscaled(3, false);
        let b = Fixed128::new_unscaled(4, false);
        assert(a.pow(b).into() == 81 * ONE, 'invalid pos base power');
    }

    #[test]
    #[available_gas(900000)] // 550k
    fn test_pow_frac() {
        let a = Fixed128::new_unscaled(3, false);
        let b = Fixed128::new(9223372036854775808, false); // 0.5
        assert_precise(
            a.pow(b), 31950697969885030000, 'invalid pos base power', Option::None(())
        ); // 1.7320508075688772
    }

    #[test]
    #[available_gas(1000000)] // 267k
    fn test_exp() {
        let a = Fixed128::new_unscaled(2, false);
        assert(a.exp().into() == 136304026800730572984, 'invalid exp of 2'); // 7.389056098793725
    }

    #[test]
    #[available_gas(400000)]
    fn test_exp2() {
        let a = Fixed128::new_unscaled(24, false);
        assert(a.exp2().into() == 309485009821345068724781056, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(20000)]
    fn test_exp2_int() {
        assert(exp2_int(24).into() == 309485009821345068724781056, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_ln() {
        let a = Fixed128::from_unscaled_felt(1);
        assert(a.ln().into() == 0, 'invalid ln of 1');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log2() {
        let a = Fixed128::from_unscaled_felt(32);
        assert_precise(a.log2(), 5 * ONE, 'invalid log2 32', Option::None(()));
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log10() {
        let a = Fixed128::from_unscaled_felt(100);
        assert_precise(a.log10(), 2 * ONE, 'invalid log10', Option::None(()));
    }

    #[test]
    fn test_eq() {
        let a = Fixed128::from_unscaled_felt(42);
        let b = Fixed128::from_unscaled_felt(42);
        let c = a == b;
        assert(c, 'invalid result');
    }

    #[test]
    fn test_ne() {
        let a = Fixed128::from_unscaled_felt(42);
        let b = Fixed128::from_unscaled_felt(42);
        let c = a != b;
        assert(!c, 'invalid result');
    }

    #[test]
    fn test_add() {
        let a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(2);
        assert(a + b == Fixed128::from_unscaled_felt(3), 'invalid result');
    }

    #[test]
    fn test_add_eq() {
        let mut a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(2);
        a += b;
        assert(a.into() == 3 * ONE, 'invalid result');
    }

    #[test]
    fn test_sub() {
        let a = Fixed128::from_unscaled_felt(5);
        let b = Fixed128::from_unscaled_felt(2);
        let c = a - b;
        assert(c.into() == 3 * ONE, 'false result invalid');
    }

    #[test]
    fn test_sub_eq() {
        let mut a = Fixed128::from_unscaled_felt(5);
        let b = Fixed128::from_unscaled_felt(2);
        a -= b;
        assert(a.into() == 3 * ONE, 'invalid result');
    }

    #[test]
    #[available_gas(100000)] // 22k
    fn test_mul_pos() {
        let a = Fixed128::new(53495557813757699680, false); // 2.9
        let b = Fixed128::new(53495557813757699680, false); // 2.9
        let c = a * b;
        assert(c.into() == 155137117659897329053, 'invalid result');
    }

    #[test]
    fn test_mul_neg() {
        let a = Fixed128::from_unscaled_felt(5);
        let b = Fixed128::from_unscaled_felt(-2);
        let c = a * b;
        assert(c.into() == -10 * ONE, 'true result invalid');
    }

    #[test]
    fn test_mul_eq() {
        let mut a = Fixed128::from_unscaled_felt(5);
        let b = Fixed128::from_unscaled_felt(-2);
        a *= b;
        assert(a.into() == -10 * ONE, 'invalid result');
    }

    #[test]
    fn test_div() {
        let a = Fixed128::from_unscaled_felt(10);
        let b = Fixed128::from_felt(53495557813757699680); // 2.9
        let c = a / b;
        assert(c.into() == 63609462323136384890, 'invalid pos decimal'); // 3.4482758620689653
    }

    #[test]
    fn test_le() {
        let a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(0);
        let c = Fixed128::from_unscaled_felt(-1);

        assert(a <= a, 'a <= a');
        assert(!(a <= b), 'a <= b');
        assert(!(a <= c), 'a <= c');

        assert(b <= a, 'b <= a');
        assert(b <= b, 'b <= b');
        assert(!(b <= c), 'b <= c');

        assert(c <= a, 'c <= a');
        assert(c <= b, 'c <= b');
        assert(c <= c, 'c <= c');
    }

    #[test]
    fn test_lt() {
        let a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(0);
        let c = Fixed128::from_unscaled_felt(-1);

        assert(!(a < a), 'a < a');
        assert(!(a < b), 'a < b');
        assert(!(a < c), 'a < c');

        assert(b < a, 'b < a');
        assert(!(b < b), 'b < b');
        assert(!(b < c), 'b < c');

        assert(c < a, 'c < a');
        assert(c < b, 'c < b');
        assert(!(c < c), 'c < c');
    }

    #[test]
    fn test_ge() {
        let a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(0);
        let c = Fixed128::from_unscaled_felt(-1);

        assert(a >= a, 'a >= a');
        assert(a >= b, 'a >= b');
        assert(a >= c, 'a >= c');

        assert(!(b >= a), 'b >= a');
        assert(b >= b, 'b >= b');
        assert(b >= c, 'b >= c');

        assert(!(c >= a), 'c >= a');
        assert(!(c >= b), 'c >= b');
        assert(c >= c, 'c >= c');
    }

    #[test]
    fn test_gt() {
        let a = Fixed128::from_unscaled_felt(1);
        let b = Fixed128::from_unscaled_felt(0);
        let c = Fixed128::from_unscaled_felt(-1);

        assert(!(a > a), 'a > a');
        assert(a > b, 'a > b');
        assert(a > c, 'a > c');

        assert(!(b > a), 'b > a');
        assert(!(b > b), 'b > b');
        assert(b > c, 'b > c');

        assert(!(c > a), 'c > a');
        assert(!(c > b), 'c > b');
        assert(!(c > c), 'c > c');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_cos() {
        let a = Fixed128::new(HALF_PI_u128, false);
        assert(a.cos().into() == 0, 'invalid half pi');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sin() {
        let a = Fixed128::new(HALF_PI_u128, false);
        assert_precise(a.sin(), ONE, 'invalid half pi', Option::None(()));
    }

    #[test]
    #[available_gas(2000000)]
    fn test_tan() {
        let a = Fixed128::new(HALF_PI_u128 / 2, false);
        assert(a.tan().into() == ONE, 'invalid quarter pi');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_cosh() {
        let a = Fixed128::new_unscaled(2, false);
        assert_precise(
            a.cosh(), 69400261068632590000, 'invalid two', Option::None(())
        ); // 3.762195691016423
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sinh() {
        let a = Fixed128::new_unscaled(2, false);
        assert_precise(
            a.sinh(), 66903765734623805000, 'invalid two', Option::None(())
        ); // 3.6268604077773023
    }

    #[test]
    #[available_gas(1000000)]
    fn test_tanh() {
        let a = Fixed128::new_unscaled(2, false);
        assert_precise(
            a.tanh(), 17783170049656136000, 'invalid two', Option::None(())
        ); // 0.9640275800745076
    }

    #[test]
    #[available_gas(1000000)]
    fn test_acosh() {
        let a = Fixed128::new(69400261067392811864, false); // 3.762195691016423
        assert_precise(a.acosh(), 2 * ONE, 'invalid two', Option::None(()));
    }

    #[test]
    #[available_gas(1000000)]
    fn test_asinh() {
        let a = Fixed128::new(66903765733337761105, false); // 3.6268604077773023
        assert_precise(a.asinh(), 2 * ONE, 'invalid two', Option::None(()));
    }

    #[test]
    #[available_gas(1000000)]
    fn test_atanh() {
        let a = Fixed128::new(16602069666338597000, false); // 0.9
        assert_precise(
            a.atanh(), 27157656144668970000, 'invalid 0.9', Option::None(())
        ); // 1.4722194895832204
    }
}


use core::num::traits::WideMul;
use fixed::types::fixed::Fixed;

pub impl FixedMul<
    Mag,
    const ONE_MAG: Mag,
    +WideMul<Mag, Mag>,
    +Drop<Mag>,
    +Drop<WideMul::<Mag, Mag>::Target>,
    +Into<Mag, WideMul::<Mag, Mag>::Target>,
    +TryInto<WideMul::<Mag, Mag>::Target, Mag>,
    +Div<WideMul::<Mag, Mag>::Target>,
> of Mul<Fixed<Mag>> {
    fn mul(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        let mag: Mag = match (lhs.mag.wide_mul(rhs.mag) / ONE_MAG.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        };
        Fixed { mag, sign: lhs.sign != rhs.sign }
    }
}

pub impl FixedDiv<
    Mag,
    const ONE_MAG: Mag,
    +WideMul<Mag, Mag>,
    +Drop<Mag>,
    +Drop<WideMul::<Mag, Mag>::Target>,
    +Into<Mag, WideMul::<Mag, Mag>::Target>,
    +TryInto<WideMul::<Mag, Mag>::Target, Mag>,
    +Div<WideMul::<Mag, Mag>::Target>,
> of Div<Fixed<Mag>> {
    fn div(lhs: Fixed<Mag>, rhs: Fixed<Mag>) -> Fixed<Mag> {
        let mag = match (lhs.mag.wide_mul(ONE_MAG) / rhs.mag.into()).try_into() {
            Option::Some(mag) => mag,
            Option::None => panic!("Overflow error"),
        };
        Fixed { mag, sign: lhs.sign != rhs.sign }
    }
}

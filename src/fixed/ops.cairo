use core::num::traits::Zero;

use fixed::fixed::consts::FixedConstsTrait;
use fixed::fixed::types::{Fixed, FixedMagMul, FixedMagDiv};
use fixed::fixed::traits::LutTrait;

trait FixedOpsConsts<Mag> {
    const LN_FACTOR: Mag;
    const LOG10_FACTOR: Mag;
    const EXP_FACTOR: Mag;
    const LOG2_TS_FACTORS: [Mag; 8];
    const EXP2_TS_FACTORS: [Mag; 8];
}

pub trait FixedMagOpsTrait<Mag> {
    fn mag_log2(self: Mag) -> Mag;
    fn mag_inverse(self: Mag) -> Mag;
}


impl FixedMagOpsImpl<
    Mag,
    const ONE_MAG: Mag,
    const LOG2_TS_FACTORS: [Mag; 9],
    const EXP2_TS_FACTORS: [Mag; 9],
    +LutTrait<Mag>,
    +FixedMagDiv<Mag>,
    +Mul<Fixed<Mag>>,
    +Add<Fixed<Mag>>,
    +Add<Mag>,
    +Sub<Mag>,
    +Mul<Mag>,
    +Div<Mag>,
    +Drop<Mag>,
    +Copy<Mag>,
> of FixedMagOpsTrait<Mag> {
    fn mag_log2(self: Mag) -> Mag {
        let (msb, div) = self.lut_msb();
        let norm = Fixed { mag: self / div, sign: false };

        let [f0, f1, f2, f3, f4, f5, f6, f7, f8] = LOG2_TS_FACTORS;
        let r8 = norm * Fixed { mag: f8, sign: true };
        let r7 = (r8 + Fixed { mag: f7, sign: false }) * norm;
        let r6 = (r7 + Fixed { mag: f6, sign: true }) * norm;
        let r5 = (r6 + Fixed { mag: f5, sign: false }) * norm;
        let r4 = (r5 + Fixed { mag: f4, sign: true }) * norm;
        let r3 = (r4 + Fixed { mag: f3, sign: false }) * norm;
        let r2 = (r3 + Fixed { mag: f2, sign: true }) * norm;
        let r1 = (r2 + Fixed { mag: f1, sign: false }) * norm;
        let Fixed { mag, sign } = r1;
        if sign {
            msb * ONE_MAG - mag - f0
        } else {
            msb * ONE_MAG + mag - f0
        }
    }
    fn mag_inverse(self: Mag) -> Mag {
        ONE_MAG.fixed_mag_div(self)
    }
}

use core::num::traits::{WideMul, Sqrt};


use fixed::types::fixed::Fixed;
use fixed::types::vec::Vec4;
use fixed::traits::fixed::FixedTrait;
use fixed::traits::consts::FixedConstsTrait;
use fixed::traits::vec::VecTrait;

impl Vec4Impl<
    Mag,
    +Copy<Mag>,
    +Drop<Fixed<Mag>>,
    +Add<Fixed<Mag>>,
    +Mul<Fixed<Mag>>,
    +Sqrt<Fixed<Mag>>,
    +Into<Sqrt::<Fixed<Mag>>::Target, Fixed<Mag>>,
> of VecTrait<Vec4<Mag>> {
    type Fixed = Fixed<Mag>;

    fn splat(v: Fixed<Mag>) -> Vec4<Mag> {
        Vec4 { x: v, y: v, z: v, w: v }
    }

    fn abs(self: @Vec4<Mag>) -> Vec4<Mag> {
        Vec4 {
            x: Fixed { mag: *self.x.mag, sign: false },
            y: Fixed { mag: *self.y.mag, sign: false },
            z: Fixed { mag: *self.z.mag, sign: false },
            w: Fixed { mag: *self.z.mag, sign: false },
        }
    }

    fn dot(self: @Vec4<Mag>, rhs: Vec4<Mag>) -> Fixed<Mag> {
        *self.x * rhs.x + *self.y * rhs.y + *self.z * rhs.z + *self.w * rhs.w
    }
    fn norm(self: @Vec4<Mag>) -> Fixed<Mag> {
        Self::dot(self, *self).sqrt().into()
    }
}

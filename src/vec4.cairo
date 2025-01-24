use core::num::traits::{WideMul, Sqrt};

use fixed::fixed::types::{Fixed, FixedDrop};
use fixed::fixed::traits::FixedTrait;
use fixed::vec::traits::VecTrait;

#[derive(Copy, Drop)]
struct Vec4<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
    z: Fixed<Mag>,
    w: Fixed<Mag>,
}

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

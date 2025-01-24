use core::num::traits::{WideMul, Sqrt};

use fixed::fixed::types::{Fixed, FixedDrop};
use fixed::fixed::traits::FixedTrait;
use fixed::vec::traits::VecTrait;

#[derive(Copy, Drop)]
struct Vec3<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
    z: Fixed<Mag>,
}

impl Vec3Impl<
    Mag,
    +Copy<Mag>,
    +Drop<Fixed<Mag>>,
    +Add<Fixed<Mag>>,
    +Mul<Fixed<Mag>>,
    +Sqrt<Fixed<Mag>>,
    +Into<Sqrt::<Fixed<Mag>>::Target, Fixed<Mag>>,
> of VecTrait<Vec3<Mag>> {
    type Fixed = Fixed<Mag>;

    fn splat(v: Fixed<Mag>) -> Vec3<Mag> {
        Vec3 { x: v, y: v, z: v }
    }

    fn abs(self: @Vec3<Mag>) -> Vec3<Mag> {
        Vec3 {
            x: Fixed { mag: *self.x.mag, sign: false },
            y: Fixed { mag: *self.y.mag, sign: false },
            z: Fixed { mag: *self.z.mag, sign: false },
        }
    }

    fn dot(self: @Vec3<Mag>, rhs: Vec3<Mag>) -> Fixed<Mag> {
        *self.x * rhs.x + *self.y * rhs.y + *self.z * rhs.z
    }
    fn norm(self: @Vec3<Mag>) -> Fixed<Mag> {
        Self::dot(self, *self).sqrt().into()
    }
}

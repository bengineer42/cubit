use core::num::traits::{WideMul, Sqrt};

use fixed::fixed::types::{Fixed, FixedDrop};
use fixed::fixed::traits::FixedTrait;
use fixed::vec::traits::VecTrait;

#[derive(Copy, Drop)]
struct Vec2<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
}

impl Vec2Impl<
    Mag,
    +Copy<Mag>,
    +Drop<Fixed<Mag>>,
    +Add<Fixed<Mag>>,
    +Mul<Fixed<Mag>>,
    +Sqrt<Fixed<Mag>>,
    +Into<Sqrt::<Fixed<Mag>>::Target, Fixed<Mag>>,
> of VecTrait<Vec2<Mag>> {
    type Fixed = Fixed<Mag>;

    fn splat(v: Fixed<Mag>) -> Vec2<Mag> {
        Vec2 { x: v, y: v }
    }

    fn abs(self: @Vec2<Mag>) -> Vec2<Mag> {
        Vec2 {
            x: Fixed { mag: *self.x.mag, sign: false }, y: Fixed { mag: *self.y.mag, sign: false },
        }
    }

    fn dot(self: @Vec2<Mag>, rhs: Vec2<Mag>) -> Fixed<Mag> {
        *self.x * rhs.x + *self.y * rhs.y
    }
    fn norm(self: @Vec2<Mag>) -> Fixed<Mag> {
        Self::dot(self, *self).sqrt().into()
    }
}

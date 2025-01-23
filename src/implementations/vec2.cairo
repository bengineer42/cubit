use core::num::traits::{WideMul, Sqrt};


use fixed::types::fixed::Fixed;
use fixed::types::vec::Vec2;
use fixed::traits::fixed::FixedTrait;
use fixed::traits::consts::FixedConstsTrait;
use fixed::traits::vec::VecTrait;

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

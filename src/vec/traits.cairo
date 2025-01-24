use core::num::traits::{WideMul, Sqrt};
use fixed::fixed::types::Fixed;

trait VecTrait<Vec> {
    type Fixed;
    fn splat(v: Self::Fixed) -> Vec;
    // Math
    fn abs(self: @Vec) -> Vec;
    fn dot(self: @Vec, rhs: Vec) -> Self::Fixed;
    fn norm(self: @Vec) -> Self::Fixed;
}

mod math;
mod procgen;
mod test;
mod types;

use types::fixed::{f128, Fixed128, FixedPrint, ONE_u128, ONE};
use types::vec2::{Vec2, Vec2Trait, Vec2Print};
use types::vec3::{Vec3, Vec3Trait, Vec3Print};
use types::vec4::{Vec4, Vec4Trait, Vec4Print};

use math::{comp, ops, hyp, trig};
use procgen::{rand, simplex3};

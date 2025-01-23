pub mod traits {
    pub mod arith;
    pub mod fixed;
    pub mod consts;
    pub mod vec;
    pub mod num;
    pub use fixed::FixedTrait;
}
pub mod types {
    pub mod fixed;
    pub mod vec;
}
pub mod implementations {
    mod fp64x64;
    mod fp32x32;
    mod vec2;
    mod vec3;
    mod vec4;
}
pub use implementations::{fp64x64, fp32x32};
pub mod utils;

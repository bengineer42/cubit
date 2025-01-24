pub mod fixed {
    pub mod traits;
    pub mod types;
    pub mod implementations;
    pub mod consts;
    pub mod fixed;
    pub mod ops;
}

pub mod fp64x64 {
    pub mod types;
    pub mod lut;
    pub use types::{FP64X64, fp64x64};
}

pub mod fp32x32 {
    pub mod types;
    pub mod lut;
    pub use types::{FP32X32, fp32x32};
}

pub mod vec {
    pub mod traits;
    pub mod types;
}

pub mod vec2;
pub mod vec3;
pub mod vec4;

pub mod utils;

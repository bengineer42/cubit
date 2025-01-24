pub mod fixed {
    pub mod traits;
    pub mod types;
    pub mod implementations;
    pub mod consts;
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

pub mod vec2 {
    pub mod implementations;
}
pub mod utils;

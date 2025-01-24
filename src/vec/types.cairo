use fixed::fixed::types::{Fixed};

#[derive(Copy, Drop)]
struct Vec2<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
}

#[derive(Copy, Drop)]
struct Vec3<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
    z: Fixed<Mag>,
}

#[derive(Copy, Drop)]
struct Vec4<Mag> {
    x: Fixed<Mag>,
    y: Fixed<Mag>,
    z: Fixed<Mag>,
    w: Fixed<Mag>,
}


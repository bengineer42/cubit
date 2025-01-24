pub impl FixedImpl<
    Mag,
    const EXP_MAG: Mag,
    const EXP2_RS: [Mag; 8],
    impl Consts: FixedConstsTrait<Mag>,
    +LutTrait<Mag>,
    +Mul<Fixed<Mag>>,
    +Div<Fixed<Mag>>,
    +FixedSqrtTrait<Mag>,
    +Add<Fixed<Mag>>,
    +Sub<Fixed<Mag>>,
    +PartialEq<Mag>,
    +PartialOrd<Mag>,
    +Zero<Mag>,
    +One<Mag>,
    +TryInto<Mag, NonZero<Mag>>,
    +Into<Mag, u256>,
    +Into<Mag, felt252>,
    +TryInto<u256, Mag>,
    +TryInto<felt252, Mag>,
    +Add<Mag>,
    +Sub<Mag>,
    +Mul<Mag>,
    +Div<Mag>,
    +DivRem<Mag>,
    +FixedMagMul<Mag>,
    +WideMul<Mag, Mag>,
> of FixedTrait{
    // Constructors
    fn new(mag: Mag, sign: bool) -> Fixed<Mag> {
        Fixed { mag, sign }
    }
    fn new_unscaled(
        mag: Mag, sign: bool,
    ) -> Fixed<Mag> {
        Fixed { mag: mag * Consts::ONE_MAG, sign }
    }
    fn from_felt(
        val: felt252,
    ) -> Fixed<Mag> {
        Self::new(felt_abs(val).try_into().unwrap(), felt_sign(val))
    }
    fn from_unscaled_felt(
        val: felt252,
    ) -> Fixed<Mag> {
        Self::from_felt(val * Consts::ONE_MAG.into())
    }
    fn from_decimal(
        val: u256, places: u8,
    ) -> Fixed<
        Mag,
    > {
        let mut pow: u8 = 1;
        for _ in 0..places {
            pow *= 10;
        };
        let mag = (val * Consts::ONE_MAG.into() / pow.into()).try_into().unwrap();
        Fixed { mag, sign: false }
    }

    // Casters
    fn to_decimal(
        self: @Fixed<Mag>, places: u8,
    ) -> u256 {
        assert(!*self.sign, 'Negative value');
        let mut value: u256 = (*self.mag).into();
        for _ in 0..places {
            value *= 10;
        };
        value / Consts::ONE_MAG.into()
    }
    fn split(
        self: @Fixed<Mag>,
    ) -> (Mag, Mag) {
        DivRem::div_rem(*self.mag, Consts::ONE_MAG.try_into().unwrap())
    }

    // // Math
    fn abs(self: @Fixed<Mag>) -> Fixed<Mag> {
        Fixed { mag: *self.mag, sign: false }
    }
    fn ceil(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            *self
        } else if *self.sign {
            Fixed { mag: div, sign: true }
        } else {
            Fixed { mag: div + Consts::ONE_MAG, sign: false }
        }
    }
    fn exp(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        Self::exp2(@Fixed { mag: (*self.mag).fixed_mag_mul(EXP_MAG), sign: *self.sign })
    }
    fn exp2(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        if (self.mag == 0) {
            return Consts::ONE;
        }

        let (int_part, frac_part) = Self::split(self);

        // let int_res = Fixed128::new_unscaled(lut::exp2(int_part), false);
        let mut res_u = int_part.lut_exp2();
        if frac_part != 0 {
            let [r1f, r2f, r3f, r4f, r5f, r6f, r7f, r8f] = EXP2_RS;

            let r8 = frac_part.fixed_mag_mul(r8f);
            let r7 = (r8 + r7f).fixed_mag_mul(frac_part);
            let r6 = (r7 + r6f).fixed_mag_mul(frac_part);
            let r5 = (r6 + r5f).fixed_mag_mul(frac_part);
            let r4 = (r5 + r4f).fixed_mag_mul(frac_part);
            let r3 = (r4 + r3f).fixed_mag_mul(frac_part);
            let r2 = (r3 + r2f).fixed_mag_mul(frac_part);
            let r1 = (r2 + r1f).fixed_mag_mul(frac_part);

            res_u = res_u * (r1 + Fixed128::ONE());
        }

        if (a.sign) {
            return Consts::ONE_MAG.wide_mul(res_u);
        } else {
            return res_u;
        }
    }
    fn floor(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        if rem.is_zero() {
            *self
        } else if *self.sign {
            Fixed { mag: div + Consts::ONE_MAG, sign: true }
        } else {
            Fixed { mag: div, sign: false }
        }
    }
    fn ln(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn log2(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn log10(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn pow(self: @Fixed<Mag>, b: Fixed<Mag>) -> Fixed<Mag>;
    fn round(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let (div, rem) = Self::split(self);
        let mag = div + match rem >= Consts::HALF_MAG {
            true => One::one(),
            false => Zero::zero(),
        };
        Self::new_unscaled(mag, *self.sign)
    }

    // Trigonometry
    fn acos(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = Self::asin(@((Consts::ONE - val * val).fixed_sqrt()));
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn acos_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = Self::asin_fast(@((Consts::ONE - val * val).fixed_sqrt()));
        match self.sign {
            true => Consts::PI - root,
            false => root,
        }
    }
    fn asin(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan(@((Consts::ONE - val * val).fixed_sqrt())),
        }
    }
    fn asin_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        assert(val.mag <= Consts::ONE_MAG, 'asin: out of range');
        match val.mag == Consts::ONE_MAG {
            true => Fixed { mag: Consts::HALF_PI_MAG, sign: val.sign },
            false => Self::atan_fast(@((Consts::ONE - val * val).fixed_sqrt())),
        }
    }
    fn atan(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn atan_fast(self: @Fixed<Mag>) -> Fixed<Mag>;
    fn cos(self: @Fixed<Mag>) -> Fixed<Mag> {
        Self::sin(@(Consts::HALF_PI - *self))
    }
    fn cos_fast(self: @Fixed<Mag>) -> Fixed<Mag> {
        Self::sin_fast(@(Consts::HALF_PI - *self))
    }
    fn sin(self: @Fixed<Mag>) -> Fixed<Mag>; //
    fn sin_fast(self: @Fixed<Mag>) -> Fixed<Mag>; //
    fn tan(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin(self) / cos
    }
    fn tan_fast(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let cos = Self::cos_fast(self);
        assert(cos.mag != Zero::zero(), 'tan undefined');
        Self::sin_fast(self) / cos
    }

    // Hyperbolic
    fn acosh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = (val * val - Consts::ONE).fixed_sqrt();
        Self::ln(@(val + root))
    }
    fn asinh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let root = (val * val + Consts::ONE).fixed_sqrt();
        Self::ln(@(val + root))
    }
    fn atanh(
        self: @Fixed<Mag>,
    ) -> Fixed<
        Mag,
    > {
        let val = *self;
        let ln_val = (Consts::ONE + val) / (Consts::ONE - val);
        Self::ln(@(ln_val)) / Consts::TWO
    }
    fn cosh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea + (Consts::ONE / ea)) / Consts::TWO
    }
    fn sinh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        (ea - (Consts::ONE / ea)) / Consts::TWO
    }
    fn tanh(
        self: @Fixed<Mag>,
    ) -> Fixed<Mag> {
        let ea = Self::exp(self);
        let iea = Consts::ONE / ea;
        (ea - iea) / (ea + iea)
    }
}

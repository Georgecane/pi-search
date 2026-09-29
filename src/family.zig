const Rational = @import("rational.zig").Rational;

pub const max_factors = 6;

pub const FamilyKind = enum {
    hypergeometric_3f2,
    inverse_binomial,
    central_binomial,
    factorial_ratio,
    balanced_product,
    generated_product,
};

pub const LinearFactor = struct {
    a: Rational,
    b: Rational,

    pub fn value(self: LinearFactor, x: f64) f64 {
        return self.a.value() * x + self.b.value();
    }
};

pub const Family = struct {
    name: []const u8,
    kind: FamilyKind,
    s: Rational,
    t: Rational,
    q: f64,
    description: []const u8,

    // Term polynomial P(n) = prefactor_a + prefactor_b*n.
    // The overall scale is handled separately by the K search, so
    // the generator normally fixes prefactor_a = 1.
    prefactor_a: f64 = 1.0,
    prefactor_b: f64 = 0.0,

    numerator: [max_factors]LinearFactor = undefined,
    denominator: [max_factors]LinearFactor = undefined,
    numerator_count: usize = 0,
    denominator_count: usize = 0,

    pub fn ratio(self: Family, n: usize) f64 {
        const x = @as(f64, @floatFromInt(n));

        if (self.kind == .generated_product) {
            var num: f64 = 1.0;
            var den: f64 = 1.0;

            for (self.numerator[0..self.numerator_count]) |factor| {
                num *= factor.value(x);
            }

            for (self.denominator[0..self.denominator_count]) |factor| {
                den *= factor.value(x);
            }

            return num / den;
        }

        const s = self.s.value();
        const t = self.t.value();

        return switch (self.kind) {
            .hypergeometric_3f2 =>
                ((x - 0.5) * (x - 1.0 + s) * (x - s)) /
                (x * x * x),

            .inverse_binomial =>
                ((x - 1.0 + s) * (x - s)) /
                (x * (2.0 * x - 1.0 + t)),

            .central_binomial =>
                ((2.0 * x - 1.0 + s) * (2.0 * x + t)) /
                (x * x * 4.0),

            .factorial_ratio =>
                ((2.0 * x - 1.0 + s) * (2.0 * x + t)) /
                (x * (x + s) * 4.0),

            .balanced_product =>
                ((x - 0.5 + s) * (x - 0.5 - s) * (x - 1.0 + t)) /
                (x * x * x),

            .generated_product => unreachable,
        };
    }

    pub fn termValue(self: Family, n: usize, base_term: f64) f64 {
        const x = @as(f64, @floatFromInt(n));
        return base_term * (self.prefactor_a + self.prefactor_b * x);
    }

    pub fn termRatio(self: Family, n: usize) f64 {
        const previous = @as(f64, @floatFromInt(n - 1));
        const current = @as(f64, @floatFromInt(n));

        const polynomial_ratio =
            (self.prefactor_a + self.prefactor_b * current) /
            (self.prefactor_a + self.prefactor_b * previous);

        return self.q * self.ratio(n) * polynomial_ratio;
    }

    pub fn withFactors(
        name: []const u8,
        q: f64,
        numerator: []const LinearFactor,
        denominator: []const LinearFactor,
    ) Family {
        var result = Family{
            .name = name,
            .kind = .generated_product,
            .s = Rational.init(0, 1),
            .t = Rational.init(0, 1),
            .q = q,
            .description = "Generated rational-product formula.",
        };

        result.numerator_count = @min(numerator.len, max_factors);
        result.denominator_count = @min(denominator.len, max_factors);

        @memcpy(result.numerator[0..result.numerator_count], numerator[0..result.numerator_count]);
        @memcpy(result.denominator[0..result.denominator_count], denominator[0..result.denominator_count]);

        return result;
    }
};

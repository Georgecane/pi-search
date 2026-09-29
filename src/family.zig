const Rational = @import("rational.zig").Rational;

pub const FamilyKind = enum {
    hypergeometric_3f2,
    inverse_binomial,
    central_binomial,
    factorial_ratio,
    balanced_product,
};

pub const Family = struct {
    name: []const u8,
    kind: FamilyKind,
    s: Rational,
    t: Rational,
    q: f64,
    description: []const u8,

    pub fn ratio(self: Family, n: usize) f64 {
        const x = @as(f64, @floatFromInt(n));
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
        };
    }

    pub fn termRatio(self: Family, n: usize) f64 {
        return self.q * self.ratio(n);
    }
};

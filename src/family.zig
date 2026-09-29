const Rational = @import("rational.zig").Rational;

pub const FamilyKind = enum {
    exploratory,
    certified_reference,
};

pub const Family = struct {
    name: []const u8,
    s: Rational,
    q: f64,
    kind: FamilyKind,
    description: []const u8,

    pub fn ratio(self: Family, n: usize) f64 {
        const x = @as(f64, @floatFromInt(n));
        const s = self.s.value();

        return ((x - 0.5) *
            (x - 1.0 + s) *
            (x - s)) / (x * x * x);
    }

    pub fn termRatio(self: Family, n: usize) f64 {
        return self.q * self.ratio(n);
    }
};

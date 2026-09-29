const std = @import("std");

pub const Rational = struct {
    num: i64,
    den: i64,

    pub fn init(num: i64, den: i64) Rational {
        std.debug.assert(den != 0);

        var n = num;
        var d = den;

        if (d < 0) {
            n = -n;
            d = -d;
        }

        const g = gcd(abs(n), d);

        return .{
            .num = @divExact(n, g),
            .den = @divExact(d, g),
        };
    }

    pub fn value(self: Rational) f64 {
        return @as(f64, @floatFromInt(self.num)) /
            @as(f64, @floatFromInt(self.den));
    }
};

fn abs(x: i64) i64 {
    return if (x < 0) -x else x;
}

fn gcd(a0: i64, b0: i64) i64 {
    var a = a0;
    var b = b0;

    while (b != 0) {
        const r = @mod(a, b);
        a = b;
        b = r;
    }

    return if (a == 0) 1 else a;
}

test "rational normalization" {
    const r = Rational.init(6, -8);
    try std.testing.expectEqual(@as(i64, -3), r.num);
    try std.testing.expectEqual(@as(i64, 4), r.den);
}

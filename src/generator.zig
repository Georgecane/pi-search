const Rational = @import("rational.zig").Rational;
const family = @import("family.zig");

const Family = family.Family;
const FamilyKind = family.FamilyKind;
const LinearFactor = family.LinearFactor;

const KindInfo = struct {
    kind: FamilyKind,
    name: []const u8,
    description: []const u8,
};

pub const GeneratorConfig = struct {
    s_values: []const Rational,
    t_values: []const Rational,
    q_exponents: []const i32,
    slope_values: []const Rational = &[_]Rational{},
    offset_values: []const Rational = &[_]Rational{},
};

pub const Generator = struct {
    config: GeneratorConfig,

    pub fn generate(self: Generator, out: []Family) usize {
        const kinds = [_]KindInfo{
            .{ .kind = .hypergeometric_3f2, .name = "3F2", .description = "Hypergeometric 3F2-type recurrence." },
            .{ .kind = .inverse_binomial, .name = "inverse-binomial", .description = "Inverse-binomial-type recurrence." },
            .{ .kind = .central_binomial, .name = "central-binomial", .description = "Central-binomial-type recurrence." },
            .{ .kind = .factorial_ratio, .name = "factorial-ratio", .description = "Factorial-ratio-type recurrence." },
            .{ .kind = .balanced_product, .name = "balanced-product", .description = "Balanced product recurrence." },
        };

        var count: usize = 0;

        for (kinds) |kind| {
            for (self.config.s_values) |s| {
                for (self.config.t_values) |t| {
                    for (self.config.q_exponents) |exponent| {
                        if (count >= out.len) return count;

                        out[count] = .{
                            .name = kind.name,
                            .kind = kind.kind,
                            .s = s,
                            .t = t,
                            .q = pow10(exponent),
                            .description = kind.description,
                        };
                        count += 1;
                    }
                }
            }
        }

        count = self.generateProductGrammar(out, count);
        return count;
    }

    fn generateProductGrammar(self: Generator, out: []Family, start: usize) usize {
        var count = start;

        if (self.config.slope_values.len == 0 or self.config.offset_values.len == 0) {
            return count;
        }

        // Grammar seed:
        //   Π ((a1*k+b1)...(ar*k+br)) / ((c1*k+d1)...(cm*k+dm))
        //
        // We deliberately generate several structurally distinct shapes rather
        // than merely changing one scalar parameter.

        for (self.config.slope_values) |a| {
            for (self.config.offset_values) |b| {
                for (self.config.q_exponents) |exponent| {
                    if (count >= out.len) return count;

                    const numerator = [_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                    };

                    const denominator = [_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                    };

                    out[count] = Family.withFactors(
                        "product-3/3",
                        pow10(exponent),
                        &numerator,
                        &denominator,
                    );
                    count += 1;
                }
            }
        }

        return count;
    }
};

fn pow10(exponent: i32) f64 {
    var result: f64 = 1.0;
    const negative = exponent < 0;
    var e: i32 = if (negative) -exponent else exponent;

    while (e > 0) : (e -= 1) {
        result *= 10.0;
    }

    return if (negative) 1.0 / result else result;
}

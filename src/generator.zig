const Rational = @import("rational.zig").Rational;
const family = @import("family.zig");

const Family = family.Family;
const FamilyKind = family.FamilyKind;

const KindInfo = struct {
    kind: FamilyKind,
    name: []const u8,
    description: []const u8,
};

pub const GeneratorConfig = struct {
    s_values: []const Rational,
    t_values: []const Rational,
    q_exponents: []const i32,
};

pub const Generator = struct {
    config: GeneratorConfig,

    pub fn generate(self: Generator, out: []Family) usize {
        const kinds = [_]KindInfo{
            .{
                .kind = .hypergeometric_3f2,
                .name = "3F2",
                .description = "Hypergeometric 3F2-type recurrence.",
            },
            .{
                .kind = .inverse_binomial,
                .name = "inverse-binomial",
                .description = "Inverse-binomial-type recurrence.",
            },
            .{
                .kind = .central_binomial,
                .name = "central-binomial",
                .description = "Central-binomial-type recurrence.",
            },
            .{
                .kind = .factorial_ratio,
                .name = "factorial-ratio",
                .description = "Factorial-ratio-type recurrence.",
            },
            .{
                .kind = .balanced_product,
                .name = "balanced-product",
                .description = "Balanced product recurrence.",
            },
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

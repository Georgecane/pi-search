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

        return self.generateProductGrammar(out, count);
    }

    fn generateProductGrammar(self: Generator, out: []Family, start: usize) usize {
        var count = start;

        if (self.config.slope_values.len == 0 or self.config.offset_values.len == 0) {
            return count;
        }

        // Product grammar:
        //
        //   Π ((a1*k+b1)...(ar*k+br)) / ((c1*k+d1)...(cm*k+dm))
        //
        // The important part of this stage is topology. We deliberately create
        // several different numerator/denominator shapes instead of merely
        // changing one coefficient inside a fixed 3/3 template.

        for (self.config.slope_values) |a| {
            for (self.config.offset_values) |b| {
                for (self.config.q_exponents) |exponent| {
                    const q = pow10(exponent);

                    if (!self.appendProduct(out, &count, "product-3/3", q, &[_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                    }, &[_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                    })) return count;

                    if (!self.appendProduct(out, &count, "product-2/2", q, &[_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(2, 1), .b = Rational.init(1, 1) },
                    }, &[_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
                    })) return count;

                    if (!self.appendProduct(out, &count, "product-3/2", q, &[_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(1, 3) },
                    }, &[_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
                    })) return count;

                    if (!self.appendProduct(out, &count, "product-2/3", q, &[_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(1, 2) },
                    }, &[_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(2, 1) },
                    })) return count;

                    if (!self.appendProduct(out, &count, "product-3/1", q, &[_]LinearFactor{
                        .{ .a = a, .b = b },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                        .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 3) },
                    }, &[_]LinearFactor{
                        .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                    })) return count;
                }
            }
        }

        return count;
    }

    fn appendProduct(
        self: Generator,
        out: []Family,
        count: *usize,
        name: []const u8,
        q: f64,
        numerator: []const LinearFactor,
        denominator: []const LinearFactor,
    ) bool {
        _ = self;

        if (count.* >= out.len) return false;

        out[count.*] = Family.withFactors(name, q, numerator, denominator);
        count.* += 1;
        return true;
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

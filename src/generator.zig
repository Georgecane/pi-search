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
    q_values: []const Rational = &[_]Rational{},
    q_exponents: []const i32 = &[_]i32{},
    slope_values: []const Rational = &[_]Rational{},
    offset_values: []const Rational = &[_]Rational{},
    term_slopes: []const Rational = &[_]Rational{},
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
                    if (self.config.q_values.len > 0) {
                        for (self.config.q_values) |q| {
                            if (!self.appendKindVariants(out, &count, kind, s, t, q.value())) return count;
                        }
                    } else {
                        for (self.config.q_exponents) |exponent| {
                            if (!self.appendKindVariants(out, &count, kind, s, t, pow10(exponent))) return count;
                        }
                    }
                }
            }
        }

        return self.generateProductGrammar(out, count);
    }

    fn appendKindVariants(
        self: Generator,
        out: []Family,
        count: *usize,
        kind: KindInfo,
        s: Rational,
        t: Rational,
        q: f64,
    ) bool {
        const slopes = if (self.config.term_slopes.len == 0)
            &[_]Rational{Rational.init(0, 1)}
        else
            self.config.term_slopes;

        for (slopes) |slope| {
            if (count.* >= out.len) return false;

            out[count.*] = .{
                .name = kind.name,
                .kind = kind.kind,
                .s = s,
                .t = t,
                .q = q,
                .description = kind.description,
                .prefactor_a = 1.0,
                .prefactor_b = slope.value(),
            };
            count.* += 1;
        }

        return true;
    }

    fn generateProductGrammar(self: Generator, out: []Family, start: usize) usize {
        var count = start;

        if (self.config.slope_values.len == 0 or self.config.offset_values.len == 0) {
            return count;
        }

        for (self.config.slope_values) |a| {
            for (self.config.offset_values) |b| {
                if (self.config.q_values.len > 0) {
                    for (self.config.q_values) |q| {
                        if (!self.appendTopologies(out, &count, q.value(), a, b)) return count;
                    }
                } else {
                    for (self.config.q_exponents) |exponent| {
                        if (!self.appendTopologies(out, &count, pow10(exponent), a, b)) return count;
                    }
                }
            }
        }

        return count;
    }

    fn appendTopologies(
        self: Generator,
        out: []Family,
        count: *usize,
        q: f64,
        a: Rational,
        b: Rational,
    ) bool {
        const slopes = if (self.config.term_slopes.len == 0)
            &[_]Rational{Rational.init(0, 1)}
        else
            self.config.term_slopes;

        for (slopes) |term_slope| {
            if (!appendProduct(out, count, "product-3/3", q, term_slope.value(), &[_]LinearFactor{
                .{ .a = a, .b = b },
                .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
            }, &[_]LinearFactor{
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
            })) return false;

            if (!appendProduct(out, count, "product-2/2", q, term_slope.value(), &[_]LinearFactor{
                .{ .a = a, .b = b },
                .{ .a = Rational.init(2, 1), .b = Rational.init(1, 1) },
            }, &[_]LinearFactor{
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
            })) return false;

            if (!appendProduct(out, count, "product-3/2", q, term_slope.value(), &[_]LinearFactor{
                .{ .a = a, .b = b },
                .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(1, 3) },
            }, &[_]LinearFactor{
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
            })) return false;

            if (!appendProduct(out, count, "product-2/3", q, term_slope.value(), &[_]LinearFactor{
                .{ .a = a, .b = b },
                .{ .a = Rational.init(1, 1), .b = Rational.init(1, 2) },
            }, &[_]LinearFactor{
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(1, 1) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(2, 1) },
            })) return false;

            if (!appendProduct(out, count, "product-3/1", q, term_slope.value(), &[_]LinearFactor{
                .{ .a = a, .b = b },
                .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 2) },
                .{ .a = Rational.init(1, 1), .b = Rational.init(-1, 3) },
            }, &[_]LinearFactor{
                .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) },
            })) return false;
        }

        return true;
    }
};

fn appendProduct(
    out: []Family,
    count: *usize,
    name: []const u8,
    q: f64,
    term_slope: f64,
    numerator: []const LinearFactor,
    denominator: []const LinearFactor,
) bool {
    if (count.* >= out.len) return false;

    out[count.*] = Family.withFactors(name, q, numerator, denominator);
    out[count.*].prefactor_a = 1.0;
    out[count.*].prefactor_b = term_slope;
    count.* += 1;
    return true;
}

fn pow10(exponent: i32) f64 {
    var result: f64 = 1.0;
    const negative = exponent < 0;
    var e: i32 = if (negative) -exponent else exponent;

    while (e > 0) : (e -= 1) {
        result *= 10.0;
    }

    return if (negative) 1.0 / result else result;
}

const Rational = @import("rational.zig").Rational;
const Family = @import("family.zig").Family;

pub const GeneratorConfig = struct {
    q_exponents: []const i32,
    s_values: []const Rational,
};

pub const Generator = struct {
    config: GeneratorConfig,

    pub fn generate(self: Generator, out: []Family) usize {
        var count: usize = 0;

        for (self.config.s_values) |s| {
            for (self.config.q_exponents) |exponent| {
                if (count >= out.len) return count;

                out[count] = .{
                    .name = "hypergeometric-exploration",
                    .s = s,
                    .q = pow10(exponent),
                    .kind = .exploratory,
                    .description = "Exploratory hypergeometric family.",
                };
                count += 1;
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

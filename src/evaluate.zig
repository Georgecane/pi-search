const std = @import("std");
const Family = @import("family.zig").Family;

pub const Result = struct {
    sum: f64,
    terms: usize,
    converged: bool,
    last_term: f64,
    residual_pi: f64,
    residual_inv_pi: f64,
};

pub fn evaluate(family: Family, max_terms: usize, tolerance: f64) Result {
    var term: f64 = 1.0;
    var sum: f64 = 1.0;
    var n: usize = 0;

    while (n < max_terms) : (n += 1) {
        const next_n = n + 1;
        const ratio = family.termRatio(next_n);

        if (!std.math.isFinite(ratio)) {
            return makeResult(sum, next_n, false, term);
        }

        term *= ratio;

        if (!std.math.isFinite(term)) {
            return makeResult(sum, next_n, false, term);
        }

        sum += term;

        if (@abs(term) <= tolerance * @max(@abs(sum), 1.0)) {
            return makeResult(sum, next_n, true, term);
        }
    }

    return makeResult(sum, max_terms, false, term);
}

fn makeResult(sum: f64, terms: usize, converged: bool, last_term: f64) Result {
    const pi = 3.141592653589793238462643383279502884;
    const inv_pi = 1.0 / pi;

    return .{
        .sum = sum,
        .terms = terms,
        .converged = converged,
        .last_term = last_term,
        .residual_pi = @abs(sum - pi),
        .residual_inv_pi = @abs(sum - inv_pi),
    };
}

test "evaluate geometric baseline" {
    const FamilyKind = @import("family.zig").FamilyKind;
    const Rational = @import("rational.zig").Rational;

    var family = Family{
        .name = "test",
        .kind = FamilyKind.generated_product,
        .s = Rational.init(0, 1),
        .t = Rational.init(0, 1),
        .q = 0.5,
        .description = "test",
    };

    family.numerator_count = 1;
    family.numerator[0] = .{
        .a = Rational.init(1, 1),
        .b = Rational.init(0, 1),
    };
    family.denominator_count = 1;
    family.denominator[0] = .{
        .a = Rational.init(1, 1),
        .b = Rational.init(0, 1),
    };

    const result = evaluate(family, 1000, 1e-14);
    try std.testing.expect(result.converged);
    try std.testing.expect(@abs(result.sum - 2.0) < 1e-12);
}

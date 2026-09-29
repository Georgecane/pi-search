const std = @import("std");
const Family = @import("family.zig").Family;

pub const Prefactor = struct {
    name: []const u8,
    value: f64,
};

pub const Match = struct {
    prefactor: Prefactor,
    scaled_sum: f64,
    residual: f64,
    target_name: []const u8,
};

pub const Result = struct {
    sum: f64,
    terms: usize,
    converged: bool,
    last_term: f64,
    residual_pi: f64,
    residual_inv_pi: f64,
    best: Match,
};

const pi = 3.141592653589793238462643383279502884;
const inv_pi = 1.0 / pi;

const prefactors = [_]Prefactor{
    .{ .name = "1", .value = 1.0 },
    .{ .name = "2", .value = 2.0 },
    .{ .name = "3", .value = 3.0 },
    .{ .name = "4", .value = 4.0 },
    .{ .name = "6", .value = 6.0 },
    .{ .name = "8", .value = 8.0 },
    .{ .name = "12", .value = 12.0 },
    .{ .name = "16", .value = 16.0 },
    .{ .name = "24", .value = 24.0 },
    .{ .name = "1/2", .value = 0.5 },
    .{ .name = "1/3", .value = 1.0 / 3.0 },
    .{ .name = "1/4", .value = 0.25 },
    .{ .name = "1/6", .value = 1.0 / 6.0 },
    .{ .name = "1/8", .value = 0.125 },
    .{ .name = "1/12", .value = 1.0 / 12.0 },
    .{ .name = "1/16", .value = 1.0 / 16.0 },
    .{ .name = "sqrt(2)", .value = 1.4142135623730951 },
    .{ .name = "sqrt(3)", .value = 1.7320508075688772 },
    .{ .name = "sqrt(5)", .value = 2.23606797749979 },
    .{ .name = "1/sqrt(2)", .value = 0.7071067811865475 },
    .{ .name = "1/sqrt(3)", .value = 0.5773502691896258 },
    .{ .name = "1/sqrt(5)", .value = 0.4472135954999579 },
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
    var best = Match{
        .prefactor = prefactors[0],
        .scaled_sum = sum,
        .residual = @min(@abs(sum - pi), @abs(sum - inv_pi)),
        .target_name = if (@abs(sum - pi) < @abs(sum - inv_pi)) "pi" else "1/pi",
    };

    for (prefactors) |prefactor| {
        const scaled = prefactor.value * sum;
        const pi_error = @abs(scaled - pi);
        const inv_pi_error = @abs(scaled - inv_pi);

        if (pi_error < best.residual) {
            best = .{
                .prefactor = prefactor,
                .scaled_sum = scaled,
                .residual = pi_error,
                .target_name = "pi",
            };
        }

        if (inv_pi_error < best.residual) {
            best = .{
                .prefactor = prefactor,
                .scaled_sum = scaled,
                .residual = inv_pi_error,
                .target_name = "1/pi",
            };
        }
    }

    return .{
        .sum = sum,
        .terms = terms,
        .converged = converged,
        .last_term = last_term,
        .residual_pi = @abs(sum - pi),
        .residual_inv_pi = @abs(sum - inv_pi),
        .best = best,
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
    try std.testing.expect(@abs(result.best.scaled_sum - 2.0) < 1e-12);
}

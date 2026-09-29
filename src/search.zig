const std = @import("std");
const Family = @import("family.zig").Family;
const evaluate = @import("evaluate.zig");

pub const max_results = 20;

pub const Candidate = struct {
    family: Family,
    evaluation: evaluate.Result,
};

pub const Ranking = struct {
    items: [max_results]Candidate = undefined,
    count: usize = 0,

    pub fn consider(self: *Ranking, family: Family, result: evaluate.Result) void {
        if (!result.converged or !std.math.isFinite(result.best.residual)) return;

        var position: usize = self.count;
        if (position > max_results) position = max_results;

        while (position > 0 and
            position > 0 and
            result.best.residual < self.items[position - 1].evaluation.best.residual)
        {
            if (position < max_results) {
                self.items[position] = self.items[position - 1];
            }
            position -= 1;
        }

        if (position < max_results) {
            self.items[position] = .{
                .family = family,
                .evaluation = result,
            };

            if (self.count < max_results) self.count += 1;
        }
    }
};

pub fn rank(families: []const Family, max_terms: usize, tolerance: f64) Ranking {
    var result = Ranking{};

    for (families) |family| {
        const evaluation = evaluate.evaluate(family, max_terms, tolerance);
        result.consider(family, evaluation);
    }

    return result;
}

test "ranking keeps smallest residual" {
    const FamilyKind = @import("family.zig").FamilyKind;
    const Rational = @import("rational.zig").Rational;

    var families: [2]Family = undefined;

    families[0] = .{
        .name = "bad",
        .kind = FamilyKind.generated_product,
        .s = Rational.init(0, 1),
        .t = Rational.init(0, 1),
        .q = 0.5,
        .description = "bad",
    };
    families[0].numerator_count = 1;
    families[0].numerator[0] = .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) };
    families[0].denominator_count = 1;
    families[0].denominator[0] = .{ .a = Rational.init(1, 1), .b = Rational.init(0, 1) };

    families[1] = families[0];
    families[1].name = "better";
    families[1].q = 0.0;

    const ranking = rank(&families, 100, 1e-14);
    try std.testing.expect(ranking.count == 2);
    try std.testing.expectEqualStrings("bad", ranking.items[0].family.name);
}

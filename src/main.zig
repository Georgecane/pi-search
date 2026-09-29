const std = @import("std");
const Rational = @import("rational.zig").Rational;
const Family = @import("family.zig").Family;
const FamilyKind = @import("family.zig").FamilyKind;
const Generator = @import("generator.zig").Generator;
const search = @import("search.zig");

pub fn main() void {
    const s_values = [_]Rational{
        Rational.init(1, 2), Rational.init(1, 3), Rational.init(1, 4),
        Rational.init(1, 5), Rational.init(1, 6), Rational.init(1, 7),
        Rational.init(2, 7), Rational.init(2, 9), Rational.init(1, 8),
        Rational.init(1, 10),
    };

    const t_values = [_]Rational{
        Rational.init(1, 2), Rational.init(1, 3), Rational.init(1, 4),
        Rational.init(1, 5), Rational.init(1, 6),
    };

    const q_values = [_]Rational{
        Rational.init(1, 8), Rational.init(-1, 8),
        Rational.init(1, 16), Rational.init(-1, 16),
        Rational.init(1, 64), Rational.init(-1, 64),
        Rational.init(1, 125), Rational.init(-1, 125),
        Rational.init(1, 1000), Rational.init(-1, 1000),
        Rational.init(1, 4096), Rational.init(-1, 4096),
    };

    const slope_values = [_]Rational{
        Rational.init(1, 1), Rational.init(2, 1), Rational.init(3, 1),
        Rational.init(1, 2), Rational.init(1, 3), Rational.init(1, 4),
    };

    const offset_values = [_]Rational{
        Rational.init(-2, 1), Rational.init(-1, 1), Rational.init(-1, 2),
        Rational.init(0, 1), Rational.init(1, 2), Rational.init(1, 1),
        Rational.init(2, 1),
    };

    // We normalize the linear term to 1 + c*n.
    // The missing overall scale is absorbed by the K search.
    const term_slopes = [_]Rational{
        Rational.init(-2, 1), Rational.init(-1, 1), Rational.init(-1, 2),
        Rational.init(0, 1), Rational.init(1, 2), Rational.init(1, 1),
        Rational.init(2, 1), Rational.init(3, 1), Rational.init(4, 1),
    };

    var families: [65536]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_values = &q_values,
            .s_values = &s_values,
            .t_values = &t_values,
            .slope_values = &slope_values,
            .offset_values = &offset_values,
            .term_slopes = &term_slopes,
        },
    };

    const count = generator.generate(&families);

    std.debug.print(
        "pi-search\n==========\n" ++
        "Formula-grammar mathematical search space\n" ++
        "Candidates generated: {d}\n\n",
        .{count},
    );

    const ranking = search.rank(families[0..count], 10000, 1e-15);

    std.debug.print(
        "Top {d} numerical matches\n" ++
        "--------------------------\n",
        .{ranking.count},
    );

    for (ranking.items[0..ranking.count], 0..) |item, index| {
        const family = item.family;
        const result = item.evaluation;

        std.debug.print(
            "#{d:0>2} {s: <18} c={d:.3} s={d}/{d} t={d}/{d} q={e:.4} " ++
            "K={s: <10} K*S={e:.12} target={s: <4} residual={e:.3}\n",
            .{
                index + 1,
                family.name,
                family.prefactor_b,
                family.s.num,
                family.s.den,
                family.t.num,
                family.t.den,
                family.q,
                result.best.prefactor.name,
                result.best.scaled_sum,
                result.best.target_name,
                result.best.residual,
            },
        );
    }

    std.debug.print(
        "\nRanking is heuristic f64 numerical evidence only. " ++
        "No candidate is considered a proven pi identity.\n",
        .{},
    );
}

test "generator produces multiple families" {
    const s_values = [_]Rational{Rational.init(1, 6)};
    const t_values = [_]Rational{Rational.init(1, 5)};
    const q_values = [_]Rational{Rational.init(-1, 8), Rational.init(1, 64)};

    var families: [64]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_values = &q_values,
            .s_values = &s_values,
            .t_values = &t_values,
        },
    };

    const count = generator.generate(&families);

    try std.testing.expectEqual(@as(usize, 10), count);
    try std.testing.expectEqual(FamilyKind.hypergeometric_3f2, families[0].kind);
    try std.testing.expectEqual(@as(f64, -0.125), families[0].q);
    try std.testing.expectEqual(FamilyKind.balanced_product, families[8].kind);
}

test "product grammar creates multiple topologies" {
    const s_values = [_]Rational{Rational.init(1, 6)};
    const t_values = [_]Rational{Rational.init(1, 5)};
    const q_values = [_]Rational{Rational.init(-1, 8)};
    const slopes = [_]Rational{Rational.init(2, 1)};
    const offsets = [_]Rational{Rational.init(1, 2)};

    var families: [64]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_values = &q_values,
            .s_values = &s_values,
            .t_values = &t_values,
            .slope_values = &slopes,
            .offset_values = &offsets,
        },
    };

    const count = generator.generate(&families);

    try std.testing.expectEqual(@as(usize, 10), count);
    try std.testing.expectEqual(FamilyKind.generated_product, families[5].kind);
    try std.testing.expectEqual(@as(usize, 3), families[5].numerator_count);
    try std.testing.expectEqual(@as(usize, 3), families[5].denominator_count);
    try std.testing.expectEqual(@as(f64, -0.125), families[5].q);

    try std.testing.expectEqual(@as(usize, 2), families[6].numerator_count);
    try std.testing.expectEqual(@as(usize, 2), families[6].denominator_count);
    try std.testing.expectEqual(@as(usize, 3), families[7].numerator_count);
    try std.testing.expectEqual(@as(usize, 2), families[7].denominator_count);
    try std.testing.expectEqual(@as(usize, 2), families[8].numerator_count);
    try std.testing.expectEqual(@as(usize, 3), families[8].denominator_count);
    try std.testing.expectEqual(@as(usize, 3), families[9].numerator_count);
    try std.testing.expectEqual(@as(usize, 1), families[9].denominator_count);
}

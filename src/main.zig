const std = @import("std");
const Rational = @import("rational.zig").Rational;
const Family = @import("family.zig").Family;
const FamilyKind = @import("family.zig").FamilyKind;
const Generator = @import("generator.zig").Generator;
const benchmark = @import("benchmark.zig");

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

    var families: [8192]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_values = &q_values,
            .s_values = &s_values,
            .t_values = &t_values,
            .slope_values = &slope_values,
            .offset_values = &offset_values,
        },
    };

    const count = generator.generate(&families);

    std.debug.print(
        "pi-search\n==========\n" ++
        "Formula-grammar mathematical search space\n" ++
        "Candidates generated: {d}\n\n",
        .{count},
    );

    // The first 120 entries are grammar order, not mathematical ranking.
    // Keep this view compact while exposing actual numerical behavior.
    const shown = @min(count, 40);
    for (families[0..shown]) |candidate| {
        benchmark.printFamily(candidate, 100.0);
    }

    std.debug.print(
        "\nShowing first {d} grammar candidates.\n" ++
        "Numerical residuals are heuristic f64 measurements, not identity proofs.\n",
        .{shown},
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

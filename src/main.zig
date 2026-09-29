const std = @import("std");
const Rational = @import("rational.zig").Rational;
const Family = @import("family.zig").Family;
const FamilyKind = @import("family.zig").FamilyKind;
const Generator = @import("generator.zig").Generator;
const GeneratorConfig = @import("generator.zig").GeneratorConfig;
const benchmark = @import("benchmark.zig");

pub fn main() void {
    const s_values = [_]Rational{
        Rational.init(1, 2),
        Rational.init(1, 3),
        Rational.init(1, 4),
        Rational.init(1, 5),
        Rational.init(1, 6),
        Rational.init(1, 7),
        Rational.init(2, 7),
        Rational.init(2, 9),
        Rational.init(1, 8),
        Rational.init(1, 10),
    };

    const t_values = [_]Rational{
        Rational.init(1, 2),
        Rational.init(1, 3),
        Rational.init(1, 4),
        Rational.init(1, 5),
        Rational.init(1, 6),
    };

    const q_exponents = [_]i32{
        -2, -4, -6, -8, -10,
        -12, -16, -20, -30, -50,
    };

    var families: [4096]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_exponents = &q_exponents,
            .s_values = &s_values,
            .t_values = &t_values,
        },
    };

    const count = generator.generate(&families);

    std.debug.print(
        "pi-search\n==========\n" ++
        "Multi-family mathematical search space\n" ++
        "Candidates generated: {d}\n\n",
        .{count},
    );

    const shown = @min(count, 100);
    for (families[0..shown]) |candidate| {
        benchmark.printFamily(candidate, 100.0);
    }

    std.debug.print(
        "\nShowing first {d} candidates.\n" ++
        "All generated candidates are exploratory, not proven pi identities.\n",
        .{shown},
    );
}

test "generator produces multiple families" {
    const s_values = [_]Rational{Rational.init(1, 6)};
    const t_values = [_]Rational{Rational.init(1, 5)};
    const q_exponents = [_]i32{-10, -20};

    var families: [32]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_exponents = &q_exponents,
            .s_values = &s_values,
            .t_values = &t_values,
        },
    };

    const count = generator.generate(&families);

    try std.testing.expectEqual(@as(usize, 10), count);
    try std.testing.expectEqual(FamilyKind.hypergeometric_3f2, families[0].kind);
    try std.testing.expectEqual(FamilyKind.balanced_product, families[8].kind);
}

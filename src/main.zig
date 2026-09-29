const std = @import("std");
const Rational = @import("rational.zig").Rational;
const Family = @import("family.zig").Family;
const Generator = @import("generator.zig").Generator;
const GeneratorConfig = @import("generator.zig").GeneratorConfig;
const benchmark = @import("benchmark.zig");

pub fn main() !void {
    const stdout = std.fs.File.stdout().deprecatedWriter();

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

    const q_exponents = [_]i32{
        -2, -4, -6, -8, -10,
        -12, -16, -20, -30, -50,
    };

    var families: [128]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_exponents = &q_exponents,
            .s_values = &s_values,
        },
    };

    const count = generator.generate(&families);

    try stdout.print(
        "pi-search\n==========\n" ++
        "Exploratory hypergeometric family search\n" ++
        "Candidates: {d}\n\n",
        .{count},
    );

    for (families[0..count]) |family| {
        try benchmark.printFamily(stdout, family, 100.0);
    }

    try stdout.print(
        "\nNOTE: these q values are exploratory search parameters, not proven pi identities.\n",
        .{},
    );
}

test "generator produces candidates" {
    const s_values = [_]Rational{Rational.init(1, 6)};
    const q_exponents = [_]i32{-10, -20};

    var families: [4]Family = undefined;

    const generator = Generator{
        .config = .{
            .q_exponents = &q_exponents,
            .s_values = &s_values,
        },
    };

    const count = generator.generate(&families);

    try std.testing.expectEqual(@as(usize, 2), count);
    try std.testing.expectEqual(@as(i64, 1), families[0].s.num);
    try std.testing.expectEqual(@as(i64, 6), families[0].s.den);
}

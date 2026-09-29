const Family = @import("family.zig").Family;
const convergence = @import("convergence.zig");
const identity = @import("identity.zig");

pub fn printFamily(
    writer: anytype,
    family: Family,
    target_digits: f64,
) !void {
    const result = convergence.benchmark(family, target_digits, 10000);
    const certificate = identity.verify(family);

    try writer.print(
        "{s: <26} s={d}/{d} q={e:.6} asymptotic={d:.3} digits/term terms={d} status={s}\n",
        .{
            family.name,
            family.s.num,
            family.s.den,
            family.q,
            result.asymptotic_digits_per_term,
            result.terms_to_target,
            @tagName(certificate.status),
        },
    );
}

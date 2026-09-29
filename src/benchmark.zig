const std = @import("std");
const Family = @import("family.zig").Family;
const convergence = @import("convergence.zig");
const identity = @import("identity.zig");

pub fn printFamily(family: Family, target_digits: f64) void {
    const result = convergence.benchmark(family, target_digits, 10000);
    const certificate = identity.verify(family);

    std.debug.print(
        "{s: <18} s={d}/{d} t={d}/{d} q={e:.4} asymptotic={d:.3} terms={d} status={s}\n",
        .{
            family.name,
            family.s.num,
            family.s.den,
            family.t.num,
            family.t.den,
            family.q,
            result.asymptotic_digits_per_term,
            result.terms_to_target,
            @tagName(certificate.status),
        },
    );
}

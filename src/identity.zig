const Family = @import("family.zig").Family;

pub const Status = enum {
    unverified,
    verified,
};

pub const Certificate = struct {
    status: Status,
    note: []const u8,
};

pub fn verify(family: Family) Certificate {
    _ = family;

    return .{
        .status = .unverified,
        .note = "No identity certificate is attached.",
    };
}

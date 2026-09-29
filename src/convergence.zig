const std = @import("std");
const Family = @import("family.zig").Family;

pub const Result = struct {
    asymptotic_digits_per_term: f64,
    measured_digits_per_term: f64,
    terms_to_target: usize,
    final_term_log10: f64,
    converges: bool,
};

pub fn asymptoticDigitsPerTerm(family: Family) f64 {
    const magnitude = @abs(family.q);
    if (magnitude == 0.0) return std.math.inf(f64);
    return -std.math.log10(magnitude);
}

pub fn benchmark(
    family: Family,
    target_digits: f64,
    max_terms: usize,
) Result {
    var term: f64 = 1.0;
    var previous_log10: f64 = 0.0;
    var best_step: f64 = 0.0;

    var n: usize = 0;
    while (n < max_terms) : (n += 1) {
        const next_n = n + 1;
        const ratio = family.termRatio(next_n);

        if (!std.math.isFinite(ratio)) {
            return .{
                .asymptotic_digits_per_term = asymptoticDigitsPerTerm(family),
                .measured_digits_per_term = best_step,
                .terms_to_target = n,
                .final_term_log10 = previous_log10,
                .converges = false,
            };
        }

        term *= ratio;
        if (term == 0.0) break;

        const magnitude = @abs(term);
        const next_log10 = std.math.log10(magnitude);
        const step = @abs(next_log10 - previous_log10);

        if (step > best_step) best_step = step;
        previous_log10 = next_log10;

        if (-next_log10 >= target_digits) {
            return .{
                .asymptotic_digits_per_term = asymptoticDigitsPerTerm(family),
                .measured_digits_per_term = best_step,
                .terms_to_target = next_n,
                .final_term_log10 = next_log10,
                .converges = true,
            };
        }
    }

    return .{
        .asymptotic_digits_per_term = asymptoticDigitsPerTerm(family),
        .measured_digits_per_term = best_step,
        .terms_to_target = max_terms,
        .final_term_log10 = previous_log10,
        .converges = true,
    };
}

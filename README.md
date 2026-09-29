# pi-search

A Zig-based mathematical search engine for discovering and benchmarking fast-convergent hypergeometric and product-form series related to $$\pi$$.

## Current goal

The project is being built as a research engine rather than a conventional pi calculator.

```
Generate
   ↓
Normalize
   ↓
Convergence analysis
   ↓
Identity discovery
   ↓
Identity verification
   ↓
Benchmark
   ↓
Mutate / generate better families
```

The objective is to search for mathematically structured series whose effective contraction is substantially stronger than conventional formulas.

## Important distinction

A rapidly convergent numerical series is **not automatically a formula for $$\pi$$**.

Generated families are therefore marked as `exploratory` until an identity certificate exists.

## Current family

The first search space uses

```
H_s(n) = (1/2)_n (s)_n (1-s)_n / (n!)^3
```

with recurrence

```
H_s(n) / H_s(n-1)
= ((n-1/2)(n-1+s)(n-s)) / n^3
```

For

```
t_n = q^n H_s(n)
```

the asymptotic exponential contraction is governed by `|q|`.

## Build

Requires Zig.

```sh
zig build
zig build run
zig build test
```

## Roadmap

- [x] Rational parameter representation
- [x] Hypergeometric recurrence
- [x] Candidate generation
- [x] Convergence benchmarking
- [x] Explicit identity-verification boundary
- [ ] Mutation / evolutionary search
- [ ] Symbolic normalization
- [ ] Arbitrary-precision arithmetic
- [ ] PSLQ / integer-relation discovery
- [ ] Rigorous identity certificates
- [ ] Binary-splitting evaluation
- [ ] Certified ultra-high-digit pi computation

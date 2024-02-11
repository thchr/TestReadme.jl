# TestReadme.jl

[![Build status][ci-status-img]][ci-status-url] [![Coverage][coverage-img]][coverage-url]

This package provides a macro `@test_readme path` which extracts all Julia code snippets of the following form
~~~md
```jl 
julia> input
output
```
~~~
from a file at `path`, comparing `repr(MIME(text/plain), input)` against `output` for each such input-output pair.

The purpose of TestReadme.jl is two-fold:
1. Automatically turn README examples into unit tests.
2. Ensure that README examples stay synced with package functionality.

Additional `@test_readme` details:
- If omitted, `path` defaults to `(@__DIR__)/../README.md` (i.e., default Julia project structure).
- If no `output` is featured in the code snippet, it is simply tested that `input` evaluates without error.
- If evaluation of the README code snippets requires specific packages, load them *before* calling `@test_readme`.
- Results are aggregated in a single `@testset`, named `"README tests"`.

## Example: README snippets tested by `@test_readme` 

The following code snippets form part of the test suite of TestReadme.jl itself (see [`/test/runtests.jl`](https://github.com/thchr/TestReadme.jl/blob/main/test/runtests.jl)).

A basic test of math output:
```jl
julia> cos(π)
-1.0
julia> sum([1,2,3])
6
```

A test of string outputs:
```jl
julia> join(["abc", "xyz"], " and ")
"abc and xyz"
```

It is also possible to chain commands and define variables; a variable defined in one code snippet is in scope throughout a `@test_readme` call:
```jl
julia> x = 2
2
julia> x += 3
julia> x
5
```

Similarly, a single 
```jl
julia> begin
y = 2
z = y+x
end
7
julia> exp(z)
1096.6331584284585
```

### Inspecting extracted code-snippets
The extracted input-output pairs can be obtained and inspected via `parse_readme(path)`:
```jl
julia> m = TestReadme # pick your module
julia> path = joinpath(pkgdir(m), "README.md")
julia> input_outputs = parse_readme(path)
```
With the last line here printing (not included as output in the above above to avoid recursive madness):
```jl
11-element Vector{InputOutput}:
 :(cos(π)) ⇒ -1.0
 :(sum([1, 2, 3])) ⇒ 6
 :(join(["abc", "xyz"], " and ")) ⇒ "abc and xyz"
 :(x = 2) ⇒ 2
 :(x += 3) ⇒ ""
 :(x) ⇒ 5
 :(begin\n y = 2\n z = y + x\n end) ⇒ 7
 :(exp(z)) ⇒ 1096.6331584284585
 :(m = TestReadme) ⇒ ""
 :(path = joinpath(pkgdir(m), "README.md")) ⇒ ""
 :(input_outputs = parse_readme(path)) ⇒ ""
```

[ci-status-img]:   https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml/badge.svg?branch=main
[ci-status-url]:   https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml?query=branch%3Amain
[coverage-img]:    https://codecov.io/gh/thchr/TestReadme.jl/branch/main/graph/badge.svg
[coverage-url]:    https://codecov.io/gh/thchr/TestReadme.jl
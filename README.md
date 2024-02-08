# TestReadme.jl

[![Build Status](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package provides a single macro, `@test_readme path`, which extracts all code snippets of the following form
~~~md
```jl 
julia> input
output
```
~~~
from a README file at `path`, comparing for each such snippet the `repr(MIME(text/plain), input)` representation against `output`.

The purpose of TestReadme.jl is two-fold:
(1) automatically turn README examples into unit tests and
(2) ensure that README examples stay synced with package functionality.

Additional details includes:
- If omitted, `path` defaults to `(@__DIR__)/../README.test`, assuming the default Julia project structure.
- If no `output` is featured in the code snippet, it is simply tested that `input` evaluates without error.
- If the evaluation of the README code snippets requires specific packages, they must be manually loaded *before* calling `@test_readme`.
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
julia> m = TestReadme # choose your module
julia> path = joinpath(pkgdir(TestReadme), "README.md")
julia> input_outputs = parse_readme(path)
```
Which here prints:
```jl
10-element Vector{InputOutput}:
 :(cos(π)) ⇒ -1.0
 :(sum([1, 2, 3])) ⇒ 6
 :(x = 2) ⇒ 2
 :(x += 3) ⇒ ""
 :(x) ⇒ 5
 :(begin\n y = 2\n z = y + x\n end) ⇒ 7
 :(exp(z)) ⇒ 1096.6331584284585
 :(m = TestReadme) ⇒ ""
 :(path = joinpath(pkgdir(TestReadme), "README.md")) ⇒ ""
 :(input_outputs = parse_readme(path)) ⇒ ""
```
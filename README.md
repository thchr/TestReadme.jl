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

Additional details includes:
- If omitted, `path` defaults to `(@__DIR__)/../README.test`, assuming the default Julia project structure.
- If no `output` is featured in the code snippet, it is simply tested that `input` evaluates without error.
- The overall results are aggregated in a single `@testset`, named `"README tests"`.
- If the evaluation of the README code snippets require specific packages, they must be manually loaded before calling `@test_readme`.

## Example: README snippets tested by `@test_readme` 

The following code is tested by TestReadme.jl itself (see [`/test/runtests.jl`](https://github.com/thchr/TestReadme.jl/blob/main/test/runtests.jl)).

```jl
julia> cos(π)
-1.0
```

And some more advanced stuff:
```jl
julia> x = 2
2
julia> x += 3
julia> x
5
```

And some fancy stuff:
```jl
julia> begin
y = 2
z = y+x
end
7
julia> exp(z)
1096.6331584284585
```
# TestReadme

[![Build Status](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package provides a single macro, `@test_readme path`, which extracts all code snippets of the following form
> ~~~md
> ```jl
> julia> input
> output
> ```
> ~~~
from a README.md file at `path` and compares the `repr(MIME(text/plain), input)` representation against `output` for each. 
If no `output` is included, the test only ensures that `input` evaluates without error.
If no `path` is provided, it is set to `../README.test`, assuming the default Julia project structure.

The overall results are aggregated in a single `@testset`, named `"README tests"`.

# Example structure of readme 

The following code is tested by TestReadme.jl itself (see `test/runtests.jl`).

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

And something wrong:
```jl
julia> x = 3
4
```
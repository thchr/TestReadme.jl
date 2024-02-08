# TestReadme

[![Build Status](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/thchr/TestReadme.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package provides a single macro, `@test_readme path`, which extracts all code of the following form
> ```
> ````jl
> julia> input
> output
> ````
> ```
and compares the `repr(MIME(text/plain), input)` representation against `output`. If no `output` is included, the test only ensures that `input` evaluates without error.

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
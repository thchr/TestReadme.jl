module TestReadme

# ---------------------------------------------------------------------------------------- #

using Test

export @test_readme

# ---------------------------------------------------------------------------------------- #

struct InputOutput
    input :: Union{Symbol, Expr}
    output :: String
    # TODO: store line numbers of readme file?
end

# ---------------------------------------------------------------------------------------- #
# Parsing of README files: extracting input/output snippets for eventual testing

function parse_readme(path::AbstractString)
    readme = read(path, String)
    idx = firstindex(readme)
    snippets = Vector{String}()
    while true
        tmp = read_next_snippet(readme, idx)
        isnothing(tmp) && break
        s, idx = tmp
        push!(snippets, s)
    end
    return snippets
end

function read_next_snippet(readme, idx)
    # in principle, the same could be done with a regex - but it is a complicated regex
    # (namely, rx =r"```jl\n((?:.*\n)*?)``", capture anything between ```jl and ```, incl.
    # newlines) - but it is actually slower, so easier just to do it ourselves here

    idxs′ = findnext("```jl\n", readme, idx)
    isnothing(idxs′) && return nothing
    idx₁ = nextind(readme, last(idxs′))

    idxs′′ = findnext("\n```", readme, idx₁)
    isnothing(idxs′′) && return nothing
    idx₂ = prevind(readme, last(idxs′′), length("\n```"))

    snippet = readme[idx₁:idx₂]
    return snippet, nextind(readme, idx₂)
end

function extract_input_output(snippet::AbstractString)
    inouts = InputOutput[]
    idx′ = firstindex(snippet)
    break_now = false
    while !break_now
        idxs = findnext("julia> ", snippet, idx′)
        isnothing(idxs) && return ins

        in, idx′ = Meta.parse(snippet, nextind(snippet, last(idxs)); greedy=true)

        # look for possible output string
        if startswith((@view snippet[idx′:end]), "julia> ")
            # we interpret this as a "no-output" input line, assigning `""` as output
            out = ""
        else
            idxs′′ = findnext("julia> ", snippet, idx′)
            if isnothing(idxs′′)
                out = snippet[idx′:end]
                break_now = true
            else
                idx′′ = prevind(snippet, first(idxs′′), 1)
                out = chomp(snippet[idx′:idx′′])
                idx′ = idx′′
            end
        end
        push!(inouts, InputOutput(in, out))
    end

    return inouts
end

# ---------------------------------------------------------------------------------------- #
# Macros

"""
    @test_readme [path]

Test the code contents of a README file with file location `path`.

If omitted, `path` is set to `joinpath((@__DIR__), "..", "README.md")`.

Test results are associated with the `@testset` `"README tests"`.
"""
macro test_readme(path)
    snippets = gensym()
    snippet = gensym()
    inouts = gensym()
    inout = gensym()
    quote
        @testset "README tests" begin
            $snippets = parse_readme($(esc(path)))
            for $snippet in $snippets
                $inouts = extract_input_output($snippet)
                for $inout in $inouts
                    @test_repr_input_output $inout
                end
            end
        end
    end
end

macro test_readme() 
    quote
        @test_readme joinpath((@__DIR__), "..", "README.md")
    end
end

# this achieves two things: it evaluates the expression in `inout.input` while storing any
# variables created during this evaluates in the current scope (unlike `@test`); it then
# compares the `repr(MIME("text/plain", ...)` representation of this evaluated value against
# `output`. If the representations disagree, the test fails, and a nicely formatted
# expression is shown that actually shows what was evaluated
macro test_repr_input_output(inout)
    input = gensym()
    output = gensym()
    r = gensym()
    show_ex = gensym("show_ex")
    quote
        $input  = $(esc(inout)).input
        $output = $(esc(inout)).output
        $r = eval(quote repr(MIME("text/plain"), $($input)) end)
        $show_ex = :( ($($input))  |>  Base.Fix1(repr, MIME("text/plain")) == $($output) )
        #$show_ex = "(" * 
        #           string(:( ($($input))  |>  Base.Fix1(repr, MIME("text/plain")) )) * 
        #           ")  ==  \"$($output)\""
        if !isempty($output)
            @test_with_custom_expr_show(($r == $output), $show_ex)
        else
            @test true
        end
    end
end

# custom variant of `@test` that lets us pass our own expression to show (`show_ex`) if 
# `ex` evaluates to `false`; the canabalization from `@test` unfortunately involves some
# code generation that introduces symbols that belong to Test.jl: if we don't manually
# import them ahead of time, they will be wrongly identified as belonging to this module
# (see imports marked by *)
using Test: get_test_result, do_test
using Test: eval_test, Threw # *) imported to avoid module confusion
macro test_with_custom_expr_show(ex, show_ex)
    result = get_test_result(ex, __source__)
    quote
        do_test($result, $show_ex)
    end
end

end # module
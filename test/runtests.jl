using TestReadme
# NB: load any other packages that are needed to evaluate the code snippets contained in the
#     README file _before_ calling `@test_readme`

@test_readme

# To inspect the parsed input-output pairs, use `parse_readme(path)`:
#   path = joinpath((@__DIR__), "..", "README.md")
#   inouts = parse_readme(path)
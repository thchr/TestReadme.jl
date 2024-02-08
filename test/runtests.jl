using TestReadme
# NB: load any other packages that are needed to evaluate the code snippets contained in the
#     README file _before_ calling `@test_readme`

@test_readme

# To inspect the internal structures, run the following:
#   path = joinpath((@__DIR__), "..", "README.md")
#   snippets = TestReadme.parse_readme(path)
#   inouts = TestReadme.extract_input_output.(snippets)
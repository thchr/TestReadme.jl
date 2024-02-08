using TestReadme

#path = joinpath((@__DIR__), "..", "README.md")
#snippets = TestReadme.parse_readme(path)
#inouts = TestReadme.extract_input_output.(snippets)

@test_readme

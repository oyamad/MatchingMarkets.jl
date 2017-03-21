using Documenter, Matching

makedocs(
    modules = [Matching],
    format = :html,
    sitename = "Matching.jl",
    pages = Any[
        "Home" => "index.md",
        "API" => Any[
            "Matching" => "api/Matching.md"
        ],
    ]
)

deploydocs(
    repo = "github.com/oyamad/Matching.jl.git",
    branch = "gh-pages",
    target = "build",
    julia  = "0.5",
    deps = nothing,
    make = nothing,
)

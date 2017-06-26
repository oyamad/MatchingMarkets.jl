using Documenter, MatchingMarkets

makedocs(
    modules = [MatchingMarkets],
    format = :html,
    sitename = "MatchingMarkets.jl",
    pages = Any[
        "Home" => "index.md",
        "Library" => Any[
            "lib/public.md",
            "lib/internals.md",
        ],
    ]
)

deploydocs(
    repo = "github.com/oyamad/MatchingMarkets.jl.git",
    branch = "gh-pages",
    target = "build",
    julia  = "0.5",
    deps = nothing,
    make = nothing,
)

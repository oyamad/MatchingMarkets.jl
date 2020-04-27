using Documenter, MatchingMarkets

makedocs(;
    modules=[MatchingMarkets],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Library" => [
            "lib/public.md",
            "lib/internals.md",
        ],
    ],
    repo="https://github.com/oyamad/MatchingMarkets.jl/blob/{commit}{path}#L{line}",
    sitename="MatchingMarkets.jl",
)

deploydocs(;
    repo="github.com/oyamad/MatchingMarkets.jl",
)

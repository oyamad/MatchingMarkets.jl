module MatchingMarkets

include("types.jl")
include("util.jl")
include("deferred_acceptance.jl")
include("matching_tools.jl")

export Matching, TwoSidedMatchingMarket, get_all_pairs
export deferred_acceptance, SProposing, CProposing
export random_prefs, ReturnCaps

end # module

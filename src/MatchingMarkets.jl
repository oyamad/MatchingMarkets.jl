module MatchingMarkets

include("types.jl")
include("util.jl")
include("deferred_acceptance.jl")
include("top_trading_cycles.jl")
include("boston.jl")
include("serial_dictatorship.jl")
include("matching_tools.jl")

export Agents, Objects, Priority, TwoSidedMatchingMarket, 
    OneSidedMatchingMarket, Matching, get_all_pairs
export get_acceptables
export deferred_acceptance
export top_trading_cycles
export boston
export serial_dictatorship
export random_prefs, ReturnCaps

end # module

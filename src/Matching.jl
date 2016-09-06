module Matching

# 0.5 compatibility
import Compat.view

include("util.jl")
include("deferred_acceptance.jl")
include("matching_tools.jl")

export deferred_acceptance, SProposing, CProposing
export random_prefs, ReturnCaps

end # module

using Matching

if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

# 0.5 compatibility
import Compat.view

include("test_deferred_acceptance.jl")
include("test_matching_tools.jl")

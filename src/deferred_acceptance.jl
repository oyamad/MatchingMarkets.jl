#=
Implement the Deferred Acceptance (Gale-Shapley) algorithm. Support one-to-one,
many-to-one, and many-to-many matching problems.

Author: Daisuke Oyama

=#
import .Util: BinMaxHeap, top, push!, pop!, replace_least!, _prefs2ranks

# deferred_acceptance
"""
    deferred_acceptance(market, inverse=false)

Compute a stable matching by the DA algorithm for a two-sided matching
problem.

# Arguments

* `market::TwoSidedMatchingMarket` : The structure of the market that 
  contains two sides of agents (students and schools).
* `inverse::Bool=false`: If true, this function executes schools proposing 
  DA algorithm. Otherwise it executes students proposing DA algorithm.

# Returns

* `matching::Matching` : The resulting matching of the DA algorithm.
"""
function deferred_acceptance(market::TwoSidedMatchingMarket; inverse::Bool=false)
    if inverse
        props, resps = market.schools, market.students
    else
        props, resps = market.students, market.schools
    end 

    resp_ranks::Matrix{Int} = _prefs2ranks(props.size, resps.size, resps.prefs)

    # IDs representing unmatched
    prop_unmatched, resp_unmatched = 0, 0

    # Index representing unmatched
    resp_unmatched_idx = props.size + 1

    # Numbers of props' vacant slots
    nums_prop_vacant = copy(props.caps)

    # Next resps to propose to
    next_resps = ones(Int, props.size)

    # Binary heaps
    bhs = [
        BinMaxHeap(resps.caps[r])
        for r in 1:resps.size
    ]

    remaining::Int = props.size
    props_unmatched = collect(1:props.size)

    p_rank::Int = 0
    p::Int = 0
    least_prop_rank::Int = 0
    least_prop::Int = 0
    r::Int = 0

    # Main loop
    while remaining > 0
        p = props_unmatched[remaining]
        @inbounds r = props.prefs[p][next_resps[p]]  # p proposes to r

        # Prefers to be unmatched
        if r == prop_unmatched
            nums_prop_vacant[p] = 0
            remaining -= 1

        # Unacceptable for r
        elseif resp_ranks[p, r] > resp_ranks[resp_unmatched_idx, r]
            next_resps[p] += 1

        # Some seats vacant
        elseif length(bhs[r]) < resps.caps[r]
            nums_prop_vacant[p] -= 1
            push!(bhs[r], resp_ranks[p, r])
            if nums_prop_vacant[p] == 0
                remaining -= 1
            end
            next_resps[p] += 1

        # All seats occupied
        else
            @inbounds p_rank = resp_ranks[p, r]
            # Use binary heap structure
            least_prop_rank = top(bhs[r])
            if p_rank < least_prop_rank
                least_prop = resps.prefs[r][least_prop_rank]
                @inbounds nums_prop_vacant[p] -= 1
                @inbounds nums_prop_vacant[least_prop] += 1
                replace_least!(bhs[r], p_rank)
                if nums_prop_vacant[p] == 0
                    remaining -= 1
                end
                if nums_prop_vacant[least_prop] == 1
                    remaining += 1
                    props_unmatched[remaining] = least_prop
                end
            end
            next_resps[p] += 1
        end
    end

    matching = Matching(props.size, resps.size)
    for r in 1:resps.size
        for j in 1:resps.caps[r]
            if j <= length(bhs[r])
                p = resps.prefs[r][bhs[r][j]]
                matching[p, r] = true
            end
        end
    end

    return matching
end

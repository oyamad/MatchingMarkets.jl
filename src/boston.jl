#=
Implement the Boston mechanism for two-sided matching market.

Author: Akira Matsushita

=#
import .Util: BinMaxHeap, top, push!, pop!, replace_least!, _prefs2ranks

# boston
"""
    boston(market; inverse=false)

Compute a matching of a two-sided matching market by the Boston 
mechanism.

# Arguments

* `market::TwoSidedMatchingMarket` : The structure of the market that 
  contains two sides of agents (students and schools).
* `inverse::Bool=false`: If true, this function executes the 
  school-proposing Boston mechanism. Otherwise students propose to
  schools.

# Returns

* `matching::Matching` : The resulting matching of the Boston mechanism.
"""
function boston(market::TwoSidedMatchingMarket; inverse::Bool=false)
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

    # Lengths of preferences
    len_prop_prefs = [size(p, 1) for p in props.prefs]

    # Numbers of props'/resps' vacant slots
    nums_prop_vacant = copy(props.caps)
    nums_resp_vacant = copy(resps.caps)

    matching = Matching(props.size, resps.size)

    # Main loop
    for k in 1:resps.size
        bhs = [BinMaxHeap(nums_resp_vacant[r]) for r in 1:resps.size]

        for p in 1:props.size
            if nums_prop_vacant[p] == 0 || k > len_prop_prefs[p]
                # pass
            else
                @inbounds r = props.prefs[p][k]
                if r == prop_unmatched
                    @inbounds nums_prop_vacant[p] = 0
                elseif nums_resp_vacant[r] == 0 || 
                    resp_ranks[p, r] > resp_ranks[resp_unmatched_idx, r]
                    # pass
                elseif length(bhs[r]) < nums_resp_vacant[r]
                    push!(bhs[r], resp_ranks[p, r])
                else
                    @inbounds p_rank = resp_ranks[p, r]
                    least_prop_rank = top(bhs[r])
                    if p_rank < least_prop_rank
                        least_prop = resps.prefs[r][least_prop_rank]
                        replace_least!(bhs[r], p_rank)
                    end
                end
            end
        end

        for r in 1:resps.size
            for j in 1:resps.caps[r]
                if j <= length(bhs[r])
                    @inbounds p = resps.prefs[r][bhs[r][j]]
                    @inbounds matching[r, p] = true
                    @inbounds nums_prop_vacant[p] -= 1
                    @inbounds nums_resp_vacant[r] -= 1
                end
            end
        end
    end

    return matching
end

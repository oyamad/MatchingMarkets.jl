#=
Implement the Serial Dictatorship (SD) mechanism. Support both 
two-sided matching market and one-sided matching market problems.

Author: Akira Matsushita

=#
import .Util: get_acceptables

# two-sided matching market
"""
    serial_dictatorship(market, priority, inverse=false)

Compute a matching of a two-sided matching market by the Serial 
Dictatorship (SD) mechanism.

# Arguments

* `market::TwoSidedMatchingMarket` : The structure of the market that 
  contains two sides of agents (students and schools).
* `priority::Priority` : An enumeration of students 
  (if inverse=true, schools). In order of the priority, each 
  student (school) proposes the most preferred one among the 
  remaining schools (students).
* `inverse::Bool=false`: If true, this function executes the 
  school-proposing SD mechanism. Otherwise students propose to
  schools.

# Returns

* `matching::Matching` : The resulting matching of the SD mechanism.
"""
function serial_dictatorship(market::TwoSidedMatchingMarket, 
    priority::Priority; inverse::Bool=false)
    if inverse
        props, resps = market.schools, market.students
    else
        props, resps = market.students, market.schools
    end

    if minimum(priority.enum) < 1 || props.size < maximum(priority.enum)
        throw(ArgumentError(
            "`priority` contains an inappropriate student (school) number"))
    end

    # matrix of acceptable/unacceptable props
    is_acceptable = get_acceptables(resps.prefs, props.size)

    # IDs representing unmatched
    prop_unmatched = 0

    # Numbers of props'/resps' vacant slots
    nums_prop_vacant = copy(props.caps)
    nums_resp_vacant = copy(resps.caps)

    # Next resp ranks to propose to
    next_resp_ranks = ones(Int, props.size)

    matching = Matching(props.size, resps.size)

    # Main loop
    for p in priority.enum
        if nums_prop_vacant[p] > 0
            next_rank = next_resp_ranks[p]
            for r in props.prefs[p][next_rank:end]
                next_resp_ranks[p] += 1
                if r == prop_unmatched
                    break
                elseif nums_resp_vacant[r] > 0 && is_acceptable[p, r]
                    matching[r, p] = true
                    nums_prop_vacant[p] -= 1
                    nums_resp_vacant[r] -= 1
                    break
                end
            end
        end
    end

    return matching
end


# one-sided matching market
"""
    serial_dictatorship(market, priority)

Compute a matching of a one-sided matching market by the Serial 
Dictatorship (SD) mechanism.

# Arguments

* `market::OneSidedMatchingMarket` : The structure of the market that 
  contains two sides of agents (students and schools).
* `priority::Priority` : An enumeration of agents. In order 
  of the priority, each agent acquires the most preferred one among 
  the remaining objects.

# Returns

* `matching::Matching` : The resulting matching of the SD mechanism.
"""
function serial_dictatorship(market::OneSidedMatchingMarket, 
    priority::Priority)
    agents, objects = market.agents, market.objects

    if minimum(priority.enum) < 1 || agents.size < maximum(priority.enum)
        throw(ArgumentError(
            "`priority` contains an inappropriate agent number"))
    end

    # IDs representing unmatched
    agent_unmatched = 0

    # Numbers of agents'/objects' vacant slots
    nums_agent_vacant = copy(agents.caps)
    nums_object_vacant = copy(objects.caps)

    # Next object ranks to propose to
    next_obj_ranks = ones(Int, agents.size)

    matching = Matching(agents.size, objects.size)

    # Main loop
    for a in priority.enum
        if nums_agent_vacant[a] > 0
            next_rank = next_obj_ranks[a]
            for o in agents.prefs[a][next_rank:end]
                next_obj_ranks[a] += 1
                if o == agent_unmatched
                    break
                elseif nums_object_vacant[o] > 0
                    matching[o, a] = true
                    nums_agent_vacant[a] -= 1
                    nums_object_vacant[o] -= 1
                    break
                end
            end
        end
    end

    return matching
end

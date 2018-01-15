#=
Implement the Top Trading Cycles algorithm. Support both two-sided 
matching market and one-sided matching market problems.

Author: Akira Matsushita

=#
import LightGraphs: DiGraph, simplecycles
import .Util: get_acceptables

# top_trading_cycles
"""
    top_trading_cycles(market, inverse=false)

Compute a Pareto efficient matching by the TTC algorithm 
for a two-sided matching problem.

# Arguments

* `market::TwoSidedMatchingMarket` : The structure of the market that 
  contains two sides of agents (students and schools).
* `inverse::Bool=false`: If true, this function returns a matching
  that is Pareto efficient for schools. Otherwise it returns a 
  Pareto efficient matching for students.

# Returns

* `matching::Matching` : The resulting matching of the TTC algorithm.
"""
function top_trading_cycles(market::TwoSidedMatchingMarket; inverse::Bool=false)
    if inverse
        agents, objects = market.schools, market.students
    else
        agents, objects = market.students, market.schools
    end 

    # matrix of acceptable/unacceptable agents
    is_acceptable = get_acceptables(objects.prefs, agents.size)

    # IDs representing unmatched
    agent_unmatched, object_unmatched = 0, 0

    # Numbers of agents'/objects' vacant slots
    nums_agents_vacant = copy(agents.caps)
    nums_objects_vacant = copy(objects.caps)

    # Lengths of preferences
    len_agent_prefs = [size(p, 1) for p in agents.prefs]
    len_object_prefs = [size(p, 1) for p in objects.prefs]

    # Next objects/agents pointing at
    next_object_ranks = ones(Int, agents.size)
    next_agent_ranks = ones(Int, objects.size)
    next_objects = Vector{Int}(agents.size)
    next_agents = Vector{Int}(objects.size)

    agents_remaining::Int = agents.size
    objects_remaining::Int = objects.size

    # matching
    matching = Matching(agents.size, objects.size)

    total_size = agents.size + objects.size
    adj_mat = Matrix{Bool}(total_size, total_size)

    # Main loop
    while agents_remaining > 0 && objects_remaining > 0
        adj_mat .= false

        # set objects that agents point at
        for a in 1:agents.size
            if nums_agents_vacant[a] > 0
                while true
                    if next_object_ranks[a] > len_agent_prefs[a]
                        next_objects[a] = agent_unmatched
                        nums_agents_vacant[a] = 0
                        agents_remaining -= 1
                        break
                    end
                    obj = agents.prefs[a][next_object_ranks[a]]
                    # pointing herself
                    if obj == agent_unmatched
                        next_objects[a] = agent_unmatched
                        nums_agents_vacant[a] = 0
                        agents_remaining -= 1
                        break
                    end
                    # pointing at an object
                    if nums_objects_vacant[obj] > 0 && is_acceptable[a, obj]
                        next_objects[a] = obj
                        break
                    end
                    next_object_ranks[a] += 1
                end

                next_obj = next_objects[a]
                if next_obj != agent_unmatched
                    adj_mat[a, agents.size+next_obj] = true
                end
            end
        end

        # set agents that objects point at
        for o in 1:objects.size
            if nums_objects_vacant[o] > 0
                while true
                    if next_agent_ranks[o] > len_object_prefs[o]
                        next_agents[o] = object_unmatched
                        nums_objects_vacant[o] = 0
                        objects_remaining -= 1
                        break
                    end
                    age = objects.prefs[o][next_agent_ranks[o]]
                    # pointing herself
                    if age == object_unmatched
                        next_agents[o] = age
                        nums_objects_vacant[o] = 0
                        objects_remaining -= 1
                        break
                    end
                    # pointing at an object
                    if nums_agents_vacant[age] > 0
                        next_agents[o] = age
                        break
                    end
                    next_agent_ranks[o] += 1
                end

                next_age = next_agents[o]
                if next_age != object_unmatched
                    adj_mat[agents.size+o, next_age] = true
                end
            end
        end

        # detect cycles
        cycles = simplecycles(DiGraph(adj_mat))
        for c in cycles
            # reorder a cycle so that odd elements are agents
            if c[1] > agents.size
                first_obj = shift!(c)
                Base.push!(c, first_obj)
            end
            for i in 1:(size(c, 1) >> 1)
                agent = c[2*i-1]
                object = c[2*i] - agents.size
                matching[agent, object] = true
                next_object_ranks[agent] += 1
                next_agent_ranks[object] += 1
                nums_agents_vacant[agent] -= 1
                nums_objects_vacant[object] -= 1
                if nums_agents_vacant[agent] == 0
                    agents_remaining -= 1
                end
                if nums_objects_vacant[object] == 0
                    objects_remaining -= 1
                end
            end
        end
    end

    return matching
end

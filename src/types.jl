#=
Type definitions of various matching markets.

Author: Akira Matsushita

=#

import Base: getindex, setindex!


"""
Type representing a set of agents in matching markets. This class is 
used in TwoSidedMatchingMarket and OneSidedMatchingMarket.

* In two sided matching problems this type represents a set of
  agents on each side.

* In object allocation problems this type represents a set of agents.

# Fields

- `size::Int` : The number of agents.

- `prefs::Vector{Vector{Int}}` : Vector of preferences of agents.
  Each inside vector contains a strict preference order over 
  the agents or the objects of another side, and the outside option (0). 

  `prefs[i][j]` represents the `j`-th preferable agent/object in 
  another side of the market for the `i`-th agent. 

  This vector does not necessarily need to include all agents or 
  objects in another side. Those not listed in the preference vector 
  are treated as unacceptable (assuming the outside option locates
  right after the last agents/objects).

- `caps::Vector{Int}` : Vector of length `size` containing the
  maximum numbers(capacities) each player can match.
"""
type Agents
    size::Int
    prefs::Vector{Vector{Int}}
    caps::Vector{Int}
end


"""
    Agents(prefs::Vector{Vector{Int}}, caps::Vector{Int})

A constructer of the type `Agents`.
"""
function Agents(prefs::Vector{Vector{Int}}, caps::Vector{Int})
    return Agents(size(prefs, 1), prefs, caps)
end


"""
    Agents(prefs::Vector{Vector{Int}})

A constructer of the type `Agents` without specifying capacities.
`caps` are set to `ones(Int, size)`.
"""
function Agents(prefs::Vector{Vector{Int}})
    s = size(prefs, 1)
    return Agents(s, prefs, ones(Int, s))
end


"""
Type representing a set of objects in matching markets. This class is 
used in object allocation problems.

* In object allocation problems this type represents a set of objects.

# Fields

- `size::Int` : Total number of kinds of objects.
- `caps::Vector{Int}` : Vector of length `size` containing the
  maximum numbers(capacities) of each good.
"""
type Objects
    size::Int
    caps::Vector{Int}
end


"""
    Objects(caps::Vector{Int})

A constructer of the type `Objects`.
"""
function Objects(caps::Vector{Int})
    s = size(caps, 1)
    return Objects(s, caps)
end


"""
    Objects(caps::Vector{Int})

A constructer of the type `Objects` without specifying capacities.
`caps` are set to `ones(Int, size)`.
"""
function Objects(s::Int)
    return Objects(s, ones(Int, s))
end


abstract type AbstractEnum end;


"""
Type representing an enumeration of agents in matching markets. 
This class allows duplicates and lack of agents. It is used 
in the priority based alogrithms like the Serial Dictatorship 
mechanism.

# Fields

- `enum::Vector{Int}` : Vector of agents/objects ordered by
  the priority. The first agent/object has the highest priority.
"""
type Enumeration <: AbstractEnum
    enum::Vector{Int}
end


"""
Type representing a priority of agents in matching markets. 
This class does NOT allow duplicates or lack of agents. 
It is used in the Top Trading Cycles alogrithm for 
a one-sided market.

# Fields

- `enum::Vector{Int}` : Vector of agents/objects ordered by
  the priority. The first agent/object has the highest priority.
"""
type Priority <: AbstractEnum
    enum::Vector{Int}

    function Priority(enum::Vector{Int})
        if minimum(enum) < 0
            throw(ArgumentError(
                "`enum` contains an invalid agent number"))
        end

        if size(enum, 1) != size(unique(enum), 1) 
            throw(ArgumentError(
                "type `Priority` does not allow duplicates of agents"))
        end

        new(enum)
    end
end


"""
Type representing ownership of objects in a one-sided matching 
market. This class is used in the mixed-ownership market mechanisms 
like the Top Trading Cycles alogrithm.

# Fields

- `num_objects::Int` : The number of agents.
- `num_objects::Int` : The number of objects.
- `owners::SparseMatrixCSC{Bool}` : Matrix representing the ownership 
  structure. If `owners[a, o] == true`, it represents the agent `a` has 
  a property right of the object `o`.
"""
type Owners
    num_agents::Int
    num_objects::Int
    owners::SparseMatrixCSC{Bool}

    function Owners(num_agents::Int, num_objects::Int, 
        owners::SparseMatrixCSC{Bool})
        if size(owners, 1) != num_agents
            throw(ArgumentError(
                "the number of columns of `owners` does "*
                "not match `num_agents`"))
        end

        if size(owners, 2) != num_objects
            throw(ArgumentError(
                "the number of rows of `owners` does "*
                "not match `num_objects`"))
        end

        new(num_agents, num_objects, owners)
    end
end


"""
    Owners(num_agents::Int, num_objects::Int, owners::Vector{Vector{Int}})

A constructer of the type `Owners` using the Vector of Vectors. 
`owners[o]` are the set of agents who hold the object `o`.
"""
function Owners(num_agents::Int, num_objects::Int, 
    owners::Vector{Vector{Int}})
    if size(owners, 1) != num_objects
        throw(ArgumentError(
            "the length of `owners` does not match `num_objects`"))
    end

    spm = spzeros(Bool, num_agents, num_objects)
    for o in 1:num_objects
        for a in owners[o]
            if a < 1 || num_agents < a
                throw(ArgumentError(
                    "`owners` contains an invalid agent $(a)"))
            end
            spm[a, o] = true
        end
    end
    return Owners(num_agents, num_objects, spm)
end


"""
    Owners(num_agents::Int, num_objects::Int, owners::Vector{Vector{Any}})

A constructer of the type `Owners` using the Vector of Vectors. 
`owners[o]` are the set of agents who hold the object `o`.
"""
function Owners(num_agents::Int, num_objects::Int, 
    owners::Vector{Vector{Any}})
    if size(owners, 1) != num_objects
        throw(ArgumentError(
            "the length of `owners` does not match `num_objects`"))
    end

    spm = spzeros(Bool, num_agents, num_objects)
    for o in 1:num_objects
        for a in owners[o]
            if typeof(a) != Int || a < 1 || num_agents < a
                throw(ArgumentError(
                    "`owners` contains an invalid agent $(a)"))
            end
            spm[a, o] = true
        end
    end
    return Owners(num_agents, num_objects, spm)
end


"""
    Owners(num_agents::Int, num_objects::Int, owners::Vector{Int})

A simplified constructer of the type `Owners` when all objects 
are possessed at most one agent. `owners[i] = 0` is interpreted as 
no agents own the object `i`. 
"""
function Owners(num_agents::Int, num_objects::Int, 
    owners::Vector{Int})
    if size(owners, 1) != num_objects
        throw(ArgumentError(
            "the length of `owners` does not match `num_objects`"))
    end
    unowned = 0
    spm = spzeros(Bool, num_agents, num_objects)
    for (o, a) in enumerate(owners)
        if a < 0 || num_agents < a
            throw(ArgumentError(
                "`owners` contains an invalid agent $(a)"))
        elseif a == unowned
            #pass
        else
            spm[a, o] = true
        end
    end
    return Owners(num_agents, num_objects, spm)
end


"""
    Owners(num_agents::Int, num_objects::Int)

A constructer of the type `Owners` which returns a ownership structure 
in which no agents hold any objects.
"""
function Owners(num_agents::Int, num_objects::Int)
    return Owners(num_agents, num_objects, 
        spzeros(Bool, num_agents, num_objects))
end


"""
Type representing a two-sided matching market containing 
two set of agents. 

# Fields

- `students::Agents` : Agents of one side in the two-sided matching market.
- `schools::Agents` : Agents of another side in the two-sided matching market.
"""
type TwoSidedMatchingMarket
    students::Agents
    schools::Agents

    function TwoSidedMatchingMarket(students::Agents, schools::Agents)
        for s in 1:students.size
            min_s = minimum(students.prefs[s])
            max_s = maximum(students.prefs[s])
            if min_s < 0 || schools.size < max_s
                throw(ArgumentError(
                    "`students.prefs` contains invalid school numbers"))
            end
            if length(unique(students.prefs[s])) != length(students.prefs[s])
                throw(ArgumentError(
                    "`students.prefs` contains duplicate school numbers"))
            end
        end
        
        for s in 1:schools.size
            min_s = minimum(schools.prefs[s])
            max_s = maximum(schools.prefs[s])
            if min_s < 0 || students.size < max_s
                throw(ArgumentError(
                    "`schools.prefs` contains invalid school numbers"))
            end
            if length(unique(schools.prefs[s])) != length(schools.prefs[s])
                throw(ArgumentError(
                    "`schools.prefs` contains duplicate school numbers"))
            end
        end

        new(students, schools)
    end
end


"""
Type representing a one-sided matching market containing agents and objects. 

# Fields

- `agents::Agents` : Agents in the one-sided matching market.
- `objects::Objects` : Objects in the one-sided matching market.
"""
type OneSidedMatchingMarket
    agents::Agents
    objects::Objects

    function OneSidedMatchingMarket(agents::Agents, objects::Objects)
        for a in 1:agents.size
            min_a = minimum(agents.prefs[a])
            max_a = maximum(agents.prefs[a])
            if min_a < 0 || objects.size < max_a
                throw(ArgumentError(
                    "`agents.prefs` contains invalid object numbers"))
            end
            if length(unique(agents.prefs[a])) != length(agents.prefs[a])
                throw(ArgumentError(
                    "`agents.prefs` contains duplicate object numbers"))
            end
        end
        
        new(agents, objects)
    end
end


"""
Type representing a matching of a one-sided matching market or a 
two-sided matching market. In a one-sided market, a matching 
is a function from agents to objects and outside options. 
In a two-sided market, a matching is a function from students 
to schools and outside options. Some alogrithms for a two-sided 
market return a matching from schools to students and outside options, 
when specifying the optional argument `inverse=true`.

# Fields

- `num_agents::Int` : The number of agents.
- `num_objects::Int` : The number of objects.
- `matching::SparseMatrixCSC{Bool}` : Matrix of Bool. If 
  `matching[o, a] == true`, then that implies the agent `a` matches 
  to the object `o`. Otherwise `i` and `o` do not match.
"""
type Matching
    num_agents::Int
    num_objects::Int
    matching::SparseMatrixCSC{Bool}
end


"""
    Matching(num_agents::Int, num_objects::Int)

A constructer of the type `Matching` which returns an empty matching.
"""
function Matching(num_agents::Int, num_objects::Int)
    return Matching(num_agents, num_objects, 
        spzeros(Bool, num_objects, num_agents))
end


function Base.getindex(matching::Matching, 
    object_index::Int, agent_index::Int)
    if 1 <= agent_index <= matching.num_agents
        if 1 <= object_index <= matching.num_objects
            return matching.matching[object_index, agent_index]
        end
    end
    throw(BoundsError(matching.matching, (object_index, agent_index)))
end


function Base.getindex(matching::Matching, 
    object_index::Colon, agent_index::Int)
    if 1 <= agent_index <= matching.num_agents
        return matching.matching[:, agent_index]
    end
    throw(BoundsError(matching.matching, (object_index, agent_index)))
end


function Base.getindex(matching::Matching, 
    object_index::Int, agent_index::Colon)
    if 1 <= object_index <= matching.num_objects
        return matching.matching[object_index, :]
    end
    throw(BoundsError(matching.matching, (object_index, agent_index)))
end


function Base.setindex!(matching::Matching, bool::Bool, 
    object_index::Int, agent_index::Int)
    if 1 <= agent_index <= matching.num_agents
        if 1 <= object_index <= matching.num_objects
            matching.matching[object_index, agent_index] = bool
            return
        end
    end
    throw(BoundsError(matching.matching, (object_index, agent_index)))
end


function (matching::Matching)(index::Int; inverse::Bool=false)
    # agent index case
    if inverse == false
        if index < 1 || matching.num_agents < index
            throw(BoundsError(matching.matching, (:, index)))
        end
        sparse_objects, sparse_bools = findnz(matching.matching[:, index])
        objects = Vector{Int}()
        for (s, bool) in zip(sparse_objects, sparse_bools)
            if bool
                Base.push!(objects, s)
            end
        end
        return objects
    # object index case
    else
        if index < 1 || matching.num_objects < index
            throw(BoundsError(matching.matching, (index, :)))
        end
        sparse_agents, sparse_bools = findnz(matching.matching[index, :])
        agents = Vector{Int}()
        for (s, bool) in zip(sparse_agents, sparse_bools)
            if bool
                Base.push!(agents, s)
            end
        end
        return agents
    end
end


function Base.show(io::IO, matching::Matching)
    println(io, "MatchingMarkets.Matching (agent: object)")
    for a in 1:matching.num_agents
        objects = Vector{Int}()
        for o in 1:matching.num_objects
            if matching.matching[o, a]
                Base.push!(objects, o)
            end
        end
        text = a > 1 ? ", " : ""
        text *= "$(a): "
        print(io, text)
        if size(objects, 1) == 0
            print(io, "[]") # avoid print "Int64[]"
        else
            print(io, objects)
        end
    end
end



"""
    get_all_pairs(matching::Matching; inverse::Bool=false)

A constructer of the type `Matching` which returns an empty matching.

# Arguments
- `matching::Matching` : A matching.
- `inverse::Bool=false` : If true, then the keys of `pairs` will be 
  objects. Otherwise the keys will be agents.

# Returns
- `pairs::Dict{Int, Vector{Int}}` : A dict whose keys are agents 
  (if inverse = true, objects) and values are vector of matched 
  objects (agents).
"""
function get_all_pairs(matching::Matching; inverse::Bool=false)
    pairs = Dict{Int, Vector{Int}}()
    objects, agents, bools = findnz(matching.matching)

    # agent -> objects
    if inverse == false
        for i in 1:matching.num_agents
            pairs[i] = Vector{Int}()
        end
        for (object, agent, bool) in zip(objects, agents, bools)
            if bool
                Base.push!(pairs[agent], object)
            end
        end
    # object -> agents
    else
        for i in 1:matching.num_objects
            pairs[i] = Vector{Int}()
        end
        for (object, agent, bool) in zip(objects, agents, bools)
            if bool
                Base.push!(pairs[object], agent)
            end
        end
    end
    return pairs
end

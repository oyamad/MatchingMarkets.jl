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


"""
Type representing a two sided matching market containing
  two set of agents. 

# Fields

- `students::Agents` : Agents of one side in the two sided matching market.
- `schools::Agents` : Agents of another side in the two sided matching market.
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


type OneSidedMatchingMarket
    agents::Agents
    objects::Objects
end


"""
Type representing a matching
"""
type Matching
    num_students::Int
    num_schools::Int
    matching::SparseMatrixCSC{Bool}
end


function Matching(num_students::Int, num_schools::Int)
    return Matching(num_students, num_schools, spzeros(Bool, num_students, num_schools))
end


function Base.getindex(matching::Matching, student_index::Int, school_index::Int)
    if 1 <= student_index <= matching.num_students
        if 1 <= school_index <= matching.num_schools
            return matching.matching[student_index, school_index]
        end
    end
    throw(BoundsError(matching.matching, (student_index, school_index)))
end


function Base.getindex(matching::Matching, student_index::Int, school_index::Colon)
    if 1 <= student_index <= matching.num_students
        return matching.matching[student_index, :]
    end
    throw(BoundsError(matching.matching, (student_index, school_index)))
end


function Base.getindex(matching::Matching, student_index::Colon, school_index::Int)
    if 1 <= school_index <= matching.num_schools
        return matching.matching[:, school_index]
    end
    throw(BoundsError(matching.matching, (student_index, school_index)))
end


function Base.setindex!(matching::Matching, bool::Bool, student_index::Int, school_index::Int)
    if 1 <= student_index <= matching.num_students
        if 1 <= school_index <= matching.num_schools
            matching.matching[student_index, school_index] = bool
            return
        end
    end
    throw(BoundsError(matching.matching, (student_index, school_index)))
end


function (matching::Matching)(index::Int; inverse::Bool=false)
    # student index case
    if inverse == false
        if index < 1 || matching.num_students < index
            throw(BoundsError(matching.matching, (index, :)))
        end
        sparse_schools, sparse_bools = findnz(matching.matching[index, :])
        schools = Vector{Int}()
        for (s, bool) in zip(sparse_schools, sparse_bools)
            if bool
                Base.push!(schools, s)
            end
        end
        return schools
    # school index case
    else
        if index < 1 || matching.num_schools < index
            throw(BoundsError(matching.matching, (:, index)))
        end
        sparse_students, sparse_bools = findnz(matching.matching[:, index])
        students = Vector{Int}()
        for (s, bool) in zip(sparse_students, sparse_bools)
            if bool
                Base.push!(students, s)
            end
        end
        return students
    end
end


function get_all_pairs(matching::Matching; inverse::Bool=false)
    pairs = Dict{Int, Vector{Int}}()
    students, schools, bools = findnz(matching.matching)

    # student -> schools
    if inverse == false
        for i in 1:matching.num_students
            pairs[i] = Vector{Int}()
        end
        for (student, school, bool) in zip(students, schools, bools)
            if bool
                Base.push!(pairs[student], school)
            end
        end
    # school -> students
    else
        for i in 1:matching.num_schools
            pairs[i] = Vector{Int}()
        end
        for (student, school, bool) in zip(students, schools, bools)
            if bool
                Base.push!(pairs[school], student)
            end
        end
    end
    return pairs
end

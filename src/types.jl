#=
Type definitions of various matching markets.

Author: Akira Matsushita

=#

import Base: getindex


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






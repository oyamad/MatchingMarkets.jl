#=
Tools for matching algorithms.

Author: Daisuke Oyama

=#

# random_prefs

"""
    random_prefs([rng, ]m, n[, ReturnCaps]; allow_unmatched=true)

Generate random preference order lists for two groups, say, m males and n
females.

Each male has a preference order over femals [1, ..., n] and "unmatched" which
is represented by 0, while each female has a preference order over males
[1, ..., m] and "unmatched" which is again represented by 0.

The argument `ReturnCaps` should be supplied in the context of college
admissions, in which case "males" and "females" should be read as "students"
and "colleges", respectively, where each college has its capacity.

The optional `rng` argument specifies a random number generator.

# Arguments

* `m::Integer` : Number of males.
* `n::Integer` : Number of females.
* `::Type{ReturnCaps}` : If supplied, `caps` is also returned.
* `;allow_unmatched::Bool(true)` : If false, return preference order lists of
  males and females where 0 is always placed in the last place, (i.e.,
  "unmatched" is least preferred by every individual).

# Returns

* `m_prefs::Matrix{Int}` :  Array of shape (n+1, m), where each column contains
  a random permutation of 0, 1, ..., n.
* `f_prefs::Matrix{Int}` :  Array of shape (m+1, n), where each column contains
  a random permutation of 0, 1, ..., m.
* `caps::Vector{Int}` : Vector of length n containing each female's (or
  college's) capacity. Returned only when `ReturnCaps` is supplied.

# Examples

```julia
julia> m_prefs, f_prefs = random_prefs(4, 3);

julia> m_prefs
4x4 Array{Int64,2}:
 3  3  1  3
 0  2  3  1
 2  1  2  0
 1  0  0  2

julia> f_prefs
5x3 Array{Int64,2}:
 1  2  4
 4  3  1
 3  4  2
 0  0  0
 2  1  3

julia> m_prefs, f_prefs = random_prefs(4, 3, allow_unmatched=false);

julia> m_prefs
4x4 Array{Int64,2}:
 1  3  1  2
 2  1  3  3
 3  2  2  1
 0  0  0  0

julia> f_prefs
5x3 Array{Int64,2}:
 1  2  3
 2  3  4
 4  1  1
 3  4  2
 0  0  0

julia> s_prefs, c_prefs, caps = random_prefs(4, 3, ReturnCaps);

julia> s_prefs
4x4 Array{Int64,2}:
 2  1  2  1
 1  3  1  0
 3  2  3  3
 0  0  0  2

julia> c_prefs
5x3 Array{Int64,2}:
 3  4  1
 0  1  4
 4  3  0
 1  2  3
 2  0  2

julia> caps
3-element Array{Int64,1}:
 1
 2
 2
```
"""
function random_prefs(rng::AbstractRNG,
                      m::Integer, n::Integer;
                      allow_unmatched::Bool=true)
    m_prefs = _random_prefs(rng, m, n, allow_unmatched)
    f_prefs = _random_prefs(rng, n, m, allow_unmatched)
    return m_prefs, f_prefs
end

random_prefs(m::Integer, n::Integer; allow_unmatched::Bool=true) =
    random_prefs(Base.GLOBAL_RNG, m, n, allow_unmatched=allow_unmatched)

immutable ReturnCaps end

function random_prefs(rng::AbstractRNG,
                      m::Integer, n::Integer, ::Type{ReturnCaps};
                      allow_unmatched::Bool=true)
    s_prefs = _random_prefs(rng, m, n, allow_unmatched)
    c_prefs = _random_prefs(rng, n, m)

    if allow_unmatched
        unmatched_rankings = Array(Int, n) #rand(r, 2:n+1, m)
        _random_unmatched!(rng, c_prefs, unmatched_rankings)
        caps = _random_caps(rng, unmatched_rankings)
    else
        caps = _random_caps(rng, m, n)
    end
    return s_prefs, c_prefs, caps
end

random_prefs(m::Integer, n::Integer, T::Type{ReturnCaps};
             allow_unmatched::Bool=true) =
    random_prefs(Base.GLOBAL_RNG, m, n, T, allow_unmatched=allow_unmatched)


function _random_prefs(rng::AbstractRNG, m::Integer, n::Integer)
    prefs = Array(Int, n+1, m)
    for j in 1:m
        prefs[end, j] = 0
    end

    _randperm2d!(rng, sub(prefs, 1:n, :))

    return prefs
end

function _random_unmatched!(rng::AbstractRNG, prefs::Matrix{Int},
                            unmatched_rankings::Vector{Int})
    n = size(prefs, 1) - 1
    m = size(prefs, 2)
    rand!(rng, unmatched_rankings, 2:n+1)
    for j in 1:m
        prefs[end, j] = prefs[unmatched_rankings[j], j]
        prefs[unmatched_rankings[j], j] = 0
    end
end

function _random_prefs(rng::AbstractRNG, m::Integer, n::Integer,
                       allow_unmatched::Bool)
    prefs = _random_prefs(rng, m, n)

    if allow_unmatched
        unmatched_rankings = Array(Int, m)
        _random_unmatched!(rng, prefs, unmatched_rankings)
    end

    return prefs
end


function _random_caps(rng::AbstractRNG, unmatched_rankings::Vector{Int})
    n = length(unmatched_rankings)
    u = rand(rng, n)
    for i in 1:n
        u[i] *= unmatched_rankings[i]
        u[i] += 1
    end
    return floor(Int, u)
end

function _random_caps(rng::AbstractRNG, m::Int, n::Int)
    u = rand(rng, n)
    for i in 1:n
        u[i] *= m
        u[i] += 1
    end
    return floor(Int, u)
end


# Copied from base/random.jl
"Return a random `Int` (masked with `mask`) in ``[0, n)``, when `n <= 2^52`."
@inline function rand_lt(r::AbstractRNG, n::Int, mask::Int=nextpow2(n)-1)
    # this duplicates the functionality of RangeGenerator objects,
    # to optimize this special case
    while true
        x = (Base.Random.rand_ui52_raw(r) % Int) & mask
        x < n && return x
    end
end

# In-place version of randperm in base/random.jl
"""
Given a vector `a` of length n, generate a random permutation of length n and
store it in `a`.
"""
function _randperm!{T<:Integer}(r::AbstractRNG, a::AbstractVector{T})
    # a = Array{typeof(n)}(n)
    n = length(a)
    @assert n <= Int64(2)^52
    if n == 0
       return a
    end
    a[1] = 1
    mask = 3
    @inbounds for i = 2:Int(n)
        j = 1 + rand_lt(r, i, mask)
        if i != j # a[i] is uninitialized (and could be #undef)
            a[i] = a[j]
        end
        a[j] = i
        i == 1+mask && (mask = 2mask + 1)
    end
    return a
end


"""
Given an m x n matrix `a`, generate n random permutations of length m and store
them in columns of `a`.
"""
function _randperm2d!{T<:Integer}(r::AbstractRNG, a::AbstractMatrix{T})
    m, n = size(a)
    for j in :1:n
        _randperm!(r, sub(a, :, j))
    end
    a
end

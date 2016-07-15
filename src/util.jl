module Util

# BinHeap

type BinHeap{TR<:AbstractVector,TD<:AbstractVector}
    ranking::TR
    data::TD
    is_heapified::Bool
end

Base.length(bh::BinHeap) = length(bh.data)


function heapify!(bh::BinHeap)
    if bh.is_heapified
        return bh
    end

    n = length(bh)
    for i in 2:n
        _heap_bubble_up!(bh, i)
    end

    bh.is_heapified = true
    return bh
end


function least!(bh::BinHeap)
    if !bh.is_heapified
        heapify!(bh)
    end
    return bh.data[1]
end


function replace_least!(bh::BinHeap, v::Int)
    v_least = least!(bh)

    n = length(bh)
    bh.data[1] = bh.data[n]
    _heap_bubble_down!(bh, 1)
    bh.data[n] = v
    _heap_bubble_up!(bh, n)

    return v_least
end


# BEGIN: From DataStructures.jl/src/heaps/binary_heap.jl

function _heap_bubble_up!(bh::BinHeap, i::Int)
    i0::Int = i
    @inbounds v = bh.data[i]

    while i > 1  # nd is not root
        p = i >> 1
        @inbounds vp = bh.data[p]

        if bh.ranking[v] > bh.ranking[vp]
            # move parent downward
            @inbounds bh.data[i] = vp
            i = p
        else
            break
        end
    end

    if i != i0
        @inbounds bh.data[i] = v
    end

    return bh
end

function _heap_bubble_down!(bh::BinHeap, i::Int)
    @inbounds v = bh.data[i]
    swapped = true
    n = length(bh)
    last_parent = n >> 1

    while swapped && i <= last_parent
        lc = i << 1
        if lc < n   # contains both left and right children
            rc = lc + 1
            @inbounds lv = bh.data[lc]
            @inbounds rv = bh.data[rc]
            if bh.ranking[rv] > bh.ranking[lv] #compare(comp, rv, lv)
                if bh.ranking[rv] > bh.ranking[v]  #compare(comp, rv, v)
                    @inbounds bh.data[i] = rv
                    i = rc
                else
                    swapped = false
                end
            else
                if bh.ranking[lv] > bh.ranking[v]
                    @inbounds bh.data[i] = lv
                    i = lc
                else
                    swapped = false
                end
            end
        else        # contains only left child
            @inbounds lv = bh.data[lc]
            if bh.ranking[lv] > bh.ranking[v]
                @inbounds bh.data[i] = lv
                i = lc
            else
                swapped = false
            end
        end
    end

    bh.data[i] = v

    return bh
end

# END: From DataStructures.jl/src/heaps/binary_heap.jl


# Stack

type Stack{T,TD<:AbstractVector}
    data::TD
    ptr::Int
end

Stack(data::AbstractVector) = Stack{eltype(data), typeof(data)}(data, 1)

Base.length(s::Stack) = length(s.data) - s.ptr + 1
isempty(s::Stack) = length(s) == 0
isfull(s::Stack) = s.ptr == 1

function top(s::Stack)
    isempty(s) && throw(ArgumentError("Stack must be non-empty"))
    @inbounds out = s.data[s.ptr]
    return out
end

function pop!(s::Stack)
    out = top(s)
    s.ptr += 1
    return out
end

function push!{T}(s::Stack{T}, x::T)
    isfull(s) && throw(ArgumentError("Stack must not be full"))
    s.ptr -= 1
    @inbounds s.data[s.ptr] = x
    return s
end


# Stacks

type Stacks{T,TD<:AbstractVector}
    data::Vector{Stack{T,TD}}
    num_elements::Int
end

Base.getindex(stacks::Stacks, i::Int) = stacks.data[i]
Base.length(stacks::Stacks) = stacks.num_elements

top(stacks::Stacks, i::Int) = top(stacks[i])

function pop!(stacks::Stacks, i::Int)
    stacks.num_elements -= 1
    return pop!(stacks[i])
end

function push!{T}(stacks::Stacks{T}, i::Int, x::T)
    stacks.num_elements += 1
    return push!(stacks[i], x)
end

end  # module

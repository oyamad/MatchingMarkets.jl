module Util

mutable struct BinHeap{TR<:AbstractVector{Int},TD<:AbstractVector{Int}}
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

end  # module
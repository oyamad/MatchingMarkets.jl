module Util

import Base.==

mutable struct BinMaxHeap{TD<:AbstractVector{Int}, TI<:Integer}
    data::TD
    ind::TI
end

BinMaxHeap(cap::T) where {T <: Integer} = BinMaxHeap(Vector{Int}(cap), 0)

==(bh1::BinMaxHeap, bh2::BinMaxHeap) = bh1.data[1:bh1.ind] == bh2.data[1:bh2.ind]

Base.length(bh::BinMaxHeap) = bh.ind

Base.getindex(bh::BinMaxHeap, ind::Int) = bh.data[ind]

function top(bh::BinMaxHeap)
    if bh.ind == 0
        throw(BoundsError(
            "attempt to access top of 0-element BinMaxheap"
            )
        )
    end
    return bh.data[1]
end

# BEGIN: From DataStructures.jl/src/heaps/binary_heap.jl

function push!(bh::BinMaxHeap, r::Int)
    bh.data[bh.ind+1] = r
    bh.ind += 1
    _heap_bubble_up!(bh)
end

function pop!(bh::BinMaxHeap)
    max_r = bh.data[1]
    bh.data[1] = bh.data[bh.ind]
    bh.ind -= 1
    if bh.ind != 0
        _heap_bubble_down!(bh)
    end
    return max_r
end

function replace_least!(bh::BinMaxHeap, r::Int)
    pop!(bh)
    push!(bh, r)
end

function _heap_bubble_up!(bh::BinMaxHeap)
    i::Int = bh.ind
    @inbounds r = bh.data[i]

    while i > 1  # nd is not root
        p = i >> 1
        @inbounds rp = bh.data[p]

        if r > rp
            # move parent downward
            @inbounds bh.data[i] = rp
            i = p
        else
            break
        end
    end

    if i != bh.ind
        @inbounds bh.data[i] = r
    end
end

function _heap_bubble_down!(bh::BinMaxHeap)
    i = 1
    @inbounds r = bh.data[i]
    swapped = true
    n = length(bh)
    last_parent = n >> 1

    while swapped && i <= last_parent
        lc = i << 1
        if lc < n   # contains both left and right children
            rc = lc + 1
            @inbounds lr = bh.data[lc]
            @inbounds rr = bh.data[rc]
            if rr > lr #compare(comp, rv, lv)
                if rr > r  #compare(comp, rv, v)
                    @inbounds bh.data[i] = rr
                    i = rc
                else
                    swapped = false
                end
            else
                if lr > r
                    @inbounds bh.data[i] = lr
                    i = lc
                else
                    swapped = false
                end
            end
        else        # contains only left child
            @inbounds lr = bh.data[lc]
            if lr > r
                @inbounds bh.data[i] = lr
                i = lc
            else
                swapped = false
            end
        end
    end

    bh.data[i] = r
end

# END: From DataStructures.jl/src/heaps/binary_heap.jl


function get_acceptables(prefs::Vector{Vector{Int}}, opposite_size::Int)
    unmatched = 0
    this_side_size = size(prefs, 1)
    matrix = zeros(Bool, (opposite_size, this_side_size))
    for i in 1:this_side_size
        for op in prefs[i]
            if op == unmatched
                break
            end
            matrix[op, i] = true
        end
    end
    return matrix
end

end  # module

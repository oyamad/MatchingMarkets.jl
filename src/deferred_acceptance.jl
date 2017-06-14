#=
Implement the Deferred Acceptance (Gale-Shapley) algorithm. Support one-to-one,
many-to-one, and many-to-many matching problems.

Author: Daisuke Oyama

=#
import .Util: BinHeap, least!, replace_least!

# deferred_acceptance

# Many-to-many
"""
    deferred_acceptance(prop_prefs, resp_prefs, prop_caps, resp_caps)

Compute a stable matching by the DA algorithm for a many-to-many matching
problem.

# Arguments

* `prop_prefs::Matrix{Int}` : Array of shape (n+1, m) containing the proposers'
  preference orders as columns, where m is the number of proposers and n is
  that of the responders. `prop_prefs[j, i]` is the `j`-th preferred responder
  for the `i`-th proposer, where "responder `0`" represents "vacancy".
* `resp_prefs::Matrix{Int}` : Array of shape (m+1, n) containing the
  responders' preference orders as columns. `resp_prefs[i, j]` is the `i`-th
  preferred proposer for the `j`-th responder, where "proposer `0`" epresents
  "vacancy".
* `prop_caps::Vector{Int}` : Vector of length n containing the proposers'
  capacities.
* `resp_caps::Vector{Int}` : Vector of length n containing the responders'
  capacities.

# Returns

* `prop_matches::Vector{Int}` : Vector of length m representing the matches for
  the proposers, where the responders who proposer `i` is matched with are
  contained in `prop_matches[prop_indptr[i]:prop_indptr[i+1]-1]`.
* `resp_matches::Vector{Int}` : Vector of length n representing the matches for
  the responders, where the proposers who responder `j` is matched with are
  contained in `resp_matches[resp_indptr[j]:resp_indptr[j+1]-1]`.
* `prop_indptr::Vector{Int}` : Contains index pointers for `prop_matches`.
* `resp_indptr::Vector{Int}` : Contains index pointers for `resp_matches`.
"""
function deferred_acceptance(prop_prefs::Matrix{Int},
                             resp_prefs::Matrix{Int},
                             prop_caps::Vector{Int},
                             resp_caps::Vector{Int})
    num_props, num_resps = size(prop_prefs, 2), size(resp_prefs, 2)

    (size(prop_prefs) == (num_resps+1, num_props) &&
     size(resp_prefs) == (num_props+1, num_resps)) ||
        throw(ArgumentError("shapes of preferences arrays do not match"))

    length(prop_caps) == num_props ||
        throw(ArgumentError(
            "`length(prop_caps)` must be equal to `size(prop_prefs, 2)`"
            )
        )
    length(resp_caps) == num_resps ||
        throw(ArgumentError(
            "`length(resp_caps)` must be equal to `size(resp_prefs, 2)`"
            )
        )

    resp_ranks::Matrix{Int} = _prefs2ranks(resp_prefs)

    # IDs representing unmatched
    prop_unmatched, resp_unmatched = 0, 0

    # Index representing unmatched
    resp_unmatched_idx = num_props + 1

    # Set up index pointers
    prop_indptr = _caps2indptr(prop_caps)
    resp_indptr::Vector{Int} = _caps2indptr(resp_caps)

    num_prop_caps = prop_indptr[end] - 1
    num_resp_caps = resp_indptr[end] - 1

    #is_single_prop = trues(num_props)
    # Numbers of props' vacant slots
    nums_prop_vacant = copy(prop_caps)
    total_num_prop_open_slots = num_prop_caps

    # Next resps to propose to
    next_resps = ones(Int, num_props)

    # Props currently matched
    current_props::Vector{Int} = Array{Int}(num_resp_caps)
    fill!(current_props, resp_unmatched_idx)

    # Numbers of resps' occupied seats
    nums_resp_occupied = zeros(Int, num_resps)

    # Binary heaps
    bhs = [
        BinHeap(view(resp_ranks, :, r),
                view(current_props, resp_indptr[r]:resp_indptr[r+1]-1),
                false)
        for r in 1:num_resps
    ]

    # Main loop
    while total_num_prop_open_slots > 0
        for p in 1:num_props
            if nums_prop_vacant[p] > 0
                @inbounds r = prop_prefs[next_resps[p], p]  # p proposes to r

                # Prefers to be unmatched
                if r == prop_unmatched
                    total_num_prop_open_slots -= nums_prop_vacant[p]
                    nums_prop_vacant[p] = 0

                # Unacceptable for r
                elseif resp_ranks[p, r] > resp_ranks[resp_unmatched_idx, r]
                    # pass

                # Some seats vacant
                elseif nums_resp_occupied[r] < resp_caps[r]
                    current_props[resp_indptr[r]+nums_resp_occupied[r]] = p
                    nums_resp_occupied[r] += 1
                    nums_prop_vacant[p] -= 1
                    total_num_prop_open_slots -= 1

                # All seats occupied
                else
                    # Use binary heap structure
                    least_prop = least!(bhs[r])
                    if resp_ranks[p, r] < resp_ranks[least_prop, r]
                        replace_least!(bhs[r], p)
                        nums_prop_vacant[p] -= 1
                        @inbounds nums_prop_vacant[least_prop] += 1
                    end
                end
                next_resps[p] += 1
            end
        end
    end

    prop_matches = zeros(Int, num_prop_caps)
    resp_matches = current_props
    for r in 1:num_resps
        for j in resp_indptr[r]:resp_indptr[r+1]-1
            p = resp_matches[j]
            if p == resp_unmatched_idx
                resp_matches[j] = resp_unmatched
            else
                prop_matches[prop_indptr[p]+nums_prop_vacant[p]] = r
                nums_prop_vacant[p] += 1
            end
        end
    end

    return prop_matches, resp_matches, prop_indptr, resp_indptr
end

# One-to-one
"""
    deferred_acceptance(prop_prefs, resp_prefs)

Compute a stable matching by the DA algorithm for a one-to-one matching
(marriage) problem.

# Arguments

* `prop_prefs::Matrix{Int}` : Array of shape (n+1, m) containing the proposers'
  preference orders as columns, where m is the number of proposers and n is
  that of the responders. `prop_prefs[j, i]` is the `j`-th preferred
  responder for the `i`-th proposer, where "responder `0`" represents
  "being-single".
* `resp_prefs::Matrix{Int}` : Array of shape (m+1, n) containing the
  responders' preference orders as columns. `resp_prefs[i, j]` is the `i`-th
  preferred proposer for the `j`-th responder, where "proposer `0`" represents
  "being-single".

# Returns

* `prop_matches::Vector{Int}` : Vector of length m representing the matches for
  the proposers, where `prop_matches[i]` is the responder who proposer `i` is
  matched with.
* `resp_matches::Vector{Int}` : Vector of length n representing the matches for
  the responders, where `resp_matches[j]` is the proposer who responder `j` is
  matched with.
"""
function deferred_acceptance(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int})
    prop_caps = ones(Int, size(prop_prefs, 2))
    resp_caps = ones(Int, size(resp_prefs, 2))
    prop_matches, resp_matches, _, _ =
        deferred_acceptance(prop_prefs, resp_prefs, prop_caps, resp_caps)
    return prop_matches, resp_matches
end

# Many-to-one
@compat abstract type DAProposal end
immutable SProposing <: DAProposal end
immutable CProposing <: DAProposal end

"""
    deferred_acceptance(s_prefs, c_prefs, caps[, proposal])

Compute a stable matching by the DA algorithm for a many-to-one matching
(college admission) problem.

# Arguments

* `s_prefs::Matrix{Int}` : Array of shape (n+1, m) containing the students'
  preference orders as columns, where m is the number of students and n is that
  of the colleges. `s_prefs[j, i]` is the `j`-th preferred college for the
  `i`-th studnet, where "college `0`" represents "being single".
* `c_prefs::Matrix{Int}` : Array of shape (m+1, n) containing the colleges'
  preference orders as columns. `c_prefs[i, j]` is the `i`-th preferred student
  for the `j`-th college, where "student `0`" represents "vacancy".
* `caps::Vector{Int}` : Vector of length n containing the colleges' capacities.
* `proposal::Type(SProposing)` : `SProposing` runs the student-proposing DA
  algorithm, while `CProposing` runs the college-proposing algorithm. Default
  to the former.

# Returns

* `s_matches::Vector{Int}` : Vector of length m representing the matches for
  the students, where `s_matches[i]` is the college that proposer `i` is
  matched with.
* `c_matches::Vector{Int}` : Vector of length n representing the matches for
  the colleges, where the students who college `j` is matched with are
  contained in `c_matches[indptr[j]:indptr[j+1]-1]`.
* `indptr::Vector{Int}` : Contains index pointers for `c_matches`.
"""
function deferred_acceptance{P<:DAProposal}(s_prefs::Matrix{Int},
                                            c_prefs::Matrix{Int},
                                            caps::Vector{Int},
                                            proposal::Type{P}=SProposing)
    s_caps = ones(Int, size(s_prefs, 2))
    if proposal == SProposing
        s_matches, c_matches, _, indptr =
            deferred_acceptance(s_prefs, c_prefs, s_caps, caps)
    else
        c_matches, s_matches, indptr, _ =
            deferred_acceptance(c_prefs, s_prefs, caps, s_caps)
    end
    return s_matches, c_matches, indptr
end


function _prefs2ranks(prefs::Matrix{Int})
    unmatched = 0
    ranks = similar(prefs)
    m, n = size(prefs)
    for j in 1:n, i in 1:m
        k = prefs[i, j]
        if k == unmatched
            ranks[end, j] = i
        else
            ranks[k, j] = i
        end
    end
    return ranks
end


function _caps2indptr(caps::Vector{Int})
    n = length(caps)
    indptr = Array{Int}(n+1)
    indptr[1] = 1
    @inbounds for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end
    return indptr
end

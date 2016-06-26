#=
Deferred Acceptance (DA) algorithm

Author: Daisuke Oyama

=#

# deferred_acceptance

"""
    deferred_acceptance(prop_prefs, resp_prefs[, caps])

Compute a stable matching by the deferred acceptance (Gale-Shapley) algorithm.
Support both one-to-one (marrige) and many-to-one (college admission)
matchings.

# Arguments

* `prop_prefs::Matrix{Int}` : Array of shape (n+1, m) containing the proposers'
  preference orders as columns, where m is the number of proposers and n is
  that of the respondants. `prop_prefs[j, i]` is the `j`-th preferred
  respondant for the `i`-th proposer, where "respondant `0`" represents "being
  single".
* `resp_prefs::Matrix{Int}` : Array of shape (m+1, n) containing the
  respondants' preference orders as columns. `resp_prefs[i, j]` is the `i`-th
  preferred proposer for the `j`-th respondant, where "proposer `0`" represents
  "being single" (or "vacancy" in the context of college admissions).
* `caps::Vector{Int}` : Vector of length n containing the respondnats'
  capacities. If not supplied, the capacities are all regarded as one (i.e.,
  the matching is one-to-one).

# Returns

* `prop_matches::Vector{Int}` : Vector of length m representing the matches for
  the proposers, where `prop_matches[i]` is the repondant who proposer `i` is
  matched with.
* `resp_matches::Vector{Int}` : Vector of length n representing the matches for
  the respondants: if `caps` is not supplied, `resp_matches[j]` is the proposer
  who respondant `j` is matched with; if `caps` is specified, the proposers who
  respondant `j` is matched with are contained in
  `resp_matches[indptr[j]:indptr[j+1]-1]`.
* `indptr::Vector{Int}` : Returned only when `caps` is specified. Contains
  index pointers for `resp_matches`.
"""
function deferred_acceptance(prop_prefs::Matrix{Int},
                             resp_prefs::Matrix{Int},
                             caps::Vector{Int})
    num_props, num_resps = size(prop_prefs, 2), size(resp_prefs, 2)

    resp_ranks = _prefs2ranks(resp_prefs)

    # IDs representing unmatched
    prop_unmatched, resp_unmatched = 0, 0

    # Index representing unmatched
    resp_unmatched_idx = num_props + 1

    is_single_prop = trues(num_props)

    # Next resp to propose to
    next_resp = ones(Int, num_props)

    # Set up index pointers
    indptr = Array(Int, num_resps+1)
    indptr[1] = 1
    for i in 1:num_resps
        indptr[i+1] = indptr[i] + caps[i]
    end

    num_caps = indptr[end] - 1

    # Props currently matched
    current_props = Array(Int, num_caps)
    fill!(current_props, resp_unmatched_idx)

    # Numbers of occupied seats
    nums_occupied = zeros(Int, num_resps)

    # Main loop
    while any(is_single_prop)
        for p in 1:num_props
            if is_single_prop[p]
                r = prop_prefs[next_resp[p], p]  # p proposes r

                # Prefers to be unmatched
                if r == prop_unmatched
                    is_single_prop[p] = false

                # Unacceptable for r
                elseif resp_ranks[p, r] > resp_ranks[resp_unmatched_idx, r]
                    # pass

                # Some seats vacant
                elseif nums_occupied[r] < caps[r]
                    current_props[indptr[r]+nums_occupied[r]] = p
                    is_single_prop[p] = false
                    nums_occupied[r] += 1

                # All seats occupied
                else
                    # Find the least preferred among the currently accepted
                    least_ptr = indptr[r]
                    least = current_props[least_ptr]
                    for i in indptr[r]:indptr[r+1]-1
                        compared = current_props[i]
                        if resp_ranks[least, r] < resp_ranks[compared, r]
                            least_ptr = i
                            least = compared
                        end
                    end

                    if resp_ranks[p, r] < resp_ranks[least, r]
                        current_props[least_ptr] = p
                        is_single_prop[p] = false
                        is_single_prop[least] = true
                    end
                end
                next_resp[p] += 1
            end
        end
    end

    prop_matches = Array(Int, num_props)
    for p in 1:num_props
        prop_matches[p] = prop_prefs[next_resp[p]-1, p]
    end
    resp_matches = current_props
    resp_matches[resp_matches.==resp_unmatched_idx] = resp_unmatched

    return prop_matches, resp_matches, indptr
end

function deferred_acceptance(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int})
    caps = ones(Int, size(resp_prefs, 2))
    prop_matches, resp_matches, _ =
        deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end


function _prefs2ranks(prefs::Matrix{Int})
    unmatched = 0
    ranks = similar(prefs)
    m, n = size(prefs)
    for j in 1:n
        for i in 1:m
            k = prefs[i, j]
            if k == unmatched
                ranks[end, j] = i
            else
                ranks[k, j] = i
            end
        end
    end
    return ranks
end

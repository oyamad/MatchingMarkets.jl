function sort_matches!(matches::Vector{Int}, indptr::Vector{Int})
    for i in 1:length(indptr)-1
        sort!(sub(matches, indptr[i]:indptr[i+1]-1))
    end
end


@testset "Testing deferred_acceptance.jl" begin

    matchings_one_to_one = Array{Dict, 1}()
    matchings_many_to_one = Array{Dict, 1}()
    matchings_many_to_many = Array{Dict, 1}()

    # Test case: one-to-one
    m, n = 4, 3
    # Males' preference orders over females [1, 2, 3] and unmatched 0
    m_prefs = [1 3 2 3;
               2 1 3 1;
               3 2 1 2;
               0 0 0 0]
    # Females' preference orders over males [1, 2, 3, 4] and unmatched 0
    f_prefs = [3 1 3;
               1 2 0;
               2 3 2;
               4 4 1;
               0 0 4]
    # Unique stable matching
    m_matches_m_opt = m_matches_f_opt = [1, 2, 3, 0]
    f_matches_m_opt = f_matches_f_opt = [1, 2, 3]
    d = Dict(
        "m_prefs" => m_prefs,
        "f_prefs" => f_prefs,
        "m_matches_m_opt" => m_matches_m_opt,
        "f_matches_m_opt" => f_matches_m_opt,
        "m_matches_f_opt" => m_matches_f_opt,
        "f_matches_f_opt" => f_matches_f_opt,
    )
    push!(matchings_one_to_one, d)

    # Test case: one-to-one; from Roth and Sotomayor Example 2.9
    m, n = 5, 4
    m_prefs = [
        1, 2, 3, 4, 0,
        4, 2, 3, 1, 0,
        4, 3, 1, 2, 0,
        1, 4, 3, 2, 0,
        1, 2, 4, 0, 3,
    ]
    m_prefs = reshape(m_prefs, n+1, m)
    f_prefs = [
        2, 3, 1, 4, 5, 0,
        3, 1, 2, 4, 5, 0,
        5, 4, 1, 2, 3, 0,
        1, 4, 5, 2, 3, 0,
    ]
    f_prefs = reshape(f_prefs, m+1, n)
    m_matches_m_opt, f_matches_m_opt = [1, 2, 3, 4, 0], [1, 2, 3, 4]
    m_matches_f_opt, f_matches_f_opt = [4, 1, 2, 3, 0], [2, 3, 4, 1]
    d = Dict(
        "m_prefs" => m_prefs,
        "f_prefs" => f_prefs,
        "m_matches_m_opt" => m_matches_m_opt,
        "f_matches_m_opt" => f_matches_m_opt,
        "m_matches_f_opt" => m_matches_f_opt,
        "f_matches_f_opt" => f_matches_f_opt,
    )
    push!(matchings_one_to_one, d)

    # Test case: one-to-one; from Roth and Sotomayor Example 2.17
    m = n = 4
    m_prefs = [
        1, 2, 3, 4, 0,
        2, 1, 4, 3, 0,
        3, 4, 1, 2, 0,
        4, 3, 2, 1, 0,
    ]
    m_prefs = reshape(m_prefs, n+1, m)
    f_prefs = [
        4, 3, 2, 1, 0,
        3, 4, 1, 2, 0,
        2, 1, 4, 3, 0,
        1, 2, 3, 4, 0,
    ]
    f_prefs = reshape(f_prefs, m+1, n)
    m_matches_m_opt = f_matches_m_opt = [1, 2, 3, 4]
    m_matches_f_opt = f_matches_f_opt = [4, 3, 2, 1]
    d = Dict(
        "m_prefs" => m_prefs,
        "f_prefs" => f_prefs,
        "m_matches_m_opt" => m_matches_m_opt,
        "f_matches_m_opt" => f_matches_m_opt,
        "m_matches_f_opt" => m_matches_f_opt,
        "f_matches_f_opt" => f_matches_f_opt,
    )
    push!(matchings_one_to_one, d)

    # Test case: many-to-many; from Roth and Sotomayor Example 5.24
    m_caps = fill(2, m)
    f_caps = fill(2, n)
    m_matches_m_opt = f_matches_m_opt = [1, 2, 1, 2, 3, 4, 3, 4]
    m_matches_f_opt = f_matches_f_opt = [3, 4, 3, 4, 1, 2, 1, 2]
    m_indptr = f_indptr = [1, 3, 5, 7, 9]
    d = Dict(
        "s_prefs" => m_prefs,
        "c_prefs" => f_prefs,
        "s_caps" => m_caps,
        "c_caps" => f_caps,
        "s_matches_s_opt" => m_matches_m_opt,
        "c_matches_s_opt" => f_matches_m_opt,
        "s_matches_c_opt" => m_matches_f_opt,
        "c_matches_c_opt" => f_matches_f_opt,
        "s_indptr" => m_indptr,
        "c_indptr" => f_indptr,
    )
    push!(matchings_many_to_many, d)

    # Test case: many-to-one
    # From Gusfield and Irving (1989, Section 1.6.5)

    m = 11  # Number of students
    n = 5   # Number of colleges

    # Students' preference orders over colleges 1, ..., 5 and unmatched 0
    s_prefs = [3, 1, 5, 4, 0, 2,
               1, 3, 4, 2, 5, 0,
               4, 5, 3, 1, 2, 0,
               3, 4, 1, 5, 0, 2,
               1, 4, 2, 0, 3, 5,
               4, 3, 2, 1, 5, 0,
               2, 5, 1, 3, 0, 4,
               1, 3, 2, 5, 4, 0,
               4, 1, 5, 0, 2, 3,
               3, 1, 5, 2, 4, 0,
               5, 4, 1, 3, 2, 0]
    s_prefs = reshape(s_prefs, n+1, m)

    # Colleges' preference orders over students 1, ..., 11 and unmatched 0
    c_prefs = [3, 7, 9, 11, 5, 4, 10, 8, 6, 1,
               2, 0, 5, 7, 10, 6, 8, 2, 3, 11,
               0, 1, 4, 9, 11, 6, 8, 3, 2, 4,
               7, 1, 10, 0, 5, 9, 10, 1, 2, 11,
               4, 9, 5, 3, 6, 8, 0, 7, 2, 4,
               10, 7, 6, 1, 8, 3, 11, 9, 0, 5]
    c_prefs = reshape(c_prefs, m+1, n)

    # Capacities for colleges
    caps = [4, 1, 3, 2, 1]
    indptr = [1, 5, 6, 9, 11, 12]

    # Optimal stable matchings
    s_matches_s_opt = [3, 1, 4, 3, 1, 3, 2, 1, 4, 1, 5]
    c_matches_s_opt = [2, 5, 8, 10, 7, 1, 4, 6, 3, 9, 11]
    s_matches_c_opt = [4, 4, 3, 1, 1, 3, 2, 2, 3, 1, 5, 1]
    c_matches_c_opt = [4, 5, 9, 11, 7, 3, 6, 8, 1, 2, 10]

    d = Dict(
        "s_prefs" => s_prefs,
        "c_prefs" => c_prefs,
        "caps" => caps,
        "s_matches_s_opt" => s_matches_s_opt,
        "c_matches_s_opt" => c_matches_s_opt,
        "s_matches_c_opt" => s_matches_c_opt,
        "c_matches_c_opt" => c_matches_c_opt,
        "indptr" => indptr,
    )
    push!(matchings_many_to_one, d)

    # Test case: many-to-one; from Roth and Sotomayor Page 16
    m, n = 7, 5
    s_prefs = [
        5, 1, 0, 2, 3, 4,
        2, 5, 1, 0, 3, 4,
        3, 1, 0, 2, 4, 5,
        4, 1, 0, 2, 3, 5,
        1, 2, 0, 3, 4, 5,
        1, 3, 0, 2, 4, 5,
        1, 3, 4, 0, 2, 6,
    ]
    s_prefs = reshape(s_prefs, n+1, m)
    c_prefs = [
        1, 2, 3, 4, 5, 6, 7, 0,
        5, 2, 0, 1, 3, 4, 6, 7,
        6, 7, 3, 0, 1, 2, 4, 5,
        7, 4, 0, 1, 2, 3, 5, 6,
        2, 1, 0, 3, 4, 5, 6, 7,
    ]
    c_prefs = reshape(c_prefs, m+1, n)
    caps = [3, 1, 1, 1, 1]
    indptr = [1, 4, 5, 6, 7,  8]
    s_matches_s_opt = [5, 2, 3, 4, 1, 1, 1]
    c_matches_s_opt = [5, 6, 7, 2, 3, 4, 1]
    s_matches_c_opt = [1, 5, 1, 1, 2, 3, 4]
    c_matches_c_opt = [1, 3, 4, 5, 6, 7, 2]
    d = Dict(
        "s_prefs" => s_prefs,
        "c_prefs" => c_prefs,
        "caps" => caps,
        "s_matches_s_opt" => s_matches_s_opt,
        "c_matches_s_opt" => c_matches_s_opt,
        "s_matches_c_opt" => s_matches_c_opt,
        "c_matches_c_opt" => c_matches_c_opt,
        "indptr" => indptr,
    )
    push!(matchings_many_to_one, d)


    @testset "deferred_acceptance: one-to-one" begin
        for d in matchings_one_to_one
            # Male proposal
            m_matches, f_matches =
                deferred_acceptance(d["m_prefs"], d["f_prefs"])
            @test m_matches == d["m_matches_m_opt"]
            @test f_matches == d["f_matches_m_opt"]

            # Female proposal
            f_matches, m_matches =
                deferred_acceptance(d["f_prefs"], d["m_prefs"])
            @test m_matches == d["m_matches_f_opt"]
            @test f_matches == d["f_matches_f_opt"]
        end
    end

    @testset "deferred_acceptance: many-to-one" begin
        for d in matchings_many_to_one
            # Default (Student proposal)
            s_matches, c_matches, indptr =
                deferred_acceptance(d["s_prefs"], d["c_prefs"], d["caps"])
            sort_matches!(c_matches, indptr)
            @test s_matches == d["s_matches_s_opt"]
            @test c_matches == d["c_matches_s_opt"]
            @test indptr == d["indptr"]

            # Student proposal
            s_matches, c_matches, indptr =
                deferred_acceptance(d["s_prefs"], d["c_prefs"], d["caps"],
                                    SProposing)
            sort_matches!(c_matches, indptr)
            @test s_matches == d["s_matches_s_opt"]
            @test c_matches == d["c_matches_s_opt"]
            @test indptr == d["indptr"]

            # College proposal
            s_matches, c_matches, indptr =
                deferred_acceptance(d["s_prefs"], d["c_prefs"], d["caps"],
                                    CProposing)
            sort_matches!(c_matches, indptr)
            @test s_matches == d["s_matches_c_opt"]
            @test c_matches == d["c_matches_c_opt"]
            @test indptr == d["indptr"]
        end
    end

    @testset "deferred_acceptance: many-to-many" begin
        for d in matchings_many_to_many
            # Student proposal
            s_matches, c_matches, s_indptr, c_indptr =
                deferred_acceptance(d["s_prefs"], d["c_prefs"],
                                    d["s_caps"], d["c_caps"])
            sort_matches!(s_matches, s_indptr)
            sort_matches!(c_matches, c_indptr)
            @test s_matches == d["s_matches_s_opt"]
            @test c_matches == d["c_matches_s_opt"]
            @test s_indptr == d["s_indptr"]
            @test c_indptr == d["c_indptr"]

            # Course proposal
            c_matches, s_matches, c_indptr, s_indptr =
                deferred_acceptance(d["c_prefs"], d["s_prefs"],
                                    d["c_caps"], d["s_caps"])
            sort_matches!(s_matches, s_indptr)
            sort_matches!(c_matches, c_indptr)
            @test s_matches == d["s_matches_c_opt"]
            @test c_matches == d["c_matches_c_opt"]
            @test s_indptr == d["s_indptr"]
            @test c_indptr == d["c_indptr"]
        end
    end

    # Invalid inputs

    @testset "prefs arrays inconsistent shapes" begin
        prop_prefs = [1 1;
                      2 2]
        resp_prefs = [1 1;
                      2 2]
        @test_throws ArgumentError deferred_acceptance(prop_prefs, resp_prefs)
    end

    @testset "caps inconsistent length" begin
        prop_prefs = [1 1;
                      2 2;
                      0 0]
        resp_prefs = [1 1;
                      2 2;
                      0 0]
        caps = [2, 1, 2]
        @test_throws ArgumentError deferred_acceptance(
            prop_prefs, resp_prefs, caps
        )
    end

end

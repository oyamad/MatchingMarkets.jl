@testset "Testing deferred_acceptance.jl" begin

    @testset "deferred_acceptance: one-to-one" begin
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
        m_matched_expected = [1, 2, 3, 0]
        f_matched_expected = [1, 2, 3]

        # Male proposal
        m_matched_computed, f_matched_computed =
            deferred_acceptance(m_prefs, f_prefs)
        @test m_matched_computed == m_matched_expected
        @test f_matched_computed == f_matched_expected

        # Female proposal
        f_matched_computed, m_matched_computed =
            deferred_acceptance(f_prefs, m_prefs)
        @test m_matched_computed == m_matched_expected
        @test f_matched_computed == f_matched_expected
    end

    @testset "deferred_acceptance: many-to-one with caps 1" begin
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

        # Capacities for females
        caps = [1, 1, 1]
        indptr_expected = [1, 2, 3, 4]

        # Unique stable matching
        m_matched_expected = [1, 2, 3, 0]
        f_matched_expected = [1, 2, 3]

        # Male proposal
        m_matched_computed, f_matched_computed, indptr_computed =
            deferred_acceptance(m_prefs, f_prefs, caps)
        @test m_matched_computed == m_matched_expected
        @test f_matched_computed == f_matched_expected
        @test indptr_computed == indptr_expected
    end

    @testset "deferred_acceptance: many-to-one" begin
        # From http://www.columbia.edu/~js1353/pubs/qst-many-to-one.pdf
        # Originally from Gusfield and Irving (1989, Section 1.6.5)

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
        indptr_expected = [1, 5, 6, 9, 11, 12]

        # Unique stable matching
        s_matched_expected = [3, 1, 4, 3, 1, 3, 2, 1, 4, 1, 5]
        c_matched_expected = [2, 5, 8, 10, 7, 1, 4, 6, 3, 9, 11]

        # Male proposal
        s_matched_computed, c_matched_computed, indptr_computed =
            deferred_acceptance(s_prefs, c_prefs, caps)
        @test s_matched_computed == s_matched_expected
        @test indptr_computed == indptr_expected

        # Sort matched students for each college
        for j in 1:n
            sort!(sub(c_matched_computed,
                      indptr_expected[j]:indptr_expected[j+1]-1)
            )
        end
        @test c_matched_computed == c_matched_expected
    end

end

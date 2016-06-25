@testset "Testing deferred_acceptance.jl" begin

    @testset "deferred_acceptance" begin
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

end

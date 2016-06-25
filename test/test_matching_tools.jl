@testset "Testing matching_tools.jl" begin

    @testset "random_prefs for one-to-one" begin
        nums = (8, 6)
        prefs_arrays = random_prefs(nums..., allow_unmatched=false)
        prefs_arrays_allowed = random_prefs(nums..., allow_unmatched=true)
        prefs_arrays_all = tuple(prefs_arrays..., prefs_arrays_allowed...)

        @testset "size" begin
            for (i, prefs_array) in enumerate(prefs_arrays_all)
                @test size(prefs_array) == (nums[i%2+1]+1, nums[(i+1)%2+1])
            end
        end

        @testset "permutation" begin
            sorted_arrays = [repmat(0:nums[i%2+1], 1, nums[i]) for i in 1:2]
            for (i, prefs_array) in enumerate(prefs_arrays_all)
                @test sort(prefs_array, 1) == sorted_arrays[(i+1)%2+1]
            end
        end

        @testset "unmatched not allowed" begin
            for prefs_array in prefs_arrays
                @test all(prefs_array[end, :] .== 0)
            end
        end

        @testset "unmatched not most preferred" begin
            for prefs_array in prefs_arrays_allowed
                @test all(prefs_array[1, :] .!= 0)
            end
        end
    end

    @testset "random_prefs for many-to-one" begin
        nums = (8, 6)
        s_prefs, c_prefs, caps =
            random_prefs(nums..., ReturnCaps, allow_unmatched=false)
        s_prefs_allowed, c_prefs_allowed, caps_allowed =
            random_prefs(nums..., ReturnCaps, allow_unmatched=true)
        prefs_arrays_all = (s_prefs, c_prefs, s_prefs_allowed, c_prefs_allowed)

        @testset "permutation" begin
            sorted_arrays = [repmat(0:nums[i%2+1], 1, nums[i]) for i in 1:2]
            for (i, prefs_array) in enumerate(prefs_arrays_all)
                @test sort(prefs_array, 1) == sorted_arrays[(i+1)%2+1]
            end
        end

        @testset "permutation" begin
            sorted_arrays = [repmat(0:nums[i%2+1], 1, nums[i]) for i in 1:2]
            for (i, prefs_array) in enumerate(prefs_arrays_all)
                @test sort(prefs_array, 1) == sorted_arrays[(i+1)%2+1]
            end
        end

        @testset "unmatched not allowed" begin
            for prefs_array in (s_prefs, c_prefs)
                @test all(prefs_array[end, :] .== 0)
            end
        end

        @testset "unmatched not most preferred" begin
            for prefs_array in (s_prefs_allowed, c_prefs_allowed)
                @test all(prefs_array[1, :] .!= 0)
            end
        end

        @testset "caps positive" begin
            for x in (caps, caps_allowed)
                @test all(x .> 0)
            end
        end

        @testset "caps not exceed rankings of unmatched" begin
            for (prefs_array, x) in ((c_prefs, caps),
                                     (c_prefs_allowed, caps_allowed))
                rankings_unmatched = findn(prefs_array .== 0)[1]
                @test all(x .<= rankings_unmatched)
            end
        end
    end

end

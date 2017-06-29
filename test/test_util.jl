using MatchingMarkets.Util

@testset "Testing util.jl" begin

    @testset "binary max heap" begin
        bh1 = Util.BinMaxHeap(10)
        bh2 = Util.BinMaxHeap(10)
        bh3 = Util.BinMaxHeap(10)
        bh4 = Util.BinMaxHeap(10)
        bh5 = Util.BinMaxHeap(10)

        @testset "empty heap equality" begin
            @test bh1 == bh2
        end

        @testset "accessing an empty heap" begin
            @test_throws BoundsError Util.top(bh1)
        end

        @testset "pop! from an empty heap" begin
            @test_throws BoundsError Util.pop!(bh1)
        end

        @testset "heap ordered" begin
            for i in [3, 2, 10, 6, 5, 9, 7, 1, 4, 8]
                Util.push!(bh2, i)
            end
            for i in 10:-1:1
                @test Util.pop!(bh2) == i
            end
            for i in [1, 8, 2, 3, 6, 5, 4, 7, 10, 9]
                Util.push!(bh2, i)
            end
            for i in 10:-1:1
                @test Util.pop!(bh2) == i
            end
        end

        @testset "length of heap" begin
            for i in 1:10
                Util.push!(bh3, i)
                @test length(bh3) == i
            end
        end

        @testset "pushing to full heap not allowed" begin
            for i in 1:10
                Util.push!(bh4, i)
            end
            @test_throws BoundsError Util.push!(bh4, 11)
        end

        @testset "least replacement" begin
            for i in 10:-1:1
                Util.push!(bh5, i)
            end
            Util.replace_least!(bh5, 11)
            @test Util.top(bh5) == 11
            Util.replace_least!(bh5, 10)
            @test Util.top(bh5) == 10
            Util.replace_least!(bh5, 9)
            @test Util.top(bh5) == 9
        end
    end

end

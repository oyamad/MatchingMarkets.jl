import MatchingMarkets.Util: BinMaxHeap, top, push!, pop!, replace_least!

@testset "Testing util.jl" begin

    @testset "binary max heap" begin
        bh1 = BinMaxHeap(10)
        bh2 = BinMaxHeap(10)
        bh3 = BinMaxHeap(10)
        bh4 = BinMaxHeap(10)
        bh5 = BinMaxHeap(10)

        @testset "empty heap equality" begin
            @test bh1 == bh2
        end

        @testset "accessing an empty heap" begin
            @test_throws BoundsError top(bh1)
        end

        @testset "pop! from an empty heap" begin
            @test_throws BoundsError pop!(bh1)
        end

        @testset "heap ordered" begin
            for i in [3, 2, 10, 6, 5, 9, 7, 1, 4, 8]
                push!(bh2, i)
            end
            for i in 10:-1:1
                @test pop!(bh2) == i
            end
            for i in [1, 8, 2, 3, 6, 5, 4, 7, 10, 9]
                push!(bh2, i)
            end
            for i in 10:-1:1
                @test pop!(bh2) == i
            end
        end

        @testset "length of heap" begin
            for i in 1:10
                push!(bh3, i)
                @test length(bh3) == i
            end
        end

        @testset "pushing to full heap not accepted" begin
            for i in 1:10
                push!(bh4, i)
            end
            @test_throws BoundsError push!(bh4, 11)
        end
    end

end

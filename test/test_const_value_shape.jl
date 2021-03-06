# This file is a part of ValueShapes.jl, licensed under the MIT License (MIT).

using ValueShapes
using Test
using ArraysOfArrays


@testset "const_value_shape" begin

    @inferred(size(ConstValueShape(42))) == ()
    @inferred(eltype(ConstValueShape(42))) == Int
    @inferred(totalndof(ConstValueShape(42))) == 0

    @inferred(size(ConstValueShape(rand(2,3)))) == (2,3)
    @inferred(ValueShapes.default_unshaped_eltype(ConstValueShape(rand(Float32,2,3)))) == Float32
    @inferred(totalndof(ConstValueShape(rand(2,3)))) == 0

    @test @inferred(ConstValueShape([1 4; 3 2])(undef)) == [1 4; 3 2]
    @test @inferred(ConstValueShape([1 4; 3 2])(Int[])) == [1 4; 3 2]

    data = [1 4; 3 2]
    shape = ConstValueShape([1 4; 3 2])

    @test typeof(@inferred(Vector{Int32}(undef, shape))) == Vector{Int32}
    @test size(@inferred(Vector{Int32}(undef, shape))) == (0,)

    @test @inferred(length(shape)) == 4

    @test @inferred(ValueShapes.shaped_type(shape, Real)) == typeof(data)

    @test @inferred (ConstValueShape(4.0) <= ConstValueShape(4.0)) == true
    @test @inferred (ConstValueShape(4.0) >= ConstValueShape{AbstractFloat}(4.0)) == false
    @test @inferred (ConstValueShape{AbstractFloat}(4.0) >= ConstValueShape(4.0)) == true
    @test @inferred (ConstValueShape(4) <= ConstValueShape(5)) == false

    @test @inferred(unshaped(4.2, ConstValueShape(4.2))) == Float32[]
    @test_throws ArgumentError unshaped(4.3, ConstValueShape(4.2))

    vecs_of_vecs = VectorOfSimilarVectors(reshape(collect(1:22), 11, 2))
    va = ValueAccessor(ArrayShape{Real}(11,1), 0)
    bcv = ValueShapes._bcasted_view(vecs_of_vecs, va)
    for (index,value) in enumerate(bcv[1])
        @test value == vecs_of_vecs[1][index]
    end
    aosv = ArrayOfSimilarVectors([ [1,2,3] [4,5,6] ])
    va = ValueAccessor(ConstValueShape{Real}(1), 0)
    inds = getindex.(aosv, Ref(va))
    for i in inds
        @test i == 1
    end
    views = view.(aosv, Ref(va))
    @test views === inds
end

using Aqua
using JET
using JuliaFormatter
using WarcraftGridGraphs
using Test

@testset "WarcraftGridGraphs.jl" begin
    @testset "Formalities" begin
        @test JuliaFormatter.format(WarcraftGridGraphs)
        Aqua.test_all(WarcraftGridGraphs)
        JET.test_package(WarcraftGridGraphs; target_defined_modules=true)
    end
    @testset "Correctness" begin
        include("correctness.jl")
    end
end

using SimulationsProjet
using Test

@testset "SimulationsProjet.jl" begin
    include("matchs.jl")
    include("equipe.jl")
    include("module.jl")
    include("modeles.jl")
    include("simulation.jl")
    include("statistiques.jl")
end

nothing
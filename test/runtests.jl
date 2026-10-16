using SimulationsProjet
using Test

@testset "SimulationsProjet.jl" begin
    include("test_matchs.jl")
    include("test_equipe.jl")
    include("test_module.jl")
    include("test_modeles.jl")
    include("test_simulation.jl")
    include("test_statistiques.jl")
end

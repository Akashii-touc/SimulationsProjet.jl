module SimulationsProjet

using CSV, DataFrames, Statistics, Distributions, Random

    include("modeles.jl")
    include("equipe.jl")
    include("matchs.jl")
    include("simulation.jl")
    include("statistiques.jl")

end

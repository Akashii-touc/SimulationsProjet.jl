module SimulationsProjet

using CSV, DataFrames, Statistics, Distributions, Random

#Les CSV sont lus au chargement : on les déclare pour que Julia recompile quand ils changent
for fichier in ["classement_club.csv", "tirs_au_but.csv", "matchs.csv"]
    include_dependency(joinpath(@__DIR__, "../fichier", fichier))
end

include("equipe.jl")
include("modeles.jl")
include("simulation.jl")
include("matchs.jl")
include("statistiques.jl")


end

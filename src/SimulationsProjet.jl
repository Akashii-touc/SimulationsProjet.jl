module SimulationsProjet

using CSV, DataFrames, Statistics, Distributions, Random

const CALENDRIER = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)
const CLASSEMENT = CSV.read(joinpath(@__DIR__, "../fichier/classement_club.csv"), DataFrame; stringtype = String)
const STATS_TAB = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame; stringtype = String)

const FORCE_BRUT = 0.8 * CLASSEMENT.Coeff_club + 0.2 * CLASSEMENT.Coeff_pays
const POIDS_CLUBS_COEFF = round.((FORCE_BRUT .- mean(FORCE_BRUT)) ./ (maximum(FORCE_BRUT) - minimum(FORCE_BRUT)), digits = 5)

include("equipe.jl")
include("modeles.jl")
include("simulation.jl")
include("matchs.jl")
include("statistiques.jl")


end

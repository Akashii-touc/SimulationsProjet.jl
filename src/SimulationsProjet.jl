module SimulationsProjet

using CSV, DataFrames, Statistics, Distributions, Random


const CALENDRIER = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)
const CLASSEMENT = CSV.read(joinpath(@__DIR__, "../fichier/classement_club.csv"), DataFrame; stringtype = String)
const STATS_TAB = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame; stringtype = String)
const FORCE_BRUT = 0.8 * CLASSEMENT.Coeff_club + 0.2 * CLASSEMENT.Coeff_pays
const POIDS_CLUBS_COEFF = round.((FORCE_BRUT .- mean(FORCE_BRUT)) ./ (maximum(FORCE_BRUT) - minimum(FORCE_BRUT)), digits = 5)


export ModelePoisson, ModelePoissonBivariee, ModeleDixonColes, ModeleBinomialeNegative, τ
export Equipe, equipes, proba_tab, poids_club, modif_equipe
export rand, league_phase, knockout_phase, home_away_match, buts, final, equipe_qualifiee, shootout
export classement_stats, pourcentage

export  CALENDRIER, CLASSEMENT, STATS_TAB, FORCE_BRUT, POIDS_CLUBS_COEFF




include("equipe.jl")
include("modeles.jl")
include("simulation.jl")
include("matchs.jl")
include("statistiques.jl")


end

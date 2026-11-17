module SimulationsProjet
    using CSV, DataFrames, Statistics, Distributions, Random, Makie, WGLMakie
    
    for fichier in ["classement_club.csv", "tirs_au_but.csv", "matchs.csv"]
        include_dependency(joinpath(@__DIR__, "../fichier", fichier))
    end

    const CALENDRIER = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)
    const CLASSEMENT = CSV.read(joinpath(@__DIR__, "../fichier/classement_club.csv"), DataFrame; stringtype = String)
    const STATS_TAB = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame; stringtype = String)
    const FORCE_BRUT = 0.8 * CLASSEMENT.Coeff_club + 0.2 * CLASSEMENT.Coeff_pays
    const POIDS_CLUBS_COEFF = round.((FORCE_BRUT .- mean(FORCE_BRUT)) ./ (maximum(FORCE_BRUT) - minimum(FORCE_BRUT)), digits = 5)

    export ModelePoisson, ModelePoissonBivariee, ModeleDixonColes, ModeleBinomialeNegative, τ
    export Equipe, equipes, proba_tab, poids_club, modif_equipe
    export league_phase, knockout_phase, home_away_match, buts, final, equipe_qualifiee, shootout, voie, arbre
    export classement_stats, pourcentage
    export graphique_chances, comparaison_modeles
    export launch, interface
    export RESULTATS, calculer_resultats, NOMS_MODELES, NOMS_POIDS, NB_RUN_DEFAULT

    export  CALENDRIER, CLASSEMENT, STATS_TAB, FORCE_BRUT, POIDS_CLUBS_COEFF

    include("equipe.jl")
    include("modeles.jl")
    include("simulation.jl")
    include("matchs.jl")
    include("statistiques.jl")
    include("graphiques.jl")


    const NB_RUN_DEFAULT = 10000
    const NOMS_MODELES = ["Poisson", "Poisson bivariée", "Binomiale négative", "Dixon-Coles"]
    const OPTION_MODELES = Dict("Poisson" => ModelePoisson(), "Poisson bivariée" => ModelePoissonBivariee(), "Binomiale négative" => ModeleBinomialeNegative(), "Dixon-Coles" => ModeleDixonColes())
    const NOMS_POIDS = ["Coefficient UEFA", "Elo"]
    const OPTION_POIDS = Dict("Coefficient UEFA" => "Coefficient_UEFA", "Elo" => "Elo")

    const RESULTATS = Dict{Tuple{String, String}, DataFrame}()

    function calculer_resultats(;seed = nothing)
        for nom_modele in NOMS_MODELES, nom_poids in NOMS_POIDS
            RESULTATS[(nom_modele, nom_poids)] = classement_stats(rand(NB_RUN_DEFAULT, OPTION_MODELES[nom_modele], OPTION_POIDS[nom_poids]; seed = seed))
        end
        return RESULTATS
    end
    include("interface.jl")
end
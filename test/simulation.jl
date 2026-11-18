# Tests complémentaires des voies, des affiches et des invariants d'une saison.

equipe_arbre(n) = Equipe(string(n), "FR", 0, 0, 0, 0, 0, Float64(n), 0, 0.75)

@testset "voies et placements dans l'arbre" begin
    equipes_classees = [equipe_arbre(i) for i in 1:24]
    voie_argent, voie_bleue = voie(equipes_classees)

    @test length(voie_argent) == 12
    @test length(voie_bleue) == 12
    rangs_argent = parse.(Int, getfield.(voie_argent, :club))
    rangs_bleue = parse.(Int, getfield.(voie_bleue, :club))
    @test sort(vcat(rangs_argent, rangs_bleue)) == collect(1:24)

    groupes_tetes = [(5, 6), (3, 4), (7, 8), (1, 2)]
    groupes_barragistes = [(21, 22), (11, 12), (19, 20), (13, 14),(23, 24), (9, 10), (17, 18), (15, 16)]
    for voie_courante in (voie_argent, voie_bleue)
        rangs = parse.(Int, getfield.(voie_courante, :club))
        for i in 1:4
            @test rangs[i] in groupes_tetes[i]
        end
        for i in 1:8
            @test rangs[i + 4] in groupes_barragistes[i]
        end
    end
    @test_throws ErrorException voie(equipes_classees[1:23])

    tetes = [equipe_arbre(i) for i in 1:4]
    barragistes = [equipe_arbre(i + 10) for i in 1:4]
    arbre_test = arbre(tetes, barragistes)
    @test length(arbre_test) == 8
    for i in 1:4
        @test arbre_test[2i - 1] === barragistes[i]
        @test arbre_test[2i] === tetes[i]
    end
    @test_throws ErrorException arbre(tetes[1:3], barragistes)
end

@testset "seed" begin
    @test rand(3, ModelePoisson(); seed = 1) == rand(3, ModelePoisson(); seed = 1)
    @test rand(3, ModelePoisson(); seed = 1) != rand(3, ModelePoisson(); seed = 2)
end

@testset "rand avec plusieurs threads" begin
    resultats = rand(20, ModelePoisson(); seed = 3)
    @test length(resultats) == 36
    @test all(length(rangs) == 20 for (rangs, points, parcours) in values(resultats))
    @test sum(count(==(6), parcours) for (rangs, points, parcours) in values(resultats)) == 20
end

@testset "calendrier précalculé" begin
    @test length(SimulationsProjet.MATCHS) == 144
    @test all(dom != ext for (dom, ext) in SimulationsProjet.MATCHS)
end

@testset "poids stables sur une saison" begin
    #les poids ne doivent plus exploser (bug Elo : λ de l'ordre de 1e27 et InexactError dans Poisson)
    for poids in (PoidsUEFA(), PoidsElo())
        modele = ModeleDixonColes()
        classement = jouer(PhaseLigue(), modele, poids)
        jouer(PhaseEliminatoire(), classement, modele, poids)
        poids_clubs = [e.poids for e in classement]
        @test maximum(poids_clubs) - minimum(poids_clubs) < 5
    end
    @test length(rand(50, ModeleDixonColes(), PoidsElo())) == 36
end
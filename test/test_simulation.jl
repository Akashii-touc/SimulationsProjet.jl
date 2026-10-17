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

@testset "invariants d'une saison complète" begin
    classement = league_phase(ModelePoisson())
    @test length(classement) == 36
    @test all(equipe -> equipe.mj == 8, classement)
    @test sum(equipe.mj for equipe in classement) == 36 * 8
    @test sum(equipe.db for equipe in classement) == 0
    @test sum(equipe.buts_pour for equipe in classement) == sum(equipe.buts_contre for equipe in classement)
    @test 36 * 8 <= sum(equipe.points for equipe in classement) <= 36 * 12

    knockout_phase(classement, ModelePoisson())
    parcours = getfield.(classement, :parcours)
    @test all(p -> 0 <= p <= 6, parcours)
    @test count(==(6), parcours) == 1
    @test_throws ErrorException knockout_phase(classement[1:35], ModelePoisson())
end

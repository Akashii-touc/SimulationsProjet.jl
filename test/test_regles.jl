const S = SimulationsProjet

if !isdefined(S, :tirs_au_but)
    Base.include(S, joinpath(@__DIR__, "../src/regles.jl"))
end

equipe(nom, poids) = S.Equipe(nom, "FR", 0, 0, 0, 0, 0, poids, 0)

@testset "calcul_score_terrain" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    score = S.calcul_score_terrain(A, B)
    @test length(score) == 2
    @test score[1] >= 0
    @test score[2] >= 0

    n = 20000
    dom = 0
    ext = 0
    for i in 1:n
        s = S.calcul_score_terrain(A, B)
        dom += s[1]
        ext += s[2]
    end
    @test dom / n > ext / n
    @test isapprox(dom / n, exp(S.avantage_terrain), atol = 0.05)

    dom = 0
    ext = 0
    for i in 1:n
        s = S.calcul_score_terrain(A, B, true)
        dom += s[1]
        ext += s[2]
    end
    @test isapprox(dom / n, 1.0, atol = 0.05)
    @test isapprox(ext / n, 1.0, atol = 0.05)
end

@testset "prolongation" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    n = 20000
    total = 0
    for i in 1:n
        s = S.prolongation(A, B, true)
        total += s[1] + s[2]
    end
    @test isapprox(total / n, 2/3, atol = 0.05)
end

@testset "tirs_au_but" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    @test S.tirs_au_but(A, B) isa Bool
    n = 20000
    victoires = 0
    for i in 1:n
        if S.tirs_au_but(A, B)
            victoires += 1
        end
    end
    @test isapprox(victoires / n, 0.5, atol = 0.02)

    A.proba_tab = 1.0
    B.proba_tab = 0.0
    @test S.tirs_au_but(A, B) == true
    @test S.tirs_au_but(B, A) == false
end

@testset "proba_tab" begin
    @test equipe("A", 0.0).proba_tab == 0.75
    @test S.proba_tab("Inconnu") == 0.75
    @test S.equipes()["Bayern"].proba_tab == S.proba_tab("Bayern")

    ligne = findfirst(==("Bayern"), S.stats_tab.Club)
    tentes = S.stats_tab.tirs_tentes[ligne]
    reussis = S.stats_tab.tirs_reussis[ligne]
    S.stats_tab.tirs_tentes[ligne] = 10
    S.stats_tab.tirs_reussis[ligne] = 10
    @test S.proba_tab("Bayern") == 0.875
    S.stats_tab.tirs_tentes[ligne] = tentes
    S.stats_tab.tirs_reussis[ligne] = reussis
end

@testset "match_aller_retour" begin
    A = equipe("A", 0.5)
    B = equipe("B", -0.5)
    gagnant = S.match_aller_retour(A, B)
    @test gagnant === A || gagnant === B
    @test A.parcours + B.parcours == 1
    @test gagnant.parcours == 1
end

@testset "match_finale" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    gagnant = S.match_finale(A, B)
    @test gagnant === A || gagnant === B
    @test A.parcours + B.parcours == 1

    n = 20000
    victoires_A = 0
    for i in 1:n
        if S.match_finale(A, B) === A
            victoires_A += 1
        end
    end
    @test isapprox(victoires_A / n, 0.5, atol = 0.02)
end

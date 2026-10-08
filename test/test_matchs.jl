const S = SimulationsProjet

equipe(nom, poids) = S.Equipe(nom, "FR", 0, 0, 0, 0, 0, poids, 0)

#Moyenne des buts de A et de B sur n tirages de f()
function moyennes(f, n = 20000)
    total_A = 0
    total_B = 0
    for i in 1:n
        a, b = f()
        total_A += a
        total_B += b
    end
    return(total_A / n, total_B / n)
end

@testset "buts" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    for modele in [S.ModelePoisson(), S.ModelePoissonBivariee(), S.ModeleBinomialeNegative(), S.ModeleDixonColes()]
        a, b = S.buts(A, B, modele)
        @test a isa Integer && b isa Integer
        @test a >= 0 && b >= 0
    end

    moy_A, moy_B = moyennes(() -> S.buts(A, B, S.ModelePoisson()))
    @test isapprox(moy_A, 1.0, atol = 0.05)
    @test isapprox(moy_B, 1.0, atol = 0.05)

    moy_A, moy_B = moyennes(() -> S.buts(A, B, S.ModeleBinomialeNegative()))
    @test isapprox(moy_A, 1.0, atol = 0.05)
    @test isapprox(moy_B, 1.0, atol = 0.05)

    fort = equipe("Fort", 0.5)
    moy_A, moy_B = moyennes(() -> S.buts(fort, B, S.ModelePoisson()))
    @test isapprox(moy_A, exp(0.5), atol = 0.05)
    @test isapprox(moy_B, exp(-0.5), atol = 0.05)
end

@testset "dixon_coles" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    n = 20000

    #La correction ne change pas la moyenne de buts
    moy_A, moy_B = moyennes(() -> S.buts(A, B, S.ModeleDixonColes()))
    @test isapprox(moy_A, 1.0, atol = 0.05)
    @test isapprox(moy_B, 1.0, atol = 0.05)

    #Avec mu_A = mu_B = 1, P(0-0) = P(1-1) = exp(-2) * (1 - rho)
    scores = [S.buts(A, B, S.ModeleDixonColes(-0.1)) for i in 1:n]
    @test isapprox(count(==((0, 0)), scores) / n, exp(-2) * 1.1, atol = 0.01)
    @test isapprox(count(==((1, 1)), scores) / n, exp(-2) * 1.1, atol = 0.01)

    #rho = 0 redonne Poisson
    scores = [S.buts(A, B, S.ModeleDixonColes(0.0)) for i in 1:n]
    @test isapprox(count(==((0, 0)), scores) / n, exp(-2), atol = 0.01)
end

@testset "score_match" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    moy_dom, moy_ext = moyennes(() -> S.score_match(A, B, S.ModelePoisson()))
    @test moy_dom > moy_ext
    @test isapprox(moy_dom, 1.2, atol = 0.05)
    @test isapprox(moy_ext, 1.0, atol = 0.05)
end

@testset "score_prolongation" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    moy_dom, moy_ext = moyennes(() -> S.score_prolongation(A, B, S.ModelePoisson()))
    @test isapprox(moy_dom, 1.2 / 3, atol = 0.03)
    @test isapprox(moy_ext, 1 / 3, atol = 0.03)
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

@testset "equipe_qualifiee" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    @test S.equipe_qualifiee(A, B, 2, 1) === A
    @test S.equipe_qualifiee(A, B, 0, 3) === B
    @test A.parcours == 1
    @test B.parcours == 1

    A.proba_tab = 1.0
    B.proba_tab = 0.0
    @test S.equipe_qualifiee(A, B, 1, 1) === A
    @test S.equipe_qualifiee(B, A, 1, 1) === A
end

@testset "simul_aller_retour" begin
    equipes = [equipe(string(i), 0.0) for i in 1:8]
    qualifiees = S.simul_aller_retour(equipes, S.ModelePoisson())
    @test length(qualifiees) == 4
    @test sum(e.parcours for e in equipes) == 4
    for i in 1:4
        @test qualifiees[i] === equipes[i] || qualifiees[i] === equipes[9 - i]
        @test qualifiees[i].parcours == 1
    end
end

@testset "simul_finale" begin
    A = equipe("A", 0.0)
    B = equipe("B", 0.0)
    gagnant = S.simul_finale([A, B], S.ModelePoisson())
    @test gagnant === A || gagnant === B
    @test A.parcours + B.parcours == 1

    n = 20000
    victoires_A = 0
    for i in 1:n
        if S.simul_finale([A, B], S.ModelePoisson()) === A
            victoires_A += 1
        end
    end
    @test isapprox(victoires_A / n, 0.5, atol = 0.02)
end


@testset "equipes" begin
    for type_poids in ["Coefficient_UEFA", "Elo"]
        d = S.equipes(type_poids)
        @test length(d) == 36
    end
    @test S.equipes("Elo")["Bayern"].poids == 2046 / 400
    @test_throws ErrorException S.equipes("Autre")
end

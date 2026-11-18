using Random

function moyennes(f, n = 5_000)
    total_A = 0
    total_B = 0
    for _ in 1:n
        buts_A, buts_B = f()
        total_A += buts_A
        total_B += buts_B
    end
    return total_A / n, total_B / n
end

@testset "buts" begin
    A = Equipe(club = "A", pays = "FR", poids = 0.5)
    B = Equipe(club = "B", pays = "ES", poids = 0)
    modele = ModelePoisson(μ = 1.0)

    score = buts(A, B, modele)
    @test score isa Tuple{Int64, Int64}
    @test all(>=(0), score)
    @test modele.λ_A == exp(0.5)
    @test modele.λ_B == exp(-0.5)

    # L'avantage s'applique au domicile et la durée réduit les deux intensités.
    buts(A, B, modele; avantage = 1.2, duree = 1 / 3)
    @test isapprox(modele.λ_A, 1.2 * exp(0.5) / 3)
    @test isapprox(modele.λ_B, exp(-0.5) / 3)

    # Une durée nulle ne doit produire aucun but.
    @test buts(A, B, modele; duree = 0.0) == (0, 0)
    @test modele.λ_A == 0.0
    @test modele.λ_B == 0.0

    # Un avantage nul annule seulement l'intensité de l'équipe à domicile.
    @test buts(A, B, modele; avantage = 0.0) isa Tuple{Int64, Int64}
    @test modele.λ_A == 0.0
    @test modele.λ_B > 0.0

    Random.seed!(21)
    moyenne_A, moyenne_B = moyennes(() -> buts(A, B, ModelePoisson(μ = 1.0)))
    @test isapprox(moyenne_A, exp(0.5), atol = 0.08)
    @test isapprox(moyenne_B, exp(-0.5), atol = 0.06)
end

@testset "shootout" begin
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")

    # Des probabilités extrêmes rendent l'issue certaine après les cinq tirs.
    A.proba_tab = 1.0
    B.proba_tab = 0.0
    @test shootout(A, B) === true
    @test shootout(B, A) === false

    A.proba_tab = 0.75
    B.proba_tab = 0.75
    Random.seed!(22)
    @test shootout(A, B) isa Bool
end

@testset "equipe_qualifiee" begin
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")

    @test equipe_qualifiee(A, B, 3, 1) === A
    @test equipe_qualifiee(A, B, 1, 3) === B
    @test (A.parcours, B.parcours) == (1, 1)

    # À égalité, les probabilités de tirs au but départagent les équipes.
    A.proba_tab = 1.0
    B.proba_tab = 0.0
    @test equipe_qualifiee(A, B, 2, 2) === A
    @test equipe_qualifiee(B, A, 2, 2) === A
    @test (A.parcours, B.parcours) == (3, 1)
end

using Random

equipe(nom, poids) = Equipe(nom, "FR", 0, 0, 0, 0, 0, poids, 0, 0.75)

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
    modele = ModelePoisson()

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
    moyenne_A, moyenne_B = moyennes(() -> buts(A, B, ModelePoisson()))
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

@testset "home_away_match" begin
    equipes = [equipe("Equipe $i", i / 10) for i in 1:8]
    Random.seed!(23)
    qualifiees = home_away_match(equipes, ModelePoisson())

    @test length(qualifiees) == 4
    @test sum(e.parcours for e in equipes) == 4
    for i in 1:4
        @test qualifiees[i] === equipes[2i - 1] || qualifiees[i] === equipes[2i]
    end

    # La deuxième équipe reçoit au retour; le modèle conserve les intensités
    # correspondant à ce dernier match.
    barragiste = equipe("Barragiste", 0.0)
    tete_de_serie = equipe("Tête de série", log(2.0))
    modele = ModelePoisson()
    Random.seed!(24)
    home_away_match([barragiste, tete_de_serie], modele)
    @test isapprox(modele.λ_A / modele.λ_B, 1.2 * exp(2 * (tete_de_serie.poids - barragiste.poids)))
end

@testset "final" begin
    A = Equipe(club = "A", pays = "FR", poids = 0)
    B = Equipe(club = "B", pays = "ES", poids = 0)
    Random.seed!(25)

    gagnant = final([A, B], ModelePoisson())
    @test gagnant === A || gagnant === B
    @test A.parcours + B.parcours == 1

    # À forces égales, aucune équipe ne doit être systématiquement favorisée.
    A = Equipe(club = "A", pays = "FR", poids = 0)
    B = Equipe(club = "B", pays = "ES", poids = 0)
    Random.seed!(26)
    victoires_A = count(final([A, B], ModelePoisson()) === A for _ in 1:2_000)
    @test isapprox(victoires_A / 2_000, 0.5, atol = 0.05)
    @test A.parcours + B.parcours == 2_000
end

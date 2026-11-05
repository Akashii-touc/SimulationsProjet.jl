@testset "modif_equipe" begin
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    modif_equipe(A, B, 2, 1)
    @test (A.points, B.points) == (3, 0)
    @test (A.buts_pour, A.buts_contre, A.db) == (2, 1, 1)
    @test (B.buts_pour, B.buts_contre, B.db) == (1, 2, -1)
    @test (A.mj, B.mj) == (1, 1)

    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    modif_equipe(A, B, 1, 1)
    @test (A.points, B.points) == (1, 1)

    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    modif_equipe(A, B, 0, 2)
    @test (A.points, B.points) == (0, 3)
end

@testset "equipes créées pour une nouvelle saison" begin
    premiere = equipes()
    premiere["Bayern"].points = 15
    seconde = equipes()
    @test seconde["Bayern"].points == 0
    @test seconde["Bayern"] !== premiere["Bayern"]
end

@testset "modif_poids Elo" begin
    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 4.5)
    avant = A.poids + B.poids
    SimulationsProjet.modif_poids(A, B, 2, 0, "Elo")
    @test A.poids + B.poids ≈ avant #ce que gagne une équipe, l'autre le perd
    @test A.poids > 5.0
    @test B.poids < 4.5

    #nul entre équipes de même force : rien ne bouge
    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 5.0)
    SimulationsProjet.modif_poids(A, B, 1, 1, "Elo")
    @test A.poids ≈ 5.0
    @test B.poids ≈ 5.0

    #un outsider qui gagne gagne plus qu'un favori qui gagne, et un match déplace le poids de 40/400 au plus
    favori = Equipe(club = "F", pays = "France", poids = 5.0)
    outsider = Equipe(club = "O", pays = "Espagne", poids = 4.0)
    SimulationsProjet.modif_poids(favori, outsider, 1, 0, "Elo")
    gain_favori = favori.poids - 5.0
    favori = Equipe(club = "F", pays = "France", poids = 5.0)
    outsider = Equipe(club = "O", pays = "Espagne", poids = 4.0)
    SimulationsProjet.modif_poids(favori, outsider, 0, 1, "Elo")
    gain_outsider = outsider.poids - 4.0
    @test 0 < gain_favori < gain_outsider <= 0.1
end

@testset "modif_poids coefficient UEFA" begin
    gain_fr = SimulationsProjet.GAIN_POIDS["France"]
    gain_es = SimulationsProjet.GAIN_POIDS["Espagne"]

    #victoire : 2 points, défaite : 0
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 2, 1, "Coefficient_UEFA")
    @test A.poids ≈ 2 * gain_fr
    @test B.poids ≈ 0.0

    #nul : 1 point chacun
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 1, 1, "Coefficient_UEFA")
    @test A.poids ≈ gain_fr
    @test B.poids ≈ gain_es

    #type inconnu : rien ne bouge
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 3, 0, "Aucun")
    @test A.poids == 0.0
    @test B.poids == 0.0
end
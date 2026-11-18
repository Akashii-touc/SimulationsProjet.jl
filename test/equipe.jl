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

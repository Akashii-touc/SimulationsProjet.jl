using Random
using Statistics

@testset "paramètres du modèle de Poisson" begin
    A = Equipe("A", "FR", 0, 0, 0, 0, 0, 0.5, 0, 0.75)
    B = Equipe("B", "ES", 0, 0, 0, 0, 0, 0.0, 0, 0.75)
    modele = ModelePoisson(μ = 1.0)
    buts(A, B, modele; avantage = 1.2, duree = 1 / 3)
    @test isapprox(modele.λ_A, 1.2 * exp(0.5) / 3)
    @test isapprox(modele.λ_B, exp(-0.5) / 3)
end

@testset "partie commune du modèle bivarié" begin
    Random.seed!(42)
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    modele = ModelePoissonBivariee(λ_commun = 0.4)
    scores = [buts(A, B, modele) for _ in 1:10000]
    buts_A = first.(scores)
    buts_B = last.(scores)
    @test cov(buts_A, buts_B) > 0.2
end

@testset "variance de la binomiale négative" begin
    Random.seed!(43)
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    scores = [buts(A, B, ModeleBinomialeNegative(p = 0.5)) for _ in 1:5000]
    @test var(first.(scores)) > mean(first.(scores))
    @test var(last.(scores)) > mean(last.(scores))
end

@testset "correction Dixon-Coles" begin
    @test τ(0, 0, 1.0, 1.0, -0.1) ≈ 1.1
    @test τ(0, 1, 1.0, 1.0, -0.1) ≈ 0.9
    @test τ(1, 0, 1.0, 1.0, -0.1) ≈ 0.9
    @test τ(1, 1, 1.0, 1.0, -0.1) ≈ 1.1
    @test τ(2, 0, 1.0, 1.0, -0.1) == 1.0
    @test τ(0, 0, 1.0, 1.0, 0.0) == 1.0
end

@testset "μ multiplie les moyennes" begin
    A = Equipe(club = "A", pays = "FR")
    B = Equipe(club = "B", pays = "ES")
    modele = ModelePoisson(μ = 1.5)
    buts(A, B, modele)
    @test modele.λ_A == 1.5
    @test modele.λ_B == 1.5
end

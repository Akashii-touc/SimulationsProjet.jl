@testset "pourcentage" begin
    rangs = [1, 8, 9, 24, 25]
    @test pourcentage(r -> r <= 8, rangs) == 40.0
    @test pourcentage(r -> r > 24, rangs) == 20.0
end

@testset "classement_stats" begin
    donnees = Dict("A" => ([1, 9], [3, 6], [2, 6]))
    resultat = redirect_stdout(devnull) do
        classement_stats(donnees)
    end
    @test isnothing(resultat)
end

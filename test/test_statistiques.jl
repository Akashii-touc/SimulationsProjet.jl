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
    @test resultat.Club == ["A"]
    @test resultat.xPoints == [4.5]
    @test resultat.Top8 == [50.0]
end


@testset "graphiques" begin
    df = classement_stats(rand(20, ModelePoisson(); seed = 1))
    @test graphique_chances(df) isa SimulationsProjet.Makie.Figure
    @test comparaison_modeles(20) isa SimulationsProjet.Makie.Figure
end

@testset "données du projet" begin
    @test size(CALENDRIER) == (18, 8)
    @test size(CLASSEMENT, 1) == 36
    @test size(STATS_TAB, 1) == 36
    @test length(unique(CLASSEMENT.Club)) == 36
end

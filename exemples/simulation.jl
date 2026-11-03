using SimulationsProjet


stats_poisson = classement_stats(rand(10000, ModelePoisson()))

stats_poisson_biv = classement_stats(rand(10000, ModelePoissonBivariee()))

stats_bin = classement_stats(rand(10000, ModeleBinomialeNegative()))

stats_dc = classement_stats(rand(1000000, ModeleDixonColes()))

stats_elo_dc = classement_stats(rand(10000, ModeleDixonColes(), "Elo"))
using SimulationsProjet


classement_stats(rand(10000, ModelePoisson()))

classement_stats(rand(10000, ModelePoissonBivariee()))

classement_stats(rand(10000, ModeleBinomialeNegative()))

classement_stats(rand(10000, ModeleDixonColes()))

classement_stats(rand(10000, ModeleDixonColes(), "Elo"))

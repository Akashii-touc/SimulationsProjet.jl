using SimulationsProjet


show(classement_stats(rand(10000, ModelePoisson())), allrows = true, allcols = true)

show(classement_stats(rand(10000, ModelePoissonBivariee())), allrows = true, allcols = true)

show(classement_stats(rand(10000, ModeleBinomialeNegative())), allrows = true, allcols = true)

show(classement_stats(rand(1000000, ModeleDixonColes())), allrows = true, allcols = true)

show(classement_stats(rand(10000, ModeleDixonColes(), "Elo")), allrows = true, allcols = true)
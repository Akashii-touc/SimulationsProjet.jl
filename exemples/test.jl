using SimulationsProjet


println("================================================")
println("Simulation pour avec une loi de Poisson")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000, SimulationsProjet.ModelePoisson()))
println("")
println("================================================")
println("================================================")
println("Simulation pour avec une loi de Poisson Bivariee")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000, SimulationsProjet.ModelePoissonBivariee()))
println("")
println("================================================")
println("================================================")
println("Simulation pour avec une loi Binomiale Negative")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000, SimulationsProjet.ModeleBinomialeNegative()))
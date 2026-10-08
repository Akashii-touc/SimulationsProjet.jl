using SimulationsProjet

println("================================================")
println("Simulation pour avec une loi de Poisson")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,SimulationsProjet.ModelePoisson()))


println("================================================")
println("Simulation pour avec une loi de Poisson Bivariee")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,SimulationsProjet.ModelePoissonBivariee()))


println("================================================")
println("Simulation pour avec une loi Binomiale Negative")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,SimulationsProjet.ModeleBinomialeNegative()))


println("")
println("================================================")
println("Simulation avec le modèle de Dixon-Coles")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000, SimulationsProjet.ModeleDixonColes()))


println("")
println("================================================")
println("Simulation avec le modèle de Dixon-Coles avec Elo")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000, SimulationsProjet.ModeleDixonColes(), "Elo"))
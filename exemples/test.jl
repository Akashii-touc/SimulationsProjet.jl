using SimulationsProjet


println("================================================")
println("Simulation pour avec une loi de Poisson")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,"Poisson"))
println("")
println("================================================")
println("================================================")
println("Simulation pour avec une loi de Poisson Bivariee")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,"PoissonBivariee"))
println("")
println("================================================")
println("================================================")
println("Simulation pour avec une loi Binomiale Negative")
println("================================================")
SimulationsProjet.classement_stats(SimulationsProjet.simuler_n_fois(10000,"BinomialeNegative"))
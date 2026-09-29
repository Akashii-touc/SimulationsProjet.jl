using SimulationsProjet

println("===================================")
println("Test de la fonction simul_reguliere")
println("===================================")
classement = SimulationsProjet.simul_reguliere()
for (rang, equipe) in enumerate(classement)
    println(rang, ". ", equipe.club, " - ", equipe.points, " pts - ", equipe.buts_pour, " bp - ", equipe.buts_contre, " bc")
end
println("===================================")
#println("===================================")
#println("Test de la fonction simul_elimination_directe")
#println("===================================")
#vainqueur = SimulationsProjet.simul_elimination_directe(classement)
#println("Vainqueur : ",vainqueur)
#println("===================================")

println("===================================")
println("Test de la fonction simuler_n_fois")
println("===================================")
rangs = SimulationsProjet.simuler_n_fois(1000)
resultat = SimulationsProjet.classement_stats(rangs)
for (position, (club, (rgm, t8, t24, e, h, q, d, f, v))) in enumerate(resultat)
    println(position, ". ", club, " - rang moyen : ", rgm, " - top 8 : ", t8, "% - top 24 : ", t24, "% - eliminé : ", e, "% - huitieme : ", h, "% - quart : ", q, "% - demie : ", d, "% - finale : ", f, "% - vainqueur : ", v, "%")
end
println("===================================")

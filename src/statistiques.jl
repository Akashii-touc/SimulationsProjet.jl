function pourcentage(condition, liste)
    return(round(100 * count(condition, liste) / length(liste), digits = 2))
end


function classement_stats(dic::Dict{String, Tuple{Vector{Int}, Vector{Int}, Vector{Int}}})
    lignes = []
    for (club, (liste_rangs, liste_points, liste_parcours)) in dic
        push!(lignes, (club,
            round(mean(liste_points), digits = 2),
            pourcentage(r -> r <= 8, liste_rangs),
            pourcentage(r -> r <= 24, liste_rangs),
            pourcentage(r -> r > 24, liste_rangs),
            pourcentage(p -> p >= 2, liste_parcours),
            pourcentage(p -> p >= 3, liste_parcours),
            pourcentage(p -> p >= 4, liste_parcours),
            pourcentage(p -> p >= 5, liste_parcours),
            pourcentage(p -> p >= 6, liste_parcours)))
    end
    sort!(lignes, by = x -> x[2], rev = true)
    df = DataFrame(lignes, [:Club, :xPoints, :Top8, :Top24, :Elimine, :Huitieme, :Quart, :Demie, :Finale, :Vainqueur])
    show(df, allrows = true, allcols = true)
end
#Chances d'atteindre une étape pour les meilleurs clubs, pos pour dessiner dans une autre fenêtre
function graphique_chances(df::DataFrame; etape = :Vainqueur, nb_clubs = 16, fig = Figure(), pos = fig[1, 1])
    tri = first(sort(df, etape, rev = true), nb_clubs)
    ax = Axis(pos, alignmode = Outside(), title = string(etape), xlabel = "%", yticks = (1:nrow(tri), tri.Club), yreversed = true)
    barplot!(ax, 1:nrow(tri), tri[!, etape], direction = :x)
    return fig
end


#Compare les 4 modèles sur une étape, clubs choisis avec le premier modèle
function comparaison_modeles(n::Int; etape = :Vainqueur, nb_clubs = 10)
    noms = ["Poisson", "Poisson bivariée", "Binomiale négative", "Dixon-Coles"]
    modeles = [ModelePoisson(), ModelePoissonBivariee(), ModeleBinomialeNegative(), ModeleDixonColes()]
    tableaux = [classement_stats(rand(n, m)) for m in modeles]
    clubs = first(sort(tableaux[1], etape, rev = true).Club, nb_clubs)

    x = Int[]
    y = Float64[]
    groupe = Int[]
    for (i, df) in enumerate(tableaux)
        for (j, club) in enumerate(clubs)
            push!(x, j)
            push!(y, df[df.Club .== club, etape][1])
            push!(groupe, i)
        end
    end

    couleurs = Makie.wong_colors()
    fig = Figure(size = (1000, 500))
    ax = Axis(fig[1, 1], title = string(etape), ylabel = "%", xticks = (1:length(clubs), clubs), xticklabelrotation = π / 4)
    barplot!(ax, x, y, dodge = groupe, color = couleurs[groupe])
    Legend(fig[1, 2], [PolyElement(color = couleurs[i]) for i in 1:4], noms)
    return fig
end

calendrier = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)

function simul_reguliere(modele::Modele)
    d = equipes()
    for journee in eachcol(calendrier)
        for match in journee
            dom, ext = String.(split(match, " - "))
            buts_dom, buts_ext = score_match(d[dom], d[ext], modele)
            modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
        end
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    return(classement)
end

function simul_elimination_directe(equipes::Vector{Equipe}, modele::Modele)
    for e in equipes[1:8]
        e.parcours += 2
    end
    for e in equipes[9:24]
        e.parcours += 1
    end
    huitieme = shuffle(simul_aller_retour([equipes[9:16]; shuffle(equipes[17:24])], modele))
    quart = shuffle(simul_aller_retour([equipes[1:8]; huitieme], modele))
    demie = shuffle(simul_aller_retour(quart, modele))
    finaliste = shuffle(simul_aller_retour(demie, modele))
    return(simul_finale(finaliste, modele))
end


function simuler_n_fois(n::Int, modele::Modele)
    dic = Dict{String, Tuple{Vector{Int}, Vector{Int}, Vector{Int}}}()
    for i in 1:n
        classement = simul_reguliere(modele)
        simul_elimination_directe(classement, modele)
        for (rang, equipe) in enumerate(classement)
            if i == 1
                dic[equipe.club] = (Int[], Int[], Int[])
            end
            push!(dic[equipe.club][1], rang)
            push!(dic[equipe.club][2], equipe.points)
            push!(dic[equipe.club][3], equipe.parcours)
        end
    end
    return(dic)
end


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
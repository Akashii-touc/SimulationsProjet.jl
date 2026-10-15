function league_phase(modele::Modele, type_poids = "Coefficient_UEFA")
    d = equipes(type_poids)
    for journee in eachcol(CALENDRIER)
        for match in journee
            dom, ext = String.(split(match, " - "))
            buts_dom, buts_ext = buts(d[dom], d[ext], modele, avantage_A = 1.2)
            modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
        end
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    return(classement)
end


function knockout_phase(equipes::Vector{Equipe}, modele::Modele)
    for e in equipes[1:8]
        e.parcours += 2
    end
    for e in equipes[9:24]
        e.parcours += 1
    end
    huitieme = shuffle(home_away_match([equipes[9:16]; shuffle(equipes[17:24])], modele))
    quart = shuffle(home_away_match([equipes[1:8]; huitieme], modele))
    demie = shuffle(home_away_match(quart, modele))
    finaliste = shuffle(home_away_match(demie, modele))
    final(finaliste, modele)
end


function run_simulation(n::Int, modele::Modele, type_poids = "Coefficient_UEFA")
    dic = Dict{String, Tuple{Vector{Int}, Vector{Int}, Vector{Int}}}()
    for i in 1:n
        classement = league_phase(modele, type_poids)
        knockout_phase(classement, modele)
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

function league_phase(modele::Modele, type_poids = "Coefficient_UEFA")
    d = equipes(type_poids)
    for journee in eachcol(CALENDRIER)
        for match in journee
            dom, ext = String.(split(match, " - "))
            buts_dom, buts_ext = buts(d[dom], d[ext], modele, avantage = 1.2)
            modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
        end
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    return(classement)
end


function knockout_phase(equipes::Vector{Equipe}, modele::Modele)
    if length(equipes) == 36
        for e in equipes[1:8]
            e.parcours += 2
        end
        for e in equipes[9:24]
            e.parcours += 1
        end
        (voie_argent, voie_bleue) = voie(equipes[1:24])

        huitieme_argent = arbre(voie_argent[1:4], home_away_match(voie_argent[5:12], modele))
        huitieme_bleue = arbre(voie_bleue[1:4], home_away_match(voie_bleue[5:12], modele))

        quart_argent = home_away_match(huitieme_argent, modele)
        quart_bleue = home_away_match(huitieme_bleue, modele)

        demie_argent = home_away_match(quart_argent, modele)
        demie_bleue = home_away_match(quart_bleue, modele)

        finaliste_argent = home_away_match(demie_argent, modele)
        finaliste_bleue = home_away_match(demie_bleue, modele)
        
        final([finaliste_argent; finaliste_bleue], modele)
    else
        error("Nombre d'équipes incorrect")
    end
end


function voie(equipes::Vector{Equipe})
    voie_argent = Equipe[]
    voie_bleue = Equipe[]
    if length(equipes) == 24
        for i in [5, 3, 7, 1, 21, 11, 19, 13, 23, 9, 17, 15]
            r = rand(0:1)
            push!(voie_argent, equipes[i + r])
            push!(voie_bleue, equipes[i + 1 - r])
        end
        return (voie_argent, voie_bleue)
    else
        error("Nombre d'équipes incorrect")
    end
end


function arbre(tetes::Vector{Equipe}, barragistes::Vector{Equipe})
    if (length(tetes) != 4) || (length(barragistes) != 4)
        error("Nombre d'équipes incorrect")
    else
        resultat = Equipe[]
        for i in 1:4
            push!(resultat, barragistes[i])
            push!(resultat, tetes[i])
        end
        return resultat
    end
end

function Base.rand(n::Int, modele::Modele, type_poids = "Coefficient_UEFA")
    dic = Dict{String, Tuple{Vector{Int}, Vector{Int}, Vector{Int}}}()
    for i in 1:n
        println(i)
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

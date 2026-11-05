const MATCHS = [(String(m[1]), String(m[2])) for journee in eachcol(CALENDRIER) for m in split.(journee, " - ")]

function league_phase(modele::Modele, type_poids = "Coefficient_UEFA")
    d = equipes(type_poids)
    for (dom, ext) in MATCHS
        buts_dom, buts_ext = buts(d[dom], d[ext], modele, avantage = AVANTAGE_DOMICILE)
        modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
        modif_poids(d[dom], d[ext], buts_dom, buts_ext, type_poids)
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    if type_poids == "Coefficient_UEFA"
        for (rang, e) in enumerate(classement[1:24])
            e.poids += GAIN_POIDS[e.pays] * BONUS_CLASSEMENT * (25 - rang) #bonus de classement de la phase de ligue
        end
    end
    return classement
end


function knockout_phase(classement::Vector{Equipe}, modele::Modele, type_poids = "Coefficient_UEFA")
    if length(classement) == 36
        for e in classement[1:8]
            e.parcours += 2
            type_poids == "Coefficient_UEFA" && (e.poids += GAIN_POIDS[e.pays] * BONUS_TOUR) #huitièmes atteints directement
        end
        for e in classement[9:24]
            e.parcours += 1
        end
        (voie_argent, voie_bleue) = voie(classement[1:24])

        huitieme_argent = arbre(voie_argent[1:4], home_away_match(voie_argent[5:12], modele, type_poids))
        huitieme_bleue = arbre(voie_bleue[1:4], home_away_match(voie_bleue[5:12], modele, type_poids))

        quart_argent = home_away_match(huitieme_argent, modele, type_poids)
        quart_bleue = home_away_match(huitieme_bleue, modele, type_poids)

        demie_argent = home_away_match(quart_argent, modele, type_poids)
        demie_bleue = home_away_match(quart_bleue, modele, type_poids)

        finaliste_argent = home_away_match(demie_argent, modele, type_poids)
        finaliste_bleue = home_away_match(demie_bleue, modele, type_poids)
        
        final([finaliste_argent; finaliste_bleue], modele)
    else
        error("Nombre d'équipes incorrect")
    end
end


function voie(classement::Vector{Equipe})
    voie_argent = Equipe[]
    voie_bleue = Equipe[]
    if length(classement) == 24
        for i in [5, 3, 7, 1, 21, 11, 19, 13, 23, 9, 17, 15]
            r = rand(0:1)
            push!(voie_argent, classement[i + r])
            push!(voie_bleue, classement[i + 1 - r])
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

#seed fixe le hasard pour retrouver les mêmes résultats
#Les simulations sont réparties sur les threads (lancer julia avec -t auto)
function Base.rand(n::Int, modele::Modele, type_poids = "Coefficient_UEFA"; seed = nothing)
    if seed !== nothing
        Random.seed!(seed)
    end
    #Pour chaque club : rang, points et parcours des n saisons. Chaque simulation écrit dans sa propre case, sans conflit entre threads
    dic = Dict(club => (Vector{Int}(undef, n), Vector{Int}(undef, n), Vector{Int}(undef, n)) for club in CLASSEMENT.Club)
    Threads.@threads for i in 1:n
        copie = deepcopy(modele) #buts modifie le modèle, donc une copie par simulation
        classement = league_phase(copie, type_poids)
        knockout_phase(classement, copie, type_poids)
        for (rang, equipe) in enumerate(classement)
            rangs, points, parcours = dic[equipe.club]
            rangs[i] = rang
            points[i] = equipe.points
            parcours[i] = equipe.parcours
        end
    end
    return dic
end
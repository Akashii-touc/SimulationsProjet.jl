const MATCHS = [(String(m[1]), String(m[2])) for journee in eachcol(CALENDRIER) for m in split.(journee, " - ")]

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
function Base.rand(n::Int, modele::Modele, poids::Poids = PoidsUEFA(); seed = nothing)
    if seed !== nothing
        Random.seed!(seed)
    end
    dic = Dict(club => (Vector{Int}(undef, n), Vector{Int}(undef, n), Vector{Int}(undef, n)) for club in CLASSEMENT.Club)
    ligue = PhaseLigue()
    eliminatoire = PhaseEliminatoire()
    Threads.@threads for i in 1:n
        copie = deepcopy(modele)
        classement = jouer(ligue, copie, poids)
        jouer(eliminatoire, classement, copie, poids)
        for (rang, equipe) in enumerate(classement)
            rangs, points, parcours = dic[equipe.club]
            rangs[i] = rang
            points[i] = equipe.points
            parcours[i] = equipe.parcours
        end
    end
    return dic
end
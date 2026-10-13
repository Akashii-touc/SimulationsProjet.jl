calendrier = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)

function simul_reguliere(modele::Modele, type_poids = "Coefficient_UEFA")
    d = equipes(type_poids)
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


#Barrages : 9e-10e contre 23e-24e, ..., 15e-16e contre 17e-18e, puis huitième contre 1er-2e, ..., 7e-8e
#Chaque paire de têtes de série est séparée dans les deux moitiés du tableau, le chemin est fixé jusqu'à la finale
function simul_elimination_directe(equipes::Vector{Equipe}, modele::Modele)
    for e in equipes[1:8]
        e.parcours += 2
    end
    for e in equipes[9:24]
        e.parcours += 1
    end
    moities = [Equipe[], Equipe[]]
    for j in [1, 4, 2, 3]
        tetes = shuffle(equipes[2j-1:2j])
        barragistes = shuffle(equipes[17-2j:18-2j])
        adversaires = shuffle(equipes[15+2j:16+2j])
        for m in 1:2
            qualifie = simul_aller_retour([barragistes[m], adversaires[m]], modele)[1]
            append!(moities[m], [tetes[m], qualifie])
        end
    end
    quart = simul_tour([moities[1]; moities[2]], modele)
    demie = simul_tour(quart, modele; tirage_ordre = true)
    finaliste = simul_tour(demie, modele; tirage_ordre = true)
    return(simul_finale(finaliste, modele))
end


#Les équipes se rencontrent deux par deux dans l'ordre du tableau, la première reçoit au retour sauf si l'ordre est tiré
function simul_tour(tableau::Vector{Equipe}, modele::Modele; tirage_ordre = false)
    qualifiees = Equipe[]
    for i in 1:2:length(tableau)
        duel = tirage_ordre ? shuffle(tableau[i:i+1]) : tableau[i:i+1]
        push!(qualifiees, simul_aller_retour(duel, modele)[1])
    end
    return(qualifiees)
end


function simuler_n_fois(n::Int, modele::Modele, type_poids = "Coefficient_UEFA")
    dic = Dict{String, Tuple{Vector{Int}, Vector{Int}, Vector{Int}}}()
    for i in 1:n
        classement = simul_reguliere(modele, type_poids)
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

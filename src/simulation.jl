calendrier = CSV.read(joinpath(@__DIR__, "../fichier/matchs.csv"), DataFrame; types = String)

function simul_reguliere()
    d = equipes()
    for journee in eachcol(calendrier)
        for match in journee
            dom, ext = String.(split(match, " - "))
            buts_dom, buts_ext = calcul_score(d[dom], d[ext])
            v = modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
            d[dom] = v[1]
            d[ext] = v[2]
        end
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    return(classement)
end


function simul_elimination_directe(equipes::Vector{Equipe})
    for e in equipes[1:8]
        e.parcours += 2
    end
    for e in equipes[9:24]
        e.parcours += 1
    end
    huitieme = shuffle(simul_matchs([equipes[9:16]; shuffle(equipes[17:24])]))
    quart = shuffle(simul_matchs([equipes[1:8];huitieme]))
    demie = shuffle(simul_matchs(quart))
    finaliste = shuffle(simul_matchs(demie))
    vainqueur = simul_matchs(finaliste)
    return(vainqueur)
end


function simul_matchs(equipes::Vector{Equipe})
    l = length(equipes)
    resultat = Equipe[]
    if l == 2
        equipe_A = equipes[1]
        equipe_B = equipes[2]
        buts_A,buts_B = calcul_score(equipe_A,equipe_B)
        push!(resultat, qualif(equipe_A, equipe_B, buts_A, buts_B))
    else
        for i in 1:(length(equipes) ÷ 2)
            equipe_A = equipes[i]
            equipe_B = equipes[length(equipes) - i + 1]
            Aa,Ba = calcul_score(equipe_A,equipe_B)
            Br,Ar = calcul_score(equipe_B,equipe_A)
            buts_A = Aa + Ar
            buts_B = Ba + Br
            push!(resultat, qualif(equipe_A, equipe_B, buts_A, buts_B))
        end
    end
    return(resultat)  
end


function calcul_score(dom::Equipe,ext::Equipe)
    lambda_dom = exp(dom.poids) * exp(- ext.poids)
    lambda_ext = exp(ext.poids) * exp(- dom.poids)
    return([rand(Poisson(lambda_dom)),rand(Poisson(lambda_ext))])
end


function qualif(equipe_A::Equipe, equipe_B::Equipe, buts_A::Int64, buts_B::Int64)
    if buts_A > buts_B
        equipe_A.parcours += 1
        return(equipe_A)
    elseif buts_A < buts_B
        equipe_B.parcours += 1
        return(equipe_B)
    else
        equipe_gagnante = rand([equipe_A,equipe_B])
        equipe_gagnante.parcours += 1
        return(equipe_gagnante)
    end
end


function simuler_n_fois(n::Int)
    rangs = Dict{String, Tuple{Vector{Int}, Vector{Int}}}()
    for i in 1:n
        classement = simul_reguliere()
        simul_elimination_directe(classement)
        for (rang, equipe) in enumerate(classement)
            if i == 1
                rangs[equipe.club] = (Int[], Int[])
            end
            push!(rangs[equipe.club][1], rang)
            push!(rangs[equipe.club][2], equipe.parcours)
        end
    end
    return(rangs)
end


function classement_stats(rangs::Dict{String, Tuple{Vector{Int}, Vector{Int}}})
    pourcents = Dict{String, Vector{Float64}}()
    n = 1
    for (club, (liste_rangs,liste_parcours)) in rangs
        n = length(liste_rangs)
        moyenne_rg = 0
        top_24 = 0
        top_8 = 0
        elimine = 0
        huitieme = 0
        quart = 0
        demie = 0
        finale = 0
        vainqueur = 0
        for i in 1:n
            moyenne_rg += liste_rangs[i]
            if liste_rangs[i] <= 8
                top_8 += 1
                top_24 += 1
            elseif liste_rangs[i] <= 24
                top_24 += 1
            else 
                elimine += 1
            end
            if liste_parcours[i] == 6
                huitieme += 1
                quart += 1
                demie += 1
                finale += 1
                vainqueur += 1
            elseif liste_parcours[i] >= 5
                huitieme += 1
                quart += 1
                demie += 1
                finale += 1
            elseif liste_parcours[i] >= 4
                huitieme += 1
                quart += 1
                demie += 1
            elseif liste_parcours[i] >= 3
                huitieme += 1
                quart += 1
            elseif liste_parcours[i] >= 2
                huitieme += 1
            end
        end
        pourcents[club] = [moyenne_rg, top_8, top_24, elimine, huitieme, quart, demie, finale, vainqueur]
    end
    for (club,liste) in pourcents
        liste[1] = round(liste[1]/n, digits = 2)
        for i in 2:length(liste)
            liste[i] = round((liste[i]/n)*100,digits = 2)
        end
    end
    return(sort(collect(pourcents), by = x -> x[2][1]))
end
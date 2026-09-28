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


function simuler_n_fois(n::Int)
    rangs = Dict{String, Vector{Int}}()
    for i in 1:n
        classement = simul_reguliere()
        for (rang, equipe) in enumerate(classement)
            if i == 1
                rangs[equipe.club] = Int[]
            end
            push!(rangs[equipe.club], rang)
        end
    end
    return(rangs)
end


function simul_elimination_directe(equipes::Vector{Equipe})
    qualif_barrage = shuffle(simul_matchs([equipes[9:16]; shuffle(equipes[17:24])]))
    qualif_quart = shuffle(simul_matchs([equipes[1:8]; qualif_barrage]))
    qualif_demie = shuffle(simul_matchs(qualif_quart))
    qualif_finale = shuffle(simul_matchs(qualif_demie))
    vainqueur = simul_matchs(qualif_finale)
    return(vainqueur[1])
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
        return(equipe_A)
    elseif buts_A < buts_B
        return(equipe_B)
    else
        return(rand([equipe_A,equipe_B]))
    end
end


function classement_moyen(rangs::Dict{String, Vector{Int}})
    moyennes = [(club, mean(liste_rangs)) for (club, liste_rangs) in rangs]
    return(sort(moyennes, by = x -> x[2]))
end
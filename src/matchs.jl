function buts(equipe_A::Equipe, equipe_B::Equipe, modele::Modele; avantage = 1.0, duree = 1.0)
    Δ = equipe_A.poids - equipe_B.poids
    modele.λ_A = modele.μ * avantage * exp(Δ) * duree
    modele.λ_B = modele.μ * exp(-Δ) * duree
    return rand(modele, Δ, duree)
end


function equipe_qualifiee(equipe_A::Equipe, equipe_B::Equipe, buts_A::Int64, buts_B::Int64)
    if buts_A > buts_B
        gagnante = equipe_A
    elseif buts_A < buts_B
        gagnante = equipe_B
    elseif shootout(equipe_A, equipe_B)
        gagnante = equipe_A
    else
        gagnante = equipe_B
    end
    gagnante.parcours += 1
    return gagnante
end


function shootout(equipe_A::Equipe, equipe_B::Equipe)
    tab_A = 0
    tab_B = 0
    proba_tab_A = equipe_A.proba_tab
    proba_tab_B = equipe_B.proba_tab
    i = 1
    while tab_A == tab_B || i <= 5
        tab_A += rand(Bernoulli(proba_tab_A))
        tab_B += rand(Bernoulli(proba_tab_B))
        i += 1
    end
    return tab_A > tab_B
end
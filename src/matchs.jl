function buts(equipe_A::Equipe, equipe_B::Equipe, modele::Modele; avantage_A = 1.0, avantage_B = 1.0, duree = 1.0)
    Δ = equipe_A.poids - equipe_B.poids
    modele.λ_A = avantage_A * exp(Δ) * duree
    modele.λ_B = avantage_B * exp(-Δ) * duree
    return rand(modele, Δ, duree)
end


#A est l'équipe la mieux classée : aller chez B, retour puis prolongation éventuelle chez A
function home_away_match(equipes::Vector{Equipe}, modele::Modele)
    resultat = Equipe[]
    for i in 1:(length(equipes) ÷ 2)
        equipe_A = equipes[i]
        equipe_B = equipes[length(equipes) - i + 1]
        buts_aller_B, buts_aller_A = buts(equipe_B, equipe_A, modele, avantage_A = 1.2)
        buts_retour_A, buts_retour_B = buts(equipe_A, equipe_B, modele, avantage_A = 1.2)
        buts_A = buts_aller_A + buts_retour_A
        buts_B = buts_aller_B + buts_retour_B
        if buts_A == buts_B
            buts_prolongation_A, buts_prolongation_B = buts(equipe_A, equipe_B, modele, avantage_A = 1.2, duree = 1/3)
            buts_A += buts_prolongation_A
            buts_B += buts_prolongation_B
        end
        push!(resultat, equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B))
    end
    return resultat
end


function final((equipe_A, equipe_B)::Vector{Equipe}, modele::Modele)
    buts_A, buts_B = buts(equipe_A, equipe_B, modele)
    if buts_A == buts_B
        pro_A, pro_B = buts(equipe_A, equipe_B, modele; duree = 1/3)
        buts_A += pro_A
        buts_B += pro_B
    end
    return equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B)
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


#5 tirs chacun puis mort subite, chaque équipe tire avec sa propre proba_tab (lue dans fichier/tirs_au_but.csv)
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
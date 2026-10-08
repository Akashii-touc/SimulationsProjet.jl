function buts(equipe_A::Equipe, equipe_B::Equipe, modele::Modele; avantage_A = 1.0, avantage_B = 1.0, duree = 1.0)
    ecart = equipe_A.poids - equipe_B.poids
    mu_A = avantage_A * exp(ecart) * duree
    mu_B = avantage_B * exp(-ecart) * duree
    return(tirage(modele, mu_A, mu_B, ecart, duree))
end


function score_match(dom::Equipe, ext::Equipe, modele::Modele)
    return(buts(dom, ext, modele; avantage_A = 1.2))
end


function score_prolongation(equipe_A::Equipe, equipe_B::Equipe, modele::Modele)
    return(buts(equipe_A, equipe_B, modele; avantage_B = 1.2, duree = 1/3))
end


function simul_aller_retour(equipes::Vector{Equipe}, modele::Modele)
    resultat = Equipe[]
    for i in 1:(length(equipes) ÷ 2)
        equipe_A = equipes[i]
        equipe_B = equipes[length(equipes) - i + 1]
        aller_A, aller_B = score_match(equipe_A, equipe_B, modele)
        retour_B, retour_A = score_match(equipe_B, equipe_A, modele)
        buts_A = aller_A + retour_A
        buts_B = aller_B + retour_B
        if buts_A == buts_B
            pro_A, pro_B = score_prolongation(equipe_A, equipe_B, modele)
            buts_A += pro_A
            buts_B += pro_B
        end
        push!(resultat, equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B))
    end
    return(resultat)
end


function simul_finale((equipe_A, equipe_B)::Vector{Equipe}, modele::Modele)
    buts_A, buts_B = buts(equipe_A, equipe_B, modele)
    if buts_A == buts_B
        pro_A, pro_B = buts(equipe_A, equipe_B, modele; duree = 1/3)
        buts_A += pro_A
        buts_B += pro_B
    end
    return(equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B))
end


function equipe_qualifiee(equipe_A::Equipe, equipe_B::Equipe, buts_A::Int64, buts_B::Int64)
    if buts_A > buts_B
        gagnante = equipe_A
    elseif buts_A < buts_B
        gagnante = equipe_B
    else
        gagnante = rand([equipe_A, equipe_B])
    end
    gagnante.parcours += 1
    return(gagnante)
end
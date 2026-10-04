const avantage_terrain = 0.25

#Comme calcul_score, mais avec l'avantage du terrain (rien si neutre = true)
function calcul_score_terrain(dom::Equipe, ext::Equipe, neutre::Bool = false, duree::Float64 = 1.0)
    bonus = neutre ? 0.0 : avantage_terrain
    lambda_dom = exp(dom.poids - ext.poids + bonus) * duree
    lambda_ext = exp(ext.poids - dom.poids) * duree
    return([rand(Poisson(lambda_dom)), rand(Poisson(lambda_ext))])
end

#30 minutes de jeu, donc λ divisé par 3
function prolongation(dom::Equipe, ext::Equipe, neutre::Bool = false)
    return(calcul_score_terrain(dom, ext, neutre, 1/3))
end

#5 tirs chacun puis mort subite, chaque équipe tire avec sa propre proba_tab (lue dans fichier/tirs_au_but.csv)
function tirs_au_but(equipe_A::Equipe, equipe_B::Equipe)
    tab_A = 0
    tab_B = 0
    for i in 1:5
        if rand() < equipe_A.proba_tab
            tab_A += 1
        end
        if rand() < equipe_B.proba_tab
            tab_B += 1
        end
    end
    while tab_A == tab_B
        if rand() < equipe_A.proba_tab
            tab_A += 1
        end
        if rand() < equipe_B.proba_tab
            tab_B += 1
        end
    end
    return(tab_A > tab_B)
end

#En cas d'égalité : prolongation puis tirs au but
function vainqueur_egalite(equipe_A::Equipe, equipe_B::Equipe, neutre::Bool)
    prolong_A, prolong_B = prolongation(equipe_A, equipe_B, neutre)
    if prolong_A > prolong_B
        return(equipe_A)
    elseif prolong_A < prolong_B
        return(equipe_B)
    elseif tirs_au_but(equipe_A, equipe_B)
        return(equipe_A)
    else
        return(equipe_B)
    end
end

#A est l'équipe la mieux classée et reçoit au retour, pas de règle des buts à l'extérieur, si égalité : prolongation chez A puis tirs au but
function match_aller_retour(equipe_A::Equipe, equipe_B::Equipe)
    aller_B, aller_A = calcul_score_terrain(equipe_B, equipe_A)
    retour_A, retour_B = calcul_score_terrain(equipe_A, equipe_B)
    buts_A = aller_A + retour_A
    buts_B = aller_B + retour_B
    if buts_A > buts_B
        gagnant = equipe_A
    elseif buts_A < buts_B
        gagnant = equipe_B
    else
        gagnant = vainqueur_egalite(equipe_A, equipe_B, false)
    end
    gagnant.parcours += 1
    return(gagnant)
end

#Un seul match sur terrain neutre, puis prolongation et tirs au but si égalité
function match_finale(equipe_A::Equipe, equipe_B::Equipe)
    buts_A, buts_B = calcul_score_terrain(equipe_A, equipe_B, true)
    if buts_A > buts_B
        gagnant = equipe_A
    elseif buts_A < buts_B
        gagnant = equipe_B
    else
        gagnant = vainqueur_egalite(equipe_A, equipe_B, true)
    end
    gagnant.parcours += 1
    return(gagnant)
end

const avantage_terrain = 0.25
const proba_tir = 0.75

function calcul_score_terrain(dom::Equipe, ext::Equipe, neutre::Bool = false, duree::Float64 = 1.0)
    bonus = neutre ? 0.0 : avantage_terrain
    lambda_dom = exp(dom.poids - ext.poids + bonus) * duree
    lambda_ext = exp(ext.poids - dom.poids) * duree
    return([rand(Poisson(lambda_dom)), rand(Poisson(lambda_ext))])
end

function prolongation(dom::Equipe, ext::Equipe, neutre::Bool = false)
    return(calcul_score_terrain(dom, ext, neutre, 1/3))
end

function tirs_au_but()
    tab_A = 0
    tab_B = 0
    for i in 1:5
        if rand() < proba_tir
            tab_A += 1
        end
        if rand() < proba_tir
            tab_B += 1
        end
    end
    while tab_A == tab_B
        if rand() < proba_tir
            tab_A += 1
        end
        if rand() < proba_tir
            tab_B += 1
        end
    end
    return(tab_A > tab_B)
end

function vainqueur_egalite(equipe_A::Equipe, equipe_B::Equipe, neutre::Bool)
    prolong_A, prolong_B = prolongation(equipe_A, equipe_B, neutre)
    if prolong_A > prolong_B
        return(equipe_A)
    elseif prolong_A < prolong_B
        return(equipe_B)
    elseif tirs_au_but()
        return(equipe_A)
    else
        return(equipe_B)
    end
end

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

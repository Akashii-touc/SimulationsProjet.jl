mutable struct Equipe
    club::String #Nom du club
    pays::String #Pays du club
    mj::Int64 #Nombre de matchs joués
    points::Int64
    buts_pour::Int64
    buts_contre::Int64
    db::Int64 #Différence de buts
    poids::Float64 #Poids du club
    parcours::Int64 #0=éliminer en phase de ligue, 1 = éliminer en barrage, ..., 6 = vainqueur
    proba_tab::Float64 #Proba de marquer un tir au but
end

#Crée une équipe sans proba_tab donnée, elle vaut alors 0.75
Equipe(club, pays, mj, points, buts_pour, buts_contre, db, poids, parcours) = Equipe(club, pays, mj, points, buts_pour, buts_contre, db, poids, parcours, 0.75)

#Calcule la proba de marquer un tir au but d'un club depuis fichier/tirs_au_but.csv, ramenée vers 0.75 quand il y a peu de tirs (0.75 si le club est absent)
function proba_tab(club::String)
    ligne = findfirst(==(club), STATS_TAB.Club)
    if ligne === nothing
        return(0.75)
    end
    tentes = STATS_TAB.tirs_tentes[ligne]
    reussis = STATS_TAB.tirs_reussis[ligne]
    return((reussis + 0.75 * 10) / (tentes + 10))
end


#Poids d'un club selon type_poids : "Coefficient_UEFA" (coefficients club et pays) ou "Elo" (Elo / 400)
function poids_club(i, type_poids)
    if type_poids == "Elo"
        return CLASSEMENT.Elo[i] / 400
    elseif type_poids == "Coefficient_UEFA"
        return POIDS_CLUBS_COEFF[i]
    end
    error("type_poids inconnu : $type_poids (\"Coefficient_UEFA\" ou \"Elo\")")
end


function equipes(type_poids = "Coefficient_UEFA")
    dic = Dict{String,Equipe}()
    for i in 1:36
        nom = CLASSEMENT.Club[i]
        dic[nom] = Equipe(nom, CLASSEMENT.Pays[i], 0, 0, 0, 0, 0, poids_club(i, type_poids), 0, proba_tab(nom))
    end
    return(dic)
end


function modif_equipe(domicile::Equipe, exterieure::Equipe, buts_dom, buts_ext)
    domicile.buts_pour += buts_dom
    domicile.buts_contre += buts_ext
    exterieure.buts_pour += buts_ext
    exterieure.buts_contre += buts_dom
    domicile.db += buts_dom - buts_ext
    exterieure.db += buts_ext - buts_dom
    if buts_dom > buts_ext
        domicile.points += 3
    elseif buts_dom == buts_ext
        domicile.points += 1
        exterieure.points += 1
    else
        exterieure.points += 3
    end
    domicile.mj += 1
    exterieure.mj += 1
end
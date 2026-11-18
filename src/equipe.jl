const PROBA_TAB_MOYENNE = 0.75
const PROBA_TAB_FORCE = 100
const GAIN_POIDS = Dict(p => (0.8 + 0.2 / count(==(p), CLASSEMENT.Pays)) / (maximum(FORCE_BRUT) - minimum(FORCE_BRUT)) for p in unique(CLASSEMENT.Pays))


@kwdef mutable struct Equipe
    club::String #Nom du club
    pays::String #Pays du club
    mj::Int64 = 0 #Nombre de matchs joués
    points::Int64 = 0
    buts_pour::Int64 = 0
    buts_contre::Int64 = 0
    db::Int64 = 0 #Différence de buts
    poids::Float64 = 0.0 #Poids du club
    parcours::Int64 = 0 #0=éliminer en phase de ligue, 1 = éliminer en barrage, ..., 6 = vainqueur
    proba_tab::Float64 = 0.75 #Proba de marquer un tir au but
end


function proba_tab(club::String)
    ligne = findfirst(==(club), STATS_TAB.Club)
    if ligne === nothing
        return PROBA_TAB_MOYENNE
    end
    tentes = STATS_TAB.tirs_tentes[ligne]
    reussis = STATS_TAB.tirs_reussis[ligne]
    return (reussis + PROBA_TAB_MOYENNE * PROBA_TAB_FORCE) / (tentes + PROBA_TAB_FORCE)
end


function equipes(poids = PoidsUEFA())
    dic = Dict{String,Equipe}()
    for i in 1:nrow(CLASSEMENT)
        nom = CLASSEMENT.Club[i]
        equipe = Equipe(club = nom, pays = CLASSEMENT.Pays[i])
        equipe.poids = poids_club(i, poids)
        equipe.proba_tab = proba_tab(nom)
        dic[nom] = equipe
    end
    return dic
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
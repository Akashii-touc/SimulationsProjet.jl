classement = CSV.read(joinpath(@__DIR__, "../fichier/classement_uefa.csv"), DataFrame; stringtype = String)
stats_tab = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame; stringtype = String)

force_brut = 0.8 * classement.Coeff_club + 0.2 * classement.Coeff_pays
poids_clubs = round.((force_brut .- mean(force_brut)) ./ (maximum(force_brut) - minimum(force_brut)), digits = 5)

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
    ligne = findfirst(==(club), stats_tab.Club)
    if ligne === nothing
        return(0.75)
    end
    tentes = stats_tab.tirs_tentes[ligne]
    reussis = stats_tab.tirs_reussis[ligne]
    return((reussis + 0.75 * 10) / (tentes + 10))
end


function equipes()
    dic = Dict{String,Equipe}()
    for i in 1:36
        n = classement.Club[i]
        dic[n] = Equipe(n, classement.Pays[i], 0, 0, 0, 0, 0, poids_clubs[i], 0, proba_tab(n))
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
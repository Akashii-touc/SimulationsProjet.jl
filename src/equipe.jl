classement = CSV.read(joinpath(@__DIR__, "../fichier/classement_uefa.csv"), DataFrame)
classement.Club = String.(classement.Club)
classement.Pays = String.(classement.Pays)
stats_tab = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame)
stats_tab.Club = String.(stats_tab.Club)


mutable struct Equipe
    club::String #Nom du club
    pays::String #Pays du club
    mj::Float64 #Nombre de matchs joués
    points::Float64 
    buts_pour::Float64
    buts_contre::Float64
    db::Float64 #Différence de buts
    poids::Float64 #Poids du club
    parcours::Int64 #0=éliminer en phase de ligue, 1 = éliminer en barrage, ..., 6 = vainqueur
    proba_tab::Float64
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
    dic::Dict{String,Equipe} = Dict()
    force_brut = 0.8 * classement.Coeff_club + 0.2 * classement.Coeff_pays
    moyenne = mean(force_brut)
    ect = std(force_brut)
    for i in range(1,36)
        n = classement.Club[i]
        p = classement.Pays[i]
        poids = round((force_brut[i] - moyenne)/ect,digits = 5)
        dic[n] = Equipe(n,p,0,0,0,0,0,poids,0,proba_tab(n))
    end
    return(dic)
end

function modif_equipe(domicile::Equipe,exterieure::Equipe,buts_dom,buts_ext)
    domicile.buts_pour += buts_dom
    domicile.buts_contre += buts_ext
    exterieure.buts_pour += buts_ext
    exterieure.buts_contre += buts_dom
    diff_buts(domicile)
    diff_buts(exterieure)
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
    return(domicile,exterieure)
end

function diff_buts(equipe::Equipe)
    equipe.db = equipe.buts_pour - equipe.buts_contre    
end
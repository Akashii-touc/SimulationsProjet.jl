classement = CSV.read(joinpath(@__DIR__, "../fichier/classement_club.csv"), DataFrame; stringtype = String)
stats_tab = CSV.read(joinpath(@__DIR__, "../fichier/tirs_au_but.csv"), DataFrame; stringtype = String)

force_brut = 0.8 * classement.Coeff_club + 0.2 * classement.Coeff_pays
poids_clubs_coeff = round.((force_brut .- mean(force_brut)) ./ (maximum(force_brut) - minimum(force_brut)), digits = 5)


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


function proba_tab()
    dic = Dict{String,Float64}()
    for i in 1:36
        club = stats_tab.Club[i]
        ratio_sceances = stats_tab.seances_gagnees[i]/stats_tab.seances_jouees[i]
        ratio_tirs = stats_tab.tirs_reussis[i]/stats_tab.tirs_tentes[i]
        dic[club] = 0.6 * ratio_sceances + 0.4 * ratio_tirs
    end
    return(dic)
end


function equipes(type_poids = "Coefficient_UEFA")
    dic = Dict{String,Equipe}()
    tab = proba_tab()
    for i in 1:36
        if type_poids == "Elo"
            nom = classement.Club[i]
            dic[nom] = Equipe(nom, classement.Pays[i], 0, 0, 0, 0, 0, classement.Elo[i]/400, 0, tab[nom])
        elseif type_poids == "Coefficient_UEFA"
            nom = classement.Club[i]
            dic[nom] = Equipe(nom, classement.Pays[i], 0, 0, 0, 0, 0, poids_clubs_coeff[i], 0, tab[nom])
        end
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
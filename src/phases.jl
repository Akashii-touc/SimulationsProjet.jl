abstract type Phase end

@kwdef mutable struct PhaseLigue <: Phase
    avantage::Float64 = 1.2
end

@kwdef mutable struct AllerRetour <: Phase
    avantage::Float64 = 1.2
    duree_prolongation::Float64 = 1/3
end

@kwdef mutable struct Finale <: Phase
    duree_prolongation::Float64 = 1/3
end

@kwdef mutable struct PhaseEliminatoire <: Phase
    tour::AllerRetour = AllerRetour()
    finale::Finale = Finale()
end

function jouer(phase::PhaseLigue, modele::Modele, poids::Poids = PoidsUEFA())
    d = equipes(poids)
    for (dom, ext) in MATCHS
        buts_dom, buts_ext = buts(d[dom], d[ext], modele, avantage = phase.avantage)
        modif_equipe(d[dom], d[ext], buts_dom, buts_ext)
        modif_poids(d[dom], d[ext], buts_dom, buts_ext, poids)
    end
    classement = sort(collect(values(d)), by = e -> (e.points, e.db, e.buts_pour), rev = true)
    for (rang, e) in enumerate(classement[1:24])
        bonus_classement(e, rang, poids)
    end
    return classement
end


#equipes[2i] est l'équipe la mieux classée. Match aller chez équipes[2i - 1], retour puis prolongation éventuelle chez équipes[2i]
function jouer(phase::AllerRetour, equipes::Vector{Equipe}, modele::Modele, poids::Poids = PoidsUEFA())
    resultat = Equipe[]
    for i in 1:2:length(equipes)
        equipe_A = equipes[i]
        equipe_B = equipes[i + 1]
        buts_aller_A, buts_aller_B = buts(equipe_A, equipe_B, modele; avantage = phase.avantage)
        modif_poids(equipe_A, equipe_B, buts_aller_A, buts_aller_B, poids)
        buts_retour_B, buts_retour_A = buts(equipe_B, equipe_A, modele; avantage = phase.avantage)
        buts_A = buts_aller_A + buts_retour_A
        buts_B = buts_aller_B + buts_retour_B
        if buts_A == buts_B
            buts_prolongation_B, buts_prolongation_A = buts(equipe_B, equipe_A, modele; avantage = phase.avantage, duree = phase.duree_prolongation)
            buts_A += buts_prolongation_A
            buts_B += buts_prolongation_B
        end
        modif_poids(equipe_B, equipe_A, buts_B - buts_aller_B, buts_A - buts_aller_A, poids)
        gagnante = equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B)
        if 2 <= gagnante.parcours <= 5
            bonus_tour(gagnante, poids) #huitièmes, quarts, demies ou finale atteints
        end
        push!(resultat, gagnante)
    end
    return resultat
end


#Le poids n'évolue pas pendant la finale, poids sert seulement à avoir la même forme d'appel que les autres phases
function jouer(phase::Finale, equipes::Vector{Equipe}, modele::Modele, poids::Poids = PoidsUEFA())
    equipe_A = equipes[1]
    equipe_B = equipes[2]
    buts_A, buts_B = buts(equipe_A, equipe_B, modele)
    if buts_A == buts_B
        prolongation_A, prolongation_B = buts(equipe_A, equipe_B, modele; duree = phase.duree_prolongation)
        buts_A += prolongation_A
        buts_B += prolongation_B
    end
    return equipe_qualifiee(equipe_A, equipe_B, buts_A, buts_B)
end


#classement : les 36 équipes triées à la fin de la phase de ligue
function jouer(phase::PhaseEliminatoire, classement::Vector{Equipe}, modele::Modele, poids::Poids)
    if length(classement) == 36
        for e in classement[1:8]
            e.parcours += 2
            bonus_tour(e, poids) #huitièmes atteints directement
        end
        for e in classement[9:24]
            e.parcours += 1
        end
        (voie_argent, voie_bleue) = voie(classement[1:24])

        huitieme_argent = arbre(voie_argent[1:4], jouer(phase.tour, voie_argent[5:12], modele, poids))
        huitieme_bleue = arbre(voie_bleue[1:4], jouer(phase.tour, voie_bleue[5:12], modele, poids))

        quart_argent = jouer(phase.tour, huitieme_argent, modele, poids)
        quart_bleue = jouer(phase.tour, huitieme_bleue, modele, poids)

        demie_argent = jouer(phase.tour, quart_argent, modele, poids)
        demie_bleue = jouer(phase.tour, quart_bleue, modele, poids)

        finaliste_argent = jouer(phase.tour, demie_argent, modele, poids)
        finaliste_bleue = jouer(phase.tour, demie_bleue, modele, poids)

        return jouer(phase.finale, [finaliste_argent; finaliste_bleue], modele, poids)
    else
        error("Nombre d'équipes incorrect")
    end
end
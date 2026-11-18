abstract type Poids end


#Départ : coefficients UEFA du club et du pays. Le poids monte avec les résultats et les bonus de parcours
@kwdef mutable struct PoidsUEFA <: Poids
    gain_match::Float64 = 2.0 #multiplie GAIN_POIDS : victoire = 2 gains, nul = 1 gain, défaite = 0
    bonus_tour::Float64 = 1.5 #bonus quand une équipe atteint les huitièmes, quarts, demies ou la finale
    bonus_classement::Float64 = 0.25 #bonus de la phase de ligue, multiplié par (25 - rang)
end


#Départ : Elo / échelle. Le poids suit la formule Elo, sans bonus
@kwdef mutable struct PoidsElo <: Poids
    K::Float64 = 40.0 #variation maximale du Elo après un match
    echelle::Float64 = 400.0 #Elo = échelle * poids
end


#Valeur de départ du poids du club numéro i dans CLASSEMENT
function poids_club(i::Integer, poids::PoidsUEFA)
    return POIDS_CLUBS_COEFF[i]
end

function poids_club(i::Integer, poids::PoidsElo)
    return CLASSEMENT.Elo[i] / poids.echelle
end


#Résultat d'un match pour A et pour B : victoire = 1, nul = 0.5, défaite = 0
function score_match(buts_A, buts_B)
    if buts_A > buts_B
        return 1.0, 0.0
    elseif buts_A == buts_B
        return 0.5, 0.5
    else
        return 0.0, 1.0
    end
end


function modif_poids(equipe_A::Equipe, equipe_B::Equipe, buts_A, buts_B, poids::PoidsUEFA)
    S_A, S_B = score_match(buts_A, buts_B)
    equipe_A.poids += GAIN_POIDS[equipe_A.pays] * poids.gain_match * S_A
    equipe_B.poids += GAIN_POIDS[equipe_B.pays] * poids.gain_match * S_B
end

function modif_poids(equipe_A::Equipe, equipe_B::Equipe, buts_A, buts_B, poids::PoidsElo)
    S_A, S_B = score_match(buts_A, buts_B)
    elo_A = poids.echelle * equipe_A.poids
    elo_B = poids.echelle * equipe_B.poids
    E_A = 1 / (1 + 10^((elo_B - elo_A) / poids.echelle))
    equipe_A.poids = (elo_A + poids.K * (S_A - E_A)) / poids.echelle
    equipe_B.poids = (elo_B + poids.K * (S_B - (1 - E_A))) / poids.echelle
end

#Bonus de la phase de ligue : le 1er reçoit 24 fois le bonus, le 24e une fois
function bonus_classement(equipe::Equipe, rang::Integer, poids::PoidsElo)
    return nothing
end

function bonus_classement(equipe::Equipe, rang::Integer, poids::PoidsUEFA)
    equipe.poids += GAIN_POIDS[equipe.pays] * poids.bonus_classement * (25 - rang)
end


#Bonus quand une équipe atteint les huitièmes, quarts, demies ou la finale
function bonus_tour(equipe::Equipe, poids::PoidsElo)
    return nothing
end

function bonus_tour(equipe::Equipe, poids::PoidsUEFA)
    equipe.poids += GAIN_POIDS[equipe.pays] * poids.bonus_tour
end

using Distributions, StatsBase #Ajout pour modèle Dixon-Coles

#Un modèle décide comment on tire les buts des deux équipes à partir de leurs moyennes mu_A et mu_B
abstract type Modele end

#Buts indépendants qui suivent chacun une loi de Poisson
struct ModelePoisson <: Modele end

#Poisson + une partie commune X aux deux équipes, plus grande quand les équipes sont proches
struct ModelePoissonBivariee <: Modele
    lambda_commun::Float64 #Moyenne de X quand les deux équipes ont le même poids
end
ModelePoissonBivariee() = ModelePoissonBivariee(0.4)

#Binomiale négative de même moyenne que Poisson mais plus dispersée (plus p est petit, plus c'est dispersé)
struct ModeleBinomialeNegative <: Modele
    p::Float64
end

ModeleBinomialeNegative() = ModeleBinomialeNegative(0.8)


function tirage(::ModelePoisson, mu_A, mu_B, ecart, duree)
    return(rand(Poisson(mu_A)), rand(Poisson(mu_B)))
end

function tirage(modele::ModelePoissonBivariee, mu_A, mu_B, ecart, duree)
    X = rand(Poisson(modele.lambda_commun * exp(-abs(ecart)) * duree))
    return(rand(Poisson(mu_A)) + X, rand(Poisson(mu_B)) + X)
end

#r est choisi pour que la moyenne r(1-p)/p vaille mu
function tirage(modele::ModeleBinomialeNegative, mu_A, mu_B, ecart, duree)
    p = modele.p
    return(rand(NegativeBinomial(mu_A * p / (1 - p), p)), rand(NegativeBinomial(mu_B * p / (1 - p), p)))
end

#Modèle Dixon-Coles
#Étape 1: Définition du struct basé sur abstract type Modele
struct ModeleDixonColes <: Modele
    rho::Float64
end

ModeleDixonColes() = ModeleDixonColes(-0.15)

#Étape 2: Fonction d'ajustement de Dixon-Coles
function tau_dixon_coles(x::Int, y::Int, lambda::Float64, mu::Float64, rho::Float64 = -0.15)
    if x == 0 && y == 0
        return max(0.0, 1.0 - lambda * mu * rho)
    elseif x == 0 && y == 1
        return max(0.0, 1.0 + lambda * rho)
    elseif x == 1 && y == 0
        return max(0.0, 1.0 + mu * rho)
    elseif x == 1 && y == 1
        return max(0.0, 1.0 - rho)
    else
        return 1.0 # Les autres scores restent inchangés
    end
end

# Étape 3 : Méthode 'tirage' spécifique pour ModeleDixonColes
function tirage(modele::ModeleDixonColes, mu_A, mu_B, ecart, duree)
    # Construction de la matrice de probabilités pour les scores de 0-0 à 10-10
    max_buts = 10
    proba_array = Float64[]
    tissos = Tuple{Int, Int}[]

    for x in 0:max_buts
        for y in 0:max_buts
            # Utilisation directe de mu_A et mu_B calculés en amont
            proba_base = pdf(Poisson(mu_A), x) * pdf(Poisson(mu_B), y)
            
            # Utilisation de modele.rho pour l'ajustement
            proba_final = proba_base * tau_dixon_coles(x, y, mu_A, mu_B, modele.rho)
            
            push!(proba_array, proba_final)
            push!(tissos, (x, y))
        end
    end

    # Tirage au sort du score 
    idx_choisi = sample(1:length(tissos), Weights(proba_array))
    
    # Retourne un tuple pour correspondre aux autres modèles
    return (tissos[idx_choisi][1], tissos[idx_choisi][2])
end
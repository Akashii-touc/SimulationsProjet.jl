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


#Poisson corrigé sur les petits scores (0-0, 1-0, 0-1, 1-1), avec rho < 0 il y a plus de 0-0 et de 1-1
struct ModeleDixonColes <: Modele
    rho::Float64
end
ModeleDixonColes() = ModeleDixonColes(-0.1)


function tirage(modele::ModelePoisson, mu_A, mu_B, ecart, duree)
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


function tirage(modele::ModeleDixonColes, mu_A, mu_B, ecart, duree)
    rho = modele.rho
    tau_max = max(1.0, maximum(tau(a, b, mu_A, mu_B, rho) for a in 0:1, b in 0:1))
    while true
        buts_A, buts_B = rand(Poisson(mu_A)), rand(Poisson(mu_B))
        if rand() * tau_max < tau(buts_A, buts_B, mu_A, mu_B, rho)
            return(buts_A, buts_B)
        end
    end
end


#Facteur de correction de Dixon-Coles, il vaut 1 pour tous les scores sauf 0-0, 0-1, 1-0 et 1-1
function tau(buts_A, buts_B, mu_A, mu_B, rho)
    if buts_A == 0 && buts_B == 0
        return(max(0.0, 1 - mu_A * mu_B * rho))
    elseif buts_A == 0 && buts_B == 1
        return(max(0.0, 1 + mu_A * rho))
    elseif buts_A == 1 && buts_B == 0
        return(max(0.0, 1 + mu_B * rho))
    elseif buts_A == 1 && buts_B == 1
        return(max(0.0, 1 - rho))
    end
    return(1.0)
end
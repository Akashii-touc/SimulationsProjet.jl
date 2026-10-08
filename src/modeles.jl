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

#Un modèle décide comment on tire les buts des deux équipes à partir de leurs moyennes λ_A et λ_B
abstract type Modele end

#Buts indépendants qui suivent chacun une loi de Poisson
@kwdef mutable struct ModelePoisson <: Modele
    λ_A::Float64 = 1.0
    λ_B::Float64 = 1.0
end


#Poisson + une partie commune X aux deux équipes, plus grande quand les équipes sont proches
@kwdef mutable struct ModelePoissonBivariee <: Modele
    λ_A::Float64 = 1.0
    λ_B::Float64 = 1.0
    λ_commun::Float64 = 0.4
end


#Binomiale négative de même moyenne que Poisson mais plus dispersée (plus p est petit, plus c'est dispersé)
@kwdef mutable struct ModeleBinomialeNegative <: Modele
    λ_A::Float64 = 1.0
    λ_B::Float64 = 1.0
    p::Float64 = 0.8
end


#Poisson corrigé sur les petits scores (0-0, 1-0, 0-1, 1-1), avec ρ < 0 il y a plus de 0-0 et de 1-1
@kwdef mutable struct ModeleDixonColes <: Modele
    λ_A::Float64 = 1.0
    λ_B::Float64 = 1.0
    ρ::Float64 = -0.1
end


function Base.rand(modele::ModelePoisson, Δ::Float64, duree::Float64)
    return rand(Poisson(modele.λ_A)), rand(Poisson(modele.λ_B))
end


function Base.rand(modele::ModelePoissonBivariee, Δ::Float64, duree::Float64)
    X = rand(Poisson(modele.λ_commun * exp(-abs(Δ)) * duree))
    return (rand(Poisson(modele.λ_A)) + X, rand(Poisson(modele.λ_B)) + X)
end


function Base.rand(modele::ModeleBinomialeNegative, Δ::Float64, duree::Float64)
    return rand(NegativeBinomial(modele.λ_A * modele.p / (1 - modele.p), modele.p)), rand(NegativeBinomial(modele.λ_B * modele.p / (1 - modele.p), modele.p))
end


#On tire un score avec Poisson et on le garde avec une proba tau / tau_max, sinon on recommence
function Base.rand(modele::ModeleDixonColes, Δ::Float64, duree::Float64)
    τ_max = max(1.0, maximum(τ(a, b, modele.λ_A, modele.λ_B, modele.ρ) for a in 0:1, b in 0:1))
    while true
        buts_A, buts_B = rand(Poisson(modele.λ_A)), rand(Poisson(modele.λ_B))
        if rand() * τ_max < τ(buts_A, buts_B, modele.λ_A, modele.λ_B, modele.ρ)
            return (buts_A, buts_B)
        end
    end
end


#Facteur de correction de Dixon-Coles, il vaut 1 pour tous les scores sauf 0-0, 0-1, 1-0 et 1-1
function τ(buts_A::Int64, buts_B::Int64, λ_A::Float64, λ_B::Float64, ρ::Float64)
    if buts_A == 0 && buts_B == 0
        return max(0.0, 1 - λ_A * λ_B * ρ)
    elseif buts_A == 0 && buts_B == 1
        return max(0.0, 1 + λ_A * ρ)
    elseif buts_A == 1 && buts_B == 0
        return max(0.0, 1 + λ_B * ρ)
    elseif buts_A == 1 && buts_B == 1
        return max(0.0, 1 - ρ)
    end
    return 1.0
end
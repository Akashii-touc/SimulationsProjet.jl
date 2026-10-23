# SimulationsProjet

Simule la Ligue des champions (phase de ligue puis phase finale) des milliers de fois pour estimer les chances de chaque club.

## Utilisation

```julia
using SimulationsProjet

classement_stats(rand(10000, ModeleDixonColes()))                  # poids UEFA
classement_stats(rand(10000, ModeleDixonColes(), "Elo"))           # poids Elo
classement_stats(rand(10000, ModeleDixonColes(); seed = 1))        # mêmes résultats à chaque fois
classement_stats(rand(10000, ModeleDixonColes(μ = 1.1)))           # moins de buts par match
```

Graphiques (avec `using GLMakie`) :

```julia
df = classement_stats(rand(10000, ModeleDixonColes()))
graphique_chances(df)                     # chances de gagner par club
graphique_chances(df; etape = :Quart)     # autre étape
comparaison_modeles(10000)                # les 4 modèles côte à côte
```

Exemples complets dans `exemples/test.jl`.

Les simulations sont réparties sur plusieurs cœurs si Julia est lancé avec plusieurs threads : `julia -t auto` (ou réglage « Julia: Num Threads » à `auto` dans VS Code). Avec une `seed`, les résultats sont les mêmes tant que le nombre de threads ne change pas.

## Modèles

| Modèle | Idée | Paramètres par défaut |
|---|---|---|
| `ModelePoisson` | buts indépendants, loi de Poisson | `μ = 1.25` |
| `ModelePoissonBivariee` | Poisson + une partie commune aux deux équipes | `μ = 1.0`, `λ_commun = 0.4` |
| `ModeleBinomialeNegative` | plus dispersé que Poisson | `μ = 1.25`, `p = 0.8` |
| `ModeleDixonColes` | Poisson corrigé sur les petits scores | `μ = 1.25`, `ρ = -0.1` |

`μ` multiplie les moyennes de buts : avec les valeurs par défaut on a environ 3 buts par match, comme en Ligue des champions.

## Données (`fichier/`)

- `matchs.csv` : calendrier des 8 journées de la phase de ligue.
- `classement_club.csv` : coefficients UEFA (club et pays) et Elo des 36 clubs.
- `tirs_au_but.csv` : tirs au but tentés et réussis par club.

## Ajouts possibles

1. **Elo qui évolue** : mettre à jour l'Elo après chaque match simulé.
2. **Interface graphique**

## Tests automatiques

Les tests (`test/runtests.jl`) se lancent tout seuls sur GitHub :

- à chaque PR ouverte ou mise à jour,
- à chaque push sur `dev` ou `main`.

Le résultat s'affiche sur la PR : ✅ si tout passe, ❌ si un test casse (cliquer sur « Details » pour voir l'erreur).

Pour fusionner une PR vers `dev` ou `main`, il faut :

- que les tests passent,
- que la branche soit à jour avec la branche visée (sinon cliquer sur « Update branch »),
- une validation d'un des responsables (voir `.github/CODEOWNERS`).

La configuration est dans `.github/workflows/tests.yml`. Pour lancer les tests en local : `using Pkg; Pkg.test()`.

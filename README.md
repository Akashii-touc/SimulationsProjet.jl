# SimulationsProjet

Simulation de la Ligue des champions (format à 36 équipes) : phase de ligue, barrages, puis élimination directe jusqu'à la finale. On répète la compétition un grand nombre de fois pour estimer, pour chaque club, ses points moyens et ses chances d'aller à chaque tour.

## Lancer le projet

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using SimulationsProjet
S = SimulationsProjet

resultats = S.simuler_n_fois(10000, S.ModelePoisson())
S.classement_stats(resultats)
```

Un exemple complet avec tous les modèles est dans `exemples/test.jl`.

Lancer les tests :

```julia
using Pkg
Pkg.test()
```

## Modèles de buts

| Modèle | Idée |
|---|---|
| `ModelePoisson()` | Les buts de chaque équipe suivent une loi de Poisson, indépendamment |
| `ModelePoissonBivariee()` | Poisson avec une partie commune aux deux équipes, plus grande quand elles sont proches |
| `ModeleBinomialeNegative()` | Même moyenne que Poisson mais scores plus dispersés |
| `ModeleDixonColes()` | Poisson corrigé sur les petits scores (0-0, 1-0, 0-1, 1-1) |

## Force des équipes

Le troisième argument de `simuler_n_fois` choisit comment on mesure la force des clubs :

- `"Coefficient_UEFA"` (par défaut) : 80 % coefficient du club et 20 % coefficient du pays
- `"Elo"` : classement Elo du club

```julia
S.simuler_n_fois(10000, S.ModeleDixonColes(), "Elo")
```

## Organisation

- `src/equipe.jl` : équipes, force des clubs, probabilité de réussir un tir au but
- `src/modeles.jl` : modèles de buts
- `src/matchs.jl` : matchs, prolongations, tirs au but
- `src/simulation.jl` : phase de ligue, élimination directe, répétition des simulations
- `src/statistiques.jl` : tableau des résultats
- `fichier/` : classement des clubs, calendrier, statistiques de tirs au but

## Ajouts possibles

Par ordre de priorité :

1. **Tests automatiques sur GitHub** : lancer les tests à chaque PR pour voir tout de suite si quelque chose casse.
2. **Tableau final fidèle au vrai** : les affiches dépendent du classement (9e-10e contre 23e-24e en barrages, chemin fixé jusqu'à la finale) au lieu d'un tirage au hasard à chaque tour.
3. **Nombre de buts réaliste** : un paramètre pour régler la moyenne de buts par match (environ 3 en Ligue des champions, environ 2,2 dans la simulation actuelle).
4. **Elo qui évolue** : mettre à jour l'Elo après chaque match simulé.
5. **Résultats reproductibles** : fixer le hasard pour retrouver exactement les mêmes chiffres.
6. **Simulations plus rapides** : répartir les simulations sur plusieurs cœurs.
7. **Départage officiel** : appliquer les critères UEFA en cas d'égalité au classement (après les points, la différence de buts et les buts marqués).
8. **Comparaison avec la réalité** : comparer les probabilités obtenues aux vrais résultats ou aux cotes des bookmakers pour savoir quel modèle est le meilleur.
9. **Graphiques** : probabilités de victoire par club, comparaison des modèles.
10. **Interface graphique** : à voir une fois le reste en place.

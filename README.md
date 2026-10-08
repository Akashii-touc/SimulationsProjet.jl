# SimulationsProjet

## Ajouts possibles

1. **Tableau final fidèle au vrai** : les affiches dépendent du classement (9e-10e contre 23e-24e en barrages, chemin fixé jusqu'à la finale) au lieu d'un tirage au hasard à chaque tour.
2. **Nombre de buts réaliste** : un paramètre pour régler la moyenne de buts par match (environ 3 en Ligue des champions, environ 2,2 dans la simulation actuelle).
3. **Elo qui évolue** : mettre à jour l'Elo après chaque match simulé.
4. **Résultats reproductibles** : fixer le hasard pour retrouver exactement les mêmes chiffres.
5. **Simulations plus rapides** : répartir les simulations sur plusieurs cœurs.
6. **Départage officiel** : appliquer les critères UEFA en cas d'égalité au classement (après les points, la différence de buts et les buts marqués).
7. **Comparaison avec la réalité** : comparer les probabilités obtenues aux vrais résultats ou aux cotes des bookmakers pour savoir quel modèle est le meilleur.
8. **Graphiques** : probabilités de victoire par club, comparaison des modèles.
9. **Interface graphique**

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

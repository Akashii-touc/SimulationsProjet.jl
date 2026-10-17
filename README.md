# SimulationsProjet

## Ajouts possibles

1. **Nombre de buts réaliste** : un paramètre pour régler la moyenne de buts par match (environ 3 en Ligue des champions, environ 2,2 dans la simulation actuelle).
2. **Elo qui évolue** : mettre à jour l'Elo après chaque match simulé.
3. **Résultats reproductibles** : fixer le hasard pour retrouver exactement les mêmes chiffres.
4. **Simulations plus rapides** : répartir les simulations sur plusieurs cœurs.
5. **Départage officiel** : appliquer les critères UEFA en cas d'égalité au classement (après les points, la différence de buts et les buts marqués).
6. **Comparaison avec la réalité** : comparer les probabilités obtenues aux vrais résultats ou aux cotes des bookmakers pour savoir quel modèle est le meilleur.
7. **Graphiques** : probabilités de victoire par club, comparaison des modèles.
8. **Interface graphique**

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

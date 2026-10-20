# SimulationsProjet

## Ajouts possibles

1. **Elo qui évolue** : mettre à jour l'Elo après chaque match simulé.
2. **Résultats reproductibles** : fixer le hasard pour retrouver exactement les mêmes chiffres.
3. **Simulations plus rapides** : répartir les simulations sur plusieurs cœurs.
4. **Départage officiel** : appliquer les critères UEFA en cas d'égalité au classement (après les points, la différence de buts et les buts marqués).
5. **Comparaison avec la réalité** : comparer les probabilités obtenues aux vrais résultats ou aux cotes des bookmakers pour savoir quel modèle est le meilleur.
6. **Graphiques** : probabilités de victoire par club, comparaison des modèles.
7. **Interface graphique**

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

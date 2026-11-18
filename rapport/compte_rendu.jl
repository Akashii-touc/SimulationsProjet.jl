try; import KaimonSlate; catch; error("This is a Kaimon Slate notebook — running it as plain Julia needs the KaimonSlate runtime in this environment. Add it with `import Pkg; Pkg.add(\"KaimonSlate\")`, or open it in Kaimon Slate."); end; KaimonSlate.standalone!(@__MODULE__; dir=@__DIR__)

#%% md id=titre
@md"""
# Projet : simulation de la Ligue des champions

Dans ce projet, on a voulu savoir quelles sont les chances de chaque club de gagner la Ligue des champions (ou d'aller en huitièmes, en quarts, etc.).

Pour ça, on simule toute la compétition (phase de ligue + phase finale) 10 000 fois sur ordinateur, avec des scores tirés au hasard. Ensuite on compte : si un club gagne dans 2 000 simulations sur 10 000, on dit qu'il a 20 % de chances de gagner. C'est la méthode de Monte-Carlo.
"""

#%% md id=lancement
@md"""
### Comment lancer le notebook

Le notebook est fait avec [KaimonSlate](https://github.com/kahliburke/KaimonSlate.jl) (Julia 1.12 ou plus).

1. Installer Slate (une seule fois) : dans le REPL Julia, `] app add KaimonSlate`
2. Dans le dossier du projet, installer les dépendances : `julia --project -e "using Pkg; Pkg.instantiate()"`
3. Lancer `slate rapport/compte_rendu.jl` (sous Windows, `~/.julia/bin/slate.bat`), le notebook s'ouvre dans le navigateur

Le notebook utilise directement le projet qui le contient (`Project.toml` à la racine), donc le code est toujours celui de cette version du dépôt. Slate est réactif : quand on modifie une cellule, les cellules qui en dépendent sont relancées toutes seules.

La première fois c'est un peu long (compilation des paquets), après les simulations prennent environ 3 minutes.
"""

#%% md id=chargement_titre
@md"""
## 1. On charge le projet
"""

#%% code id=chargement
using SimulationsProjet, DataFrames, CairoMakie, Base64
CairoMakie.activate!(type = "png")

# Slate n'affiche pas les figures Makie directement : on les transforme en image
afficher(fig) = HTML("<img src='data:image/png;base64,$(base64encode(io -> show(io, MIME("image/png"), fig)))'>")

N = 10000 # nombre de simulations

#%% md id=donnees
@md"""
## 2. Les données

On a récupéré trois fichiers :
- `classement_club.csv` : les coefficients UEFA des 36 clubs (celui du club et celui de son pays)
- `matchs.csv` : le calendrier des 8 journées de la phase de ligue
- `tirs_au_but.csv` : les séances de tirs au but de chaque club, avec le nombre de tirs tentés et réussis
"""

#%% code id=classement
first(CLASSEMENT, 10)

#%% code id=calendrier
first(CALENDRIER, 5)

#%% code id=tirs
first(STATS_TAB, 5)

#%% md id=force
@md raw"""
### La force d'un club

Pour savoir si un club est fort, on lui donne un poids $w$ calculé à partir de ses coefficients UEFA. On compte surtout le coefficient du club (80 %) et un peu celui du pays (20 %) :

$$F = 0.8 \times \text{Coeff}_\text{club} + 0.2 \times \text{Coeff}_\text{pays}$$

Puis on ramène ça autour de 0, pour que les poids restent petits :

$$w = \frac{F - \overline{F}}{\max F - \min F}$$

### Les tirs au but

Pour chaque club, on regarde combien de tirs au but il a réussis. Mais certains clubs ont tiré très peu de fois, et ça ne suffit pas pour se faire une idée. On mélange donc avec 75 %, qui est à peu près la moyenne :

$$p = \frac{\text{réussis} + 0.75 \times 10}{\text{tentés} + 10}$$

Un club qui a tiré beaucoup de fois garde à peu près son vrai pourcentage. Un club qui a peu tiré reste proche de 75 %.
"""

#%% md id=scores
@md raw"""
## 3. Comment on tire les scores

Pour un match entre $A$ (à domicile) et $B$, on calcule d'abord la différence de force $\Delta = w_A - w_B$, puis le nombre moyen de buts de chaque équipe :

$$\lambda_A = \mu \times 1.2 \times e^{\Delta}, \qquad \lambda_B = \mu \times e^{-\Delta}$$

- plus $A$ est fort par rapport à $B$, plus $\lambda_A$ est grand ;
- le $1.2$ donne un petit avantage à l'équipe qui joue à domicile ;
- $\mu$ règle le nombre de buts. On l'a choisi pour avoir environ 3 buts par match, comme en vrai en Ligue des champions.

On a ensuite testé 4 façons (4 modèles) de tirer les scores à partir de $\lambda_A$ et $\lambda_B$ :

| Modèle | Idée | Paramètres |
|---|---|---|
| Poisson | les buts de chaque équipe suivent une loi de Poisson, chacun de son côté | μ = 1.25 |
| Poisson bivariée | pareil, plus des buts « en commun » aux deux équipes (pour avoir plus de matchs serrés entre équipes proches) | μ = 1, λ commun = 0.4 |
| Binomiale négative | même moyenne que Poisson, mais les scores varient plus | μ = 1.25, p = 0.8 |
| Dixon-Coles | Poisson, mais corrigé sur les petits scores (0-0, 1-0, 0-1, 1-1), que Poisson ne prévoit pas assez bien | μ = 1.25, ρ = -0.1 |

Rappel, la loi de Poisson : $P(X = k) = \dfrac{\lambda^k e^{-\lambda}}{k!}$
"""

#%% md id=simulation
@md"""
## 4. Comment se passe une simulation

1. **Phase de ligue :** on joue les 8 journées du calendrier. Une victoire rapporte 3 points, un nul 1 point.
2. **Classement :** les 8 premiers vont directement en huitièmes, les places 9 à 24 passent par un barrage, les 12 derniers sont éliminés.
3. **Phase finale :** matchs aller-retour. En cas d'égalité, il y a une prolongation puis des tirs au but. La finale se joue en un seul match.
"""

#%% md id=resultats_titre
@md"""
## 5. Résultats (modèle de Dixon-Coles)
"""

#%% code id=resultats
df = classement_stats(rand(N, ModeleDixonColes(); seed = 1))
show(df, allrows = true, allcols = true)

#%% code id=graphique
afficher(graphique_chances(df))

#%% code id=graphique_quarts
afficher(graphique_chances(df; etape = :Quart))

#%% md id=lecture
@md"""
**Comment lire le tableau :**
- `xPoints` : le nombre moyen de points en phase de ligue
- `Top8`, `Top24`, `Elimine` : les chances (en %) de finir dans les 8 premiers, dans les 24 premiers, ou d'être éliminé dès la phase de ligue
- `Huitieme`, `Quart`, `Demie`, `Finale`, `Vainqueur` : les chances (en %) d'arriver à cette étape

*(Si on relance, les chiffres peuvent un peu bouger selon le nombre de threads de Julia.)*

**Ce qu'on remarque :**

- **Il y a 4 favoris :** Arsenal (environ 22 %), le Bayern (environ 17,5 %), le Real Madrid (environ 13 %) et le PSG (environ 10 %). Même le favori gagne moins d'une fois sur 4 : avec les matchs à élimination directe, une mauvaise soirée suffit pour sortir.
- **Bizarrement, c'est le Bayern qui fait le plus de points en phase de ligue, mais c'est Arsenal qui gagne le plus souvent.** On pense que c'est parce qu'Arsenal a le meilleur poids (le championnat anglais a un gros coefficient : $F = 122{,}4$ contre $119{,}9$ pour le Bayern). Le Bayern aurait donc des adversaires plus faciles en phase de ligue. En plus, Arsenal est meilleur aux tirs au but (environ 83 % contre 78 %).
- **Finir dans le top 8 aide beaucoup**, parce qu'on évite le barrage. Les gros clubs y arrivent dans 55 à 80 % des cas.
- **En bas du tableau**, Sabah FC, le LASK et Viking sont éliminés dès la phase de ligue environ 9 fois sur 10.
- Sur le graphique des quarts, les clubs sont plus proches : beaucoup arrivent souvent en quarts. C'est après que les favoris font la différence.
"""

#%% md id=modeles_titre
@md"""
## 6. On compare les 4 modèles
"""

#%% code id=modeles
afficher(comparaison_modeles(N))

#%% md id=modeles_remarques
@md"""
**Ce qu'on remarque :**

- **Les 4 modèles donnent presque le même classement** : Arsenal, Bayern, Real Madrid, PSG, puis Inter, City et Liverpool. Les différences entre modèles sont petites (1 à 3 points au maximum).
- Avec la **binomiale négative**, les favoris gagnent un peu moins souvent (Arsenal environ 19 %). C'est logique : les scores varient plus, donc il y a plus de surprises.
- Avec **Dixon-Coles**, c'est l'inverse, les favoris gagnent un peu plus (Arsenal environ 22 %, Bayern environ 19 %).
- Donc **le choix du modèle ne change pas grand-chose** au résultat final.
"""

#%% md id=mu_titre
@md raw"""
## 7. Et si on change le nombre de buts ($\mu$) ?
"""

#%% code id=mu
for μ in [1.0, 1.25, 1.5]
    d = classement_stats(rand(N, ModeleDixonColes(μ = μ); seed = 1))
    println("μ = $μ : ", first(sort(d, :Vainqueur, rev = true), 3)[:, [:Club, :Vainqueur]])
end

#%% md id=mu_remarques
@md raw"""
**Ce qu'on remarque :**

- Les 3 favoris restent les mêmes quel que soit $\mu$.
- Avec plus de buts, le meilleur club gagne un peu plus souvent, car il y a moins de matchs nuls et donc moins de tirs au but (où tout peut arriver). Par exemple, le Bayern passe d'environ 17,3 % à 18,8 % quand $\mu$ passe de 1 à 1,5.
- Mais l'effet est petit (1 à 2 points), donc ce n'est pas grave si $\mu$ n'est pas réglé parfaitement.
"""

#%% md id=n_titre
@md"""
## 8. Est-ce que 10 000 simulations, c'est assez ?
"""

#%% code id=n
for n in [1000, 10000, 50000]
    d = classement_stats(rand(n, ModeleDixonColes(); seed = 2))
    println("n = $n : ", first(sort(d, :Vainqueur, rev = true), 3)[:, [:Club, :Vainqueur]])
end

#%% md id=n_remarques
@md raw"""
On a relancé avec 1 000, 10 000 et 50 000 simulations pour comparer.

L'erreur faite en estimant une probabilité $p$ avec $n$ essais est d'environ $\sqrt{p(1-p)/n}$. Pour $p = 0{,}2$ :

| $n$ | erreur |
|---|---|
| 1 000 | environ 1,3 point |
| 10 000 | environ 0,4 point |
| 50 000 | environ 0,2 point |

**Ce qu'on remarque :** on retrouve bien ça. Avec 1 000 simulations, le Bayern est à 15,9 % au lieu d'environ 18 %, ce n'est pas assez précis. Entre 10 000 et 50 000, les chiffres ne bougent presque plus. **10 000 simulations suffisent** : l'erreur (0,4 point) est bien plus petite que les écarts entre les clubs.
"""

#%% md id=conclusion
@md raw"""
## 9. Conclusion

En simulant 10 000 fois la Ligue des champions, on a pu estimer les chances de chaque club à chaque étape. D'après nos simulations (modèle de Dixon-Coles), **Arsenal est le favori avec environ 22 % de chances**, devant le Bayern, le Real Madrid et le PSG.

- Les résultats sont **assez stables** : ils changent peu quand on change de modèle ou de nombre de buts, et 10 000 simulations donnent une bonne précision.
- Même le favori gagne moins d'une fois sur 4 : en Ligue des champions, il y a beaucoup de hasard.

**Les limites de notre projet :**
- la force d'un club ne change pas pendant la compétition (pas de blessures, pas de forme du moment) ;
- le tirage de la phase finale est simplifié ;
- certains paramètres ($\mu$, $\rho$, l'avantage à domicile de 1,2) ont été choisis à la main, on ne les a pas calculés à partir de vrais matchs.
"""

# ╔═╡ Slate.config · per-notebook settings (Settings panel)
#   docid = 24161c59-f98d-43ca-b282-95bc3d839edd
# ╚═╡

#PARAMETRES DE L'INTERFACE
const MODELE_DEFAULT = "Poisson"
const POIDS_DEFAULT = "Coefficient UEFA"
const AFFICHAGES = ["Tableau", "Graphique"]
const AFFICHAGE_DEFAULT = "Tableau"
const ETAPES = ["Vainqueur" => :Vainqueur, "Finale" => :Finale, "Demi-finales" => :Demie, "Quarts de finale" => :Quart, "Huitièmes de finale" => :Huitieme, "Top 8" => :Top8]
const NOMS_ETAPES = first.(ETAPES) #noms des étapes dans l'ordre du menu
const OPTION_ETAPES = Dict(ETAPES) #nom de l'étape => colonne du DataFrame
const ETAPE_DEFAULT = "Vainqueur"
const NB_CLUBS_GRAPHIQUE = 16
const COLONNES_TABLEAU = [(:xPoints, "xPoints"), (:Top8, "Top 8 (%)"), (:Top24, "Top 24 (%)"), (:Elimine, "Éliminé (%)"), (:Huitieme, "8èmes (%)"), (:Quart, "Quarts (%)"), (:Demie, "Demies (%)"), (:Finale, "Finale (%)"), (:Vainqueur, "Vainqueur (%)")]


#COULEURS
const NAVY = "#10233F"
const BLUE = "#3978F6"
const GREY = "#F3F6FB"
const WHITE = "#FFFFFF"
const BLEU_CLAIR = "#91B7FF"
const TEXTE_GRIS = "#8A97AD"
const BANDE = "#F3F6FB"


struct Ecran
    menu_modele::Menu
    menu_poids::Menu
    menu_affichage::Menu
    menu_etape::Menu
    titre::Observable{String}
    sous_titre::Observable{String}
    contenu::GridLayout
end


function bloquer_zoom(ax)
    for interaction in (:scrollzoom, :dragpan, :rectanglezoom, :limitreset)
        deregister_interaction!(ax, interaction)
    end
end


function titre_resultats(affichage, nom_etape, etape)
    if affichage == "Tableau"
        return "Simulation complète"
    elseif etape == :Vainqueur
        return "Pourcentage de chances de remporter la Ligue des champions"
    else
        return "Pourcentage de chances d'atteindre : $nom_etape"
    end
end


function vider_layout(layout)
    for element in collect(contents(layout))
        delete!(element)
    end
    trim!(layout)
end


function tableau_resultats(pos, df::DataFrame)
    n = nrow(df)
    larg_club = 2.0
    larg_col = 1.35
    largeur = larg_club + larg_col * length(COLONNES_TABLEAU)

    ax = Axis(pos, backgroundcolor = :transparent)
    hidedecorations!(ax)
    hidespines!(ax)
    bloquer_zoom(ax)

    poly!(ax, Rect2f(0, -0.5, largeur, 1), color = NAVY)
    lignes_paires = Rect2f[]
    for i in 2:2:n
        push!(lignes_paires, Rect2f(0, -i - 0.5, largeur, 1))
    end
    poly!(ax, lignes_paires, color = BANDE)

    positions_entete = Point2f[]
    titres_colonnes = String[]
    for j in eachindex(COLONNES_TABLEAU)
        push!(positions_entete, Point2f(larg_club + (j - 0.5) * larg_col, 0))
        push!(titres_colonnes, COLONNES_TABLEAU[j][2])
    end
    translate!(text!(ax, positions_entete, text = titres_colonnes, align = (:center, :center), fontsize = 12, font = :bold, color = WHITE), 0, 0, 3)
    translate!(text!(ax, [Point2f(0.3, 0)], text = ["Club"], align = (:left, :center), fontsize = 13, font = :bold, color = WHITE), 0, 0, 3)

    positions_clubs = Point2f[]
    for i in 1:n
        push!(positions_clubs, Point2f(0.3, -i))
    end
    translate!(text!(ax, positions_clubs, text = df.Club, align = (:left, :center), fontsize = 13, font = :bold, color = NAVY), 0, 0, 3)

    positions_valeurs = Point2f[]
    textes_valeurs = String[]
    couleurs_valeurs = String[]
    for j in eachindex(COLONNES_TABLEAU)
        colonne = COLONNES_TABLEAU[j][1]
        for i in 1:n
            valeur = df[i, colonne]
            push!(positions_valeurs, Point2f(larg_club + (j - 0.5) * larg_col, -i))
            push!(textes_valeurs, string(round(valeur, digits = 2)))
            if valeur == 0
                push!(couleurs_valeurs, TEXTE_GRIS)
            else
                push!(couleurs_valeurs, NAVY)
            end
        end
    end
    translate!(text!(ax, positions_valeurs, text = textes_valeurs, align = (:center, :center), fontsize = 13, color = couleurs_valeurs), 0, 0, 3)
    limits!(ax, 0, largeur, -n - 0.5, 0.5)
    return ax
end


function graphique_resultats(pos, df::DataFrame; etape = :Vainqueur, nb_clubs = NB_CLUBS_GRAPHIQUE)
    tri = first(sort(df, etape, rev = true), nb_clubs)
    valeurs = Float64.(tri[!, etape])
    maxi = max(maximum(valeurs), 1.0)

    textes_barres = String[]
    for valeur in valeurs
        push!(textes_barres, string(round(valeur, digits = 2)) * " %")
    end

    ax = Axis(pos,
        backgroundcolor = :transparent,
        xlabel = "Probabilité (%)",
        xlabelcolor = NAVY,
        yticks = (1:nrow(tri), tri.Club),
        yreversed = true,
        yticklabelcolor = NAVY,
        xticklabelcolor = NAVY,
        yticksvisible = false,
        ygridvisible = false,
        xgridcolor = "#E3E9F3",
        topspinevisible = false,
        rightspinevisible = false,
        leftspinevisible = false,
        bottomspinecolor = "#C9D3E3",
        xtickcolor = "#C9D3E3",
        yticklabelsize = 14,
    )
    bloquer_zoom(ax)
    barplot!(ax, 1:nrow(tri), valeurs;
        direction = :x,
        color = BLUE,
        gap = 0.3,
        bar_labels = textes_barres,
        label_size = 13,
        label_color = NAVY,
        label_offset = 8,
    )
    xlims!(ax, 0, maxi * 1.15)
    return ax
end


function menu_deroulant(pos, options, default)
    return Menu(pos;
        options = options,
        default = default,
        width = 252,
        fontsize = 15,
        textcolor = NAVY,
        textpadding = (12, 12, 10, 10),
        cell_color_inactive_even = WHITE,
        cell_color_inactive_odd = WHITE,
        cell_color_hover = "#E5EDFB",
        cell_color_active = "#D3E2FD",
        selection_cell_color_inactive = WHITE,
        dropdown_arrow_color = BLUE,
    )
end

#MENU LATERAL
function creer_menu_lateral(grille)
    Box(grille[1, 1], color = "#CAD9ED", strokevisible = false)

    menus = grille[1, 1] = GridLayout(valign = :top, halign = :center, tellheight = false, alignmode = Outside(24, 24, 0, 110))
    rowgap!(menus, 8)

    Label(grille[1, 1], "MENU DE SIMULATIONS", fontsize = 24, font = :bold, color = NAVY, halign = :center, valign = :top, tellwidth = false, tellheight = false, padding = (0, 0, 0, 28))

    Label(menus[1, 1], "MODÈLE", fontsize = 15, font = :bold, color = NAVY, halign = :left, tellwidth = false, padding = (0, 0, 2, 0))
    menu_modele = menu_deroulant(menus[2, 1], NOMS_MODELES, MODELE_DEFAULT)

    Label(menus[3, 1], "POIDS DES CLUBS", fontsize = 15, font = :bold, color = NAVY, halign = :left, tellwidth = false, padding = (0, 0, 2, 20))
    menu_poids = menu_deroulant(menus[4, 1], NOMS_POIDS, POIDS_DEFAULT)

    Label(menus[5, 1], "AFFICHAGE", fontsize = 15, font = :bold, color = NAVY, halign = :left, tellwidth = false, padding = (0, 0, 2, 20))
    menu_affichage = menu_deroulant(menus[6, 1], AFFICHAGES, AFFICHAGE_DEFAULT)

    Label(menus[7, 1], "ÉTAPE", fontsize = 15, font = :bold, color = NAVY, halign = :left, tellwidth = false, padding = (0, 0, 2, 20))
    menu_etape = menu_deroulant(menus[8, 1], NOMS_ETAPES, ETAPE_DEFAULT)

    return menu_modele, menu_poids, menu_affichage, menu_etape
end


#ZONE DES RESULTATS
function creer_zone_resultats(grille)
    zone = grille[1, 2] = GridLayout(alignmode = Outside(28))
    rowgap!(zone, 16)

    titre = Observable("")
    sous_titre = Observable("")
    entete = zone[1, 1] = GridLayout()
    rowgap!(entete, 4)
    Label(entete[1, 1], titre, fontsize = 24, font = :bold, color = NAVY, halign = :left, tellwidth = false)
    Label(entete[2, 1], sous_titre, fontsize = 14, color = TEXTE_GRIS, halign = :left, tellwidth = false)

    Box(zone[2, 1], color = WHITE, cornerradius = 14, strokevisible = false)
    contenu = zone[2, 1] = GridLayout(alignmode = Outside(18))
    return titre, sous_titre, contenu
end


function afficher_resultats(ecran::Ecran, nom_modele, nom_poids, affichage, nom_etape)
    vider_layout(ecran.contenu)
    df = RESULTATS[(nom_modele, nom_poids)]
    etape = OPTION_ETAPES[nom_etape]
    ecran.titre[] = titre_resultats(affichage, nom_etape, etape)
    ecran.sous_titre[] = "Modèle : $nom_modele  ·  Poids : $nom_poids  ·  10 000 simulations"
    if affichage == "Graphique"
        graphique_resultats(ecran.contenu[1, 1], df; etape = etape)
    else
        tableau_resultats(ecran.contenu[1, 1], df)
    end
end


function mettre_a_jour(ecran::Ecran)
    nom_modele = ecran.menu_modele.selection[]
    nom_poids = ecran.menu_poids.selection[]
    affichage = ecran.menu_affichage.selection[]
    nom_etape = ecran.menu_etape.selection[]
    afficher_resultats(ecran, nom_modele, nom_poids, affichage, nom_etape)
end


function creer_interface()
    #menu à gauche (largeur fixe), résultats à droite
    fig = Figure(size = (1360, 860), backgroundcolor = GREY, fontsize = 15, figure_padding = 0)
    grille = fig[1, 1] = GridLayout()
    colsize!(grille, 1, Fixed(300))
    colgap!(grille, 0)

    menu_modele, menu_poids, menu_affichage, menu_etape = creer_menu_lateral(grille)
    titre, sous_titre, contenu = creer_zone_resultats(grille)
    ecran = Ecran(menu_modele, menu_poids, menu_affichage, menu_etape, titre, sous_titre, contenu)

    #affichage de départ avec les choix par défaut
    afficher_resultats(ecran, MODELE_DEFAULT, POIDS_DEFAULT, AFFICHAGE_DEFAULT, ETAPE_DEFAULT)

    #à chaque changement d'un menu, on réaffiche
    on(menu_modele.selection) do _
        mettre_a_jour(ecran)
    end
    on(menu_poids.selection) do _
        mettre_a_jour(ecran)
    end
    on(menu_affichage.selection) do _
        mettre_a_jour(ecran)
    end
    on(menu_etape.selection) do _
        mettre_a_jour(ecran)
    end
    return fig
end


function interface()
    #les simulations ne sont lancées que si elles n'ont pas déjà été faites
    if isempty(RESULTATS)
        calculer_resultats()
    end
    return WGLMakie.Bonito.App(creer_interface)
end


function launch(; port = 8080)
    app = interface()
    serveur = WGLMakie.Bonito.Server(app, "127.0.0.1", port)
    println("Interface disponible sur http://127.0.0.1:$port")
    return serveur
end
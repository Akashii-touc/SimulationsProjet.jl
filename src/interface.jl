#PARAMETRES
const NB_RUN_DEFAULT = 10000 #nombre de simulations par défaut
const NOMS_MODELES = ["Poisson", "Poisson bivariée", "Binomiale négative", "Dixon-Coles"] #ordre d'affichage du menu
const OPTION_MODELES = Dict("Poisson" => ModelePoisson(), "Poisson bivariée" => ModelePoissonBivariee(), "Binomiale négative" => ModeleBinomialeNegative(), "Dixon-Coles" => ModeleDixonColes())
const MODELE_DEFAULT = "Poisson"
const OPTION_POIDS = Dict("Coefficient UEFA" => "Coefficient_UEFA", "Elo" => "Elo")
const NOMS_POIDS = ["Coefficient UEFA", "Elo"]
const POIDS_DEFAULT = "Coefficient UEFA"
const OPTION_ETAPES = ["Vainqueur", "Finale", "Demie", "Quart", "Huitieme", "Top8"]


#COULEURS
const NAVY = "#10233F"
const NAVYBLUE = "#172B4D"
const BLUE = "#3978F6"
const GREY = "#F3F6FB"
const WHITE = "#FFFFFF"

#MENU
const STYLE_MENU = (width = 250, cell_color_active = "#F9FAFB", cell_color_hover = "#E5E7EB", selection_cell_color_inactive = WHITE)


#Bloque le zoom et le déplacement à la souris
function bloquer_zoom(ax)
    for interaction in (:scrollzoom, :dragpan, :rectanglezoom, :limitreset)
        deregister_interaction!(ax, interaction)
    end
end


#Tableau avec un seul text! (plus rapide que un Label par case)
function tableau_resultats(pos, df::DataFrame)
    ax = Axis(pos, backgroundcolor = :transparent)
    hidedecorations!(ax)
    hidespines!(ax)
    bloquer_zoom(ax)

    positions = Point2f[] #où écrire chaque texte
    textes = String[]     #ce qu'on écrit

    for j in 1:ncol(df)
        if j == 1
            x = 1 #colonne des clubs
        else
            x = j + 2 #les autres colonnes, plus à droite pour laisser de la place aux noms
        end
        push!(positions, Point2f(x, 0)) #en-tête
        push!(textes, names(df)[j])
        for i in 1:nrow(df)
            push!(positions, Point2f(x, -i)) #une ligne par club, vers le bas
            push!(textes, string(df[i, j]))
        end
    end

    text!(ax, positions, text = textes, align = (:center, :center), fontsize = 12, color = NAVY)
    limits!(ax, 0, ncol(df) + 3, -nrow(df) - 1, 1)
end


#Construit une figure neuve (appelée à chaque ouverture de la page)
function creer_interface()
    #CREATION DE LA FENETRE
    fig = Figure(size = (1280, 720), backgroundcolor = GREY, fontsize = 17)
    grille = fig[1,1] = GridLayout()
    menu_lateral = grille[1,1] = GridLayout(alignmode = Inside())
    affichage_sim = grille[1,2] = GridLayout(alignmode = Inside())
    tableau = affichage_sim[1,1] = GridLayout(alignmode = Inside())
    colsize!(grille, 1, Relative(0.22))
    colsize!(grille, 2, Relative(0.78))


    #LABELS
    Label(menu_lateral[1,1], "MENU DE SIMULATIONS", fontsize = 25, color = NAVY, font = :bold, halign = :left)
    Label(menu_lateral[2,1], "Nombre de simulation", font = :bold, halign = :left)
    Label(menu_lateral[4,1], "Choix du modele et du poids", font = :bold, halign = :left)
    Label(menu_lateral[7,1], "Affichage et étape", font = :bold, halign = :left)


    #BOUTONS
    nb_run = Textbox(menu_lateral[3, 1],
        stored_string = string(NB_RUN_DEFAULT),
        placeholder = "Exemple : 10000",
        textcolor = NAVYBLUE,
        validator = Int,
        width = 245,
        height = 42,
        textpadding = (12, 12, 10, 10),
        boxcolor = WHITE,
        bordercolor = "#D8E0EC",
        bordercolor_hover = "#3B82F6",
        bordercolor_focused = BLUE,
        borderwidth = 1.5,
        cornerradius = 8,
    )

    menu_mod = Menu(menu_lateral[5,1]; options = NOMS_MODELES, default = MODELE_DEFAULT, STYLE_MENU...)
    menu_poids = Menu(menu_lateral[6,1]; options = NOMS_POIDS, default = POIDS_DEFAULT, STYLE_MENU...)
    menu_affichage = Menu(menu_lateral[8,1]; options = ["Tableau", "Graphique"], default = "Tableau", STYLE_MENU...)
    menu_etape = Menu(menu_lateral[9,1]; options = OPTION_ETAPES, default = "Vainqueur", STYLE_MENU...)

    run_button = Button(menu_lateral[10, 1],
        label = "RUN SIMULATIONS",
        labelcolor = WHITE,
        font = :bold,
        width = 250,
        height = 45,
        buttoncolor = "#3B82F6",
        buttoncolor_hover = "#2563EB",
        cornerradius = 6,
        strokewidth = 0
    )


    on(run_button.clicks) do _
        n = tryparse(Int, strip(something(nb_run.stored_string[], "")))
        if n === nothing || n < 1
            return #nombre invalide : on ne fait rien
        end
        for element in collect(contents(tableau))
            delete!(element)
        end
        trim!(tableau)
        poids = OPTION_POIDS[menu_poids.selection[]]
        modele = OPTION_MODELES[menu_mod.selection[]]
        df = classement_stats(rand(n, modele, poids))
        if menu_affichage.selection[] == "Graphique"
            graphique_chances(df; etape = Symbol(menu_etape.selection[]), fig = fig, pos = tableau[1,1])
            for element in contents(tableau)
                element isa Axis && bloquer_zoom(element)
            end
        else
            tableau_resultats(tableau[1,1], df)
        end
    end

    return fig
end


function launch(; port = 8080)
    app = WGLMakie.Bonito.App(creer_interface)
    serveur = WGLMakie.Bonito.Server(app, "127.0.0.1", port)
    println("Interface disponible sur http://127.0.0.1:$port")
    return serveur
end
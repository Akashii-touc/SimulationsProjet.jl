#PARAMETRES

const NB_RUN_DEFAULT = 10000 #nombre de simulations par défaut
const OPTION_MODELES = Dict("Poisson" => ModelePoisson(),
                            "Poisson bivariée" => ModelePoissonBivariee(),
                            "Binomiale négative" => ModeleBinomialeNegative(), 
                            "Dixon-Coles" => ModeleDixonColes()
                       )
const MODELE_DEFAULT = "Poisson"
const OPTION_POIDS = Dict("Coefficient UEFA" => "Coefficient_UEFA", "Elo" => "Elo")
const POIDS_DEFAULT = "Coefficient UEFA"
const OPTION_ETAPES = ["Vainqueur", "Finale", "Demie", "Quart", "Huitieme", "Top8"]

#COULEURS

const NAVY = "#10233F"
const NAVYBLUE = "#172B4D"
const LIGHTBLUE = "#6B7A90"
const BLUE = "#3978F6"
const GREEN = "#19A974"
const GREY = "#F3F6FB"
const WHITE = "#FFFFFF"


function launch()
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

    
    #BOUTONS
    nb_run = Textbox(menu_lateral[3, 1],
        stored_string = "10000",
        placeholder = "Exemple : 10000",
        textcolor_placeholder = "#000002", 
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
    
    menu_mod = Menu(menu_lateral[5,1],
        options = collect(keys(OPTION_MODELES)),
        default = MODELE_DEFAULT,
        width = 250,
        cell_color_active = "#F9FAFB",
        cell_color_hover = "#E5E7EB",
        selection_cell_color_inactive = WHITE
    )

    menu_poids = Menu(menu_lateral[6,1],
        options = collect(keys(OPTION_POIDS)),
        default = POIDS_DEFAULT,
        width = 250,
        cell_color_active = "#F9FAFB",
        cell_color_hover = "#E5E7EB",
        selection_cell_color_inactive = WHITE
    )

    Label(menu_lateral[7,1], "Affichage et étape", font = :bold, halign = :left)

    menu_affichage = Menu(menu_lateral[8,1],
        options = ["Tableau", "Graphique"],
        default = "Tableau",
        width = 250,
        cell_color_active = "#F9FAFB",
        cell_color_hover = "#E5E7EB",
        selection_cell_color_inactive = WHITE
    )

    menu_etape = Menu(menu_lateral[9,1],
        options = OPTION_ETAPES,
        default = "Vainqueur",
        width = 250,
        cell_color_active = "#F9FAFB",
        cell_color_hover = "#E5E7EB",
        selection_cell_color_inactive = WHITE
    )

    run_button = Button(menu_lateral[10, 1],
        label = "RUN SIMULATIONS",
        labelcolor = WHITE,              # Texte en blanc
        font = :bold,
        width = 250,
        height = 45,
        buttoncolor = "#3B82F6",          # Bouton bleu
        buttoncolor_hover = "#2563EB",    # Bleu foncé au survol
        cornerradius = 6,
        strokewidth = 0                   # Pas de bordure noire
    )

    
    on(run_button.clicks) do _
        for element in collect(contents(tableau))
            delete!(element)
        end
        trim!(tableau)
        n = tryparse(Int, strip(nb_run.stored_string[]))
        poids = OPTION_POIDS[menu_poids.selection[]]
        modele = OPTION_MODELES[menu_mod.selection[]]
        classement = rand(n, modele, poids)
        df = classement_stats(classement)
        if menu_affichage.selection[] == "Graphique"
            rowsize!(tableau, 1, Auto())
            graphique_chances(df; etape = Symbol(menu_etape.selection[]), fig = fig, pos = tableau[1,1])
            return
        end
        nom = names(df)
        for j in eachindex(nom)
            if (j == 1)
                Label(tableau[1,j], nom[j], fontsize = 16, color = NAVY, font = :bold, halign = :left)
            else
                Label(tableau[1,j], nom[j], fontsize = 16, color = NAVY, font = :bold, halign = :center)
            end
        end
        for i in 1:nrow(df)
            for j in 1:ncol(df)
                if (j == 1)
                    Label(tableau[i + 1,j], string(df[i,j]), fontsize = 12, color = NAVY, font = :bold, halign = :left)
                else
                    Label(tableau[i + 1,j], string(df[i,j]), fontsize = 12, color = NAVY, font = :bold, halign = :center)
                end
            end
            rowsize!(tableau, i, Fixed(0))
        end
        rowsize!(tableau, nrow(df)+1, Fixed(0))
    end
    display(fig, float = false)
end

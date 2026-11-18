using Random

equipe_phase(nom, poids) = Equipe(nom, "France", 0, 0, 0, 0, 0, poids, 0, 0.75)

@testset "types de phases" begin
    for type_phase in (PhaseLigue, AllerRetour, Finale, PhaseEliminatoire)
        @test type_phase <: Phase
    end

    #valeurs par défaut
    @test PhaseLigue().avantage == 1.2
    @test AllerRetour().avantage == 1.2
    @test AllerRetour().duree_prolongation ≈ 1 / 3
    @test Finale().duree_prolongation ≈ 1 / 3
    @test PhaseEliminatoire().tour isa AllerRetour
    @test PhaseEliminatoire().finale isa Finale

    #paramètres réglables, et modifiables après la création (mutable struct)
    @test AllerRetour(avantage = 1.5).avantage == 1.5
    phase = Finale()
    phase.duree_prolongation = 0.5
    @test phase.duree_prolongation == 0.5

    #chaque PhaseEliminatoire a ses propres tours
    a = PhaseEliminatoire()
    b = PhaseEliminatoire()
    a.tour.avantage = 1.0
    @test b.tour.avantage == 1.2
end

@testset "jouer PhaseLigue" begin
    Random.seed!(20)
    classement = jouer(PhaseLigue(), ModelePoisson(), PoidsUEFA())
    @test length(classement) == 36
    @test all(equipe -> equipe.mj == 8, classement)
    @test sum(equipe.mj for equipe in classement) == 36 * 8
    @test sum(equipe.db for equipe in classement) == 0
    @test sum(equipe.buts_pour for equipe in classement) == sum(equipe.buts_contre for equipe in classement)
    @test 36 * 8 <= sum(equipe.points for equipe in classement) <= 36 * 12

    #classement trié par points, puis différence de buts, puis buts marqués
    cles = [(e.points, e.db, e.buts_pour) for e in classement]
    @test issorted(cles, rev = true)

    #avec K = 0, les poids Elo de départ ne bougent pas pendant toute la phase de ligue
    classement = jouer(PhaseLigue(), ModelePoisson(), PoidsElo(K = 0.0))
    for equipe in classement
        i = findfirst(==(equipe.club), CLASSEMENT.Club)
        @test equipe.poids ≈ CLASSEMENT.Elo[i] / 400
    end

    #avec le coefficient UEFA, les poids évoluent
    classement = jouer(PhaseLigue(), ModelePoisson(), PoidsUEFA())
    @test any(equipe -> equipe.poids != POIDS_CLUBS_COEFF[findfirst(==(equipe.club), CLASSEMENT.Club)], classement)
end

@testset "jouer PhaseLigue avantage du terrain" begin
    #avantage = 0 : l'équipe à domicile ne marque jamais, donc il y a moins de buts qu'avec l'avantage par défaut
    Random.seed!(27)
    sans_avantage = jouer(PhaseLigue(avantage = 0.0), ModelePoisson(), PoidsElo())
    avec_avantage = jouer(PhaseLigue(), ModelePoisson(), PoidsElo())
    @test sum(equipe.buts_pour for equipe in sans_avantage) < sum(equipe.buts_pour for equipe in avec_avantage)
end

@testset "jouer AllerRetour" begin
    equipes_tour = [equipe_phase("Equipe $i", i / 10) for i in 1:8]
    Random.seed!(23)
    qualifiees = jouer(AllerRetour(), equipes_tour, ModelePoisson(), PoidsElo())

    @test length(qualifiees) == 4
    @test sum(e.parcours for e in equipes_tour) == 4
    for i in 1:4
        @test qualifiees[i] === equipes_tour[2i - 1] || qualifiees[i] === equipes_tour[2i]
    end

    #la deuxième équipe reçoit au retour : le modèle garde les intensités de ce dernier match (K = 0 : les poids ne changent pas)
    barragiste = equipe_phase("Barragiste", 0.0)
    tete_de_serie = equipe_phase("Tête de série", log(2.0))
    modele = ModelePoisson()
    Random.seed!(24)
    jouer(AllerRetour(), [barragiste, tete_de_serie], modele, PoidsElo(K = 0.0))
    @test isapprox(modele.λ_A / modele.λ_B, 1.2 * exp(2 * (tete_de_serie.poids - barragiste.poids)))

    #l'avantage vient de la phase
    barragiste = equipe_phase("Barragiste", 0.0)
    tete_de_serie = equipe_phase("Tête de série", log(2.0))
    modele = ModelePoisson()
    Random.seed!(24)
    jouer(AllerRetour(avantage = 2.0), [barragiste, tete_de_serie], modele, PoidsElo(K = 0.0))
    @test isapprox(modele.λ_A / modele.λ_B, 2.0 * exp(2 * (tete_de_serie.poids - barragiste.poids)))

    #avec le coefficient UEFA, les poids des équipes bougent pendant le tour
    A = equipe_phase("A", 0.0)
    B = equipe_phase("B", 0.0)
    Random.seed!(28)
    jouer(AllerRetour(), [A, B], ModelePoisson(), PoidsUEFA())
    @test A.poids != 0.0 || B.poids != 0.0

    #avec K = 0 (Elo), ils ne bougent pas
    A = equipe_phase("A", 0.0)
    B = equipe_phase("B", 0.0)
    Random.seed!(28)
    jouer(AllerRetour(), [A, B], ModelePoisson(), PoidsElo(K = 0.0))
    @test A.poids == 0.0
    @test B.poids == 0.0
end

@testset "jouer Finale" begin
    A = Equipe(club = "A", pays = "FR", poids = 0)
    B = Equipe(club = "B", pays = "ES", poids = 0)
    Random.seed!(25)

    gagnant = jouer(Finale(), [A, B], ModelePoisson(), PoidsElo())
    @test gagnant === A || gagnant === B
    @test A.parcours + B.parcours == 1

    #à forces égales, aucune équipe n'est systématiquement favorisée
    A = Equipe(club = "A", pays = "FR", poids = 0)
    B = Equipe(club = "B", pays = "ES", poids = 0)
    Random.seed!(26)
    victoires_A = count(jouer(Finale(), [A, B], ModelePoisson(), PoidsElo()) === A for _ in 1:2_000)
    @test isapprox(victoires_A / 2_000, 0.5, atol = 0.05)
    @test A.parcours + B.parcours == 2_000

    #la finale se joue sans avantage du terrain : λ_A / λ_B = exp(2Δ)
    A = Equipe(club = "A", pays = "FR", poids = 0.3)
    B = Equipe(club = "B", pays = "ES", poids = 0.0)
    modele = ModelePoisson()
    jouer(Finale(), [A, B], modele, PoidsElo())
    @test isapprox(modele.λ_A / modele.λ_B, exp(0.6))
end

@testset "jouer PhaseEliminatoire" begin
    classement = jouer(PhaseLigue(), ModelePoisson(), PoidsUEFA())
    Random.seed!(29)
    gagnant = jouer(PhaseEliminatoire(), classement, ModelePoisson(), PoidsUEFA())

    @test gagnant isa Equipe
    @test gagnant.parcours == 6
    parcours = getfield.(classement, :parcours)
    @test all(p -> 0 <= p <= 6, parcours)
    @test count(==(6), parcours) == 1
    @test count(>=(5), parcours) == 2 #les deux finalistes

    #il faut les 36 équipes de la phase de ligue
    @test_throws ErrorException jouer(PhaseEliminatoire(), classement[1:35], ModelePoisson(), PoidsUEFA())
end

@testset "mêmes phases avec chaque poids" begin
    for poids in (PoidsUEFA(), PoidsElo())
        modele = ModeleDixonColes()
        classement = jouer(PhaseLigue(), modele, poids)
        gagnant = jouer(PhaseEliminatoire(), classement, modele, poids)
        @test gagnant.parcours == 6
    end
end

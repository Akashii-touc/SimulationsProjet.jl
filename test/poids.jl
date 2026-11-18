@testset "types de poids" begin
    @test PoidsUEFA <: Poids
    @test PoidsElo <: Poids

    #valeurs par défaut
    @test PoidsUEFA().gain_match == 2.0
    @test PoidsUEFA().bonus_tour == 1.5
    @test PoidsUEFA().bonus_classement == 0.25
    @test PoidsElo().K == 40.0
    @test PoidsElo().echelle == 400.0

    #paramètres réglables, et modifiables après la création (mutable struct)
    @test PoidsElo(K = 20.0).K == 20.0
    poids = PoidsUEFA(bonus_tour = 3.0)
    @test poids.bonus_tour == 3.0
    @test poids.gain_match == 2.0
    poids.gain_match = 4.0
    @test poids.gain_match == 4.0
end

@testset "poids_club" begin
    @test poids_club(1, PoidsUEFA()) == POIDS_CLUBS_COEFF[1]
    @test poids_club(1, PoidsElo()) == CLASSEMENT.Elo[1] / 400
    @test poids_club(1, PoidsElo(echelle = 200.0)) == CLASSEMENT.Elo[1] / 200

    #un type inconnu n'est plus ignoré en silence
    @test_throws MethodError poids_club(1, "Elo")
end

@testset "equipes selon le poids" begin
    i = findfirst(==("Bayern"), CLASSEMENT.Club)
    @test equipes(PoidsUEFA())["Bayern"].poids == POIDS_CLUBS_COEFF[i]
    @test equipes(PoidsElo())["Bayern"].poids == CLASSEMENT.Elo[i] / 400
    @test equipes()["Bayern"].poids == POIDS_CLUBS_COEFF[i] #PoidsUEFA par défaut
end

@testset "score_match" begin
    @test SimulationsProjet.score_match(2, 1) == (1.0, 0.0)
    @test SimulationsProjet.score_match(1, 1) == (0.5, 0.5)
    @test SimulationsProjet.score_match(0, 3) == (0.0, 1.0)
end

@testset "modif_poids Elo" begin
    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 4.5)
    avant = A.poids + B.poids
    SimulationsProjet.modif_poids(A, B, 2, 0, PoidsElo())
    @test A.poids + B.poids ≈ avant #ce que gagne une équipe, l'autre le perd
    @test A.poids > 5.0
    @test B.poids < 4.5

    #nul entre équipes de même force : rien ne bouge
    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 5.0)
    SimulationsProjet.modif_poids(A, B, 1, 1, PoidsElo())
    @test A.poids ≈ 5.0
    @test B.poids ≈ 5.0

    #un outsider qui gagne gagne plus qu'un favori qui gagne, et un match déplace le poids de K/400 au plus
    favori = Equipe(club = "F", pays = "France", poids = 5.0)
    outsider = Equipe(club = "O", pays = "Espagne", poids = 4.0)
    SimulationsProjet.modif_poids(favori, outsider, 1, 0, PoidsElo())
    gain_favori = favori.poids - 5.0
    favori = Equipe(club = "F", pays = "France", poids = 5.0)
    outsider = Equipe(club = "O", pays = "Espagne", poids = 4.0)
    SimulationsProjet.modif_poids(favori, outsider, 0, 1, PoidsElo())
    gain_outsider = outsider.poids - 4.0
    @test 0 < gain_favori < gain_outsider <= 0.1

    #K règle la variation : K = 0 ne change rien, K plus grand change plus
    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 5.0)
    SimulationsProjet.modif_poids(A, B, 3, 0, PoidsElo(K = 0.0))
    @test A.poids == 5.0
    @test B.poids == 5.0

    A = Equipe(club = "A", pays = "France", poids = 5.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 5.0)
    SimulationsProjet.modif_poids(A, B, 3, 0, PoidsElo(K = 80.0))
    @test A.poids - 5.0 ≈ 0.1 #K = 40 donnerait 0.05
end

@testset "modif_poids coefficient UEFA" begin
    gain_fr = SimulationsProjet.GAIN_POIDS["France"]
    gain_es = SimulationsProjet.GAIN_POIDS["Espagne"]

    #victoire : 2 gains, défaite : 0
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 2, 1, PoidsUEFA())
    @test A.poids ≈ 2 * gain_fr
    @test B.poids ≈ 0.0

    #nul : 1 gain chacun
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 1, 1, PoidsUEFA())
    @test A.poids ≈ gain_fr
    @test B.poids ≈ gain_es

    #gain_match règle le gain d'une victoire
    A = Equipe(club = "A", pays = "France")
    B = Equipe(club = "B", pays = "Espagne")
    SimulationsProjet.modif_poids(A, B, 2, 1, PoidsUEFA(gain_match = 4.0))
    @test A.poids ≈ 4 * gain_fr
end

@testset "modif_poids type inconnu" begin
    A = Equipe(club = "A", pays = "France", poids = 1.0)
    B = Equipe(club = "B", pays = "Espagne", poids = 2.0)

    #un type inconnu n'est plus ignoré en silence
    @test_throws MethodError SimulationsProjet.modif_poids(A, B, 3, 0, "Aucun")
    @test A.poids == 1.0
    @test B.poids == 2.0
end

@testset "bonus_classement" begin
    gain_fr = SimulationsProjet.GAIN_POIDS["France"]

    #le 1er reçoit 24 fois le bonus, le 24e une fois
    premier = Equipe(club = "A", pays = "France")
    dernier = Equipe(club = "B", pays = "France")
    SimulationsProjet.bonus_classement(premier, 1, PoidsUEFA())
    SimulationsProjet.bonus_classement(dernier, 24, PoidsUEFA())
    @test premier.poids ≈ gain_fr * 0.25 * 24
    @test dernier.poids ≈ gain_fr * 0.25
    @test premier.poids ≈ 24 * dernier.poids

    #le bonus se règle dans le poids
    equipe = Equipe(club = "A", pays = "France")
    SimulationsProjet.bonus_classement(equipe, 24, PoidsUEFA(bonus_classement = 1.0))
    @test equipe.poids ≈ gain_fr

    #Elo : aucun bonus
    equipe = Equipe(club = "A", pays = "France", poids = 1.0)
    SimulationsProjet.bonus_classement(equipe, 1, PoidsElo())
    @test equipe.poids == 1.0
end

@testset "bonus_tour" begin
    gain_fr = SimulationsProjet.GAIN_POIDS["France"]

    equipe = Equipe(club = "A", pays = "France")
    SimulationsProjet.bonus_tour(equipe, PoidsUEFA())
    @test equipe.poids ≈ 1.5 * gain_fr

    equipe = Equipe(club = "A", pays = "France")
    SimulationsProjet.bonus_tour(equipe, PoidsUEFA(bonus_tour = 3.0))
    @test equipe.poids ≈ 3.0 * gain_fr

    #Elo : aucun bonus
    equipe = Equipe(club = "A", pays = "France", poids = 1.0)
    SimulationsProjet.bonus_tour(equipe, PoidsElo())
    @test equipe.poids == 1.0
end

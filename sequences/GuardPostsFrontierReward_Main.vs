// ============================================================================
// IMPERIVM III HD - RECOMPENSA FRONTERA GALO-GERMANA
// Sequence: GuardPostsFrontierReward_Main
// Autorun allowed
//
// REQUISITO:
// Crear un Group llamado:
//     GalGermanFrontier_GuardPosts
// y meter dentro SOLO los 4 GGuardPost de esa frontera.
//
// REGLA:
// - Si los 4 pertenecen al mismo jugador 1..8:
//   recibe UNA vez por partida 2 ejercitos de 50.
// - Tropas normales: comen, IA puede usarlas, no quedan bloqueadas.
// - Ambos ejercitos usan la misma plantilla por civilizacion.
// ============================================================================

ObjList posts;

Building p0;
Building p1;
Building p2;
Building p3;

Unit u;

int baseAX;
int baseAY;
int baseBX;
int baseBY;
int spawnX;
int spawnY;

int owner;
int i;
int army;
int rewarded;

int CONTROL_INTERVAL;
int TROOP_LEVEL;

CONTROL_INTERVAL = 1000;
TROOP_LEVEL = 12;


// ============================================================================
// OBTENER LOS 4 GUARD POST
// ============================================================================

posts =
    Group(
        "GalGermanFrontier_GuardPosts"
    )
    .GetObjList();

if (posts.count != 4)
{
    while (1)
    {
        Sleep(100000);
    }
}

p0 = posts[0].AsBuilding();
p1 = posts[1].AsBuilding();
p2 = posts[2].AsBuilding();
p3 = posts[3].AsBuilding();


// ============================================================================
// BUCLE PRINCIPAL
// ============================================================================

while (1)
{
    Sleep(CONTROL_INTERVAL);

    owner = p0.player;

    if (
        owner < 1
        ||
        owner > 8
    )
    {
        continue;
    }

    if (
        p1.player != owner
        ||
        p2.player != owner
        ||
        p3.player != owner
    )
    {
        continue;
    }


    // ========================================================================
    // COMPROBAR RECOMPENSA UNA VEZ POR JUGADOR
    // ========================================================================

    rewarded = 0;

    if (owner == 1)
    {
        rewarded = EnvReadInt(p0, "GFR_P1");
    }
    else
    {
        if (owner == 2)
        {
            rewarded = EnvReadInt(p0, "GFR_P2");
        }
        else
        {
            if (owner == 3)
            {
                rewarded = EnvReadInt(p0, "GFR_P3");
            }
            else
            {
                if (owner == 4)
                {
                    rewarded = EnvReadInt(p0, "GFR_P4");
                }
                else
                {
                    if (owner == 5)
                    {
                        rewarded = EnvReadInt(p0, "GFR_P5");
                    }
                    else
                    {
                        if (owner == 6)
                        {
                            rewarded = EnvReadInt(p0, "GFR_P6");
                        }
                        else
                        {
                            if (owner == 7)
                            {
                                rewarded = EnvReadInt(p0, "GFR_P7");
                            }
                            else
                            {
                                if (owner == 8)
                                {
                                    rewarded = EnvReadInt(p0, "GFR_P8");
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (rewarded == 1)
    {
        continue;
    }


    // ========================================================================
    // DOS PUNTOS DE APARICION
    // ========================================================================

    // EJERCITO A: punto medio entre Guard Post 1 (4142,1105)
    // y Guard Post 2 (2753,2359)
    baseAX = 3448;
    baseAY = 1732;

    // EJERCITO B: punto medio entre Guard Post 2 (2753,2359)
    // y Guard Post 3 (2155,3437)
    baseBX = 2454;
    baseBY = 2898;


    // ========================================================================
    // GENERAR DOS EJERCITOS
    // ========================================================================

    for (army = 0; army < 2; army += 1)
    {
        if (army == 0)
        {
            spawnX = baseAX;
            spawnY = baseAY;
        }
        else
        {
            spawnX = baseBX;
            spawnY = baseBY;
        }


        // ====================================================================
        // PLAYER 1 - ROMA IMPERIAL
        // 18 Hastatus
        // 10 Archer
        //  8 Velit
        //  6 Praetorian
        //  7 Scout
        //  1 Hero
        // ====================================================================

        if (owner == 1)
        {
            for (i = 0; i < 18; i += 1)
            {
                u = Place(
                    "RHastatus",
                    Point(spawnX + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 10; i += 1)
            {
                u = Place(
                    "RArcher",
                    Point(spawnX + (i % 5) * 90, spawnY + 320 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 8; i += 1)
            {
                u = Place(
                    "RVelit",
                    Point(spawnX + 540 + (i % 4) * 90, spawnY + (i / 4) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 6; i += 1)
            {
                u = Place(
                    "RPraetorian",
                    Point(spawnX + 540 + (i % 3) * 90, spawnY + 220 + (i / 3) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "RScout",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("MHero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 2 - CARTAGO
        // 18 Libyan Footman
        // 11 Javelin Thrower
        //  8 Berber Assassin
        //  5 Noble
        //  7 Numidian Rider
        //  1 Hero
        // ====================================================================

        if (owner == 2)
        {
            for (i = 0; i < 18; i += 1)
            {
                u = Place(
                    "CLibyanFootman",
                    Point(spawnX + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 11; i += 1)
            {
                u = Place(
                    "CJavelinThrower",
                    Point(spawnX + (i % 6) * 90, spawnY + 320 + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 8; i += 1)
            {
                u = Place(
                    "CBerberAssassin",
                    Point(spawnX + 560 + (i % 4) * 90, spawnY + (i / 4) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 5; i += 1)
            {
                u = Place(
                    "CNoble",
                    Point(spawnX + 560 + (i % 3) * 90, spawnY + 220 + (i / 3) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "CNumidianRider",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("CHero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 3 - IBERIA
        // 17 Defender
        // 11 Slinger
        //  8 Militiaman
        //  6 Elite Guard
        //  7 Cavalry
        //  1 Hero
        // ====================================================================

        if (owner == 3)
        {
            for (i = 0; i < 17; i += 1)
            {
                u = Place(
                    "IDefender",
                    Point(spawnX + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 11; i += 1)
            {
                u = Place(
                    "ISlinger",
                    Point(spawnX + (i % 6) * 90, spawnY + 320 + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 8; i += 1)
            {
                u = Place(
                    "IMilitiaman",
                    Point(spawnX + 560 + (i % 4) * 90, spawnY + (i / 4) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 6; i += 1)
            {
                u = Place(
                    "IEliteGuard",
                    Point(spawnX + 560 + (i % 3) * 90, spawnY + 220 + (i / 3) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "ICavalry",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("IHero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 4 - GALIA
        // 20 Woman Warrior
        // 11 Archer
        // 11 Axeman
        //  7 Horseman
        //  1 Hero
        // ====================================================================

        if (owner == 4)
        {
            for (i = 0; i < 20; i += 1)
            {
                u = Place(
                    "GWomanWarrior",
                    Point(spawnX + (i % 7) * 90, spawnY + (i / 7) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 11; i += 1)
            {
                u = Place(
                    "GArcher",
                    Point(spawnX + (i % 6) * 90, spawnY + 320 + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 11; i += 1)
            {
                u = Place(
                    "GAxeman",
                    Point(spawnX + 600 + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "GHorseman",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("GHero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 5 - BRITANIA
        // Sin caballeria:
        // 15 Bronze Spearman
        //  5 Highlander
        // 15 Bowman
        // 14 Javelineer
        //  1 Hero
        // ====================================================================

        if (owner == 5)
        {
            for (i = 0; i < 15; i += 1)
            {
                u = Place(
                    "BBronzeSpearman",
                    Point(spawnX + (i % 5) * 90, spawnY + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 5; i += 1)
            {
                u = Place(
                    "BHighlander",
                    Point(spawnX + 500 + i * 90, spawnY + 0),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 15; i += 1)
            {
                u = Place(
                    "BBowman",
                    Point(spawnX + (i % 5) * 90, spawnY + 360 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 14; i += 1)
            {
                u = Place(
                    "BJavelineer",
                    Point(spawnX + 500 + (i % 5) * 90, spawnY + 220 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("BHero1", Point(spawnX + 900, spawnY + 540), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 6 - GERMANIA
        // 20 Maceman
        // 10 Archer
        // 12 Huntress
        //  7 Teuton Rider
        //  1 Hero
        // ====================================================================

        if (owner == 6)
        {
            for (i = 0; i < 20; i += 1)
            {
                u = Place(
                    "TMaceman",
                    Point(spawnX + (i % 7) * 90, spawnY + (i / 7) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 10; i += 1)
            {
                u = Place(
                    "TArcher",
                    Point(spawnX + (i % 5) * 90, spawnY + 320 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 12; i += 1)
            {
                u = Place(
                    "THuntress",
                    Point(spawnX + 600 + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "TTeutonRider",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("THero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 7 - ROMA REPUBLICANA
        // 18 Hastatus
        // 10 Archer
        //  8 Gladiator
        //  6 Tribune
        //  7 Scout
        //  1 Hero
        // ====================================================================

        if (owner == 7)
        {
            for (i = 0; i < 18; i += 1)
            {
                u = Place(
                    "RHastatus",
                    Point(spawnX + (i % 6) * 90, spawnY + (i / 6) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 10; i += 1)
            {
                u = Place(
                    "RArcher",
                    Point(spawnX + (i % 5) * 90, spawnY + 320 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 8; i += 1)
            {
                u = Place(
                    "RGladiator",
                    Point(spawnX + 560 + (i % 4) * 90, spawnY + (i / 4) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 6; i += 1)
            {
                u = Place(
                    "RTribune",
                    Point(spawnX + 560 + (i % 3) * 90, spawnY + 220 + (i / 3) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 7; i += 1)
            {
                u = Place(
                    "RScout",
                    Point(spawnX + (i % 4) * 110, spawnY + 560 + (i / 4) * 110),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("RHero1", Point(spawnX + 760, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }


        // ====================================================================
        // PLAYER 8 - EGIPTO
        // EChariot = equivalente funcional de caballeria
        //
        // 19 Guardian
        // 10 Archer
        //  9 Axe Thrower
        //  5 Anubis Warrior
        //  6 Chariot
        //  1 Hero
        // ====================================================================

        if (owner == 8)
        {
            for (i = 0; i < 19; i += 1)
            {
                u = Place(
                    "EGuardian",
                    Point(spawnX + (i % 7) * 90, spawnY + (i / 7) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 10; i += 1)
            {
                u = Place(
                    "EArcher",
                    Point(spawnX + (i % 5) * 90, spawnY + 320 + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 9; i += 1)
            {
                u = Place(
                    "EAxetrower",
                    Point(spawnX + 600 + (i % 5) * 90, spawnY + (i / 5) * 90),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 5; i += 1)
            {
                u = Place(
                    "EAnubisWarrior",
                    Point(spawnX + 600 + i * 90, spawnY + 220),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            for (i = 0; i < 6; i += 1)
            {
                u = Place(
                    "EChariot",
                    Point(spawnX + (i % 3) * 130, spawnY + 560 + (i / 3) * 130),
                    owner
                );
                u.SetLevel(TROOP_LEVEL);
            }

            u = Place("EHero1", Point(spawnX + 800, spawnY + 560), owner);
            u.SetLevel(TROOP_LEVEL);
        }
    }


    // ========================================================================
    // MARCAR RECOMPENSA ENTREGADA
    // ========================================================================

    if (owner == 1)
    {
        EnvWriteInt(p0, "GFR_P1", 1);
    }
    else
    {
        if (owner == 2)
        {
            EnvWriteInt(p0, "GFR_P2", 1);
        }
        else
        {
            if (owner == 3)
            {
                EnvWriteInt(p0, "GFR_P3", 1);
            }
            else
            {
                if (owner == 4)
                {
                    EnvWriteInt(p0, "GFR_P4", 1);
                }
                else
                {
                    if (owner == 5)
                    {
                        EnvWriteInt(p0, "GFR_P5", 1);
                    }
                    else
                    {
                        if (owner == 6)
                        {
                            EnvWriteInt(p0, "GFR_P6", 1);
                        }
                        else
                        {
                            if (owner == 7)
                            {
                                EnvWriteInt(p0, "GFR_P7", 1);
                            }
                            else
                            {
                                if (owner == 8)
                                {
                                    EnvWriteInt(p0, "GFR_P8", 1);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

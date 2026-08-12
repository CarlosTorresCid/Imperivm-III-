// ============================================================================
// IMPERIVM III HD - SISTEMA UNIVERSAL DE GUARD POSTS
// Sequence: GuardPosts_Main
// Marcar: Autorun allowed
//
// DISEÑO
// ------
// El GGuardPost conserva intactos sus 12 sentinelas/arqueros nativos.
// Esta Sequence añade una escolta terrestre de 10 unidades:
//
//   Roma Imperial     -> 5 RHastatus        + 5 RPraetorian
//   Cartago           -> 5 CNoble           + 5 CBerberAssassin
//   Iberia            -> 5 IDefender        + 5 IEliteGuard
//   Galia             -> 5 GWomanWarrior    + 5 GAxeman
//   Britania          -> 5 BBronzeSpearman  + 5 BHighlander
//   Germania          -> 5 TMaceman         + 5 THuntress
//   Roma Republicana  -> 5 RHastatus        + 5 RTribune
//   Egipto            -> 5 EGuardian        + 5 EAnubisWarrior
//
// MAPEO DE JUGADORES DEL MAPA ACTUAL
// ----------------------------------
// Player 1 = Roma Imperial
// Player 2 = Cartago
// Player 3 = Iberia
// Player 4 = Galia
// Player 5 = Britania
// Player 6 = Germania
// Player 7 = Roma Republicana
// Player 8 = Egipto
//
// REGLAS
// ------
// - Los GGuardPost neutrales se dejan intactos hasta su primera conquista.
// - Tras ser conquistado por un jugador 1..8, aparecen 5 + 5 guardianes.
// - Guardianes: nivel 12, no comen y la IA estrategica no se los lleva.
// - No pueden utilizarse como ejercito: el script reimpone ordenes cada 500 ms.
// - Si hay enemigos en el radio del Guard Post, salen a combatir.
// - Si no hay enemigos, regresan a posiciones alrededor del Guard Post.
// - No se regenera durante el combate.
// - En paz, regenera 1 unidad cada 30 segundos hasta recuperar 5 + 5.
// - Mientras sobreviva al menos 1 guardian: AllowCapture(false).
// - Cuando mueren los 10: AllowCapture(true) y queda a la espera de conquista.
// - Una guarnicion totalmente destruida NO vuelve a regenerarse antes de que
//   el puesto cambie de propietario.
// - Al cambiar de propietario, el comportamiento nativo del GGuardPost se ocupa
//   de sus sentinelas; esta Sequence crea los 10 guardianes de la nueva cultura.
// - El ciclo se repite indefinidamente.
//
// IMPORTANTE
// ----------
// GGuardPost tiene max_units=0, asi que estas tropas NO se meten en el Settlement.
// Son defensores EXTERNOS ligados al puesto mediante un grupo dinamico.
// ============================================================================


// ============================================================================
// VARIABLES
// ============================================================================

ObjList posts;
ObjList garrison;
ObjList pool1;
ObjList pool2;
ObjList enemies;

Building post;

Unit u;
Unit defender;

Query qRange;
Query qEnemies;

str cls1;
str cls2;
str groupName;

int p;
int i;
int j;

int owner;
int lastOwner;

int max1;
int max2;
int count1;
int count2;

int initialized;
int awaitingCapture;

int regenClock;
int regenTurn;
int spawnType;

int GUARDIAN_LEVEL;
int REGEN_INTERVAL;
int CONTROL_INTERVAL;


// ============================================================================
// CONFIGURACION
// ============================================================================

GUARDIAN_LEVEL = 12;
REGEN_INTERVAL = 30000;
CONTROL_INTERVAL = 500;


// ============================================================================
// DESCUBRIR TODOS LOS GGUARDPOST DEL MAPA
//
// Se buscan en todos los posibles jugadores para conservar una lista fija aunque
// cambien de propietario durante la partida.
// ============================================================================

posts.Clear();

for (p = 1; p <= 16; p += 1)
{
    posts.AddList(
        ClassPlayerObjs(
            "GGuardPost",
            p
        )
        .GetObjList()
    );
}


// ============================================================================
// PREPARACION INICIAL
// ============================================================================

for (i = 0; i < posts.count; i += 1)
{
    post =
        posts[i]
        .AsBuilding();

    owner =
        post.player;

    groupName =
        "__GP_"
        +
        post.pos.x
        +
        "_"
        +
        post.pos.y;


    // Guardar propietario inicial.
    EnvWriteInt(
        post,
        "GP_LastOwner",
        owner
    );


    EnvWriteInt(
        post,
        "GP_Regen",
        0
    );


    EnvWriteInt(
        post,
        "GP_Turn",
        1
    );


    EnvWriteInt(
        post,
        "GP_AwaitingCapture",
        0
    );


    // ------------------------------------------------------------------------
    // SI EMPIEZA NEUTRAL:
    // no añadimos guardianes y dejamos la captura normal habilitada.
    // ------------------------------------------------------------------------

    if (
        owner < 1
        ||
        owner > 8
    )
    {
        post
            .settlement
            .AllowCapture(true);

        EnvWriteInt(
            post,
            "GP_Init",
            0
        );

        continue;
    }


    // ------------------------------------------------------------------------
    // SI EL GUARD POST YA EMPIEZA EN MANOS DE UN JUGADOR:
    // seleccionar su composicion.
    // ------------------------------------------------------------------------

    cls1 = "";
    cls2 = "";

    if (owner == 1)
    {
        // Roma Imperial
        cls1 = "RHastatus";
        cls2 = "RPraetorian";
    }
    else
    {
        if (owner == 2)
        {
            // Cartago
            cls1 = "CNoble";
            cls2 = "CBerberAssassin";
        }
        else
        {
            if (owner == 3)
            {
                // Iberia
                cls1 = "IDefender";
                cls2 = "IEliteGuard";
            }
            else
            {
                if (owner == 4)
                {
                    // Galia
                    cls1 = "GWomanWarrior";
                    cls2 = "GAxeman";
                }
                else
                {
                    if (owner == 5)
                    {
                        // Britania
                        cls1 = "BBronzeSpearman";
                        cls2 = "BHighlander";
                    }
                    else
                    {
                        if (owner == 6)
                        {
                            // Germania
                            cls1 = "TMaceman";
                            cls2 = "THuntress";
                        }
                        else
                        {
                            if (owner == 7)
                            {
                                // Roma Republicana
                                cls1 = "RHastatus";
                                cls2 = "RTribune";
                            }
                            else
                            {
                                if (owner == 8)
                                {
                                    // Egipto
                                    cls1 = "EGuardian";
                                    cls2 = "EAnubisWarrior";
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    // ------------------------------------------------------------------------
    // CREAR 5 + 5
    //
    // Se colocan en dos lineas, una a cada lado del Guard Post.
    // No usamos ForceAddUnit porque GGuardPost tiene max_units=0.
    // ------------------------------------------------------------------------

    for (j = 0; j < 5; j += 1)
    {
        u = Place(
            cls1,
            post.pos + Point(-400 + j * 200, 450),
            owner
        );

        u.SetLevel(
            GUARDIAN_LEVEL
        );

        u.SetFood(20);
        u.SetFeeding(false);
        u.SetNoAIFlag(true);

        u.AddToGroup(
            groupName
        );
    }


    for (j = 0; j < 5; j += 1)
    {
        u = Place(
            cls2,
            post.pos + Point(-400 + j * 200, -450),
            owner
        );

        u.SetLevel(
            GUARDIAN_LEVEL
        );

        u.SetFood(20);
        u.SetFeeding(false);
        u.SetNoAIFlag(true);

        u.AddToGroup(
            groupName
        );
    }


    post
        .settlement
        .AllowCapture(false);


    EnvWriteInt(
        post,
        "GP_Init",
        1
    );
}


// ============================================================================
// BUCLE UNIVERSAL PERMANENTE
// ============================================================================

while (1)
{
    Sleep(
        CONTROL_INTERVAL
    );


    for (i = 0; i < posts.count; i += 1)
    {
        // ====================================================================
        // DATOS DEL PUESTO
        // ====================================================================

        post =
            posts[i]
            .AsBuilding();


        owner =
            post.player;


        groupName =
            "__GP_"
            +
            post.pos.x
            +
            "_"
            +
            post.pos.y;


        initialized =
            EnvReadInt(
                post,
                "GP_Init"
            );


        lastOwner =
            EnvReadInt(
                post,
                "GP_LastOwner"
            );


        awaitingCapture =
            EnvReadInt(
                post,
                "GP_AwaitingCapture"
            );


        // ====================================================================
        // GUARD POST TODAVIA NEUTRAL
        //
        // Antes de la primera conquista no creamos escolta externa.
        // ====================================================================

        if (
            owner > 8
            &&
            initialized == 0
        )
        {
            post
                .settlement
                .AllowCapture(true);


            EnvWriteInt(
                post,
                "GP_LastOwner",
                owner
            );


            continue;
        }


        // ====================================================================
        // CAMBIO DE PROPIETARIO / PRIMERA CONQUISTA
        //
        // Como AllowCapture solo se habilita cuando han muerto los 10 guardianes,
        // en una conquista normal el grupo anterior ya debe estar vacio.
        // ====================================================================

        if (
            owner >= 1
            &&
            owner <= 8
            &&
            (
                initialized == 0
                ||
                owner != lastOwner
            )
        )
        {
            // ----------------------------------------------------------------
            // Elegir tropas segun el jugador/civilizacion.
            // ----------------------------------------------------------------

            cls1 = "";
            cls2 = "";


            if (owner == 1)
            {
                // Roma Imperial
                cls1 = "RHastatus";
                cls2 = "RPraetorian";
            }
            else
            {
                if (owner == 2)
                {
                    // Cartago
                    cls1 = "CNoble";
                    cls2 = "CBerberAssassin";
                }
                else
                {
                    if (owner == 3)
                    {
                        // Iberia
                        cls1 = "IDefender";
                        cls2 = "IEliteGuard";
                    }
                    else
                    {
                        if (owner == 4)
                        {
                            // Galia
                            cls1 = "GWomanWarrior";
                            cls2 = "GAxeman";
                        }
                        else
                        {
                            if (owner == 5)
                            {
                                // Britania
                                cls1 = "BBronzeSpearman";
                                cls2 = "BHighlander";
                            }
                            else
                            {
                                if (owner == 6)
                                {
                                    // Germania
                                    cls1 = "TMaceman";
                                    cls2 = "THuntress";
                                }
                                else
                                {
                                    if (owner == 7)
                                    {
                                        // Roma Republicana
                                        cls1 = "RHastatus";
                                        cls2 = "RTribune";
                                    }
                                    else
                                    {
                                        if (owner == 8)
                                        {
                                            // Egipto
                                            cls1 = "EGuardian";
                                            cls2 = "EAnubisWarrior";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


            // ----------------------------------------------------------------
            // Seguridad: limpiar referencias muertas del grupo anterior.
            // ----------------------------------------------------------------

            garrison =
                Group(
                    groupName
                )
                .GetObjList();


            garrison.ClearDead();


            // ----------------------------------------------------------------
            // Crear Pool 1: 5 unidades.
            // ----------------------------------------------------------------

            for (j = 0; j < 5; j += 1)
            {
                u = Place(
                    cls1,
                    post.pos + Point(-400 + j * 200, 450),
                    owner
                );


                u.SetLevel(
                    GUARDIAN_LEVEL
                );


                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);


                u.AddToGroup(
                    groupName
                );
            }


            // ----------------------------------------------------------------
            // Crear Pool 2: 5 unidades.
            // ----------------------------------------------------------------

            for (j = 0; j < 5; j += 1)
            {
                u = Place(
                    cls2,
                    post.pos + Point(-400 + j * 200, -450),
                    owner
                );


                u.SetLevel(
                    GUARDIAN_LEVEL
                );


                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);


                u.AddToGroup(
                    groupName
                );
            }


            // ----------------------------------------------------------------
            // Reiniciar estado del nuevo propietario.
            // ----------------------------------------------------------------

            EnvWriteInt(
                post,
                "GP_LastOwner",
                owner
            );


            EnvWriteInt(
                post,
                "GP_Init",
                1
            );


            EnvWriteInt(
                post,
                "GP_AwaitingCapture",
                0
            );


            EnvWriteInt(
                post,
                "GP_Regen",
                0
            );


            EnvWriteInt(
                post,
                "GP_Turn",
                1
            );


            post
                .settlement
                .AllowCapture(false);


            continue;
        }


        // ====================================================================
        // SI POR ALGUNA RAZON EL PROPIETARIO NO ES 1..8, NO INTERVENIMOS
        // ====================================================================

        if (
            owner < 1
            ||
            owner > 8
        )
        {
            continue;
        }


        // ====================================================================
        // SELECCIONAR COMPOSICION DEL PROPIETARIO ACTUAL
        // ====================================================================

        cls1 = "";
        cls2 = "";

        max1 = 5;
        max2 = 5;


        if (owner == 1)
        {
            // Roma Imperial
            cls1 = "RHastatus";
            cls2 = "RPraetorian";
        }
        else
        {
            if (owner == 2)
            {
                // Cartago
                cls1 = "CNoble";
                cls2 = "CBerberAssassin";
            }
            else
            {
                if (owner == 3)
                {
                    // Iberia
                    cls1 = "IDefender";
                    cls2 = "IEliteGuard";
                }
                else
                {
                    if (owner == 4)
                    {
                        // Galia
                        cls1 = "GWomanWarrior";
                        cls2 = "GAxeman";
                    }
                    else
                    {
                        if (owner == 5)
                        {
                            // Britania
                            cls1 = "BBronzeSpearman";
                            cls2 = "BHighlander";
                        }
                        else
                        {
                            if (owner == 6)
                            {
                                // Germania
                                cls1 = "TMaceman";
                                cls2 = "THuntress";
                            }
                            else
                            {
                                if (owner == 7)
                                {
                                    // Roma Republicana
                                    cls1 = "RHastatus";
                                    cls2 = "RTribune";
                                }
                                else
                                {
                                    if (owner == 8)
                                    {
                                        // Egipto
                                        cls1 = "EGuardian";
                                        cls2 = "EAnubisWarrior";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        // ====================================================================
        // RECONSTRUIR GUARNICION
        // ====================================================================

        garrison =
            Group(
                groupName
            )
            .GetObjList();


        garrison.ClearDead();


        pool1.Clear();
        pool2.Clear();


        for (
            j = 0;
            j < garrison.count;
            j += 1
        )
        {
            if (
                garrison[j]
                .IsHeirOf(
                    cls1
                )
            )
            {
                pool1.Add(
                    garrison[j]
                );
            }
            else
            {
                if (
                    garrison[j]
                    .IsHeirOf(
                        cls2
                    )
                )
                {
                    pool2.Add(
                        garrison[j]
                    );
                }
            }
        }


        count1 =
            pool1.count;


        count2 =
            pool2.count;


        // ====================================================================
        // SI YA ESTAMOS ESPERANDO CAPTURA:
        //
        // - no regenerar
        // - mantener captura permitida
        // - esperar simplemente a que cambie post.player
        //
        // En la siguiente iteracion el bloque CAMBIO DE PROPIETARIO creara
        // automaticamente la nueva guarnicion 5 + 5.
        // ====================================================================

        if (
            awaitingCapture == 1
        )
        {
            post
                .settlement
                .AllowCapture(true);


            EnvWriteInt(
                post,
                "GP_Regen",
                0
            );


            continue;
        }


        // ====================================================================
        // DETECTAR ENEMIGOS EN EL RADIO DEL GUARD POST
        // ====================================================================

        qRange =
            ObjsInRange(
                post,
                "Unit",
                post.range
            );


        qEnemies =
            Intersect(
                qRange,
                Union(
                    EnemyObjs(
                        owner,
                        "Military"
                    ),
                    EnemyObjs(
                        owner,
                        "BaseMage"
                    )
                )
            );


        // No contar Sentries como fuerza atacante.
        qEnemies =
            Subtract(
                qEnemies,
                EnemyObjs(
                    owner,
                    "Sentry"
                )
            );


        // Catapultas enemigas tambien cuentan como ataque.
        qRange =
            ObjsInRange(
                post,
                "Building",
                post.range
            );


        qRange =
            Intersect(
                qRange,
                EnemyObjs(
                    owner,
                    "Catapult"
                )
            );


        qEnemies =
            Union(
                qEnemies,
                qRange
            );


        enemies =
            qEnemies
            .GetObjList();


        enemies.ClearDead();


        // ====================================================================
        // HAN MUERTO LOS 10 GUARDIANES
        //
        // El puesto queda desbloqueado para captura y NO vuelve a regenerar
        // hasta que otro jugador lo conquiste.
        // ====================================================================

        if (
            garrison.count == 0
        )
        {
            post
                .settlement
                .AllowCapture(true);


            EnvWriteInt(
                post,
                "GP_AwaitingCapture",
                1
            );


            EnvWriteInt(
                post,
                "GP_Regen",
                0
            );


            continue;
        }


        // ====================================================================
        // QUEDA AL MENOS UN GUARDIAN:
        // el Guard Post NO puede ser capturado.
        // ====================================================================

        post
            .settlement
            .AllowCapture(false);


        // ====================================================================
        // COMBATE
        //
        // Si hay enemigos:
        // - no regenerar
        // - todos los guardianes salen a combatir
        // - las ordenes se reimponen cada 500 ms
        // ====================================================================

        if (
            enemies.count > 0
        )
        {
            EnvWriteInt(
                post,
                "GP_Regen",
                0
            );


            for (
                j = 0;
                j < garrison.count;
                j += 1
            )
            {
                defender =
                    garrison[j]
                    .AsUnit();


                // Si se aleja demasiado, obligarlo a regresar al puesto.
                if (
                    post.DistTo(
                        defender
                    )
                    >
                    post.range
                )
                {
                    defender.SetCommand(
                        "move",
                        post.pos
                    );
                }
                else
                {
                    defender.SetCommand(
                        "advance",
                        enemies[0].pos
                    );
                }
            }


            continue;
        }


        // ====================================================================
        // PAZ
        //
        // El GGuardPost tiene max_units=0, por lo que NO usamos enter_tent.
        // Los dos pools regresan a posiciones exteriores distintas.
        // ====================================================================

        for (
            j = 0;
            j < pool1.count;
            j += 1
        )
        {
            defender =
                pool1[j]
                .AsUnit();


            defender.SetCommand(
                "move",
                post.pos + Point(0, 450)
            );
        }


        for (
            j = 0;
            j < pool2.count;
            j += 1
        )
        {
            defender =
                pool2[j]
                .AsUnit();


            defender.SetCommand(
                "move",
                post.pos + Point(0, -450)
            );
        }


        // ====================================================================
        // REGENERACION
        //
        // 1 unidad cada 30 segundos.
        // Se alternan los dos pools cuando faltan unidades en ambos.
        // ====================================================================

        if (
            count1 < max1
            ||
            count2 < max2
        )
        {
            regenClock =
                EnvReadInt(
                    post,
                    "GP_Regen"
                );


            regenClock +=
                CONTROL_INTERVAL;


            if (
                regenClock
                >=
                REGEN_INTERVAL
            )
            {
                spawnType = 0;


                // ------------------------------------------------------------
                // FALTAN UNIDADES DE LOS DOS POOLS
                // ------------------------------------------------------------

                if (
                    count1 < max1
                    &&
                    count2 < max2
                )
                {
                    regenTurn =
                        EnvReadInt(
                            post,
                            "GP_Turn"
                        );


                    if (
                        regenTurn != 2
                    )
                    {
                        spawnType = 1;


                        EnvWriteInt(
                            post,
                            "GP_Turn",
                            2
                        );
                    }
                    else
                    {
                        spawnType = 2;


                        EnvWriteInt(
                            post,
                            "GP_Turn",
                            1
                        );
                    }
                }


                // ------------------------------------------------------------
                // SOLO FALTA POOL 1
                // ------------------------------------------------------------

                else
                {
                    if (
                        count1 < max1
                    )
                    {
                        spawnType = 1;
                    }
                    else
                    {
                        // ----------------------------------------------------
                        // SOLO FALTA POOL 2
                        // ----------------------------------------------------

                        if (
                            count2 < max2
                        )
                        {
                            spawnType = 2;
                        }
                    }
                }


                // ============================================================
                // REGENERAR POOL 1
                // ============================================================

                if (
                    spawnType == 1
                )
                {
                    u = Place(
                        cls1,
                        post.pos + Point(0, 450),
                        owner
                    );


                    u.SetLevel(
                        GUARDIAN_LEVEL
                    );


                    u.SetFood(20);
                    u.SetFeeding(false);
                    u.SetNoAIFlag(true);


                    u.AddToGroup(
                        groupName
                    );
                }


                // ============================================================
                // REGENERAR POOL 2
                // ============================================================

                else
                {
                    if (
                        spawnType == 2
                    )
                    {
                        u = Place(
                            cls2,
                            post.pos + Point(0, -450),
                            owner
                        );


                        u.SetLevel(
                            GUARDIAN_LEVEL
                        );


                        u.SetFood(20);
                        u.SetFeeding(false);
                        u.SetNoAIFlag(true);


                        u.AddToGroup(
                            groupName
                        );
                    }
                }


                EnvWriteInt(
                    post,
                    "GP_Regen",
                    0
                );
            }
            else
            {
                EnvWriteInt(
                    post,
                    "GP_Regen",
                    regenClock
                );
            }
        }
        else
        {
            EnvWriteInt(
                post,
                "GP_Regen",
                0
            );
        }
    }
}

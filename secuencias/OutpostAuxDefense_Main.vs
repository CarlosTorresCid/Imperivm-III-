// ============================================================================
// IMPERIVM III HD - DEFENSA AUXILIAR DE OUTPOSTS
// Sequence: OutpostAuxDefense_Main
// Marcar: Autorun allowed
//
// PAZ:
// - No toca tropas normales almacenadas.
// - El jugador puede meterlas y sacarlas libremente.
//
// ATAQUE:
// - Detecta enemigos en fort.range.
// - Lee fort.settlement.Units().
// - Solo saca Military/BaseMage del propietario.
// - Excluye la guarnicion especial de Fortresses_Main.
// - Sale a defender automaticamente.
// - Mientras dura el ataque, las ordenes defensivas se reimponen.
// - Si una auxiliar sale de fort.range, vuelve hacia el Outpost.
// - No puede perseguir enemigos indefinidamente fuera de la posicion.
//
// FIN DEL ATAQUE:
// - Espera 5 segundos sin enemigos.
// - En cuanto desaparece la amenaza, corta la persecucion y repliega.
// - Tras 5 segundos de paz intenta meterlas de nuevo en el Outpost.
// - Solo se liberan del grupo temporal cuando vuelven a la zona defensiva.
//
// CAMBIO DE PROPIETARIO:
// - Las auxiliares antiguas NO cambian de bando.
// - Simplemente dejan de ser controladas.
//
// Grupos:
//   guarnicion oficial: __FRT_X_Y
//   auxiliares:         __FRT_AUX_X_Y
// ============================================================================

ObjList forts;
ObjList garrison;
ObjList auxiliary;
ObjList settlementUnits;
ObjList enemies;

Building fort;

Unit u;
Unit aux;

Query qRange;
Query qEnemies;

str garrisonGroup;
str auxGroup;

int p;
int i;
int j;

int owner;
int lastOwner;
int initialized;

int quietClock;

int CONTROL_INTERVAL;
int RETURN_DELAY;
int RELEASE_DISTANCE;


// ============================================================================
// CONFIGURACION
// ============================================================================

CONTROL_INTERVAL = 500;
RETURN_DELAY = 5000;
RELEASE_DISTANCE = 600;


// ============================================================================
// DESCUBRIR TODOS LOS OUTPOSTS CULTURALES
// ============================================================================

forts.Clear();

for (p = 1; p <= 16; p += 1)
{
    forts.AddList(ClassPlayerObjs("TOutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("GOutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("BOutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("IOutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("COutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("ROutpost", p).GetObjList());
    forts.AddList(ClassPlayerObjs("EOutpost", p).GetObjList());
}


// ============================================================================
// ESTADO INICIAL
// ============================================================================

for (i = 0; i < forts.count; i += 1)
{
    fort = forts[i].AsBuilding();

    EnvWriteInt(
        fort,
        "OA_LastOwner",
        fort.player
    );

    EnvWriteInt(
        fort,
        "OA_QuietClock",
        0
    );
}


// ============================================================================
// BUCLE PRINCIPAL
// ============================================================================

while (1)
{
    Sleep(CONTROL_INTERVAL);

    for (i = 0; i < forts.count; i += 1)
    {
        fort = forts[i].AsBuilding();
        owner = fort.player;

        initialized =
            EnvReadInt(
                fort,
                "FG_Init"
            );

        garrisonGroup =
            "__FRT_"
            +
            fort.pos.x
            +
            "_"
            +
            fort.pos.y;

        auxGroup =
            "__FRT_AUX_"
            +
            fort.pos.x
            +
            "_"
            +
            fort.pos.y;


        // ====================================================================
        // RECONSTRUIR GRUPOS
        // ====================================================================

        garrison =
            Group(
                garrisonGroup
            )
            .GetObjList();

        garrison.ClearDead();

        auxiliary =
            Group(
                auxGroup
            )
            .GetObjList();

        auxiliary.ClearDead();


        // ====================================================================
        // CAMBIO DE PROPIETARIO
        // ====================================================================

        lastOwner =
            EnvReadInt(
                fort,
                "OA_LastOwner"
            );

        if (lastOwner != owner)
        {
            for (j = 0; j < auxiliary.count; j += 1)
            {
                auxiliary[j].RemoveFromGroup(auxGroup);
            }

            EnvWriteInt(
                fort,
                "OA_LastOwner",
                owner
            );

            EnvWriteInt(
                fort,
                "OA_QuietClock",
                0
            );

            continue;
        }


        // ====================================================================
        // SOLO DESPUES DE LA INICIALIZACION DE Fortresses_Main
        // ====================================================================

        if (initialized != 1)
        {
            for (j = 0; j < auxiliary.count; j += 1)
            {
                auxiliary[j].RemoveFromGroup(auxGroup);
            }

            EnvWriteInt(
                fort,
                "OA_QuietClock",
                0
            );

            continue;
        }


        // ====================================================================
        // SOLO JUGADORES 1..8
        // ====================================================================

        if (
            owner < 1
            ||
            owner > 8
        )
        {
            for (j = 0; j < auxiliary.count; j += 1)
            {
                auxiliary[j].RemoveFromGroup(auxGroup);
            }

            EnvWriteInt(
                fort,
                "OA_QuietClock",
                0
            );

            continue;
        }


        // ====================================================================
        // DETECTAR ENEMIGOS
        // ====================================================================

        qRange =
            ObjsInRange(
                fort,
                "Unit",
                fort.range
            );

        qEnemies =
            Intersect(
                qRange,
                Union(
                    EnemyObjs(owner, "Military"),
                    EnemyObjs(owner, "BaseMage")
                )
            );

        qEnemies =
            Subtract(
                qEnemies,
                EnemyObjs(owner, "Sentry")
            );

        qRange =
            ObjsInRange(
                fort,
                "Building",
                fort.range
            );

        qRange =
            Intersect(
                qRange,
                EnemyObjs(owner, "Catapult")
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
        // HAY ENEMIGOS
        // ====================================================================

        if (enemies.count > 0)
        {
            EnvWriteInt(
                fort,
                "OA_QuietClock",
                0
            );


            // ----------------------------------------------------------------
            // CONTROL DEFENSIVO DE AUXILIARES YA DESPLEGADAS
            // ----------------------------------------------------------------

            auxiliary =
                Group(
                    auxGroup
                )
                .GetObjList();

            auxiliary.ClearDead();

            for (j = 0; j < auxiliary.count; j += 1)
            {
                aux =
                    auxiliary[j]
                    .AsUnit();

                if (aux.player != owner)
                {
                    aux.RemoveFromGroup(auxGroup);
                }
                else
                {
                    if (
                        fort.DistTo(aux)
                        >
                        fort.range
                    )
                    {
                        aux.SetCommand(
                            "move",
                            fort.pos
                        );
                    }
                    else
                    {
                        aux.SetCommand(
                            "advance",
                            enemies[0].pos
                        );
                    }
                }
            }


            // ----------------------------------------------------------------
            // LEER UNIDADES DENTRO DEL OUTPOST
            // ----------------------------------------------------------------

            settlementUnits =
                fort
                .settlement
                .Units();

            settlementUnits.ClearDead();

            auxiliary =
                Group(
                    auxGroup
                )
                .GetObjList();

            auxiliary.ClearDead();


            // ----------------------------------------------------------------
            // SACAR SELECTIVAMENTE TROPAS NORMALES
            // ----------------------------------------------------------------

            for (j = 0; j < settlementUnits.count; j += 1)
            {
                if (
                    settlementUnits[j].AsUnit().InHolder()
                    &&
                    settlementUnits[j].player == owner
                    &&
                    (
                        settlementUnits[j].IsHeirOf("Military")
                        ||
                        settlementUnits[j].IsHeirOf("BaseMage")
                    )
                    &&
                    !garrison.Contains(settlementUnits[j])
                    &&
                    !auxiliary.Contains(settlementUnits[j])
                )
                {
                    u =
                        settlementUnits[j]
                        .AsUnit();

                    u.AddToGroup(
                        auxGroup
                    );

                    // UNA sola orden para salir y defender.
                    u.SetCommand(
                        "advance",
                        enemies[0].pos
                    );
                }
            }

            continue;
        }


        // ====================================================================
        // NO HAY ENEMIGOS: ESPERAR 5 SEGUNDOS
        // ====================================================================

        quietClock =
            EnvReadInt(
                fort,
                "OA_QuietClock"
            );

        quietClock +=
            CONTROL_INTERVAL;

        EnvWriteInt(
            fort,
            "OA_QuietClock",
            quietClock
        );


        // ====================================================================
        // DURANTE LA ESPERA, CORTAR LA PERSECUCION Y REPLEGAR
        // ====================================================================

        auxiliary =
            Group(
                auxGroup
            )
            .GetObjList();

        auxiliary.ClearDead();

        for (j = 0; j < auxiliary.count; j += 1)
        {
            aux =
                auxiliary[j]
                .AsUnit();

            if (aux.player != owner)
            {
                aux.RemoveFromGroup(auxGroup);
            }
            else
            {
                aux.SetCommand(
                    "move",
                    fort.pos
                );
            }
        }


        if (quietClock < RETURN_DELAY)
        {
            continue;
        }


        // ====================================================================
        // FIN DEL ATAQUE CONFIRMADO
        //
        // Una sola orden de regreso y liberacion inmediata del grupo temporal.
        // Así el jugador puede cancelar incluso esa orden si quiere.
        // ====================================================================

        auxiliary =
            Group(
                auxGroup
            )
            .GetObjList();

        auxiliary.ClearDead();

        for (j = 0; j < auxiliary.count; j += 1)
        {
            aux =
                auxiliary[j]
                .AsUnit();

            if (aux.player != owner)
            {
                aux.RemoveFromGroup(
                    auxGroup
                );
            }
            else
            {
                if (
                    fort.DistTo(aux)
                    >
                    fort.range
                )
                {
                    aux.SetCommand(
                        "move",
                        fort.pos
                    );
                }
                else
                {
                    aux.SetCommand(
                        "enter_tent",
                        fort
                    );

                    aux.RemoveFromGroup(
                        auxGroup
                    );
                }
            }
        }

        EnvWriteInt(
            fort,
            "OA_QuietClock",
            0
        );
    }
}

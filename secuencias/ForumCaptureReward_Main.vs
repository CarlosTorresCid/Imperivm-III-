// ============================================================================
// IMPERIVM III HD - RECOMPENSA POR CAPTURA DE FORO NEUTRAL
// Sequence: ForumCaptureReward_Main
// Autorun allowed
//
// FUNCIONAMIENTO
// --------------
// - Al arrancar, descubre automaticamente todos los Townhall que sean
//   neutrales (Player 15 o Player 16).
// - Se usa la clase base "BaseTownhall", por lo que quedan incluidos:
//
//      BTownhall  - Britania
//      CTownhall  - Cartago
//      ETownhall  - Egipto
//      GTownhall  - Galia
//      ITownhall  - Iberia
//      MTownhall  - Roma Imperial
//      RTownhall  - Roma Republicana
//      TTownhall  - Germania
//
// - No incluye MutableVillage.
// - Cuando uno de esos Foros pasa por primera vez a un jugador 1..8:
//
//      -> se marca inmediatamente como recompensado
//      -> aparecen DOS ejercitos de 50 unidades alrededor del Foro
//      -> la composicion depende del jugador/civilizacion capturadora
//
// - Cada Foro da recompensa UNA SOLA VEZ durante toda la partida.
// - Si despues cambia de propietario, NO vuelve a crear ejercitos.
// - No hacen falta Groups manuales.
//
// TROPAS
// ------
// Son tropas normales:
// - NO SetNoAIFlag(true)
// - NO SetFeeding(false)
// - consumen comida normalmente
// - jugador e IA pueden utilizarlas libremente
//
// SPAWN
// -----
// Los dos ejercitos se colocan a izquierda y derecha del Foro.
// Como las formaciones del codigo crecen hacia +X, el origen izquierdo
// se desplaza tambien el ancho aproximado de la formacion para que esta
// no aparezca encima del Townhall.
// ============================================================================


ObjList forums;

Building forum;
Unit u;

int forumIndex;
int owner;
int rewarded;

int i;
int army;

int baseAX;
int baseAY;
int baseBX;
int baseBY;
int spawnX;
int spawnY;

int CONTROL_INTERVAL;
int TROOP_LEVEL;

int SPAWN_GAP;
int FORMATION_WIDTH;
int FORMATION_Y_OFFSET;


// ============================================================================
// CONFIGURACION
// ============================================================================

CONTROL_INTERVAL = 750;
TROOP_LEVEL = 12;

// Distancia libre aproximada entre el Townhall y cada formacion.
// BaseTownhall tiene un radio aproximado de 160-165 en data.pak.
SPAWN_GAP = 450;

// Ancho aproximado reservado para una formacion de 50.
// El codigo de las plantillas llega aproximadamente hasta +900 en X.
// Se dejan 1000 para margen.
FORMATION_WIDTH = 1000;

// Centra aproximadamente las formaciones respecto al eje Y del Foro.
FORMATION_Y_OFFSET = 350;


// ============================================================================
// DESCUBRIR TODOS LOS FOROS QUE SON NEUTRALES AL INICIO
//
// IMPORTANTE:
// Guardamos las referencias AHORA, mientras son Player 15 / Player 16.
// Cuando sean capturados seguiran siendo los mismos objetos aunque cambie
// su propiedad .player.
// ============================================================================

forums =
    ClassPlayerObjs(
        "BaseTownhall",
        15
    )
    .GetObjList();

forums.AddList(
    ClassPlayerObjs(
        "BaseTownhall",
        16
    )
    .GetObjList()
);


// ============================================================================
// BUCLE PRINCIPAL
// ============================================================================

while (1)
{
    Sleep(CONTROL_INTERVAL);

    forums.ClearDead();

    for (
        forumIndex = 0;
        forumIndex < forums.count;
        forumIndex += 1
    )
    {
        forum =
            forums[forumIndex]
            .AsBuilding();

        owner = forum.player;


        // ====================================================================
        // SOLO NOS INTERESA CUANDO EL FORO YA HA SIDO CAPTURADO POR
        // UN JUGADOR REAL DEL MAPA (1..8).
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
        // CADA FORO TIENE SU PROPIO ESTADO.
        //
        // No hace falta una clave diferente por Foro porque EnvReadInt/
        // EnvWriteInt guardan el dato sobre el objeto Building concreto.
        // ====================================================================

        rewarded =
            EnvReadInt(
                forum,
                "FCR_Rewarded"
            );

        if (rewarded == 1)
        {
            continue;
        }


        // ====================================================================
        // MARCAR ANTES DE CREAR LAS TROPAS.
        //
        // Asi el mismo Foro no puede disparar dos veces la recompensa.
        // ====================================================================

        EnvWriteInt(
            forum,
            "FCR_Rewarded",
            1
        );


        // ====================================================================
        // CALCULAR LOS DOS PUNTOS BASE ALREDEDOR DEL FORO
        //
        // EJERCITO A:
        //   a la derecha del Townhall.
        //
        // EJERCITO B:
        //   a la izquierda. Como la formacion crece hacia +X, desplazamos
        //   su origen FORMATION_WIDTH adicionalmente hacia la izquierda.
        //
        // Esquema aproximado:
        //
        // [ EJERCITO B ]   <--450-->   [ FORO ]   <--450-->   [ EJERCITO A ]
        // ====================================================================

        baseAX =
            forum.pos.x
            +
            SPAWN_GAP;

        baseAY =
            forum.pos.y
            -
            FORMATION_Y_OFFSET;

        baseBX =
            forum.pos.x
            -
            SPAWN_GAP
            -
            FORMATION_WIDTH;

        baseBY =
            forum.pos.y
            -
            FORMATION_Y_OFFSET;

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
                    u = Place("RHastatus", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 10; i += 1)
                {
                    u = Place("RArcher", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 8; i += 1)
                {
                    u = Place("RVelit", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 6; i += 1)
                {
                    u = Place("RPraetorian", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("RScout", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("MHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("CLibyanFootman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 11; i += 1)
                {
                    u = Place("CJavelinThrower", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 8; i += 1)
                {
                    u = Place("CBerberAssassin", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 5; i += 1)
                {
                    u = Place("CNoble", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("CNumidianRider", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("CHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("IDefender", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 11; i += 1)
                {
                    u = Place("ISlinger", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 8; i += 1)
                {
                    u = Place("IMilitiaman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 6; i += 1)
                {
                    u = Place("IEliteGuard", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("ICavalry", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("IHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("GWomanWarrior", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 11; i += 1)
                {
                    u = Place("GArcher", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 11; i += 1)
                {
                    u = Place("GAxeman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("GHorseman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("GHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("BBronzeSpearman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 5; i += 1)
                {
                    u = Place("BHighlander", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 15; i += 1)
                {
                    u = Place("BBowman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 14; i += 1)
                {
                    u = Place("BJavelineer", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("BHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("TMaceman", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 10; i += 1)
                {
                    u = Place("TArcher", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 12; i += 1)
                {
                    u = Place("THuntress", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("TTeutonRider", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("THero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("RHastatus", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 10; i += 1)
                {
                    u = Place("RArcher", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 8; i += 1)
                {
                    u = Place("RGladiator", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 6; i += 1)
                {
                    u = Place("RTribune", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 7; i += 1)
                {
                    u = Place("RScout", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("RHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
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
                    u = Place("EGuardian", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 10; i += 1)
                {
                    u = Place("EArcher", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 9; i += 1)
                {
                    u = Place("EAxetrower", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 5; i += 1)
                {
                    u = Place("EAnubisWarrior", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                for (i = 0; i < 6; i += 1)
                {
                    u = Place("EChariot", forum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    forum.settlement.ForceAddUnit(u);
                }

                u = Place("EHero1", forum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                forum.settlement.ForceAddUnit(u);
            }
        }
    }
}

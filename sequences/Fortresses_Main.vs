// ============================================================================
// IMPERIVM III HD - SISTEMA UNIVERSAL DE FORTALEZAS / OUTPOSTS
// Sequence: Fortresses_Main
// Marcar: Autorun allowed
//
// No necesita Holders ni Areas manuales.
// Detecta automaticamente todos los Outposts culturales del mapa.
//
// Guarniciones:
//   TOutpost -> 10 TValkyrie
//   GOutpost ->  4 GTridentWarrior
//   BOutpost -> 10 BHighlander
//   IOutpost -> 12 ISlinger + 10 IDefender
//   COutpost -> 24 CMacemen
//   ROutpost -> 20 RLiberatus
//   EOutpost -> 10 EHorusWarrior + 10 EAnubisWarrior
//
// Reglas:
// - En los fortines no egipcios se conserva la guarnicion neutral original.
// - Egipto recibe 10 Horus + 10 Anubis y su captura nativa por proximidad se bloquea.
// - En la PRIMERA conquista de un COutpost se eliminan los CVillager que
//   entrega automaticamente el juego. La mecanica normal del fortin
//   cartagines para convertir campesinos introducidos posteriormente se mantiene.
// - Tras la primera conquista, la Sequence toma el control permanente.
// - La cultura del fortin determina siempre el tipo de tropas.
// - Las tropas pertenecen al propietario actual.
// - SetFeeding(false): no dependen de comida.
// - SetNoAIFlag(true): la IA estrategica no se las lleva.
// - El script impone ordenes cada 500 ms, por lo que no sirven como ejercito.
// - Con enemigos en fort.range salen a defender.
// - Sin enemigos vuelven al fortin mediante enter_tent.
// - Las bajas regeneran 1 unidad cada 20 segundos, solo sin enemigos.
// - Si muere toda la guarnicion, el fortin NO cambia de propietario mientras
//   queden tropas militares del propietario actual dentro de fort.range.
// - La posicion queda DISPUTADA mientras haya defensores propios y atacantes.
// - Solo se conquista cuando: guarnicion == 0, atacantes > 0 y defensores propios == 0.
// - Si la posicion queda asegurada sin enemigos, la guarnicion vuelve a regenerarse.
// - El nuevo propietario recibe inmediatamente la guarnicion completa.
// - El ciclo de reconquista es infinito.
// ============================================================================

ObjList forts;
ObjList garrison;
ObjList pool1;
ObjList pool2;
ObjList enemies;
ObjList friends;
ObjList settlementUnits;

Building fort;
Unit u;
Unit defender;

Query qRange;
Query qEnemies;
Query qFriends;

str cls1;
str cls2;
str groupName;

int max1;
int max2;
int count1;
int count2;

int p;
int i;
int j;

int owner;
int newOwner;

int initialized;
int neutralInitialized;
int firstDelay;
int regenClock;
int regenTurn;

int isEgypt;
int isCarthage;
int spawnType;
int expectedOwner;
int queryOwner;
int carthageCleanup;

int REGEN_INTERVAL;
int DEFENDER_LEVEL;
int CONTROL_INTERVAL;


// ============================================================================
// CONFIGURACION GLOBAL
// ============================================================================

REGEN_INTERVAL = 20000;
DEFENDER_LEVEL = 20;
CONTROL_INTERVAL = 500;


// ============================================================================
// DESCUBRIR TODOS LOS OUTPOSTS DEL MAPA
//
// Se hace una sola vez al arrancar. La ObjList conserva las referencias aunque
// posteriormente los edificios cambien de propietario.
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
// PREINICIALIZACION EGIPCIA
//
// El fortin egipcio original no posee la guarnicion que queremos. Por eso la
// creamos inmediatamente al comenzar el mapa y bloqueamos la captura normal.
//
// El nombre del grupo se deriva de las coordenadas del propio edificio. Es
// unico y estable para cada fortin, sin crear nada manualmente en el editor.
// ============================================================================

for (i = 0; i < forts.count; i += 1)
{
    fort = forts[i].AsBuilding();

    if (fort.IsHeirOf("EOutpost"))
    {
        owner = fort.player;

        if (owner > 8)
        {
            fort.settlement.SetLoyalty(100);

            neutralInitialized = EnvReadInt(fort, "FG_NeutralInit");

            if (neutralInitialized == 0)
            {
                groupName = "__FRT_" + fort.pos.x + "_" + fort.pos.y;

                // 10 Guerreros de Horus
                for (j = 0; j < 10; j += 1)
                {
                    u = Place("EHorusWarrior", fort.pos, owner);
                    u.SetLevel(DEFENDER_LEVEL);
                    u.SetFood(20);
                    u.SetFeeding(false);
                    u.SetNoAIFlag(true);
                    fort.settlement.ForceAddUnit(u);
                    u.AddToGroup(groupName);
                }

                // 10 Guerreros de Anubis
                for (j = 0; j < 10; j += 1)
                {
                    u = Place("EAnubisWarrior", fort.pos, owner);
                    u.SetLevel(DEFENDER_LEVEL);
                    u.SetFood(20);
                    u.SetFeeding(false);
                    u.SetNoAIFlag(true);
                    fort.settlement.ForceAddUnit(u);
                    u.AddToGroup(groupName);
                }

                EnvWriteInt(fort, "FG_NeutralInit", 1);
                EnvWriteInt(fort, "FG_ExpectedOwner", owner);
                EnvWriteInt(fort, "FG_Regen", 0);
                EnvWriteInt(fort, "FG_Turn", 1);
            }
        }
    }
}


// ============================================================================
// BUCLE UNIVERSAL PERMANENTE
// ============================================================================

while (1)
{
    Sleep(CONTROL_INTERVAL);

    for (i = 0; i < forts.count; i += 1)
    {
        // --------------------------------------------------------------------
        // OBTENER FORTIN Y CONFIGURAR SU CULTURA
        // --------------------------------------------------------------------

        fort = forts[i].AsBuilding();
        owner = fort.player;

        cls1 = "";
        cls2 = "";
        max1 = 0;
        max2 = 0;
        isEgypt = 0;
        isCarthage = 0;

        if (fort.IsHeirOf("TOutpost"))
        {
            cls1 = "TValkyrie";
            max1 = 10;
        }
        else
        {
            if (fort.IsHeirOf("GOutpost"))
            {
                cls1 = "GTridentWarrior";
                max1 = 4;
            }
            else
            {
                if (fort.IsHeirOf("BOutpost"))
                {
                    cls1 = "BHighlander";
                    max1 = 10;
                }
                else
                {
                    if (fort.IsHeirOf("IOutpost"))
                    {
                        cls1 = "ISlinger";
                        cls2 = "IDefender";
                        max1 = 12;
                        max2 = 10;
                    }
                    else
                    {
                        if (fort.IsHeirOf("COutpost"))
                        {
                            cls1 = "CMacemen";
                            max1 = 24;
                            isCarthage = 1;
                        }
                        else
                        {
                            if (fort.IsHeirOf("ROutpost"))
                            {
                                cls1 = "RLiberatus";
                                max1 = 20;
                            }
                            else
                            {
                                if (fort.IsHeirOf("EOutpost"))
                                {
                                    cls1 = "EHorusWarrior";
                                    cls2 = "EAnubisWarrior";
                                    max1 = 10;
                                    max2 = 10;
                                    isEgypt = 1;
                                }
                                else
                                {
                                    continue;
                                }
                            }
                        }
                    }
                }
            }
        }

        groupName = "__FRT_" + fort.pos.x + "_" + fort.pos.y;

        initialized = EnvReadInt(fort, "FG_Init");


        // --------------------------------------------------------------------
        // FASE NEUTRAL NATIVA - TODOS MENOS EGIPTO
        //
        // Mientras el propietario sea neutral (>8) y nuestro sistema aun no
        // se haya inicializado, no tocamos absolutamente nada.
        // --------------------------------------------------------------------

        if (
            owner > 8
            && initialized == 0
            && isEgypt == 0
        )
        {
            continue;
        }


        // --------------------------------------------------------------------
        // PRIMERA CONQUISTA DE UN FORTIN NO EGIPCIO
        //
        // El cambio de propietario ya lo ha hecho el comportamiento original.
        // Esperamos 1 segundo sin bloquear toda la Sequence para darle tiempo
        // a terminar. Despues creamos la guarnicion completa del conquistador.
        // --------------------------------------------------------------------

        if (
            owner >= 1
            && owner <= 8
            && initialized == 0
            && isEgypt == 0
        )
        {
            fort.settlement.SetLoyalty(100);

            // ================================================================
            // COUTPOST - ELIMINAR EL BONUS NATIVO DE ALDEANOS
            //
            // El juego introduce CVillager en el fortin cartagines al ser
            // conquistado por primera vez. Solo eliminamos esos aldeanos
            // durante esta fase inicial.
            //
            // Los CMacemen no se tocan.
            // Tampoco se desactiva la mecanica normal del COutpost:
            // los campesinos introducidos voluntariamente mas adelante
            // podran seguir convirtiendose en guerreros con maza.
            // ================================================================

            if (isCarthage == 1)
            {
                settlementUnits =
                    fort
                    .settlement
                    .Units();

                settlementUnits.ClearDead();

                for (
                    j = 0;
                    j < settlementUnits.count;
                    j += 1
                )
                {
                    if (
                        settlementUnits[j]
                        .IsHeirOf("CVillager")
                    )
                    {
                        settlementUnits[j]
                        .SetHealth(0);
                    }
                }
            }

            firstDelay = EnvReadInt(fort, "FG_FirstDelay");
            firstDelay += CONTROL_INTERVAL;
            EnvWriteInt(fort, "FG_FirstDelay", firstDelay);

            if (firstDelay < 1000)
            {
                continue;
            }

            // Pool 1 completo
            for (j = 0; j < max1; j += 1)
            {
                u = Place(cls1, fort.pos, owner);
                u.SetLevel(DEFENDER_LEVEL);
                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);
                fort.settlement.ForceAddUnit(u);
                u.AddToGroup(groupName);
            }

            // Pool 2 completo, si existe
            for (j = 0; j < max2; j += 1)
            {
                u = Place(cls2, fort.pos, owner);
                u.SetLevel(DEFENDER_LEVEL);
                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);
                fort.settlement.ForceAddUnit(u);
                u.AddToGroup(groupName);
            }

            EnvWriteInt(fort, "FG_Init", 1);
            EnvWriteInt(fort, "FG_FirstDelay", 0);
            EnvWriteInt(fort, "FG_Regen", 0);
            EnvWriteInt(fort, "FG_Turn", 1);

            if (isCarthage == 1)
            {
                // Ventana corta para capturar cualquier CVillager que el
                // comportamiento nativo cree unas decimas despues.
                EnvWriteInt(
                    fort,
                    "FG_CarthageCleanup",
                    5000
                );
            }

            continue;
        }


        // --------------------------------------------------------------------
        // A PARTIR DE AQUI:
        // - fortin egipcio neutral personalizado, O
        // - cualquier fortin ya conquistado y controlado por este sistema.
        // --------------------------------------------------------------------


        // ====================================================================
        // COUTPOST - LIMPIEZA DE SEGURIDAD POST-CONQUISTA
        //
        // Solo permanece activa durante 5 segundos despues de la PRIMERA
        // conquista. Despues queda desactivada para siempre, por lo que no
        // interfiere con campesinos que el jugador introduzca voluntariamente.
        // ====================================================================

        if (isCarthage == 1)
        {
            carthageCleanup =
                EnvReadInt(
                    fort,
                    "FG_CarthageCleanup"
                );

            if (carthageCleanup > 0)
            {
                settlementUnits =
                    fort
                    .settlement
                    .Units();

                settlementUnits.ClearDead();

                for (
                    j = 0;
                    j < settlementUnits.count;
                    j += 1
                )
                {
                    if (
                        settlementUnits[j]
                        .IsHeirOf("CVillager")
                    )
                    {
                        settlementUnits[j]
                        .SetHealth(0);
                    }
                }

                carthageCleanup -=
                    CONTROL_INTERVAL;

                if (carthageCleanup < 0)
                {
                    carthageCleanup = 0;
                }

                EnvWriteInt(
                    fort,
                    "FG_CarthageCleanup",
                    carthageCleanup
                );
            }
        }


        fort.settlement.SetLoyalty(100);


        // --------------------------------------------------------------------
        // RECONSTRUIR LA GUARNICION DE ESTE FORTIN
        // --------------------------------------------------------------------

        garrison = Group(groupName).GetObjList();
        garrison.ClearDead();

        pool1.Clear();
        pool2.Clear();

        for (j = 0; j < garrison.count; j += 1)
        {
            if (garrison[j].IsHeirOf(cls1))
            {
                pool1.Add(garrison[j]);
            }
            else
            {
                if (
                    cls2 != ""
                    && garrison[j].IsHeirOf(cls2)
                )
                {
                    pool2.Add(garrison[j]);
                }
            }
        }

        count1 = pool1.count;
        count2 = pool2.count;


        // --------------------------------------------------------------------
        // EOUTPOST: BLOQUEAR SU CAPTURA NATIVA MIENTRAS HAYA DEFENSORES
        //
        // El EOutpost se captura por proximidad aunque tenga unidades dentro.
        // Guardamos el propietario legitimo en FG_ExpectedOwner. Si el motor
        // cambia el edificio antes de que muera la guarnicion, lo devolvemos
        // inmediatamente al propietario legitimo.
        // --------------------------------------------------------------------

        queryOwner = owner;

        if (isEgypt == 1)
        {
            expectedOwner = EnvReadInt(fort, "FG_ExpectedOwner");

            if (expectedOwner == 0)
            {
                expectedOwner = owner;
                EnvWriteInt(fort, "FG_ExpectedOwner", expectedOwner);
            }

            // Mientras quede al menos un Horus o Anubis, la captura nativa
            // del EOutpost no es valida. Restauramos edificio y defensores.
            if (garrison.count > 0)
            {
                if (fort.player != expectedOwner)
                {
                    fort.SetPlayer(expectedOwner);
                    fort.settlement.SetLoyalty(100);

                    for (j = 0; j < garrison.count; j += 1)
                    {
                        defender = garrison[j].AsUnit();
                        defender.SetPlayer(expectedOwner);
                        defender.SetNoAIFlag(true);
                    }
                }

                owner = expectedOwner;
            }

            // Incluso si el motor ya ha cambiado el EOutpost justo cuando
            // muere el ultimo defensor, los atacantes deben calcularse contra
            // el propietario legitimo anterior, no contra el propietario
            // provisional que haya puesto el motor.
            queryOwner = expectedOwner;
        }


        // --------------------------------------------------------------------
        // DETECTAR ENEMIGOS - MISMO PATRON DEL TTent ORIGINAL
        // --------------------------------------------------------------------

        qRange = ObjsInRange(fort, "Unit", fort.range);

        qEnemies = Intersect(
            qRange,
            Union(
                EnemyObjs(queryOwner, "Military"),
                EnemyObjs(queryOwner, "BaseMage")
            )
        );

        qEnemies = Subtract(
            qEnemies,
            EnemyObjs(queryOwner, "Sentry")
        );

        qRange = ObjsInRange(fort, "Building", fort.range);

        qRange = Intersect(
            qRange,
            EnemyObjs(queryOwner, "Catapult")
        );

        qEnemies = Union(qEnemies, qRange);

        enemies = qEnemies.GetObjList();
        enemies.ClearDead();


        // --------------------------------------------------------------------
        // DETECTAR DEFENSORES PROPIOS EN EL MISMO RADIO
        //
        // No basta con destruir la guarnicion especial del fortin.
        // Mientras el propietario actual conserve tropas militares reales
        // (o BaseMage) dentro de fort.range, la posicion sigue defendida.
        // --------------------------------------------------------------------

        qRange = ObjsInRange(fort, "Unit", fort.range);

        qFriends = Intersect(
            qRange,
            Union(
                ClassPlayerObjs("Military", queryOwner),
                ClassPlayerObjs("BaseMage", queryOwner)
            )
        );

        friends = qFriends.GetObjList();
        friends.ClearDead();


        // --------------------------------------------------------------------
        // EOUTPOST VACIO: BLOQUEAR TAMBIEN LA CAPTURA NATIVA SI LA POSICION
        // SIGUE DISPUTADA POR TROPAS DEL PROPIETARIO LEGITIMO.
        // --------------------------------------------------------------------

        if (
            isEgypt == 1
            && garrison.count == 0
            && fort.player != expectedOwner
            && (
                enemies.count == 0
                || friends.count > 0
            )
        )
        {
            fort.SetPlayer(expectedOwner);
            fort.settlement.SetLoyalty(100);
            owner = expectedOwner;
        }


        // --------------------------------------------------------------------
        // CAPTURA
        //
        // Solo se conquista si:
        //   - la guarnicion especial ha muerto;
        //   - hay atacantes dentro del radio;
        //   - NO quedan tropas militares del propietario dentro del radio.
        //
        // Si friends > 0 y enemies > 0, la posicion esta DISPUTADA.
        // --------------------------------------------------------------------

        if (
            garrison.count == 0
            && enemies.count > 0
            && friends.count == 0
        )
        {
            newOwner = enemies[rand(enemies.count)].player;

            if (
                newOwner < 1
                || newOwner > 8
            )
            {
                continue;
            }

            fort.SetPlayer(newOwner);
            fort.settlement.SetLoyalty(100);
            owner = newOwner;

            if (isEgypt == 1)
            {
                EnvWriteInt(fort, "FG_ExpectedOwner", newOwner);
            }

            // Limpiar estado temporal del ciclo anterior.
            EnvWriteInt(fort, "FG_Init", 1);
            EnvWriteInt(fort, "FG_FirstDelay", 0);
            EnvWriteInt(fort, "FG_Regen", 0);
            EnvWriteInt(fort, "FG_Turn", 1);

            // Guarnicion completa inmediata para el nuevo propietario.
            for (j = 0; j < max1; j += 1)
            {
                u = Place(cls1, fort.pos, owner);
                u.SetLevel(DEFENDER_LEVEL);
                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);
                fort.settlement.ForceAddUnit(u);
                u.AddToGroup(groupName);
            }

            for (j = 0; j < max2; j += 1)
            {
                u = Place(cls2, fort.pos, owner);
                u.SetLevel(DEFENDER_LEVEL);
                u.SetFood(20);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);
                fort.settlement.ForceAddUnit(u);
                u.AddToGroup(groupName);
            }

            continue;
        }


        // --------------------------------------------------------------------
        // HAY ENEMIGOS -> DEFENSA TOTAL / POSICION DISPUTADA
        //
        // Si la guarnicion ya ha muerto pero quedan tropas propias en el radio,
        // no hay captura y tampoco regeneracion mientras siga el combate.
        // --------------------------------------------------------------------

        if (enemies.count > 0)
        {
            // Nada regenera durante un ataque o una posicion disputada.
            EnvWriteInt(fort, "FG_Regen", 0);

            for (j = 0; j < garrison.count; j += 1)
            {
                defender = garrison[j].AsUnit();

                // Si una orden manual o cualquier otra causa la ha llevado
                // demasiado lejos, vuelve inmediatamente al fortin.
                if (fort.DistTo(defender) > fort.range)
                {
                    defender.SetCommand("move", fort.pos);
                }
                else
                {
                    // Reimpuesta cada CONTROL_INTERVAL: tambien anula las
                    // ordenes manuales del jugador sobre la guarnicion.
                    defender.SetCommand("advance", enemies[0].pos);
                }
            }

            continue;
        }


        // --------------------------------------------------------------------
        // NO HAY ENEMIGOS -> TODOS VUELVEN DENTRO
        // --------------------------------------------------------------------

        for (j = 0; j < garrison.count; j += 1)
        {
            defender = garrison[j].AsUnit();
            defender.SetCommand("enter_tent", fort);
        }


        // --------------------------------------------------------------------
        // EL FORTIN EGIPCIO NEUTRAL NO REGENERA
        //
        // Se comporta como las guarniciones neutrales originales: tiene una
        // cantidad inicial finita. La regeneracion empieza tras conquistarlo.
        // --------------------------------------------------------------------

        if (
            isEgypt == 1
            && owner > 8
            && initialized == 0
        )
        {
            EnvWriteInt(fort, "FG_Regen", 0);
            continue;
        }


        // --------------------------------------------------------------------
        // REGENERACION POST-CONQUISTA
        // Una sola unidad cada 20 segundos y solo sin enemigos.
        // --------------------------------------------------------------------

        if (
            count1 < max1
            || count2 < max2
        )
        {
            regenClock = EnvReadInt(fort, "FG_Regen");
            regenClock += CONTROL_INTERVAL;

            if (regenClock >= REGEN_INTERVAL)
            {
                spawnType = 0;

                // Un solo tipo de defensor.
                if (max2 == 0)
                {
                    if (count1 < max1)
                    {
                        spawnType = 1;
                    }
                }
                else
                {
                    // Faltan ambos tipos: alternar para mantener los dos pools.
                    if (
                        count1 < max1
                        && count2 < max2
                    )
                    {
                        regenTurn = EnvReadInt(fort, "FG_Turn");

                        if (regenTurn != 2)
                        {
                            spawnType = 1;
                            EnvWriteInt(fort, "FG_Turn", 2);
                        }
                        else
                        {
                            spawnType = 2;
                            EnvWriteInt(fort, "FG_Turn", 1);
                        }
                    }
                    else
                    {
                        if (count1 < max1)
                        {
                            spawnType = 1;
                        }
                        else
                        {
                            if (count2 < max2)
                            {
                                spawnType = 2;
                            }
                        }
                    }
                }

                if (spawnType == 1)
                {
                    u = Place(cls1, fort.pos, owner);
                    u.SetLevel(DEFENDER_LEVEL);
                    u.SetFood(20);
                    u.SetFeeding(false);
                    u.SetNoAIFlag(true);
                    fort.settlement.ForceAddUnit(u);
                    u.AddToGroup(groupName);
                }
                else
                {
                    if (spawnType == 2)
                    {
                        u = Place(cls2, fort.pos, owner);
                        u.SetLevel(DEFENDER_LEVEL);
                        u.SetFood(20);
                        u.SetFeeding(false);
                        u.SetNoAIFlag(true);
                        fort.settlement.ForceAddUnit(u);
                        u.AddToGroup(groupName);
                    }
                }

                EnvWriteInt(fort, "FG_Regen", 0);
            }
            else
            {
                EnvWriteInt(fort, "FG_Regen", regenClock);
            }
        }
        else
        {
            EnvWriteInt(fort, "FG_Regen", 0);
        }
    }
}
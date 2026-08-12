Query qRange;
Query qEnemies;
ObjList enemies;

qRange =
    ObjsInRange(
        fort,
        "Unit",
        fort.range
    );

qEnemies =
    Intersect(
        qRange,
        EnemyObjs(
            fort.player,
            "Military"
        )
    );

enemies =
    qEnemies
    .GetObjList();

enemies.ClearDead();

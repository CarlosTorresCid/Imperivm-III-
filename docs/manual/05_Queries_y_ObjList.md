# 5. Query y ObjList

## `Query`

Se utiliza para construir selecciones de objetos.

Ejemplo de enemigos:

```cpp
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
```

Excluir sentinelas:

```cpp
qEnemies =
    Subtract(
        qEnemies,
        EnemyObjs(owner, "Sentry")
    );
```

## `ObjList`

Conversión:

```cpp
ObjList enemies;

enemies =
    qEnemies
    .GetObjList();

enemies.ClearDead();
```

Operaciones usadas:

```cpp
list.count
list[i]
list.Clear()
list.ClearDead()
list.Add(obj)
list.AddList(otherList)
list.Contains(obj)
```

## `ClassPlayerObjs`

Ejemplo:

```cpp
ObjList forts;

forts =
    ClassPlayerObjs(
        "TOutpost",
        15
    )
    .GetObjList();
```

En los sistemas universales se consulta la misma clase para distintos jugadores para conservar referencias incluso después de cambios de propietario.

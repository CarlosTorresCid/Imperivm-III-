# 14. Patrones reutilizables

## Descubrir objetos por clase y jugador

```cpp
ObjList objects;

objects =
    ClassPlayerObjs(
        "TOutpost",
        15
    )
    .GetObjList();
```

## Iterar un `ObjList`

```cpp
for (i = 0; i < objects.count; i += 1)
{
    // objects[i]
}
```

## Convertir a `Building`

```cpp
Building fort;

fort =
    objects[i]
    .AsBuilding();
```

## Convertir a `Unit`

```cpp
Unit u;

u =
    objects[i]
    .AsUnit();
```

## Grupo dinámico por coordenadas

```cpp
groupName =
    "__FRT_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

## Crear una unidad

```cpp
u = Place(
    "IDefender",
    fort.pos,
    owner
);
```

## Guarnición sin hambre

```cpp
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

## Detectar enemigos en radio

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
        EnemyObjs(
            owner,
            "Military"
        )
    );
```

## Limpiar muertos

```cpp
units.ClearDead();
```

## Estado persistente

```cpp
EnvWriteInt(
    fort,
    "MyState",
    1
);

state =
    EnvReadInt(
        fort,
        "MyState"
    );
```

## Entrada en edificio

```cpp
u.SetCommand(
    "enter_tent",
    fort
);
```

## Defensa temporal de tropas almacenadas

```cpp
if (
    obj.AsUnit().InHolder()
    &&
    obj.IsHeirOf("Military")
)
{
    obj.AsUnit().SetCommand(
        "advance",
        enemy.pos
    );
}
```

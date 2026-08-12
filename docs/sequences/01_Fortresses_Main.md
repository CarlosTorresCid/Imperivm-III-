# `Fortresses_Main`

## Objetivo

Convertir los Outposts culturales en fortalezas persistentes y reutilizables sin crear una Sequence individual por edificio.

## Clases gestionadas

| Outpost | Guarnición |
|---|---|
| `TOutpost` | 10 `TValkyrie` |
| `GOutpost` | 4 `GTridentWarrior` |
| `BOutpost` | 10 `BHighlander` |
| `IOutpost` | 12 `ISlinger` + 10 `IDefender` |
| `COutpost` | 24 `CMacemen` |
| `ROutpost` | 20 `RLiberatus` |
| `EOutpost` | 10 `EHorusWarrior` + 10 `EAnubisWarrior` |

## Descubrimiento automático

La Sequence busca los Outposts de todos los jugadores mediante `ClassPlayerObjs()` y conserva las referencias en un `ObjList`.

No se necesitan Holders manuales para cada fortín.

## Identidad de cada fortaleza

Cada Outpost obtiene un nombre de grupo derivado de sus coordenadas:

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

Las unidades de guarnición se añaden a ese grupo.

## Propiedades de la guarnición

Al crear cada defensor:

```cpp
u.SetLevel(DEFENDER_LEVEL);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
fort.settlement.ForceAddUnit(u);
u.AddToGroup(groupName);
```

Esto permite que la guarnición:

- no dependa de comida;
- no sea absorbida por la IA estratégica;
- siga asociada a su fortaleza incluso si sale al exterior.

## Defensa

Los enemigos se detectan en `fort.range` mediante `ObjsInRange`, `EnemyObjs`, `Intersect`, `Union` y `Subtract`.

Cuando hay enemigos:

```cpp
defender.SetCommand(
    "advance",
    enemies[0].pos
);
```

Cuando no hay enemigos:

```cpp
defender.SetCommand(
    "enter_tent",
    fort
);
```

## Regeneración

La regeneración solo funciona en paz.

El sistema utiliza `EnvReadInt`/`EnvWriteInt` para conservar un reloj individual por fortaleza.

## Posición disputada

Una fortaleza ya no cambia de propietario únicamente porque su guarnición especial haya muerto.

La captura requiere:

```cpp
garrison.count == 0
&& enemies.count > 0
&& friends.count == 0
```

Por tanto, mientras existan tropas militares del propietario dentro del radio, la posición sigue disputada.

## `EOutpost`

El `EOutpost` conserva una mecánica nativa de captura por proximidad. La Sequence guarda un propietario legítimo y revierte los cambios prematuros mientras queden defensores o la posición siga disputada.

## `COutpost`

En la primera conquista el juego puede generar aldeanos cartagineses. La Sequence elimina únicamente ese bonus inicial mediante una ventana temporal de limpieza, sin desactivar el comportamiento normal del edificio para campesinos introducidos posteriormente.

## Archivo

`sequences/Fortresses_Main.vs`

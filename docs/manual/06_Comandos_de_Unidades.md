# 6. Comandos de unidades

Los comandos se envían con:

```cpp
unit.SetCommand("comando", argumento);
```

## `advance`

Movimiento ofensivo:

```cpp
defender.SetCommand(
    "advance",
    enemy.pos
);
```

Se utiliza para sacar defensores y dirigirlos hacia una amenaza.

## `move`

Movimiento normal:

```cpp
defender.SetCommand(
    "move",
    fort.pos
);
```

## `attack`

Aparece en scripts nativos, especialmente en sentinelas:

```cpp
sentry.SetCommand(
    "attack",
    target
);
```

## `enter_tent`

Entrada en un holder/Outpost:

```cpp
defender.SetCommand(
    "enter_tent",
    fort
);
```

Este comando es fundamental para devolver guarniciones o auxiliares al edificio.

## Reimposición de órdenes

En una guarnición obligatoria puede ser útil reimponer la orden periódicamente.

En tropas normales del jugador no debe hacerse, porque impediría que el jugador recupere el control.

Esta diferencia es la base de `Fortresses_Main` frente a `OutpostAuxDefense_Main`.

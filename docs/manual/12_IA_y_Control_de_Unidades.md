# 12. IA y control de unidades

## `SetNoAIFlag(true)`

Usado para unidades que deben pertenecer a una estructura y no convertirse en parte del ejército estratégico de la IA.

Ejemplo:

```cpp
u.SetNoAIFlag(true);
```

Se usa en:

- guarniciones de `Fortresses_Main`;
- guardianes externos de `GuardPosts_Main`.

No se usa en:

- tropas auxiliares normales del jugador;
- ejércitos de recompensa.

## `SetFeeding(false)`

Evita que una unidad dependa del sistema normal de alimentación.

Adecuado para guarniciones persistentes:

```cpp
u.SetFood(20);
u.SetFeeding(false);
```

No debe usarse si se desea que el ejército funcione con las reglas normales.

## Control estricto frente a control temporal

### Guarnición

Se pueden reimponer órdenes cada intervalo:

```cpp
defender.SetCommand(
    "advance",
    enemy.pos
);
```

### Auxiliar

Se da una orden inicial y después se permite al jugador intervenir.

`GetCommanded()` aparece como mecanismo útil para detectar intervención manual en unidades.

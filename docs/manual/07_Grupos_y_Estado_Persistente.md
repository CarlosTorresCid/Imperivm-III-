# 7. Groups y estado persistente

## Groups como identidad

Los Groups dinámicos permiten mantener asociaciones entre objetos.

Ejemplo de guarnición única por fortaleza:

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

Añadir:

```cpp
u.AddToGroup(groupName);
```

Recuperar:

```cpp
garrison =
    Group(groupName)
    .GetObjList();
```

Eliminar:

```cpp
u.RemoveFromGroup(groupName);
```

## Estado persistente con `EnvReadInt` / `EnvWriteInt`

Guardar:

```cpp
EnvWriteInt(
    fort,
    "FG_Regen",
    0
);
```

Leer:

```cpp
regenClock =
    EnvReadInt(
        fort,
        "FG_Regen"
    );
```

Esto permite mantener variables individuales por edificio sin arrays ni una Sequence por fortaleza.

Usos del proyecto:

- inicialización;
- reloj de regeneración;
- propietario esperado;
- alternancia entre pools;
- flags de recompensa;
- temporizadores de ausencia de enemigos.

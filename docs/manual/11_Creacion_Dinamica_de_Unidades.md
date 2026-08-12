# 11. Creación dinámica de unidades

## `Place`

Patrón básico:

```cpp
Unit u;

u = Place(
    "TValkyrie",
    fort.pos,
    owner
);
```

También puede utilizar coordenadas construidas:

```cpp
u = Place(
    "RHastatus",
    Point(spawnX, spawnY),
    owner
);
```

## Configuración posterior

```cpp
u.SetLevel(20);
u.SetFood(20);
```

Para guarniciones:

```cpp
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

Para ejércitos normales no se aplican esas dos llamadas.

## `ForceAddUnit`

Cuando el edificio admite unidades:

```cpp
fort.settlement.ForceAddUnit(u);
```

## Posiciones

En Sequences se ha usado `Point(x,y)` directamente como valor de coordenada.

Para cálculos complejos es más seguro mantener `x` e `y` en variables enteras y construir `Point(...)` en la llamada que lo necesite.

## Formaciones

Las recompensas militares utilizan offsets para evitar que todas las unidades aparezcan en el mismo punto.

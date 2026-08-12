# 8. Outposts y fortalezas

## Base `Outpost`

La investigación de `data.pak` muestra que `Outpost` es una clase de edificio capturable con Settlement.

Los Outposts culturales heredan de ella y añaden propiedades específicas.

## Variantes

```text
GOutpost
TOutpost
BOutpost
IOutpost
COutpost
ROutpost
EOutpost
```

Cada cultura puede definir:

- clases de defensor;
- máximos;
- niveles iniciales/finales;
- recursos;
- comportamientos adicionales.

## Guarnición universal

`Fortresses_Main` no depende de una Sequence por Outpost.

Descubre todas las estructuras y crea una identidad dinámica para cada una.

## Dos pools

Algunas guarniciones utilizan dos tipos:

```text
IOutpost
12 ISlinger
10 IDefender
```

```text
EOutpost
10 EHorusWarrior
10 EAnubisWarrior
```

Cada pool mantiene su propio máximo, y la regeneración puede alternar entre ambos.

## Neutralidad y primera conquista

Para los Outposts cuya lógica neutral nativa ya es útil, la Sequence evita intervenir hasta que el edificio cambia por primera vez a un jugador 1..8.

`EOutpost` requiere tratamiento especial por su comportamiento de captura.

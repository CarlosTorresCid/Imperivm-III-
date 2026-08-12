# `OutpostAuxDefense_Main`

## Objetivo

Permitir que las tropas normales introducidas por un jugador en un Outpost participen automáticamente en su defensa sin quedar convertidas en una guarnición permanente.

## Principio fundamental

La guarnición oficial y las tropas normales se separan mediante grupos.

Guarnición:

```text
__FRT_X_Y
```

Auxiliares temporales:

```text
__FRT_AUX_X_Y
```

## En paz

La Sequence no da órdenes a las tropas almacenadas.

El jugador puede:

- introducirlas;
- sacarlas;
- reorganizarlas.

## Comienzo de un ataque

La Sequence consulta:

```cpp
fort.settlement.Units()
```

y selecciona unidades que:

- están realmente dentro (`AsUnit().InHolder()`);
- pertenecen al propietario;
- son `Military` o `BaseMage`;
- no pertenecen a la guarnición especial;
- todavía no pertenecen al grupo auxiliar.

Después reciben una única orden:

```cpp
u.SetCommand(
    "advance",
    enemies[0].pos
);
```

## Libertad del jugador

La orden no se reimpone continuamente.

Si el jugador decide retirar una unidad, la Sequence puede detectarlo mediante `GetCommanded()` y/o por distancia y eliminarla del grupo auxiliar.

## Fin de combate

La Sequence espera varios segundos sin enemigos antes de considerar terminada la amenaza.

Las auxiliares que continúan participando reciben:

```cpp
aux.SetCommand(
    "enter_tent",
    fort
);
```

Después se eliminan del grupo temporal y vuelven a ser tropas normales.

## Cambio de propietario

Las tropas auxiliares del antiguo propietario:

- no cambian de dueño;
- no son transferidas;
- se eliminan del grupo temporal;
- dejan de ser controladas por la Sequence.

## Archivo

`sequences/OutpostAuxDefense_Main.vs`

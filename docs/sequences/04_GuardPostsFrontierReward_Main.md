# `GuardPostsFrontierReward_Main`

## Objetivo

Crear un premio estratégico por controlar simultáneamente cuatro `GGuardPost` de la frontera galo-germana.

## Group requerido

Debe existir en el editor:

```text
GalGermanFrontier_GuardPosts
```

con exactamente los cuatro Guard Post relevantes.

## Condición

Los cuatro edificios deben pertenecer al mismo jugador entre 1 y 8.

Cada jugador puede recibir la recompensa una sola vez durante la partida.

## Premio

Dos ejércitos de 50 unidades.

Los ejércitos son normales:

- consumen comida;
- la IA puede utilizarlos;
- no tienen `SetNoAIFlag(true)`;
- no están ligados a edificios.

## Composición por ejército

### Roma Imperial
18 `RHastatus`, 10 `RArcher`, 8 `RVelit`, 6 `RPraetorian`, 7 `RScout`, 1 `MHero1`.

### Roma Republicana
18 `RHastatus`, 10 `RArcher`, 8 `RGladiator`, 6 `RTribune`, 7 `RScout`, 1 `RHero1`.

### Germania
20 `TMaceman`, 10 `TArcher`, 12 `THuntress`, 7 `TTeutonRider`, 1 `THero1`.

### Galia
20 `GWomanWarrior`, 11 `GArcher`, 11 `GAxeman`, 7 `GHorseman`, 1 `GHero1`.

### Britania
15 `BBronzeSpearman`, 5 `BHighlander`, 15 `BBowman`, 14 `BJavelineer`, 1 `BHero1`.

### Iberia
17 `IDefender`, 11 `ISlinger`, 8 `IMilitiaman`, 6 `IEliteGuard`, 7 `ICavalry`, 1 `IHero1`.

### Cartago
18 `CLibyanFootman`, 11 `CJavelinThrower`, 8 `CBerberAssassin`, 5 `CNoble`, 7 `CNumidianRider`, 1 `CHero1`.

### Egipto
19 `EGuardian`, 10 `EArcher`, 9 `EAxetrower`, 5 `EAnubisWarrior`, 6 `EChariot`, 1 `EHero1`.

## Puntos de aparición actuales

Ejército A:

```text
(3448, 1732)
```

Ejército B:

```text
(2454, 2898)
```

Son los puntos medios definidos entre los Guard Post indicados durante el diseño.

## Archivo

`sequences/GuardPostsFrontierReward_Main.vs`

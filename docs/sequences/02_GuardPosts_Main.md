# `GuardPosts_Main`

## Objetivo

Transformar `GGuardPost` en un puesto fronterizo con defensa terrestre adicional, conservando intacto su sistema nativo de 12 sentinelas.

## Comportamiento nativo relevante

`GGuardPost`:

- hereda de `Outpost`;
- tiene `max_units="0"`;
- no admite tropas almacenadas;
- usa `GGuardPost_Sentries.vs`;
- mantiene 12 sentinelas en posiciones fijas;
- regenera sus sentinelas;
- los sustituye cuando cambia de propietario.

## Escolta terrestre

La Sequence añade 10 unidades externas:

| Propietario | Grupo 1 | Grupo 2 |
|---|---|---|
| Roma Imperial | 5 `RHastatus` | 5 `RPraetorian` |
| Cartago | 5 `CNoble` | 5 `CBerberAssassin` |
| Iberia | 5 `IDefender` | 5 `IEliteGuard` |
| Galia | 5 `GWomanWarrior` | 5 `GAxeman` |
| Britania | 5 `BBronzeSpearman` | 5 `BHighlander` |
| Germania | 5 `TMaceman` | 5 `THuntress` |
| Roma Republicana | 5 `RHastatus` | 5 `RTribune` |
| Egipto | 5 `EGuardian` | 5 `EAnubisWarrior` |

## Reglas

Los guardianes:

- tienen nivel inicial definido por la Sequence;
- no consumen comida;
- reciben `SetNoAIFlag(true)`;
- salen a defender cuando aparecen enemigos;
- vuelven a posiciones exteriores al terminar;
- regeneran en paz;
- se mantienen en dos pools separados de 5 + 5.

## Captura

Mientras sobreviva al menos un guardián terrestre, la captura puede mantenerse bloqueada mediante `AllowCapture(false)`.

Cuando la escolta se agota, el puesto queda disponible para cambiar de dueño.

## Archivo

`sequences/GuardPosts_Main.vs`

# Secuencia 8 — `ZombieWaves_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieWaves_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieWaves_Main` es la Sequence encargada de crear las oleadas del modo Zombies, controlar el calendario de rondas, repartir las apariciones entre los ocho puntos de spawn, registrar las unidades en los frentes tácticos y publicar la información necesaria para `ZombieRewards_Main`.

La arquitectura v2.0 ya no utiliza:

```text
40 rondas
48 hordas internas
HW_H1..HW_H48
```

El sistema actual utiliza:

```text
8 frentes tácticos persistentes
+
R1-R15 con composición propia
+
R16+ infinito
```

Desde R16 las rondas pueden solaparse. La siguiente ronda se programa desde el final del despliegue y **no espera a que mueran los zombies de rondas anteriores**.

`ZombieWaves_Main` debe tener:

```text
AUTORUN ALLOWED = NO
```

y es iniciada por:

```cpp
RunSequence("ZombieWaves_Main");
```

desde `ZombieIntro_Main`.

---

# 1. Nombre canónico

El nombre actual es:

```text
ZombieWaves_Main
```

No deben utilizarse como nombres canónicos:

```text
ZombieWaves_Main_40R_48H_FINAL_UI
ZombieWaves_Main_GLOBAL_TIMED_V*
ZombieWaves_Main_ENDLESS_*
```

Esos nombres corresponden a etapas anteriores del desarrollo.

---

# 2. Papel dentro del modo Zombies

La división actual es:

```text
ZombieIntro_Main
→ inicia el reloj de oleadas

ZombieWaves_Main
→ crea y distribuye zombies
→ publica estado de rondas y máscaras

ZombieTactical_Main
→ dirige HW_H1..HW_H8 contra ciudades

ZombieRewards_Main
→ entrega refuerzos
```

`ZombieWaves_Main` no decide la ruta territorial detallada ni controla Gates después del spawn.

---

# 3. Groups manuales obligatorios

Deben existir:

```text
CapitalForum_P1

HordeSpawn_01
HordeSpawn_02
HordeSpawn_03
HordeSpawn_04
HordeSpawn_05
HordeSpawn_06
HordeSpawn_07
HordeSpawn_08
```

Cada uno debe resolver exactamente a un objeto válido.

---

# 4. `CapitalForum_P1`

El Group se utiliza como memoria global:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();

if(stateList.count != 1)
{
    ShowAnnouncement(
        "ZombieHelp",
        "ERROR ZOMBIES - CapitalForum_P1"
    );

    return;
}
```

Su único objeto se convierte en:

```cpp
Building state;
```

---

# 5. Variables compartidas que Waves escribe

Entre las variables principales están:

```text
HW_ACTIVE1..8
HW_ROUND1..8
HW_TX1..8
HW_TY1..8
HW_OWNER1..8

ZR_MASK1..15
ZR_LAST_DEPLOYED_ROUND

ZR_ENDLESS_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
ZR_ENDLESS_DEPLOYED_GENERATION

EE_FIRST_HORDE_READY
ZWAVES_STOPPED_BY_PORTALS
```

---

# 6. Validación continua del estado

La Sequence puede permanecer activa durante horas.

Por ello vuelve a obtener:

```text
CapitalForum_P1
```

en distintos puntos críticos:

- durante las esperas;
- antes de cada aparición;
- cada cinco unidades durante el spawn;
- después del despliegue;
- al detener las oleadas por el Easter Egg.

Esto evita conservar durante periodos muy largos una referencia obsoleta al `Building`.

---

# 7. Los ocho HordeSpawn

Cada Group se resuelve al inicio:

```cpp
q =
    Group("HordeSpawn_01")
    .GetObjList();

q.ClearDead();

if(q.count != 1)
{
    ShowAnnouncement(
        "ZombieHelp",
        "ERROR ZOMBIES - HordeSpawn_01"
    );

    return;
}

s1 = q[0].pos;
```

El mismo patrón se aplica a `HordeSpawn_02..08`.

---

# 8. Función de los HordeSpawn

Sólo se necesita:

```cpp
q[0].pos
```

Por tanto cada Group funciona como marcador espacial.

No necesita ser un Townhall ni una unidad de combate.

---

# 9. Player técnico

La configuración utiliza:

```cpp
HP = 12;
```

Todas las unidades creadas por la Sequence pertenecen a:

```text
Player 12
```

---

# 10. Parámetros globales actuales

```cpp
HP = 12;
START_DELAY = 1800000;
WAVE_INTERVAL = 120000;
BLOCK_BREAK = 600000;
BATCH_INTERVAL = 20000;

SP = 65;
SPAWN_CLEAR_RADIUS = 350;
```

| Parámetro | Valor | Función |
|---|---:|---|
| `HP` | 12 | Player técnico zombie |
| `START_DELAY` | 1.800.000 ms | 30 minutos hasta R1 |
| `WAVE_INTERVAL` | 120.000 ms | 2 minutos tras un despliegue normal |
| `BLOCK_BREAK` | 600.000 ms | 10 minutos tras R5 y R10 |
| `BATCH_INTERVAL` | 20.000 ms | 20 segundos entre apariciones |
| `SP` | 65 | separación base de la formación |
| `SPAWN_CLEAR_RADIUS` | 350 | radio central libre alrededor del marcador |

---

# 11. Inicio sincronizado con la intro

La Sequence tiene:

```text
AUTORUN = NO
```

El reloj comienza cuando `ZombieIntro_Main` termina la introducción y ejecuta:

```cpp
RunSequence("ZombieWaves_Main");
```

Entonces:

```cpp
w = 0;
nextWave =
    GetTime()
    +
    START_DELAY;
```

Los 30 minutos empiezan en ese instante, no al cargar el mapa antes de la cinemática.

---

# 12. Cuenta atrás inicial de 30 minutos

La configuración de producción es:

```cpp
START_DELAY = 1800000;
```

Por tanto R1 comienza 30 minutos después de que `ZombieIntro_Main` lance esta Sequence.

---

# 13. HUD inicial permanente

Durante la espera de R1 se muestra:

```text
PRIMERA HORDA 29:59
PRIMERA HORDA 29:58
...
```

La cuenta se actualiza cuando cambia el segundo restante.

No muestra ya:

```text
Z
T
/16
```

ni otros datos de monitorización.

---

# 14. Avisos largos antes de R1

Con `START_DELAY = 30 min` se emiten además:

```text
HORDA EN 15 MINUTOS
HORDA EN 5 MINUTOS
HORDA EN 1 MINUTO
```

Cada aviso utiliza `ZombieHelp` y permanece visible temporalmente.

---

# 15. Aviso de 30 segundos

Antes de cada nueva ronda, si el intervalo lo permite:

```text
RONDA X EN 30 SEGUNDOS
```

se muestra mediante:

```text
ZombieAlert
```

---

# 16. Cuenta atrás 3-2-1

Los últimos segundos utilizan:

```text
3
2
1
```

con:

```text
ZombieCountdown
```

Después se ocultan los anuncios temporales y comienza el despliegue.

---

# 17. HUD durante una ronda

La interfaz estable v2.0 muestra únicamente:

```text
RONDA 1
RONDA 16
RONDA 19
RONDA 37
...
```

No existe un máximo visual `/16`.

El número puede continuar creciendo indefinidamente.

---

# 18. HUD durante descansos largos

Los descansos especiales muestran:

```text
DESCANSO 10:00
DESCANSO 9:59
...
```

La cuenta atrás se mantiene hasta la siguiente ronda.

---

# 19. Mensajes de monitorización eliminados

La versión estable ya no muestra:

```text
Zxxx
Txxx
F3/16
SIG
DESPLEGADA
R16 RESTANTES
```

Esos datos se utilizaban durante el desarrollo y se eliminaron del HUD jugable.

---

# 20. Frecuencia de espera

Durante la cuenta atrás:

```cpp
Sleep(250);
```

permite revisar el reloj aproximadamente cuatro veces por segundo.

---

# 21. Comprobación periódica del Easter Egg

Durante las esperas se consulta aproximadamente una vez por segundo:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

Si vale:

```text
1
```

se activa:

```text
stopWaves = 1
```

y no empieza ninguna ronda nueva.

---

# 22. Parada al cargar una partida con los portales ya sellados

Después de obtener `state` se ejecuta:

```cpp
stopWaves =
    EnvReadInt(
        state,
        "EE_ZOMBIE_SPAWNS_DISABLED"
    );
```

Si ya vale 1:

```text
no se resuelven nuevas rondas
```

se escribe:

```text
ZWAVES_STOPPED_BY_PORTALS = 1
```

y la Sequence termina.

---

# 23. Qué ocurre con zombies ya existentes al sellar los portales

La parada afecta únicamente a:

```text
nuevos spawns
```

No borra unidades que ya existen.

`ZombieTactical_Main` continúa controlando los zombies supervivientes.

---

# 24. R1-R15: ocho apariciones por ronda

Para:

```text
R1..R15
```

se configura:

```cpp
batchCount = 8;
maxPerSpawn = 1;
```

Por tanto:

```text
8 apariciones
```

y cada uno de los ocho `HordeSpawn` se utiliza exactamente una vez.

---

# 25. Orden aleatorio de los ocho spawns

Antes de la ronda:

```cpp
for(i=1; i<=8; i+=1)
    spawnUse[i] = 0;
```

Cada aparición selecciona:

```cpp
si = rand(8) + 1;
```

y repite mientras ese spawn haya alcanzado su máximo permitido.

Resultado R1-R15:

```text
los 8 spawns aparecen
exactamente una vez
en orden aleatorio
```

---

# 26. Separación temporal R1-R15

Entre dos apariciones consecutivas:

```cpp
BATCH_INTERVAL = 20000;
```

Por tanto existen:

```text
20 segundos
```

entre mini-hordas.

Con ocho apariciones hay siete intervalos:

```text
7 × 20 s = 140 s
```

aproximadamente 2 minutos y 20 segundos de despliegue, además del tiempo de creación.

---

# 27. R16+: dieciséis apariciones

Para:

```cpp
if(w >= 16)
{
    batchCount = 16;
    maxPerSpawn = 2;
}
```

Cada uno de los ocho HordeSpawn aparece:

```text
exactamente dos veces
```

por ronda.

---

# 28. Duración del despliegue R16+

Con 16 apariciones existen 15 intervalos:

```text
15 × 20 s
=
300 s
=
5 minutos
```

Por tanto una ronda R16+ tarda aproximadamente cinco minutos en terminar de desplegar sus 16 mini-hordas, más el coste de creación.

---

# 29. Los ocho frentes persistentes

La variable:

```cpp
S = si;
```

vincula directamente:

```text
HordeSpawn_01 → HW_H1
HordeSpawn_02 → HW_H2
...
HordeSpawn_08 → HW_H8
```

No existe un nuevo `HW_H` por ronda.

---

# 30. Reforzar un frente ya vivo

Antes de crear una nueva aparición:

```cpp
q =
    Group("HW_H" + S)
    .GetObjList();

q.ClearDead();
```

Si el Group está vacío:

```text
HW_TX
HW_TY
HW_OWNER
```

se reinician a cero.

Si quedan supervivientes de una ronda anterior:

```text
el objetivo actual NO se borra
```

y los nuevos zombies se incorporan al mismo frente.

---

# 31. Activación del frente

En cada aparición se escribe:

```cpp
EnvWriteInt(
    state,
    "HW_ACTIVE" + S,
    1
);

EnvWriteInt(
    state,
    "HW_ROUND" + S,
    w
);
```

`HW_ROUND` representa la última ronda que reforzó ese frente, no necesariamente la ronda de origen de todos los zombies presentes.

---

# 32. Dos sistemas de Group por unidad

Cada zombie pertenece a:

```text
1. frente táctico HW_H1..HW_H8
2. grupo de seguimiento de ronda
```

La lógica es:

```cpp
u.AddToGroup(
    "HW_H" + S
);

if(w < 16)
    u.AddToGroup(
        "HW_R" + w
    );
else
    u.AddToGroup(
        "HW_R16"
    );
```

---

# 33. `HW_R1..HW_R15`

Las primeras quince rondas conservan un Group independiente:

```text
HW_R1
...
HW_R15
```

`ZombieRewards_Main` puede comprobar cuándo cada uno queda completamente vacío y entregar la recompensa de aniquilación correspondiente.

---

# 34. `HW_R16` como Group agregado endless

Desde R16 todas las unidades se añaden a:

```text
HW_R16
```

Por tanto el Group puede contener simultáneamente zombies de:

```text
R16
R17
R18
R19
...
```

No puede utilizarse para saber cuándo una generación concreta ha muerto.

---

# 35. R16+ no espera a `HW_R16 == 0`

La versión v2.0 contiene expresamente una zona infinita no bloqueante.

Después de terminar un despliegue:

```text
NO espera a que HW_R16 quede vacío
NO espera a que ZombieRewards termine
```

La siguiente ronda se programa inmediatamente según el intervalo correspondiente.

---

# 36. Consecuencia: rondas solapadas

Es posible:

```text
R16 todavía combate
↓
R17 comienza
↓
R16 y R17 siguen vivos
↓
R18 comienza
```

Este comportamiento es deliberado.

---

# 37. Programación desde el final del despliegue

La siguiente ronda se calcula mediante:

```cpp
nextWave =
    GetTime()
    +
    intervalo;
```

Por tanto el intervalo comienza:

```text
cuando termina completamente el despliegue actual
```

no desde el inicio de la ronda.

---

# 38. Descansos normales

Después de una ronda ordinaria:

```cpp
currentDelay =
    WAVE_INTERVAL;

nextWave =
    GetTime()
    +
    WAVE_INTERVAL;
```

con:

```text
WAVE_INTERVAL = 2 minutos
```

---

# 39. Descansos largos

Sólo:

```cpp
if(w == 5 || w == 10)
```

activa:

```text
10 minutos
```

mediante:

```cpp
BLOCK_BREAK = 600000;
```

---

# 40. R15 no tiene descanso largo

Después de R15:

```text
intervalo normal = 2 minutos
```

Por tanto R16 llega sin un nuevo descanso de 10 minutos.

---

# 41. R16+ no tiene descansos largos

Desde R16:

```text
R16 → 2 min
R17 → 2 min
R18 → 2 min
R19 → 2 min
R20 → 2 min
...
```

La única excepción histórica sigue siendo:

```text
tras R5
tras R10
```

---

# 42. Tabla R1-R15

Cada fila describe **una aparición**. El total de ronda multiplica por ocho.

| Ronda | Nivel | Unidades/aparición | Total ronda | Composición por aparición |
|---:|---:|---:|---:|---|
| 1 | 6 | 30 | 240 | 12 `TMaceman` + 10 `RHastatus` + 5 `GAxeman` + 3 `ISlinger` |
| 2 | 6 | 30 | 240 | 10 `TMaceman` + 8 `GAxeman` + 6 `RHastatus` + 6 `RArcher` |
| 3 | 7 | 36 | 288 | 10 `RHastatus` + 9 `CLibyanFootman` + 6 `BBronzeSpearman` + 6 `ISlinger` + 5 `CJavelinThrower` |
| 4 | 7 | 36 | 288 | 10 `TMaceman` + 8 `GAxeman` + 7 `RHastatus` + 5 `EGuardian` + 6 `RArcher` |
| 5 | 8 | 40 | 320 | 12 `TMaceman` + 8 `RHastatus` + 6 `GAxeman` + 5 `EGuardian` + 4 `ISlinger` + 5 `GHorseman` |
| 6 | 8 | 44 | 352 | 12 `CLibyanFootman` + 9 `TMaceman` + 7 `BBronzeSpearman` + 5 `EGuardian` + 6 `CJavelinThrower` + 5 `CNumidianRider` |
| 7 | 9 | 44 | 352 | 12 `RHastatus` + 9 `GAxeman` + 7 `TMaceman` + 5 `EGuardian` + 5 `ISlinger` + 6 `GHorseman` |
| 8 | 9 | 50 | 400 | 13 `TMaceman` + 10 `CLibyanFootman` + 7 `RHastatus` + 5 `BBronzeSpearman` + 5 `RArcher` + 5 `CNumidianRider` + 5 `RPraetorian` |
| 9 | 10 | 50 | 400 | 12 `TMaceman` + 9 `RHastatus` + 7 `GAxeman` + 5 `EGuardian` + 5 `CJavelinThrower` + 5 `GHorseman` + 4 `RPraetorian` + 3 `IEliteGuard` |
| 10 | 11 | 56 | 448 | 12 `TMaceman` + 10 `RHastatus` + 7 `GAxeman` + 6 `EGuardian` + 5 `CJavelinThrower` + 4 `GHorseman` + 5 `RPraetorian` + 4 `IEliteGuard` + 3 `BHighlander` |
| 11 | 12 | 60 | 480 | 12 `CLibyanFootman` + 10 `TMaceman` + 8 `RHastatus` + 6 `EGuardian` + 5 `CJavelinThrower` + 4 `CNumidianRider` + 5 `RPraetorian` + 4 `IEliteGuard` + 3 `BHighlander` + 3 `EAnubisWarrior` |
| 12 | 13 | 60 | 480 | 10 `RHastatus` + 9 `TMaceman` + 7 `GAxeman` + 6 `EGuardian` + 5 `CJavelinThrower` + 4 `GHorseman` + 5 `RPraetorian` + 4 `IEliteGuard` + 3 `BHighlander` + 3 `EAnubisWarrior` + 2 `RLiberatus` + 2 `TValkyrie` |
| 13 | 14 | 64 | 512 | 10 `TMaceman` + 8 `RHastatus` + 6 `CLibyanFootman` + 5 `EGuardian` + 4 `CJavelinThrower` + 5 `RPraetorian` + 5 `IEliteGuard` + 4 `BHighlander` + 4 `EAnubisWarrior` + 3 `RLiberatus` + 3 `TValkyrie` + 4 `GTridentWarrior` + 3 `EHorusWarrior` |
| 14 | 15 | 64 | 512 | 8 `CLibyanFootman` + 8 `TMaceman` + 7 `RHastatus` + 5 `EGuardian` + 4 `CJavelinThrower` + 5 `RPraetorian` + 5 `IEliteGuard` + 4 `BHighlander` + 4 `EAnubisWarrior` + 3 `RLiberatus` + 3 `TValkyrie` + 4 `GTridentWarrior` + 2 `EHorusWarrior` + 2 `CWarElephant` |
| 15 | 17 | 70 | 560 | 10 `RHastatus` + 8 `TMaceman` + 7 `CLibyanFootman` + 5 `GAxeman` + 5 `EGuardian` + 6 `RPraetorian` + 5 `IEliteGuard` + 4 `BHighlander` + 4 `EAnubisWarrior` + 3 `RLiberatus` + 3 `TValkyrie` + 4 `GTridentWarrior` + 4 `EHorusWarrior` + 2 `CWarElephant` |

---

# 43. Escalado total R1-R15

Los totales son:

```text
R1  = 240
R2  = 240
R3  = 288
R4  = 288
R5  = 320
R6  = 352
R7  = 352
R8  = 400
R9  = 400
R10 = 448
R11 = 480
R12 = 480
R13 = 512
R14 = 512
R15 = 560
```

---

# 44. Composición base R16+

Cada una de las 16 apariciones normales contiene:

| Clase | Cantidad |
|---|---:|
| `RHastatus` | 5 |
| `TMaceman` | 5 |
| `CLibyanFootman` | 4 |
| `GAxeman` | 3 |
| `EGuardian` | 3 |
| `RPraetorian` | 4 |
| `IEliteGuard` | 4 |
| `BHighlander` | 3 |
| `EAnubisWarrior` | 3 |
| `RLiberatus` | 3 |
| `TValkyrie` | 3 |
| `GTridentWarrior` | 4 |
| `EHorusWarrior` | 4 |
| `CWarElephant` | 2 |

Total base:

```text
50 unidades por aparición
× 16 apariciones
=
800 zombies por ronda
```

---

# 45. Nivel de R16+

Se calcula:

```cpp
levelGrowth =
    w - 16;

lv =
    20
    +
    levelGrowth;
```

Por tanto:

```text
R16 → nivel 20
R17 → nivel 21
R18 → nivel 22
R19 → nivel 23
R20 → nivel 24
...
```

---

# 46. Límite de nivel

El código protege:

```cpp
if(lv > 60)
    lv = 60;
```

Por tanto:

```text
R56 → nivel 60
R57 → nivel 60
R100 → nivel 60
```

El número de ronda no tiene límite.

---

# 47. Rondas reforzadas endless

La condición es:

```cpp
if(
    w >= 20
    &&
    (w % 5) == 0
)
```

Por tanto son especiales:

```text
R20
R25
R30
R35
R40
R45
...
```

---

# 48. Bonus de las rondas reforzadas

En esas rondas:

```cpp
n1 += 10;
n2 += 10;
```

Es decir, cada aparición recibe:

```text
+10 RHastatus
+10 TMaceman
=
+20 zombies
```

---

# 49. Tamaño de una ronda reforzada

Una aparición especial contiene:

```text
50 base
+
20 extra
=
70 zombies
```

Como hay 16 apariciones:

```text
70 × 16
=
1.120 zombies generados
```

frente a los:

```text
800
```

de una ronda endless normal.

---

# 50. La siguiente ronda vuelve a la cantidad base

El bonus se aplica sólo cuando la propia ronda cumple el múltiplo de 5.

Ejemplo:

```text
R19 → 50 × 16 = 800
R20 → 70 × 16 = 1120
R21 → 50 × 16 = 800
```

No se acumula permanentemente.

---

# 51. `specialRound`

El código asigna:

```cpp
specialRound = 1;
```

en los múltiplos de 5 endless.

La modificación funcional real del tamaño se produce mediante:

```cpp
n1 += 10;
n2 += 10;
```

La variable `specialRound` no controla actualmente otra rama de interfaz o spawn.

---

# 52. Formación de spawn

Para cada unidad:

```cpp
spawnX =
    spawnBaseX
    +
    (idx % 10) * SP
    -
    5 * SP;

spawnY =
    spawnBaseY
    +
    (idx / 10) * SP
    -
    3 * SP;
```

con:

```text
SP = 65
```

La formación utiliza 10 columnas.

---

# 53. Radio libre alrededor del marcador

La configuración actual es:

```cpp
SPAWN_CLEAR_RADIUS = 350;
```

Si una posición calculada cae dentro del círculo central, se desplaza hasta el borde.

---

# 54. Cálculo del radio central

Se utilizan:

```text
spawnDX
spawnDY
```

y la comparación:

```cpp
spawnDX * spawnDX
+
spawnDY * spawnDY
<
SPAWN_CLEAR_RADIUS
*
SPAWN_CLEAR_RADIUS
```

No se necesita calcular una raíz cuadrada.

---

# 55. Cómo se desplaza una unidad dentro del radio prohibido

La Sequence compara:

```text
|spawnDX|
|spawnDY|
```

y desplaza la coordenada dominante hasta:

```text
±350
```

respecto al HordeSpawn.

La formación sigue rodeando el marcador, pero evita colocar zombies demasiado cerca del objeto central.

---

# 56. Configuración de cada zombie

Después de `Place()`:

```cpp
u.SetLevel(lv);
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

---

# 57. Alimentación

```cpp
SetFeeding(false)
```

impide que las hordas técnicas dependan de comida.

---

# 58. IA estratégica

```cpp
SetNoAIFlag(true)
```

evita que el comportamiento estratégico normal del Player 12 se apropie de las unidades.

Su control queda reservado a `ZombieTactical_Main`.

---

# 59. Creación escalonada

Cada cinco unidades:

```cpp
if((idx % 5) == 0)
{
    Sleep(20);
    ...
}
```

La Sequence cede periódicamente el turno al motor durante las tandas grandes.

---

# 60. Comprobación de parada durante el spawn

Dentro de ese mismo bloque de cada cinco unidades se vuelve a leer:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

Por tanto el Easter Egg puede detener una ronda incluso mientras se está generando una mini-horda.

---

# 61. Primera horda relevante para el Easter Egg

Cuando:

```text
w == 1
S == 1
```

las unidades se añaden además a:

```text
EE_FirstHorde_Spawn01
```

---

# 62. `EE_FIRST_HORDE_READY`

Después de terminar de crear esa aparición concreta se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FIRST_HORDE_READY",
    1
);
```

Esto permite que `ZombieEE_FirstHordeTrigger` distinga:

```text
todavía no ha aparecido
```

de:

```text
ya apareció y ahora puede esperarse su muerte
```

---

# 63. La primera aparición de Spawn 01 no tiene posición fija en la secuencia

R1 utiliza los ocho spawns en orden aleatorio.

Por tanto `HordeSpawn_01` puede ser:

```text
primera mini-horda de R1
```

o aparecer más tarde dentro de las ocho.

El flag se activa cuando termina específicamente su propia creación.

---

# 64. No hay contador visible entre mini-hordas

Durante los 20 segundos entre apariciones ya no se muestra:

```text
F x/8
F x/16
SIG
Z/T
```

El bucle de espera permanece, pero la información de monitorización fue eliminada.

---

# 65. Despliegue completo

Cuando termina la última aparición se vuelve a mostrar:

```text
RONDA X
```

y se esperan:

```text
5 segundos
```

antes de construir la máscara de objetivos.

---

# 66. Motivo de los 5 segundos

`ZombieTactical_Main` trabaja aproximadamente cada:

```text
1000 ms
```

La espera de 5 segundos deja varios ciclos para que los ocho frentes:

```text
fijen target
publiquen HW_OWNER
```

antes de que Waves capture la máscara de Players objetivo.

---

# 67. Construcción de `roundMask`

La Sequence limpia:

```cpp
markedOwner[1..8]
```

y recorre:

```text
HW_OWNER1
...
HW_OWNER8
```

Cada Player se incorpora una sola vez.

---

# 68. Pesos de la máscara

| Player | Bit/peso |
|---:|---:|
| 1 | 1 |
| 2 | 2 |
| 3 | 4 |
| 4 | 8 |
| 5 | 16 |
| 6 | 32 |
| 7 | 64 |
| 8 | 128 |

---

# 69. Máscara R1-R15

Para:

```cpp
if(w < 16)
```

se escribe:

```cpp
EnvWriteInt(
    state,
    "ZR_MASK" + w,
    roundMask
);

EnvWriteInt(
    state,
    "ZR_LAST_DEPLOYED_ROUND",
    w
);
```

`ZombieRewards_Main` podrá pagar esa ronda cuando su `HW_Rn` quede vacío.

---

# 70. Inicio de una generación endless

Antes de configurar una ronda:

```cpp
if(w >= 16)
```

incrementa:

```text
endlessGeneration
```

y escribe:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK = 0
ZR_ENDLESS_PAIDMASK = 0
```

---

# 71. Máscara R16+

Después del despliegue se escribe:

```cpp
EnvWriteInt(
    state,
    "ZR_ENDLESS_MASK",
    roundMask
);

EnvWriteInt(
    state,
    "ZR_ENDLESS_DEPLOYED_GENERATION",
    endlessGeneration
);
```

Eso autoriza a `ZombieRewards_Main` a procesar la recompensa de esa generación.

---

# 72. Rewards no bloquea Waves desde R16

Waves no consulta:

```text
ZR_ENDLESS_REWARDED_GENERATION
```

antes de programar la ronda siguiente.

Por tanto:

```text
reward pendiente
```

no detiene el scheduler.

---

# 73. Persistencia de `endlessGeneration`

Al arrancar se lee:

```cpp
endlessGeneration =
    EnvReadInt(
        state,
        "ZR_ENDLESS_GENERATION"
    );
```

Si el valor es negativo se corrige a cero.

La intención es mantener continuidad si existe estado persistido.

---

# 74. Ausencia de `MAX_ROUNDS`

La versión v2.0 no utiliza:

```text
MAX_ROUNDS = 16
MAX_ROUNDS = 40
```

como condición de salida del calendario.

El bucle es:

```cpp
while(stopWaves == 0)
```

Por tanto las rondas sólo terminan cuando el Easter Egg desactiva nuevos spawns o la Sequence retorna por un error de configuración.

---

# 75. Qué ocurre después de R16

El flujo real es:

```text
R16
↓
16 apariciones
↓
termina el despliegue
↓
registrar máscara endless
↓
2 minutos
↓
R17
↓
16 apariciones
↓
2 minutos
↓
R18
↓
...
```

No depende de que los zombies anteriores hayan muerto.

---

# 76. Ejemplos de progresión endless

| Ronda | Nivel | Apariciones | Zombies/aparición | Total generado | Descanso posterior |
|---:|---:|---:|---:|---:|---:|
| 16 | 20 | 16 | 50 | 800 | 2 min |
| 17 | 21 | 16 | 50 | 800 | 2 min |
| 18 | 22 | 16 | 50 | 800 | 2 min |
| 19 | 23 | 16 | 50 | 800 | 2 min |
| 20 | 24 | 16 | 70 | 1120 | 2 min |
| 21 | 25 | 16 | 50 | 800 | 2 min |
| 25 | 29 | 16 | 70 | 1120 | 2 min |
| 30 | 34 | 16 | 70 | 1120 | 2 min |
| 40 | 44 | 16 | 70 | 1120 | 2 min |
| 56 | 60 | 16 | 50 | 800 | 2 min |
| 60 | 60 | 16 | 70 | 1120 | 2 min |

---

# 77. Diferencia entre intervalo y duración real de una ronda

El intervalo de:

```text
2 minutos
```

no se mide desde que empieza R16.

Se mide desde:

```text
el final de sus 16 apariciones
```

Por tanto una ronda endless normal ocupa aproximadamente:

```text
5 min de despliegue
+
2 min de espera
=
~7 min entre el comienzo de una ronda
y el comienzo de la siguiente
```

sin contar el coste real de creación.

---

# 78. R1-R15 y duración real

Una ronda normal temprana ocupa aproximadamente:

```text
2 min 20 s de despliegue
+
2 min de espera
=
~4 min 20 s
```

excepto R5 y R10, donde el descanso posterior es:

```text
10 minutos
```

---

# 79. Stop por cuatro portales

Cuando:

```text
EE_ZOMBIE_SPAWNS_DISABLED == 1
```

la Sequence sale del bucle.

Después:

```cpp
EnvWriteInt(
    state,
    "ZWAVES_STOPPED_BY_PORTALS",
    1
);
```

---

# 80. Mensaje final de parada

Se ocultan:

```text
ZombieCountdown
ZombieAlert
ZombieBreak
ZombieHelp
```

y se mantiene el aviso importante:

```text
CUATRO PORTALES SELLADOS - NO HABRA MAS HORDAS
```

Las hordas ya creadas no se eliminan.

---

# 81. Interacción con `ZombieRewards_Main`

R1-R15:

```text
Waves despliega
↓
guarda ZR_MASKn
↓
Rewards espera HW_Rn == 0
↓
paga
```

R16+:

```text
Waves incrementa generación
↓
despliega
↓
publica ZR_ENDLESS_MASK
ZR_ENDLESS_DEPLOYED_GENERATION
↓
Rewards paga sin esperar HW_R16 == 0
↓
Waves ya puede estar preparando la ronda siguiente
```

---

# 82. Interacción con `ZombieTactical_Main`

Waves crea las unidades y las registra en:

```text
HW_H1..HW_H8
```

Tactical:

```text
selecciona target
mantiene ruta
gestiona Gates
captura ciudades
publica HW_OWNER
```

Waves no reemplaza esa lógica.

---

# 83. No hay Groups HW_H9+

La versión estable utiliza únicamente:

```text
HW_H1
...
HW_H8
```

Esto elimina la incompatibilidad de la arquitectura antigua que creaba H33-H48 mientras Tactical sólo conocía parte de los slots.

---

# 84. No hay una horda independiente por ronda

Desde el punto de vista táctico existen:

```text
8 frentes permanentes
```

Una ronda es una operación de refuerzo global sobre esos frentes.

---

# 85. Grupo de seguimiento y grupo táctico no son lo mismo

Ejemplo R12 en Spawn 4:

```text
unidad
├── HW_H4
└── HW_R12
```

Ejemplo R23 en Spawn 4:

```text
unidad
├── HW_H4
└── HW_R16
```

---

# 86. Consecuencia para Rewards desde R16

Como todas las rondas endless comparten:

```text
HW_R16
```

no es posible detectar individualmente:

```text
“han muerto todos los zombies de R23”
```

sin crear una arquitectura de Group adicional.

Por eso Rewards utiliza:

```text
generación desplegada
```

como disparador desde R16.

---

# 87. Uso de claves dinámicas

La Sequence mantiene escrituras como:

```cpp
EnvWriteInt(
    state,
    "HW_ACTIVE" + S,
    1
);
```

y Groups como:

```cpp
u.AddToGroup(
    "HW_H" + S
);
```

Estas construcciones forman parte del código canónico compilado actual.

---

# 88. Lecturas de propietarios desenrolladas

Al construir `roundMask`, las lecturas de:

```text
HW_OWNER1..8
```

están escritas explícitamente:

```cpp
if(S==1)
    owner =
        EnvReadInt(
            state,
            "HW_OWNER1"
        );
```

y así hasta Player/frente 8.

---

# 89. Variables heredadas sin función relevante actual

El Source conserva algunas declaraciones de etapas anteriores, por ejemplo:

```text
activeCount
totalCount
countRefreshAt
endlessRewarded
```

que ya no forman parte de la lógica principal del HUD o del bloqueo endless.

No deben interpretarse como prueba de que exista todavía:

```text
contador Z/T
espera por recompensa
espera por zombies restantes
```

La ejecución actual no utiliza esas mecánicas como condición del scheduler.

---

# 90. `specialRound` no cambia el HUD

Aunque se asigna:

```text
specialRound = 1
```

en R20, R25, R30..., el aviso principal sigue siendo:

```text
RONDA X
```

No existe actualmente un anuncio separado obligatorio de:

```text
RONDA ESPECIAL
```

---

# 91. Errores de configuración

La Sequence muestra mensajes de error para:

```text
CapitalForum_P1
HordeSpawn_01
...
HordeSpawn_08
```

y ejecuta:

```cpp
return;
```

No entra en un bucle infinito de 60 segundos como algunas versiones antiguas.

---

# 92. Elementos que no hay que crear manualmente

No hacen falta:

```text
HW_H1..8 poblados manualmente
HW_R1..16 poblados manualmente
Areas
Holders
Groups de Gates
Groups de Townhalls objetivo
rutas
marcadores de brecha
una Sequence por ronda
una Sequence por spawn
```

Los Groups dinámicos se forman mediante `AddToGroup()`.

---

# 93. Configuración exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   ├── HordeSpawn_01
│   ├── HordeSpawn_02
│   ├── HordeSpawn_03
│   ├── HordeSpawn_04
│   ├── HordeSpawn_05
│   ├── HordeSpawn_06
│   ├── HordeSpawn_07
│   └── HordeSpawn_08
│
└── Sequences
    ├── ZombieIntro_Main
    │   └── AUTORUN = Sí
    │
    └── ZombieWaves_Main
        ├── código v2.0
        ├── Compile
        └── AUTORUN = No
```

---

# 94. Comprobaciones antes de publicar el mapa

1. `CapitalForum_P1` contiene exactamente un `Building`.
2. Los ocho `HordeSpawn_XX` contienen exactamente un objeto.
3. Player 12 está reservado para zombies.
4. `ZombieIntro_Main` ejecuta `RunSequence("ZombieWaves_Main")`.
5. `ZombieTactical_Main` tiene Autorun.
6. `ZombieRewards_Main` tiene Autorun.
7. `START_DELAY` de producción sigue en `1800000`.
8. `EE_ZOMBIE_SPAWNS_DISABLED` se activa al sellar los cuatro portales.
9. `HW_H1..8` coinciden entre Waves y Tactical.
10. R16+ no contiene ningún `while` que espere `HW_R16.count == 0`.

---

# 95. Diferencias respecto a `ZombieWaves_Main_40R_48H_FINAL_UI`

| Arquitectura antigua | v2.0 |
|---|---|
| 40 rondas máximas | rondas infinitas |
| 48 slots de horda | 8 frentes persistentes |
| R1-R32 una horda | R1-R15 ocho apariciones |
| R33-R40 dos hordas | R16+ dieciséis apariciones |
| `HW_H1..HW_H48` | `HW_H1..HW_H8` |
| una horda grande por slot | mini-hordas refuerzan frentes globales |
| `MAX_ROUNDS = 40` | no existe límite de rondas |
| START_DELAY podía estar a 0 | producción = 30 minutos |
| HUD `R X/40` | HUD `RONDA X` |
| sin integración final con EE | cuatro portales detienen nuevos spawns |
| Rewards por 48 eventos | masks R1-R15 + generation R16+ |
| rondas finales rígidas | R20/R25/R30... reforzadas indefinidamente |
| nivel limitado por tabla R1-R40 | R16+ sube +1 hasta nivel 60 |

---

# 96. Flujo completo de R1-R15

```text
ZombieIntro termina
↓
RunSequence("ZombieWaves_Main")
↓
30 minutos
↓
R1
↓
8 HordeSpawn
cada uno exactamente una vez
orden aleatorio
20 s entre apariciones
↓
cada unidad:
Player 12
SetLevel
SetFeeding(false)
SetNoAIFlag(true)
HW_Hspawn
HW_Rn
↓
esperar 5 s tras despliegue
↓
leer HW_OWNER1..8
↓
construir ZR_MASKn
↓
ZR_LAST_DEPLOYED_ROUND = n
↓
si R5 o R10:
    10 min
si no:
    2 min
↓
siguiente ronda
```

---

# 97. Flujo completo R16+

```text
w >= 16
↓
endlessGeneration += 1
↓
guardar:
ZR_ENDLESS_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK = 0
ZR_ENDLESS_PAIDMASK = 0
↓
composición base R16
↓
nivel = 20 + (w-16)
máximo 60
↓
si R20/R25/R30...:
    +10 Hastatus
    +10 Maceman
    por aparición
↓
16 apariciones
cada spawn exactamente 2 veces
20 s entre apariciones
↓
cada unidad:
HW_Hspawn
HW_R16
↓
NO esperar muerte de zombies anteriores
↓
esperar 5 s tras despliegue
↓
leer HW_OWNER1..8
↓
guardar:
ZR_ENDLESS_MASK
ZR_ENDLESS_DEPLOYED_GENERATION
↓
2 min
↓
R17 / R18 / R19 / ...
```

---

# 98. Flujo al sellar los cuatro portales

```text
ZombieEE_Portals_Main
↓
EE_ZOMBIE_SPAWNS_DISABLED = 1
↓
ZombieWaves lo detecta
↓
stopWaves = 1
↓
detener nuevas apariciones
↓
NO borrar zombies existentes
↓
ZombieTactical sigue activo
↓
ZWAVES_STOPPED_BY_PORTALS = 1
↓
CUATRO PORTALES SELLADOS - NO HABRA MAS HORDAS
↓
return
```

---

# 99. Resumen funcional

`ZombieWaves_Main` v2.0 puede resumirse así:

```text
esperar a que ZombieIntro la inicie
        ↓
30 minutos hasta R1
        ↓
HUD limpio con cuenta atrás
        ↓
R1-R15:
    8 apariciones
    1 por cada spawn
        ↓
R16+:
    16 apariciones
    2 por cada spawn
        ↓
20 segundos entre mini-hordas
        ↓
8 frentes tácticos HW_H1..8
        ↓
R1-R15 también → HW_R1..15
R16+           → HW_R16 agregado
        ↓
Tactical selecciona objetivos
        ↓
Waves recoge HW_OWNER1..8
        ↓
publica máscara de recompensa
        ↓
tras R5/R10 → 10 min
resto         → 2 min
        ↓
R16+ no espera zombies anteriores
        ↓
nivel +1 por ronda hasta 60
        ↓
R20/R25/R30... +20 por aparición
        ↓
continuar indefinidamente
        ↓
hasta que EE_ZOMBIE_SPAWNS_DISABLED = 1
```

La versión actual sustituye completamente la arquitectura antigua de 40 rondas y 48 hordas. El sistema estable utiliza ocho frentes persistentes, una fase clásica R1-R15 y una zona endless no bloqueante desde R16.

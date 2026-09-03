# Secuencia 6 — `ZombieRewards_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieRewards_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieRewards_Main` es la Sequence encargada de entregar las recompensas militares del modo Zombies.

La arquitectura actual ya **no** utiliza el sistema antiguo de:

```text
48 slots ZR_PENDING
+
40 rondas cerradas
```

La versión v2.0 separa el comportamiento en dos zonas:

```text
R1-R15
→ recompensa al aniquilar completamente la ronda

R16+
→ sistema infinito no bloqueante
→ recompensa al terminar de desplegarse cada nueva generación
```

Desde R16 las rondas normales pueden solaparse. Por ello `ZombieRewards_Main` no espera a que `HW_R16` quede vacío: ese Group puede contener simultáneamente unidades procedentes de R16, R17, R18, R19 y rondas posteriores.

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Nombre canónico

El nombre actual es:

```text
ZombieRewards_Main
```

No debe utilizarse ya como nombre canónico:

```text
ZombieRewards_Main_48H_40R
```

Ese nombre pertenece a una arquitectura anterior que utilizaba 48 slots de evento y 40 rondas predefinidas.

---

# 2. Preparación necesaria en el editor

La estructura es:

```text
Scenario
└── Map
    └── Sequences
        └── ZombieRewards_Main
```

Configuración:

```text
Autorun allowed = Sí
```

No necesita invocación manual mediante `RunSequence()`.

---

# 3. Group manual obligatorio

La Sequence necesita:

```text
CapitalForum_P1
```

Al arrancar:

```cpp
stateList = Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count != 1)
{
    UserNotification(
        "ZombieRewards_Main: FALLO - CapitalForum_P1",
        "",
        Point(0,0),
        1
    );

    return;
}
```

Por tanto el Group debe resolver exactamente a un objeto válido.

---

# 4. Función de `CapitalForum_P1`

El objeto contenido en `CapitalForum_P1` funciona como memoria global del modo Zombies.

Se convierte a:

```cpp
Building state;
```

mediante:

```cpp
state = stateList[0].AsBuilding();
```

Sobre él se almacenan variables como:

```text
ZR_LAST_DEPLOYED_ROUND

ZR_REWARDED1..15
ZR_MASK1..15
ZR_PAIDMASK1..15

ZR_ENDLESS_GENERATION
ZR_ENDLESS_DEPLOYED_GENERATION
ZR_ENDLESS_REWARDED_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
```

---

# 5. Validación continua del objeto de estado

La Sequence no valida `CapitalForum_P1` únicamente al inicio.

Dentro del bucle vuelve a ejecutar:

```cpp
stateList = Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count != 1)
    return;
```

También vuelve a validarlo antes de confirmar cada pago completo.

Si el Group deja de resolver exactamente a un objeto, `ZombieRewards_Main` termina mediante:

```cpp
return;
```

---

# 6. Frecuencia principal

La configuración actual es:

```cpp
CONTROL_INTERVAL = 2000;
```

El bucle principal ejecuta:

```cpp
while(1)
{
    Sleep(CONTROL_INTERVAL);
    ...
}
```

Por tanto la Sequence revisa el estado de recompensas aproximadamente:

```text
una vez cada 2 segundos
```

---

# 7. Dos modelos de recompensa

La variable:

```cpp
checkRound
```

recorre:

```cpp
for(checkRound = 1; checkRound <= 16; checkRound += 1)
```

Pero el valor 16 no representa únicamente R16.

La interpretación real es:

```text
checkRound 1..15
→ rondas históricas individuales

checkRound 16
→ canal del sistema infinito R16+
```

---

# 8. Rondas 1 a 15

Para:

```cpp
checkRound <= 15
```

la Sequence exige que la ronda ya haya sido desplegada:

```cpp
if(checkRound > lastDeployed)
    continue;
```

donde:

```cpp
lastDeployed =
    EnvReadInt(
        state,
        "ZR_LAST_DEPLOYED_ROUND"
    );
```

---

# 9. Persistencia de R1-R15

Cada ronda dispone de una clave:

```text
ZR_REWARDED1
ZR_REWARDED2
...
ZR_REWARDED15
```

La lectura está desenrollada explícitamente:

```cpp
if(checkRound==1)
    rewarded=EnvReadInt(state,"ZR_REWARDED1");

...

if(checkRound==15)
    rewarded=EnvReadInt(state,"ZR_REWARDED15");
```

Si:

```cpp
rewarded == 1
```

esa ronda no vuelve a procesarse.

---

# 10. Caché en memoria de R1-R15

Además existe:

```cpp
IntArray rewardedCache;
```

Antes de consultar de nuevo una ronda:

```cpp
if(rewardedCache[checkRound] == 1)
    continue;
```

Cuando la persistencia confirma que una ronda ya fue recompensada:

```cpp
rewardedCache[checkRound] = 1;
```

Esto reduce lecturas repetidas durante el resto de la partida.

---

# 11. Condición de aniquilación en R1-R15

Las quince primeras rondas sí dependen de que sus zombies hayan muerto.

La Sequence obtiene:

```cpp
roundUnits =
    Group(
        "HW_R" + checkRound
    )
    .GetObjList();

roundUnits.ClearDead();
```

y exige:

```cpp
if(roundUnits.count > 0)
    continue;
```

Por tanto:

```text
HW_Rn.count == 0
```

es la condición de aniquilación para R1-R15.

---

# 12. R1-R15 no bloquean el generador de oleadas

`ZombieRewards_Main` observa estos Groups de forma independiente.

Que una recompensa de R1-R15 todavía no se haya activado no obliga por sí mismo a `ZombieWaves_Main` a detener el calendario de rondas.

La detección y el pago funcionan como una capa paralela.

---

# 13. Máscara de jugadores elegibles

Cada ronda dispone de una máscara:

```text
ZR_MASK1
...
ZR_MASK15
```

La máscara representa qué Players fueron objetivos de los frentes de esa ronda.

El sistema utiliza estos pesos:

| Player | Peso |
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

# 14. Lectura de la máscara de R1-R15

El código utiliza lecturas explícitas:

```cpp
if(roundNow==1)
    mask=EnvReadInt(state,"ZR_MASK1");

...

if(roundNow==15)
    mask=EnvReadInt(state,"ZR_MASK15");
```

Después cada Player se comprueba mediante:

```cpp
eligible =
    (mask / weight) % 2;
```

Si:

```cpp
eligible != 1
```

ese Player no recibe recompensa.

---

# 15. `ZR_PAIDMASK`

Además de saber quién es elegible, la Sequence mantiene una máscara de pagos.

Para R1-R15:

```cpp
paidMask =
    EnvReadInt(
        state,
        "ZR_PAIDMASK" + roundNow
    );
```

Cuando un Player va a recibir su recompensa:

```cpp
paidMask += weight;

EnvWriteInt(
    state,
    "ZR_PAIDMASK" + roundNow,
    paidMask
);
```

---

# 16. Por qué existe `paidMask`

Una ronda puede haber atacado a varios jugadores distintos.

Ejemplo:

```text
ZR_MASK10 = Player 1 + Player 4 + Player 8
```

Los tres pueden recibir la recompensa de R10.

`paidMask` impide que un mismo Player cobre dos veces esa ronda aunque:

- varios frentes hayan señalado al mismo propietario;
- el controlador vuelva a revisar la ronda;
- la creación haya comenzado en un ciclo anterior.

---

# 17. La marca individual se escribe antes de `Place()`

Antes de crear tropas se ejecuta:

```cpp
paidMask += weight;
```

y se persiste inmediatamente.

El comentario del código lo explica:

```text
Marcar antes de Place():
si el motor interrumpe la Sequence
no se duplica un ejército ya iniciado
al volver a ejecutar.
```

El diseño prioriza:

```text
evitar duplicados
```

frente a:

```text
reintentar automáticamente una recompensa interrumpida
```

---

# 18. Respaldo si la máscara vale cero

Si:

```cpp
mask == 0
```

la Sequence no descarta automáticamente la recompensa.

Construye una máscara de respaldo recorriendo:

```cpp
for(owner = 1; owner <= 8; owner += 1)
```

y comprobando:

```cpp
forums =
    ClassPlayerObjs(
        "BaseTownhall",
        owner
    )
    .GetObjList();
```

Todo Player 1..8 que conserve al menos un `BaseTownhall` se incorpora a la máscara.

---

# 19. Consecuencia del respaldo

Si el sistema táctico no publicó correctamente los propietarios objetivo, la recompensa no se pierde.

En ese caso puede llegar a premiarse a:

```text
todos los Players 1..8
que todavía conserven algún Foro
```

La máscara reconstruida se vuelve a persistir.

Para R1-R15:

```cpp
EnvWriteInt(
    state,
    "ZR_MASK" + roundNow,
    mask
);
```

Para R16+:

```cpp
EnvWriteInt(
    state,
    "ZR_ENDLESS_MASK",
    mask
);
```

---

# 20. Quién recibe realmente una recompensa

Un Player debe cumplir:

```text
1. estar marcado en mask
2. no estar marcado todavía en paidMask
3. conservar al menos un BaseTownhall
```

No se mide:

- quién dio el último golpe;
- quién mató más zombies;
- quién tenía más tropas en la batalla.

La elegibilidad procede de la máscara preparada por el sistema de oleadas/táctica.

---

# 21. Destino actual de los refuerzos

La versión v2.0 ya no utiliza coordenadas `ZR_X` / `ZR_Y`.

Para cada Player elegible se obtiene:

```cpp
forums =
    ClassPlayerObjs(
        "BaseTownhall",
        owner
    )
    .GetObjList();

forums.ClearDead();
```

Si existe alguno:

```cpp
forum = forums[0].AsBuilding();
```

La recompensa se entrega al **primer `BaseTownhall` actual** devuelto para ese Player.

---

# 22. No se garantiza que sea la ciudad atacada

No existe una búsqueda por:

```text
coordenadas del objetivo
```

ni una comparación con:

```text
HW_TX / HW_TY
```

dentro de `ZombieRewards_Main`.

Si un Player posee varias ciudades, la recompensa se inserta en:

```cpp
forums[0]
```

Por tanto no debe documentarse como garantizado que aparezca exactamente en el Foro que defendió la horda.

---

# 23. Qué ocurre si un Player no conserva Foro

Antes de marcar su pago:

```cpp
if(forums.count <= 0)
    continue;
```

Ese Player no recibe tropas en ese momento.

Sin embargo el procesamiento global de la ronda puede terminar y quedar marcado como completado después de revisar a todos los Players.

---

# 24. Configuración de cada unidad de recompensa

Cada unidad se crea con:

```cpp
u =
    Place(
        cls,
        forum.pos,
        owner
    )
    .AsUnit();
```

Después:

```cpp
u.SetLevel(lv);
u.SetFeeding(true);
u.SetNoAIFlag(false);

forum
    .settlement
    .ForceAddUnit(u);
```

---

# 25. Las recompensas son tropas normales

La Sequence fuerza explícitamente:

```cpp
SetFeeding(true)
SetNoAIFlag(false)
```

Por tanto los refuerzos:

- utilizan alimentación normal;
- pueden ser gestionados normalmente por la IA;
- no quedan convertidos en guarniciones estructurales;
- pueden utilizarse ofensivamente;
- forman parte del ejército normal del propietario.

---

# 26. Las tropas se insertan en el Foro

Aunque `Place()` utiliza:

```cpp
forum.pos
```

después se ejecuta:

```cpp
forum.settlement.ForceAddUnit(u);
```

Por tanto el destino funcional es el Settlement del Foro.

La versión v2.0 no construye dos formaciones exteriores para estas recompensas.

---

# 27. Creación escalonada

Después de cada unidad:

```cpp
Sleep(20);
```

Esto reparte ligeramente la carga de creación.

Por ejemplo:

```text
28 unidades R16+
×
20 ms
=
560 ms
```

de espera programada acumulada por Player recompensado.

---

# 28. Tabla real de recompensas R1-R15

| Ronda | Nivel | Recompensa por Player elegible | Total |
|---:|---:|---|---:|
| 1 | 5 | 4 `RPraetorian` + 4 `BHighlander` | 8 |
| 2 | 5 | 4 `IEliteGuard` + 4 `CNoble` | 8 |
| 3 | 6 | 4 `RLiberatus` + 4 `EAnubisWarrior` | 8 |
| 4 | 6 | 4 `TValkyrie` + 4 `GTridentWarrior` | 8 |
| 5 | 8 | 6 `RPraetorian` + 5 `IEliteGuard` + 5 `BHighlander` | 16 |
| 6 | 8 | 5 `CNoble` + 5 `EAnubisWarrior` | 10 |
| 7 | 9 | 5 `RLiberatus` + 5 `TValkyrie` | 10 |
| 8 | 9 | 5 `GTridentWarrior` + 5 `BHighlander` | 10 |
| 9 | 10 | 5 `EHorusWarrior` + 5 `IEliteGuard` | 10 |
| 10 | 12 | 6 `RPraetorian` + 6 `RLiberatus` + 5 `TValkyrie` + 3 `CWarElephant` | 20 |
| 11 | 13 | 6 `CNoble` + 6 `EAnubisWarrior` | 12 |
| 12 | 14 | 6 `BHighlander` + 6 `GTridentWarrior` | 12 |
| 13 | 15 | 6 `IEliteGuard` + 6 `EHorusWarrior` | 12 |
| 14 | 16 | 6 `RLiberatus` + 6 `RPraetorian` | 12 |
| 15 | 18 | 8 `BHighlander` + 7 `EAnubisWarrior` + 7 `CNoble` + 6 `IEliteGuard` + 2 `CWarElephant` | 30 |

---

# 29. Recompensas especiales antes de R16

El código no utiliza una rama separada llamada `specialReward`, pero la tabla hace claramente mayores:

```text
R5
R10
R15
```

Estas rondas entregan:

```text
R5  → 16 unidades
R10 → 20 unidades
R15 → 30 unidades
```

frente a las recompensas normales más pequeñas de su entorno.

---

# 30. No hay héroes en R1-R15

La tabla actual de `ZombieRewards_Main` no genera héroes durante las primeras quince rondas.

Las clases utilizadas son tropas militares y, en algunas rondas especiales, `CWarElephant`.

---

# 31. Inicio del sistema infinito

La posición:

```cpp
checkRound == 16
```

activa:

```cpp
endlessMode = 1;
```

A partir de ahí ya no se utiliza la lógica de `HW_R16.count == 0`.

---

# 32. Variables del sistema infinito

Se leen:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_DEPLOYED_GENERATION
ZR_ENDLESS_REWARDED_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
```

Estas variables coordinan `ZombieWaves_Main` y `ZombieRewards_Main`.

---

# 33. `ZR_ENDLESS_GENERATION`

Cada nueva ronda R16+ incrementa una generación interna.

La generación permite reutilizar un conjunto finito de variables sin crear:

```text
ZR_REWARDED16
ZR_REWARDED17
ZR_REWARDED18
...
```

indefinidamente.

---

# 34. `ZR_ENDLESS_ROUND`

Guarda el número visible/lógico de ronda.

Ejemplo:

```text
generación endless 1 → R16
generación endless 2 → R17
generación endless 3 → R18
...
```

`ZombieRewards_Main` lee:

```cpp
roundNow =
    EnvReadInt(
        state,
        "ZR_ENDLESS_ROUND"
    );
```

y protege:

```cpp
if(roundNow < 16)
    roundNow = 16;
```

---

# 35. Condición de pago de R16+

La recompensa endless sólo continúa si:

```cpp
endlessGeneration > 0
```

y:

```cpp
endlessDeployed >= endlessGeneration
```

y:

```cpp
endlessRewarded < endlessGeneration
```

Por tanto una generación:

```text
debe existir
+
debe haber terminado de desplegarse
+
todavía no debe estar confirmada como recompensada
```

---

# 36. R16+ no espera la muerte de la horda

Este es uno de los cambios fundamentales de v2.0.

El código contiene expresamente:

```text
Desde R16 las generaciones pueden solaparse
y todas usan HW_R16.

Por tanto NO esperamos
a que ese grupo quede vacío.
```

La recompensa se activa cuando:

```text
la generación ha terminado de desplegarse
```

no cuando:

```text
todos sus zombies han muerto
```

---

# 37. Motivo del diseño no bloqueante

Desde R16:

```text
R16 puede seguir viva
mientras empieza R17

R16/R17 pueden seguir vivas
mientras empieza R18
```

Todas esas unidades pueden coexistir dentro de la arquitectura reutilizada de `HW_R16`.

Por tanto:

```text
HW_R16.count == 0
```

ya no puede identificar la muerte de una generación concreta.

---

# 38. Relación con `ZombieWaves_Main`

Antes de desplegar una nueva generación endless, `ZombieWaves_Main` prepara:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK = 0
ZR_ENDLESS_PAIDMASK = 0
```

Al terminar el despliegue escribe:

```text
ZR_ENDLESS_MASK
ZR_ENDLESS_DEPLOYED_GENERATION
```

`ZombieRewards_Main` consume ese estado y posteriormente confirma:

```text
ZR_ENDLESS_REWARDED_GENERATION
```

---

# 39. `ZR_ENDLESS_PAIDMASK`

Cada nueva generación empieza con:

```text
ZR_ENDLESS_PAIDMASK = 0
```

La Sequence va marcando los Players pagados exactamente igual que en R1-R15.

Así la misma infraestructura de bits se reutiliza en:

```text
R16
R17
R18
R19
...
```

sin crear variables nuevas ilimitadamente.

---

# 40. Recompensa fija R16+

Cada Player elegible recibe:

```text
5 RLiberatus
5 TValkyrie
4 GTridentWarrior
4 BHighlander
3 IEliteGuard
3 EHorusWarrior
2 EAnubisWarrior
2 CWarElephant
```

Total:

```text
28 unidades
```

Esta composición se utiliza para **todas** las rondas:

```text
R16
R17
R18
R19
R20
...
```

---

# 41. Nivel de R16+

El nivel se calcula:

```cpp
lv =
    20
    +
    (roundNow - 16);
```

Después:

```cpp
if(lv > 60)
    lv = 60;
```

---

# 42. Ejemplos de nivel endless

| Ronda | Nivel de recompensa | Unidades |
|---:|---:|---:|
| 16 | 20 | 28 |
| 17 | 21 | 28 |
| 18 | 22 | 28 |
| 19 | 23 | 28 |
| 20 | 24 | 28 |
| 25 | 29 | 28 |
| 30 | 34 | 28 |
| 40 | 44 | 28 |
| 50 | 54 | 28 |
| 56 | 60 | 28 |
| 57+ | 60 | 28 |

---

# 43. Las rondas reforzadas de Waves no cambian Rewards

`ZombieWaves_Main` puede reforzar ciertas rondas posteriores a R16, por ejemplo:

```text
R20
R25
R30
...
```

aumentando el número de zombies de la oleada.

`ZombieRewards_Main` **no aumenta su recompensa en esos múltiplos de 5**.

Desde R16 la recompensa mantiene:

```text
28 unidades
```

y la dificultad/recompensa escala mediante:

```text
nivel creciente
```

hasta el límite 60.

---

# 44. Notificación R1-R15

Para las rondas normales históricas se utiliza:

```text
HORDA ANIQUILADA - REFUERZOS RONDA X
```

La notificación se envía únicamente al:

```text
owner
```

que acaba de recibir las tropas.

---

# 45. Notificación R16+

En endless se utiliza:

```text
REFUERZOS RONDA X
```

No dice:

```text
HORDA ANIQUILADA
```

porque la recompensa ya no depende de que todos los zombies de esa ronda hayan muerto.

---

# 46. La notificación no es global

A diferencia de versiones antiguas que podían emitir el evento a todos los Players, v2.0 ejecuta:

```cpp
UserNotification(
    ...,
    forum.pos,
    owner
);
```

Por tanto el aviso se dirige al Player recompensado.

---

# 47. Confirmación final de R1-R15

Después de revisar todos los Players elegibles, la Sequence vuelve a validar `CapitalForum_P1`.

Después escribe:

```text
ZR_REWARDEDn = 1
```

para la ronda correspondiente.

Ejemplo:

```cpp
if(roundNow==10)
    EnvWriteInt(
        state,
        "ZR_REWARDED10",
        1
    );
```

Finalmente:

```cpp
rewardedCache[roundNow] = 1;
```

---

# 48. Confirmación final de R16+

En modo endless:

```cpp
EnvWriteInt(
    state,
    "ZR_ENDLESS_REWARDED_GENERATION",
    endlessGeneration
);
```

Eso confirma que esa generación ya ha sido procesada.

La siguiente generación podrá utilizar de nuevo:

```text
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
```

con valores reinicializados por `ZombieWaves_Main`.

---

# 49. Diferencia fundamental R15 → R16

Hasta R15:

```text
ronda desplegada
↓
HW_Rn llega a 0
↓
recompensa
```

Desde R16:

```text
nueva generación endless
↓
termina su despliegue
↓
recompensa
↓
los zombies pueden seguir vivos
↓
las siguientes rondas continúan
```

---

# 50. No existen ya `ZR_PENDING1..48`

La versión canónica v2.0 no utiliza como arquitectura principal:

```text
ZR_PENDING1..48
ZR_OWNER1..48
ZR_ROUND1..48
ZR_X1..48
ZR_Y1..48
```

Toda la documentación antigua basada en esos 48 canales debe considerarse obsoleta para `ZombieRewards_Main`.

---

# 51. No existen ya 40 configuraciones cerradas

La Sequence tampoco limita las recompensas a:

```text
R1-R40
```

El sistema actual es:

```text
R1-R15 → tabla fija individual
R16+   → composición endless + nivel creciente
```

No existe un máximo de número de ronda en esta Sequence.

---

# 52. Máximo de nivel, no de ronda

La única limitación explícita es:

```text
lv <= 60
```

La ronda puede continuar:

```text
R61
R100
R250
...
```

si el sistema de oleadas sigue generándolas.

La recompensa permanece en nivel 60 una vez alcanzado ese límite.

---

# 53. Qué sucede si varias rondas R1-R15 quedan aniquiladas a la vez

El bucle recorre:

```text
checkRound = 1..16
```

Por tanto puede procesar varias recompensas pendientes durante una misma pasada.

El orden será:

```text
R1
R2
...
R15
canal endless
```

si varias cumplen simultáneamente sus condiciones.

---

# 54. Qué sucede si varios Players son elegibles en una misma ronda

La Sequence recorre:

```cpp
for(owner = 1; owner <= 8; owner += 1)
```

Cada Player cuyo bit esté activo recibe **su propia copia completa** de la recompensa.

Ejemplo:

```text
R10
mask = P1 + P4
```

produce:

```text
Player 1 → 20 unidades nivel 12
Player 4 → 20 unidades nivel 12
```

No se divide una recompensa total entre los Players.

---

# 55. Coste de creación si hay varios receptores

La creación se escalona con:

```cpp
Sleep(20);
```

Por ejemplo, una generación endless con cuatro Players elegibles implica:

```text
4 × 28 = 112 unidades
```

y aproximadamente:

```text
112 × 20 ms
=
2.240 ms
```

de espera programada acumulada, además del coste de `Place()` y `ForceAddUnit()`.

---

# 56. El Foro se vuelve a buscar durante la creación

Antes del pago se comprueba que el Player tenga algún `BaseTownhall`.

Además, dentro del bucle de cada unidad se vuelve a ejecutar:

```cpp
forums =
    ClassPlayerObjs(
        "BaseTownhall",
        owner
    )
    .GetObjList();

forums.ClearDead();
```

Así el código vuelve a validar que el propietario conserve un Foro mientras se está generando la recompensa.

---

# 57. Si el Player pierde todos sus Foros durante el spawn

Si durante la creación:

```cpp
forums.count <= 0
```

se fuerza la salida del bloque mediante:

```cpp
i = n;
t = 11;
continue;
```

La creación para ese Player se detiene.

Como su bit de `paidMask` ya fue escrito antes de `Place()`, esa recompensa individual no se reintentará automáticamente.

---

# 58. No se aplica `SetFood()`

El código no asigna una cantidad explícita mediante:

```cpp
SetFood(...)
```

Sólo establece:

```cpp
SetFeeding(true);
```

Las tropas quedan sujetas al comportamiento normal de alimentación del juego.

---

# 59. No hay Group de recompensa

Las unidades creadas no se añaden a un Group específico de recompensa.

Después de `ForceAddUnit()` dejan de ser rastreadas por esta Sequence.

No existe regeneración de refuerzos muertos.

---

# 60. `ZombieRewards_Main` no controla las hordas

La Sequence no:

- crea zombies;
- decide spawns;
- mueve hordas;
- busca Gates;
- controla catapultas;
- reduce loyalty;
- cierra portales;
- decide el calendario de oleadas.

Su responsabilidad es exclusivamente:

```text
detectar que existe una recompensa válida
+
crear refuerzos
+
marcarla como pagada
```

---

# 61. Dependencia con `ZombieWaves_Main`

`ZombieWaves_Main` proporciona:

```text
ZR_LAST_DEPLOYED_ROUND
ZR_MASK1..15

ZR_ENDLESS_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
ZR_ENDLESS_DEPLOYED_GENERATION
```

Sin ese estado, `ZombieRewards_Main` no puede determinar correctamente qué ronda/generación está disponible.

---

# 62. Dependencia con la capa táctica

La máscara de elegibilidad refleja los Players objetivo asociados a los frentes de la ronda.

Si esa información no queda publicada correctamente, entra en funcionamiento el respaldo:

```text
mask == 0
→ todos los Players con BaseTownhall
```

Por tanto la Sequence incluye tolerancia ante ausencia de propietarios objetivo.

---

# 63. No depende del Easter Egg para funcionar

`ZombieRewards_Main` no consulta directamente flags como:

```text
EE_PORTALS_ENABLED
EE_SACRIFICE_ENABLED
EE_FINAL_ASSAULT_ENABLED
```

Su sincronización con el Easter Egg depende de lo que haga el sistema de oleadas con el calendario y las máscaras.

---

# 64. Seguridad contra duplicados

La protección tiene varias capas:

```text
R1-R15
├── rewardedCache
├── ZR_REWARDEDn
└── ZR_PAIDMASKn

R16+
├── ZR_ENDLESS_REWARDED_GENERATION
└── ZR_ENDLESS_PAIDMASK
```

Además cada bit de `paidMask` se escribe antes de iniciar el `Place()` de ese Player.

---

# 65. Flujo completo de R1-R15

```text
ZombieWaves despliega Rn
        ↓
ZR_LAST_DEPLOYED_ROUND >= n
        ↓
ZombieRewards revisa cada 2 s
        ↓
¿ZR_REWARDEDn == 1?
        ├── Sí → ignorar
        └── No
             ↓
        ¿HW_Rn tiene zombies vivos?
        ├── Sí → esperar
        └── No
             ↓
        leer ZR_MASKn
             ↓
        si mask==0:
            construir respaldo
             ↓
        para Player 1..8:
            ¿bit elegible?
            ¿no pagado?
            ¿tiene BaseTownhall?
             ↓
        marcar bit en ZR_PAIDMASKn
             ↓
        crear recompensa en forums[0]
             ↓
        UserNotification al propietario
             ↓
        ZR_REWARDEDn = 1
        rewardedCache[n] = 1
```

---

# 66. Flujo completo de R16+

```text
ZombieWaves prepara nueva generación
        ↓
incrementa ZR_ENDLESS_GENERATION
        ↓
guarda ZR_ENDLESS_ROUND
        ↓
resetea:
ZR_ENDLESS_MASK = 0
ZR_ENDLESS_PAIDMASK = 0
        ↓
despliega la ronda
        ↓
publica ZR_ENDLESS_MASK
        ↓
publica ZR_ENDLESS_DEPLOYED_GENERATION
        ↓
ZombieRewards revisa cada 2 s
        ↓
¿generación válida?
¿ya desplegada?
¿aún no recompensada?
        ↓
NO consulta si HW_R16 está vacío
        ↓
leer roundNow / mask / paidMask
        ↓
pagar Players elegibles
        ↓
28 tropas por Player
nivel = 20 + (ronda - 16)
máximo nivel 60
        ↓
ZR_ENDLESS_REWARDED_GENERATION = generación
```

---

# 67. Diferencias respecto a la documentación antigua `48H_40R`

| Sistema antiguo | v2.0 |
|---|---|
| `ZombieRewards_Main_48H_40R` | `ZombieRewards_Main` |
| 48 slots `ZR_PENDING` | Máscaras por ronda + canal endless |
| R1-R40 fijas | R1-R15 + R16+ infinito |
| Cada evento lleva owner/round/x/y | Owner se obtiene desde masks |
| Coordenadas del Foro guardadas | Se usa `forums[0]` actual |
| Spawn en formaciones exteriores | Spawn en `forum.pos` + `ForceAddUnit()` |
| Revisión cada 250 ms | Revisión cada 2.000 ms |
| Notificación global | Notificación al Player recompensado |
| R16 era una ronda concreta | R16 abre el sistema endless |
| Recompensa condicionada a evento pendiente | R1-R15 por aniquilación; R16+ por despliegue |

---

# 68. Preparación exacta en el editor

```text
Map
├── Sequences
│   └── ZombieRewards_Main
│       ├── código v2.0
│       ├── Compile
│       └── Autorun allowed = Sí
│
└── Groups
    └── CapitalForum_P1
        └── exactamente 1 Building
```

---

# 69. Groups adicionales

`ZombieRewards_Main` no requiere manualmente:

```text
CapitalForum_P2..P8
ZR_PENDING groups
Reward groups
Areas
Holders auxiliares
marcadores de spawn
```

Sí depende de Groups dinámicos de ronda creados por el sistema Zombies:

```text
HW_R1..HW_R15
```

para detectar la aniquilación de las primeras quince rondas.

---

# 70. Resumen funcional

```text
CapitalForum_P1 = memoria global
        ↓
ZombieRewards_Main AUTORUN
        ↓
revisar cada 2 segundos

R1-R15:
    esperar despliegue
    esperar HW_Rn == 0
    leer mask de defensores
    pagar una vez a cada Player elegible
    marcar ZR_REWARDEDn

R16+:
    leer generación endless
    esperar únicamente a que termine el despliegue
    NO esperar a que HW_R16 quede vacío
    leer mask de defensores
    pagar una vez a cada Player elegible
    28 tropas
    nivel creciente hasta 60
    marcar generación como recompensada

en ambos modelos:
    si mask == 0
        usar Players que todavía tengan Foro
    marcar paidMask antes de Place()
    crear en el primer BaseTownhall actual
    SetFeeding(true)
    SetNoAIFlag(false)
    ForceAddUnit()
    Sleep(20)
```

`ZombieRewards_Main` es la capa de entrega de refuerzos del modo Zombies v2.0. Conserva la lógica clásica de aniquilación para R1-R15 y adopta un modelo infinito no bloqueante desde R16 para permitir que las rondas sigan avanzando aunque permanezcan zombies de oleadas anteriores.

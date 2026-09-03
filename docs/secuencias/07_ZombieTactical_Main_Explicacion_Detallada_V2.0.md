# Secuencia 7 — `ZombieTactical_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieTactical_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieTactical_Main` es el controlador táctico central de las hordas del modo Zombies.

La Sequence no crea las oleadas y tampoco entrega directamente las recompensas. Su responsabilidad es controlar de forma permanente los **8 frentes globales** creados por `ZombieWaves_Main`:

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
```

Cada frente puede recibir refuerzos de varias rondas distintas. Esto es especialmente importante desde R16, porque las rondas pueden solaparse y los zombies de una oleada anterior pueden seguir vivos mientras comienzan R17, R18, R19 y posteriores.

La Sequence combina cuatro capas:

```text
1. ruteo territorial por la red canónica de 18 nodos;
2. selección de objetivos intermedios y finales;
3. máquina táctica de marcha / asedio / brecha / captura;
4. publicación de HW_OWNER para el sistema de recompensas.
```

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Nombre canónico

El nombre actual es:

```text
ZombieTactical_Main
```

No debe utilizarse como nombre canónico:

```text
ZombieTactical_Main_v10_5_WALL_STUCK_GATE
```

ni otros nombres históricos de pruebas.

La versión v2.0 incorpora la lógica territorial por nodos y trabaja únicamente con 8 frentes persistentes.

---

# 2. Preparación en el editor

La estructura es:

```text
Scenario
└── Map
    └── Sequences
        └── ZombieTactical_Main
```

Configuración:

```text
Autorun allowed = Sí
```

No necesita ser iniciada mediante `RunSequence()`.

---

# 3. Group obligatorio de estado

La Sequence utiliza:

```text
CapitalForum_P1
```

Al arrancar:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();

if(stateList.count != 1)
{
    return;
}
```

El único objeto se convierte a:

```cpp
Building state;
```

mediante:

```cpp
state = stateList[0].AsBuilding();
```

---

# 4. `CapitalForum_P1` como memoria global

El `Building state` contiene el estado compartido con el sistema de oleadas.

Entre las variables relevantes están:

```text
HW_ACTIVE1..8
HW_TX1..8
HW_TY1..8
HW_OWNER1..8
```

`ZombieTactical_Main` no utiliza ya el antiguo protocolo:

```text
ZR_PENDING1..32
ZR_OWNER1..32
ZR_ROUND1..32
ZR_X1..32
ZR_Y1..32
```

La entrega de recompensas está desacoplada y se basa en las máscaras que construye `ZombieWaves_Main`.

---

# 5. Validación continua del objeto de estado

Dentro del bucle principal se mantiene la referencia:

```cpp
stateList.ClearDead();

if(stateList.count != 1)
{
    return;
}
```

Si `CapitalForum_P1` deja de resolver correctamente, la Sequence termina.

---

# 6. Player técnico de los zombies

El código define:

```cpp
HP = 12;
```

Por tanto:

```text
Player 12 = jugador técnico de la horda
```

Cuando un Foro termina siendo capturado por los zombies se ejecuta:

```cpp
target.settlement.SetPlayer(HP);
```

---

# 7. Número actual de frentes

La versión v2.0 trabaja con:

```cpp
for(H = 1; H <= 8; H += 1)
```

Por tanto existen exactamente:

```text
8 frentes tácticos persistentes
```

No existen ya 32 slots tácticos independientes.

---

# 8. Groups de frente

Cada frente usa uno de estos Groups:

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
```

`ZombieTactical_Main` no crea las unidades.

`ZombieWaves_Main`:

```text
genera zombies
↓
los añade al HW_H correspondiente
↓
activa HW_ACTIVEH
```

y Tactical se limita a controlarlos.

---

# 9. Los Groups son persistentes entre rondas

Un mismo frente puede recibir unidades de diferentes rondas.

Ejemplo:

```text
R16 añade zombies a HW_H3
↓
algunos sobreviven
↓
R17 vuelve a utilizar el mismo frente
↓
los nuevos zombies se añaden a HW_H3
```

Tactical no necesita saber a qué ronda individual pertenece cada miembro para moverlo.

---

# 10. Frecuencia principal

El controlador ejecuta:

```cpp
while(1)
{
    Sleep(1000);
    ...
}
```

Por tanto el estado táctico se revisa aproximadamente:

```text
una vez por segundo
```

---

# 11. Optimización cuando no existe ningún frente activo

Antes de reconstruir toda la información territorial se leen:

```text
HW_ACTIVE1..8
```

y se almacenan en:

```cpp
frontActive[H]
```

Si ninguno vale 1:

```cpp
if(anyActive == 0)
```

la Sequence evita realizar el resto del procesamiento pesado.

---

# 12. `idleReset`

Cuando no hay ningún frente activo, el estado interno se reinicia una sola vez mediante:

```cpp
idleReset
```

Se limpian para los ocho frentes:

```text
phase
marchTicks
phaseTicks
gateX
gateY
siegeHadHolder
lastGateHealth
siegeNoProgress
lastForumDist
captureStuck
marchLastDist
marchStuck
breachKnown
forumAccess
anchorNode
targetNode
goalNode
goalOwner
```

Después:

```text
idleReset = 1
```

impide repetir el mismo reinicio cada segundo.

Cuando vuelve a aparecer un frente:

```text
idleReset = 0
```

y Tactical recupera el trabajo normal.

---

# 13. Qué ocurre si un frente activo queda vacío

Después de:

```cpp
h.ClearDead();
```

se comprueba:

```cpp
if(h.count == 0)
```

En ese caso se limpia todo el estado táctico del frente y se escribe:

```text
HW_ACTIVEH = 0
```

No se genera directamente ninguna recompensa desde Tactical.

---

# 14. Diferencia respecto a versiones antiguas de recompensas

La documentación antigua describía:

```text
h.count == 0
↓
Tactical calcula el propietario
↓
escribe ZR_PENDINGH
↓
Rewards crea las tropas
```

Ese protocolo ya no forma parte de la arquitectura v2.0.

Actualmente:

```text
ZombieTactical_Main
→ mantiene HW_OWNER1..8

ZombieWaves_Main
→ al terminar el despliegue construye ZR_MASK / ZR_ENDLESS_MASK

ZombieRewards_Main
→ decide cuándo pagar
```

---

# 15. Townhalls que Tactical tiene en cuenta

Cuando existe al menos un frente activo se construye `allTownhalls`.

Incluye:

```text
Players 1..8 → ciudades jugables
Player 12    → ciudades ya capturadas por zombies
Player 15    → ciudades neutrales
Player 16    → ciudades neutrales
```

La consulta utiliza:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    player
)
```

---

# 16. Por qué se incluyen Player 12, 15 y 16

Los Players 1..8 representan objetivos finales válidos.

Player 12 se incluye para que el sistema territorial pueda reconocer:

```text
nodos ya conquistados por la horda
```

y atravesarlos sin volver a tratarlos como objetivos.

Players 15 y 16 permiten utilizar:

```text
ciudades neutrales intermedias
```

como escalones de una ruta.

---

# 17. Red territorial canónica de 18 nodos

La Sequence contiene una red fija de:

```text
18 nodos
```

con la correspondencia:

```text
1..9   = O1..O9
10..18 = N1..N9
```

Cada nodo tiene:

```text
nodeX
nodeY
```

y la conectividad se almacena mediante:

```cpp
edgeW
```

---

# 18. Coordenadas de los 18 nodos

La versión v2.0 utiliza estas coordenadas internas:

| ID interno | Nodo | X | Y |
|---:|---|---:|---:|
| 1 | O1 | 1025 | 1194 |
| 2 | O2 | 5402 | 6055 |
| 3 | O3 | 19341 | 866 |
| 4 | O4 | 32078 | 768 |
| 5 | O5 | 4917 | 15186 |
| 6 | O6 | 15909 | 20339 |
| 7 | O7 | 30471 | 16345 |
| 8 | O8 | 1520 | 29988 |
| 9 | O9 | 24914 | 28688 |
| 10 | N1 | 13045 | 4167 |
| 11 | N2 | 10381 | 12235 |
| 12 | N3 | 16257 | 11878 |
| 13 | N4 | 22080 | 15882 |
| 14 | N5 | 27220 | 7738 |
| 15 | N6 | 7367 | 21975 |
| 16 | N7 | 13502 | 27298 |
| 17 | N8 | 20444 | 24333 |
| 18 | N9 | 30433 | 24340 |

Estas coordenadas pertenecen al mapa actual.

La Sequence no pretende ser reutilizable directamente en otro mapa sin modificar esta red.

---

# 19. `edgeW`

La conectividad territorial se codifica mediante índices:

```cpp
edgeW[uNode * 20 + v]
```

Cada conexión dispone de un peso.

El ruteo usa esos pesos para calcular la distancia territorial acumulada, no únicamente la distancia geométrica directa entre la horda y un Foro.

---

# 20. Asociación dinámica Townhall → nodo

En cada ciclo activo se reinician:

```text
nodeOwner[node] = 0
nodeHasForum[node] = 0
```

Después cada `BaseTownhall` existente se asigna al nodo más cercano.

La comparación utiliza:

```text
|forum.x - nodeX|
+
|forum.y - nodeY|
```

Es decir, una distancia Manhattan aproximada para identificar a qué nodo pertenece el Building.

---

# 21. Estado territorial por nodo

Una vez asociado un Foro:

```cpp
nodeOwner[forumNode] = cand.player;
nodeHasForum[forumNode] = 1;
```

De esta forma la red conoce en cada ciclo qué nodo:

```text
tiene ciudad
```

y quién la controla.

---

# 22. Variables territoriales por frente

Cada frente conserva:

```text
anchorNode
targetNode
goalNode
goalOwner
```

## `anchorNode`

Nodo territorial desde el que se considera que parte el frente.

## `targetNode`

Nodo del Foro que está atacando actualmente.

## `goalNode`

Objetivo estratégico final de la ruta.

## `goalOwner`

Player 1..8 que representa el objetivo final cuya defensa cuenta para la máscara de recompensa.

---

# 23. Recuperación de un objetivo ya existente

Cada frente puede conservar:

```text
HW_TXH
HW_TYH
```

Si no son cero, Tactical intenta localizar exactamente ese Townhall por coordenadas.

Cuando lo encuentra:

```text
target = cand
```

y vuelve a calcular qué nodo de la red corresponde a ese Foro.

---

# 24. Qué ocurre si el target ya pertenece a Player 12

Si el target existente ha sido conquistado por la horda:

```text
target.player == HP
```

se invalida.

El nodo puede convertirse en nueva:

```text
anchorNode
```

y se limpian:

```text
targetNode
goalNode
goalOwner
phase
gate state
HW_TX
HW_TY
```

Después se busca otro objetivo.

---

# 25. Selección de `anchorNode`

Si un frente todavía no tiene ancla:

```cpp
if(anchorNode[H] <= 0)
```

se busca el nodo más cercano a:

```cpp
h[0].AsUnit().pos
```

El primer zombie del frente sirve como referencia inicial de posición.

---

# 26. Algoritmo de ruta

La Sequence utiliza arrays:

```text
routeDist
routePrev
routeUsed
routePath
```

junto a:

```text
INF = 1000000000
```

para calcular la ruta de menor coste sobre la red de 18 nodos.

La estructura implementa conceptualmente un algoritmo tipo Dijkstra.

---

# 27. Prioridad de objetivo estratégico

El sistema busca primero:

```text
un nodo con Foro de Player 1..8
```

alcanzable con la menor distancia de ruta.

Si no existe ninguno, puede seleccionar:

```text
un Foro neutral de Player 15/16
```

---

# 28. Player 12 no es objetivo

Los nodos cuya ciudad ya pertenece a:

```text
Player 12
```

se consideran territorio ya tomado por la horda.

No son elegidos como objetivo final.

Pueden quedar dentro de la ruta y ser atravesados.

---

# 29. Ciudad neutral en medio del camino

Una ruta hacia una ciudad de Player 1..8 puede pasar por un nodo neutral.

Al reconstruir el camino, Tactical busca el primer nodo intermedio que:

```text
contenga un Foro
```

y cuyo propietario no sea:

```text
Player 12
ni 0
```

Ese Foro intermedio se convierte en:

```text
nextTargetNode
```

Por tanto los zombies pueden conquistar una ciudad neutral de paso antes de continuar hacia el objetivo final.

---

# 30. `goalOwner` y los neutrales intermedios

Aunque el objetivo táctico inmediato sea un Foro neutral, el sistema intenta conservar como:

```text
goalOwner
```

el Player 1..8 situado al final de la ruta.

Esto es importante para el sistema de recompensas.

Ejemplo:

```text
frente
→ neutral N7
→ ciudad de Player 8
```

Mientras el frente está atacando N7:

```text
HW_OWNERH
```

puede representar al Player 8 como objetivo estratégico final.

---

# 31. Publicación de `HW_OWNERH`

Después de seleccionar un target se escriben:

```text
HW_TXH
HW_TYH
HW_OWNERH
```

`HW_TX/HW_TY` describen el objetivo táctico actual.

`HW_OWNERH` describe principalmente al propietario final perseguido cuando existe un objetivo Player 1..8.

---

# 32. Uso de `HW_OWNER` por Waves

Al terminar de desplegar una ronda, `ZombieWaves_Main` consulta:

```text
HW_OWNER1..8
```

y construye la máscara de Players que fueron objetivo de los frentes.

Por tanto Tactical participa indirectamente en la selección de quién puede recibir refuerzos.

---

# 33. Fallback si la red no resuelve target

Si el ruteo por nodos no produce un objetivo válido, Tactical dispone de un fallback.

Primero busca:

```text
el BaseTownhall de Player 1..8
más cercano geométricamente a h[0]
```

Si tampoco existe, prueba con:

```text
Player 15 / 16
```

---

# 34. La red territorial no sustituye al pathfinding del motor

El grafo decide:

```text
qué ciudad atacar a continuación
```

pero no genera una ruta física detallada punto a punto.

Una vez seleccionado el `target`, el movimiento real sigue dependiendo de:

```text
SetCommand("advance", ...)
pathfinding del motor
detección de Gate
Siege()
```

---

# 35. Las cuatro fases tácticas

Cada frente usa:

```text
phase[H] = 0 → MARCHA
phase[H] = 1 → SIEGE
phase[H] = 2 → BREACH_ADVANCE
phase[H] = 3 → CAPTURE
```

---

# 36. Acceso directo al Foro

Antes de la lógica específica de fases, Tactical comprueba si algún zombie está a:

```text
<= 850
```

del Foro.

Si existe acceso real:

```cpp
forumAccess[H] = 1;
```

y el frente puede pasar directamente a:

```text
PHASE 3
```

Esto evita seguir buscando Gates cuando la horda ya ha conseguido entrar físicamente.

---

# 37. PHASE 0 — MARCHA

La fase 0 intenta mantener al frente avanzando hacia el Foro actual.

El sistema no ordena constantemente a todas las unidades.

Se utilizan temporizadores y el estado de:

```cpp
u.command
```

para reducir la reimposición de órdenes.

---

# 38. Muestreo de progreso

Durante la marcha se utiliza una muestra de la horda.

La versión v2.0 calcula periódicamente:

```text
nearestD
```

como la distancia de las muestras más cercanas al Foro.

---

# 39. Detección de atasco

Cada aproximadamente 3 segundos se compara:

```text
nearestD actual
```

con:

```text
marchLastDist
```

Se considera progreso claro cuando:

```cpp
nearestD + 100 < marchLastDist[H]
```

Es decir, el frente se ha acercado al menos unas 100 unidades.

---

# 40. `marchStuck`

Si no existe progreso suficiente:

```cpp
marchStuck[H] += 1;
```

Cuando:

```cpp
marchStuck[H] >= 4
```

se activa:

```text
stuckMarch
```

Como la medición se produce cada ~3 segundos:

```text
~12 segundos sin progreso claro
```

activan una búsqueda de Gate.

---

# 41. Búsqueda de Gate en marcha

Cuando existe atasco real, Tactical muestrea:

```cpp
for(j = 0; j < h.count; j += 4)
```

y busca:

```cpp
ObjsInRange(
    u,
    "Building",
    2200
)
```

---

# 42. Filtros de Gate

La Gate candidata debe cumplir:

```cpp
q[i].IsHeirOf("Gate")
```

```cpp
q[i].player == target.player
```

```cpp
q[i].health > 1000
```

y:

```cpp
cand.DistTo(target)
<
u.DistTo(target)
```

La última condición exige que la Gate esté por delante del zombie respecto al Foro.

---

# 43. Gate cerrada frente a Gate superada

La lógica utiliza:

```text
health > 1000
→ Gate todavía bloqueante

health <= 1000
→ Gate considerada superada/transitable
```

No espera a que el Building desaparezca físicamente.

---

# 44. Selección de Gate

Entre las candidatas válidas se prioriza la que queda más cerca de las muestras de la horda.

Cuando existe una candidata:

```text
ga = 1
```

se inicia el asedio.

---

# 45. Número de máquinas solicitado

El cálculo es:

```cpp
nCat = h.count / 15;

if(nCat <= 0)
    nCat = 1;

if(nCat > 4)
    nCat = 4;
```

El rango final es:

```text
1 a 4
```

---

# 46. Inicio del asedio

Se guardan:

```text
gateX[H]
gateY[H]
lastGateHealth[H]
siegeHadHolder[H]
siegeNoProgress[H]
```

y se ejecuta:

```cpp
h.Siege(
    gate,
    nCat,
    4
);
```

Después:

```text
phase = 1
```

---

# 47. Marcha normal cuando no existe Gate útil

Si el detector de atasco no encuentra Gate:

```text
no inventa una puerta
```

La Sequence vuelve a ordenar avance hacia puntos próximos al Foro y reinicia el detector de atasco.

---

# 48. Refresco de marcha

`marchTicks` se incrementa cada segundo.

Cuando llega a:

```text
4
```

se revisan las unidades que no estén `InHolder()`.

Una unidad puede recibir un nuevo `advance` si:

```text
está idle
```

o:

```text
está en capture
```

o si está muy lejos del Foro y no está ya:

```text
advance
attack
engage
```

---

# 49. Rescate de rezagados

La condición de distancia utilizada en la marcha incluye:

```text
d > 4500
```

Esto permite recuperar zombies que hayan quedado muy lejos del objetivo cuando llegan refuerzos a un frente que ya se encuentra avanzado tácticamente.

---

# 50. Combates encontrados durante la ruta

La lógica de movimiento evita reescribir constantemente unidades que están en:

```text
attack
engage
```

Por tanto el objetivo estratégico sigue siendo el Foro, pero las tropas pueden combatir enemigos encontrados durante el trayecto sin que Tactical cancele el combate cada segundo.

---

# 51. PHASE 1 — SIEGE

La fase de asedio vuelve a localizar la Gate guardada mediante:

```text
gateX
gateY
```

La búsqueda se realiza alrededor del Foro:

```cpp
ObjsInRange(
    target,
    "Building",
    7000
)
```

y exige coincidencia exacta de coordenadas.

---

# 52. Gate desaparecida o abierta

La transición ocurre cuando:

```cpp
ga == 0
||
gate.health <= 1000
```

Entonces:

```text
breachKnown = 1
phase = 2
phaseTicks = 0
```

---

# 53. Vigilancia del asedio

Mientras la Gate siga cerrada, cada ~2 segundos se evalúa:

```text
si existe alguna unidad InHolder()
si la Gate ha perdido health
```

`InHolder()` se utiliza como señal de que la máquina de asedio / tripulación está activa.

---

# 54. `siegeHadHolder`

Cuando alguna unidad cumple:

```cpp
u.InHolder()
```

se guarda:

```text
siegeHadHolder = 1
```

Esto permite distinguir entre:

```text
el asedio nunca llegó a crear máquina
```

y:

```text
existió máquina pero desapareció
```

---

# 55. Reintento de asedio

Si nunca apareció holder:

```text
~12 segundos sin progreso
```

provocan un nuevo:

```cpp
h.Siege(...)
```

Si anteriormente existió holder pero ya no existe:

```text
~4 segundos sin progreso
```

son suficientes para relanzar el asedio.

---

# 56. Acercamiento de rezagados durante SIEGE

Cada ~3 segundos se recorren las unidades que no están `InHolder()`.

Si una está a más de:

```text
3000
```

de la Gate recibe:

```cpp
advance → gate.pos
```

Esto intenta concentrar al frente alrededor del punto de asedio.

---

# 57. PHASE 2 — BREACH_ADVANCE

Cuando una Gate se considera superada:

```text
breachKnown = 1
```

la fase 2 calcula un punto situado aproximadamente 650 unidades hacia el interior, en dirección al Foro.

---

# 58. Cálculo del punto interior

Partiendo de:

```text
Gate = gx, gy
Foro = target.pos
```

se calcula:

```text
insideX
insideY
```

desplazado hacia el Foro.

La intención es atravesar físicamente la abertura antes de cambiar a captura.

---

# 59. Primeros segundos de la brecha

Durante los dos primeros ticks:

```text
phaseTicks <= 2
```

no se emiten nuevas órdenes masivas.

Esto deja tiempo al motor para actualizar el estado de la Gate y la formación.

---

# 60. Órdenes sobre la propia Gate

En:

```text
phaseTicks == 3
phaseTicks == 5
```

las unidades que no están `InHolder()` reciben puntos muy próximos a:

```text
gx, gy
```

para converger sobre la abertura.

---

# 61. Órdenes al interior

Desde:

```text
phaseTicks >= 6
```

en ticks pares, los zombies disponibles reciben `advance` hacia pequeñas variaciones alrededor de:

```text
insideX
insideY
```

Esto reparte ligeramente la horda y evita mandar a todas las unidades a una coordenada idéntica.

---

# 62. Cómo determina que la brecha ha sido cruzada

Se compara la distancia Manhattan de cada zombie al Foro con la distancia Gate → Foro.

Si:

```text
unitForumDist + 180 < gateForumDist
```

esa unidad se considera situada claramente al otro lado de la Gate.

Se acumulan:

```text
crossedCount
movableCount
```

---

# 63. Condición normal de salida de BREACH_ADVANCE

A partir de 6 segundos:

```cpp
crossedCount * 3 >= movableCount
```

equivale a aproximadamente:

```text
un tercio de las unidades móviles
ha cruzado la línea de la Gate
```

Entonces:

```text
phase = 3
```

---

# 64. Límite máximo de BREACH_ADVANCE

Si no se cumple la proporción anterior:

```text
phaseTicks >= 24
```

fuerza el paso a CAPTURE.

Por tanto la fase de brecha no puede mantener al frente indefinidamente.

---

# 65. Caso sin `breachKnown`

El código conserva una rama de seguridad:

```cpp
if(breachKnown[H] != 1)
```

En ese caso, después de unos 8 segundos se pasa igualmente a:

```text
CAPTURE
```

---

# 66. PHASE 3 — CAPTURE

La fase 3 tiene prioridad sobre el Foro.

Combina:

```text
avance de rezagados
órdenes capture
reducción determinista de loyalty
detección de una posible segunda Gate
```

---

# 67. Reducción de loyalty

Cada ~2 segundos se cuentan zombies situados a:

```text
<= 850
```

del Foro.

La cuenta se detiene cuando llega a 10:

```cpp
j < h.count && zombiesIn < 10
```

---

# 68. Caída máxima por tick

Se utiliza:

```cpp
drop = zombiesIn;

if(drop > 10)
    drop = 10;

if(drop < 1)
    drop = 1;
```

Por tanto:

```text
1 zombie cerca  → -1
5 zombies       → -5
10+ zombies     → -10
```

aproximadamente cada 2 segundos.

---

# 69. Captura final

Cuando:

```cpp
actualLoyalty <= 1
```

se ejecuta:

```cpp
target.settlement.SetLoyalty(1);
target.settlement.SetPlayer(HP);
target.settlement.SetLoyalty(11);
```

El Foro pasa inmediatamente a:

```text
Player 12
```

---

# 70. Actualización del ancla tras conquistar

Si existe:

```text
targetNode[H] > 0
```

se ejecuta:

```text
anchorNode = targetNode
```

El frente considera ese nodo como nueva posición territorial de referencia.

Después se limpian:

```text
targetNode
goalNode
goalOwner
HW_TX
HW_TY
HW_OWNER
```

y la máquina vuelve a MARCHA.

---

# 71. Orden `capture`

Durante CAPTURE, para zombies suficientemente próximos:

```cpp
if(u.command == "idle")
{
    u.SetCommand(
        "capture",
        target
    );
}
```

Las unidades lejanas reciben `advance`.

---

# 72. Rescate de unidades muy lejanas en CAPTURE

Si:

```text
d > 3500
```

la Sequence puede volver a enviar un `advance` hacia un punto próximo al Foro.

Esto permite que refuerzos que entran tarde al Group compartido no queden detenidos mientras el frente ya está en fase de captura.

---

# 73. Distancia intermedia de 1200

Cuando una unidad no está suficientemente cerca para capturar y tampoco está ya ejecutando:

```text
advance
attack
engage
```

si:

```text
d > 1200
```

puede recibir un:

```text
advance → target.pos
```

---

# 74. Detector de atasco en CAPTURE

Cada ~3 segundos se mide:

```text
nearestD
```

de una muestra de zombies.

Se considera progreso si:

```cpp
nearestD + 80 < lastForumDist[H]
```

En caso contrario:

```text
captureStuck += 1
```

---

# 75. Acceso confirmado al Foro

Si:

```text
nearestD <= 900
```

se establece:

```text
forumAccess = 1
captureStuck = 0
```

Cuando ya existe acceso al Foro no se busca una Gate alternativa sólo porque algunas unidades estén atascadas.

---

# 76. Segunda Gate durante CAPTURE

La búsqueda de una segunda Gate sólo se permite cuando:

```text
forumAccess == 0
phaseTicks >= 15
captureStuck >= 5
nearestD > 1200
```

y coincide con el tick de medición.

Por tanto se necesita un atasco prolongado antes de abandonar temporalmente la prioridad del Foro.

---

# 77. Búsqueda local de segunda Gate

Se muestrea aproximadamente:

```text
1 de cada 4 zombies
```

y se buscan Buildings en:

```text
radio 1800
```

alrededor de cada muestra.

La candidata debe cumplir:

```text
Gate
mismo propietario que el Foro
health > 1000
situada por delante respecto al objetivo
```

---

# 78. Segunda Gate encontrada

Si aparece una candidata válida:

```text
nCat = 1..4
```

se guarda la nueva Gate y vuelve a:

```text
PHASE 1 — SIEGE
```

Esto permite superar ciudades con más de un anillo defensivo.

---

# 79. Segunda Gate no encontrada

Si no aparece una Gate útil:

```text
captureStuck = 0
lastForumDist = nearestD
```

y el Foro permanece como objetivo.

La Sequence no obliga al frente a recorrer la ciudad buscando puertas lejanas de manera indefinida.

---

# 80. La Gate debe estar por delante

Tanto en la búsqueda desde MARCHA como en la búsqueda de segunda Gate se utiliza una condición equivalente a:

```cpp
cand.DistTo(target)
<
u.DistTo(target)
```

La intención es evitar mandar a los zombies hacia una Gate que haya quedado detrás de ellos.

---

# 81. Estado `forumAccess`

`forumAccess[H]` representa evidencia de que el frente tiene acceso físico al Foro.

Puede activarse porque:

```text
un zombie alcanza <=850
```

o durante CAPTURE cuando:

```text
nearestD <=900
```

Una vez existe acceso, las Gates dejan de tener prioridad salvo que el estado se reinicie por cambio de objetivo.

---

# 82. Estado `breachKnown`

`breachKnown[H]` indica que Tactical ha detectado una Gate superada y puede ejecutar la lógica especial de cruce.

Se activa en:

```text
ga == 0
o
gate.health <= 1000
```

durante SIEGE.

---

# 83. `InHolder()` como exclusión general

Muchas órdenes se protegen mediante:

```cpp
if(!u.InHolder())
```

Esto impide enviar órdenes normales de movimiento a unidades que en ese instante forman parte de una máquina de asedio.

---

# 84. Limitación conocida: tripulación que puede quedar en la catapulta

La versión estable v2.0 mantiene una limitación conocida.

Cuando una Gate pasa a:

```text
health <= 1000
```

Tactical ejecuta:

```text
phase 1
→ phase 2
```

pero no existe en el código canónico una llamada explícita y validada que saque inmediatamente a todas las unidades que sigan:

```cpp
u.InHolder() == true
```

de la catapulta.

Además PHASE 2 sólo da órdenes a:

```cpp
!u.InHolder()
```

Por tanto una tripulación que el motor no libere automáticamente puede permanecer asociada al holder.

Este comportamiento queda documentado como **limitación conocida de la versión estable**, ya que los intentos de forzar la salida mediante una orden adicional se retiraron durante la estabilización por riesgo de crash.

---

# 85. Efecto de la limitación desde R16+

Esta limitación ya no bloquea el calendario de oleadas R16+.

`ZombieWaves_Main` v2.0 no espera a que los zombies de rondas anteriores mueran antes de lanzar la siguiente ronda.

Por tanto:

```text
un zombie atrapado
```

puede seguir siendo una unidad residual del frente, pero no impide por sí mismo:

```text
R17
R18
R19
...
```

---

# 86. Tactical y las rondas infinitas

`ZombieTactical_Main` no contiene un límite de:

```text
16 rondas
```

ni necesita conocer el contador `w`.

Tactical sólo ve:

```text
8 frentes activos
+
unidades acumuladas dentro de esos Groups
```

Por ello funciona igualmente en:

```text
R1
R16
R17
R30
R100
...
```

---

# 87. Qué pasa si llegan refuerzos a un frente ya en CAPTURE

Los nuevos zombies se añaden al mismo `HW_H`.

Como la fase se conserva, pueden encontrarse lejos del Foro mientras el frente principal ya está capturando.

Las condiciones:

```text
d > 3500
d > 4500
```

y los refrescos periódicos están precisamente destinados a rescatar estos rezagados.

---

# 88. Qué pasa si una horda conquista una ciudad y conserva supervivientes

Después de convertir el Foro a Player 12:

```text
anchorNode = nodo conquistado
phase = 0
objetivo actual = limpiado
```

En el siguiente ciclo se calcula otra ruta.

Los supervivientes continúan atacando otra ciudad.

---

# 89. Prioridad estratégica de ciudades jugables

El ruteo intenta alcanzar primero una ciudad de:

```text
Player 1..8
```

Los neutrales son objetivos secundarios o intermedios.

Esto evita que la horda prefiera sistemáticamente limpiar todo el territorio neutral mientras siguen existiendo jugadores vivos.

---

# 90. Fallback geométrico

Si la red de nodos no encuentra una ruta utilizable, el fallback impide que el frente quede sin objetivo por una incoherencia puntual del modelo territorial.

La prioridad del fallback es:

```text
1. BaseTownhall Player 1..8 más cercano
2. BaseTownhall neutral Player 15/16 más cercano
```

---

# 91. No se utilizan Groups manuales de nodos

Los 18 nodos están codificados directamente mediante:

```text
nodeX
nodeY
edgeW
```

No hace falta crear en el editor:

```text
O1
O2
N1
N2
...
```

como Groups para Tactical.

---

# 92. No se utilizan Groups manuales de Gates

Las Gates se localizan dinámicamente mediante:

```cpp
ObjsInRange(...)
```

y:

```cpp
IsHeirOf("Gate")
```

No hace falta crear:

```text
Gate_01
Gate_02
...
```

---

# 93. No se utilizan Areas de ciudad

No existe una Area específica por Foro.

Los radios importantes se calculan desde:

```text
target
Gate
unidad
```

mediante `DistTo()` y `ObjsInRange()`.

---

# 94. No se utiliza `RunAIHelper`

La lógica de asedio está implementada directamente mediante:

```cpp
h.Siege(...)
```

junto a la máquina de estados propia.

No se delega el asalto completo en:

```text
RunAIHelper("siege")
```

---

# 95. No se crean catapultas manualmente mediante `Place()`

Tactical no ejecuta:

```text
Place("BCatapultUnit", ...)
```

para la mecánica actual.

La creación/uso de la máquina queda delegada a:

```cpp
ObjList.Siege(...)
```

---

# 96. Captura manual de loyalty

La toma del Foro no espera únicamente a la mecánica nativa de `capture`.

Tactical reduce directamente:

```text
target.settlement.loyalty
```

según el número de zombies próximos.

Esto hace la captura determinista una vez el frente ha penetrado físicamente.

---

# 97. Máximo de reducción de loyalty

La reducción está limitada a:

```text
10 puntos por tick
```

aunque haya cientos de zombies alrededor del Foro.

Esto evita una captura instantánea causada por una horda enorme.

---

# 98. Comunicación con el sistema de recompensas

Tactical no paga recompensas.

Su contribución principal es publicar:

```text
HW_OWNER1..8
```

`ZombieWaves_Main` transforma esos propietarios en una máscara por ronda.

Después `ZombieRewards_Main` entrega los refuerzos.

---

# 99. Cadena v2.0 completa

```text
ZombieWaves_Main
        ↓
crea unidades
        ↓
las añade a HW_H1..8
        ↓
HW_ACTIVEH = 1
        ↓
ZombieTactical_Main
        ↓
selecciona ruta / objetivo
        ↓
publica HW_OWNERH
        ↓
marcha / Gate / Siege / captura
        ↓
ZombieWaves termina el despliegue
        ↓
construye ZR_MASK / ZR_ENDLESS_MASK desde HW_OWNER1..8
        ↓
ZombieRewards_Main
        ↓
entrega recompensas según la ronda/generación
```

---

# 100. Diferencias principales respecto a `v10_5_WALL_STUCK_GATE`

| Documentación antigua | v2.0 |
|---|---|
| 32 slots tácticos | 8 frentes persistentes |
| `HW_H1..HW_H32` | `HW_H1..HW_H8` |
| Target por Foro más cercano | Ruteo por red canónica de 18 nodos |
| Sólo Players 1..8 en objetivos | P1..8 + P12 + neutrales 15/16 en modelo territorial |
| Tactical genera `ZR_PENDING` | Tactical ya no entrega eventos directos de reward |
| Reward por muerte de cada horda-slot | Rewards usa máscaras de ronda / generación |
| Sin concepto de ancla territorial | `anchorNode`, `targetNode`, `goalNode`, `goalOwner` |
| 32 máquinas de estado posibles | 8 máquinas de estado persistentes |
| Rondas concebidas como hordas separadas | varias rondas pueden reforzar el mismo frente |
| R16 no tenía arquitectura endless integrada | Tactical es agnóstico al número de ronda y soporta R16+ sin cambios |

---

# 101. Parámetros tácticos principales

| Función | Valor actual |
|---|---:|
| Bucle táctico | 1.000 ms |
| Número de frentes | 8 |
| Red territorial | 18 nodos |
| Player zombie | 12 |
| Progreso mínimo de marcha | 100 |
| Medición de progreso | ~3 s |
| Atasco para buscar Gate | ~12 s |
| Búsqueda local de Gate en MARCHA | radio 2200 |
| Gate cerrada | `health > 1000` |
| Gate superada | `health <= 1000` |
| Máquinas solicitadas | 1..4 |
| Seguimiento de Siege | ~2 s |
| Reintento si nunca hubo Holder | ~12 s |
| Reintento tras perder Holder | ~4 s |
| Acercar rezagados a Gate | >3000 |
| Punto interior tras Gate | ~650 hacia el Foro |
| Cruce suficiente | ~1/3 de unidades móviles |
| Timeout de brecha | ~24 s |
| Radio efectivo de loyalty | 850 |
| Loyalty máxima por tick | 10 |
| Intervalo de loyalty | ~2 s |
| Progreso mínimo en CAPTURE | 80 |
| Foro considerado accesible | ≤900 |
| Búsqueda de segunda Gate | tras atasco prolongado |
| Segunda Gate: radio local | 1800 |
| Rescate de rezagados en CAPTURE | >3500 |
| Rescate lejano en MARCHA | >4500 |

---

# 102. Groups necesarios

## Obligatorio manual

```text
CapitalForum_P1
```

Debe contener exactamente un `Building`.

## Groups usados por el sistema

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
```

Son Groups dinámicos/persistentes rellenados por `ZombieWaves_Main`.

---

# 103. Elementos que no hay que crear

No son necesarios manualmente:

```text
32 Groups de horda
Groups de Gates
Groups de targets
Groups de nodos
Areas de ciudad
marcadores de brecha
puntos de asedio
rutas editoriales
Groups de catapultas
```

---

# 104. Dependencias funcionales

La arquitectura normal es:

```text
ZombieIntro_Main
→ inicia ZombieWaves_Main

ZombieWaves_Main
→ crea y refuerza HW_H1..8

ZombieTactical_Main
→ controla los ocho frentes

ZombieRewards_Main
→ entrega recompensas

ZombieEE_Portals_Main
→ puede detener la creación de nuevas oleadas
```

Tactical puede continuar controlando zombies ya existentes aunque `ZombieWaves_Main` deje de generar nuevos.

---

# 105. Comportamiento al sellar los portales

Cuando el Easter Egg detiene nuevas oleadas:

```text
ZombieWaves_Main deja de crear zombies
```

pero las unidades ya existentes permanecen en:

```text
HW_H1..8
```

`ZombieTactical_Main` continúa ejecutándose y las sigue llevando hacia ciudades hasta que mueren o conquistan objetivos.

---

# 106. Preparación exacta en el editor

```text
Map
├── Groups
│   └── CapitalForum_P1
│       └── exactamente 1 Building
│
└── Sequences
    ├── ZombieWaves_Main
    │   └── AUTORUN = NO
    │
    └── ZombieTactical_Main
        ├── código v2.0
        ├── Compile
        └── Autorun allowed = Sí
```

`ZombieWaves_Main` es iniciado por `ZombieIntro_Main`.

Tactical permanece autorun porque debe estar preparado antes de que empiece la primera ronda.

---

# 107. Flujo completo de un frente

```text
HW_ACTIVEH = 1
        ↓
leer HW_HH
        ↓
ClearDead()
        ↓
¿h.count == 0?
        ├── Sí
        │    ↓
        │   HW_ACTIVEH = 0
        │   limpiar estado
        │
        └── No
             ↓
        recuperar / elegir target
             ↓
        si no existe target:
            anchorNode
            Dijkstra sobre 18 nodos
            objetivo Player 1..8
            neutral intermedio si procede
            fallback geométrico
             ↓
        guardar:
            HW_TX
            HW_TY
            HW_OWNER
             ↓
        PHASE 0 — MARCHA
             ↓
        detectar atasco
             ↓
        buscar Gate local
             ↓
        si Gate:
            PHASE 1 — SIEGE
             ↓
        Gate <=1000
             ↓
        PHASE 2 — BREACH_ADVANCE
             ↓
        atravesar abertura
             ↓
        PHASE 3 — CAPTURE
             ↓
        reducir loyalty
             ↓
        si existe otra Gate bloqueante:
            volver a SIEGE
             ↓
        Foro → Player 12
             ↓
        anchorNode = nodo conquistado
             ↓
        limpiar objetivo
             ↓
        volver a MARCHA
             ↓
        seleccionar siguiente ciudad
```

---

# 108. Flujo de rondas solapadas

```text
frente HW_H4 está atacando una ciudad
        ↓
R16 termina de desplegarse
        ↓
siguen vivos zombies
        ↓
2 minutos
        ↓
R17 genera nuevos zombies
        ↓
parte de R17 se añade también a HW_H4
        ↓
Tactical no crea una segunda IA para esa ronda
        ↓
los nuevos zombies heredan el frente global
        ↓
las reglas de rezagados los llevan al objetivo actual
```

Esta arquitectura reduce el número de Groups y estados que crecerían indefinidamente durante un modo endless.

---

# 109. Limitaciones conocidas de v2.0

1. **Tripulación de catapulta:** una unidad puede permanecer `InHolder()` después de que la Gate baje a `<=1000` si el motor no la libera automáticamente.
2. **El ruteo es específico del mapa:** las coordenadas y pesos de los 18 nodos están codificados directamente.
3. **Los objetivos físicos dependen del pathfinding del motor:** la red decide el orden territorial, pero no garantiza una ruta física libre de obstáculos.
4. **La captura usa loyalty manual:** el balance depende de los radios y límites establecidos por la Sequence.
5. **Un frente mezcla generaciones:** Tactical no distingue qué zombie concreto pertenece a R16, R17 o R18 una vez están en el mismo `HW_H`.

---

# 110. Resumen funcional

`ZombieTactical_Main` v2.0 puede resumirse así:

```text
esperar frentes HW_H1..8
        ↓
si no hay ninguno activo:
    no ejecutar el procesamiento territorial pesado
        ↓
si hay frentes:
    reconstruir Townhalls y estado de 18 nodos
        ↓
para cada frente activo:
    limpiar muertos
    mantener target si sigue válido
    o calcular ruta territorial
        ↓
guardar objetivo táctico y propietario final
        ↓
marchar hacia el Foro
        ↓
si no progresa:
    buscar Gate útil
        ↓
Siege con 1..4 máquinas
        ↓
vigilar Holder + health
        ↓
Gate <=1000
        ↓
hacer cruzar la brecha
        ↓
capturar Foro
        ↓
reducir loyalty según zombies cercanos
        ↓
si aparece segunda muralla real:
    repetir Siege
        ↓
SetPlayer(12)
        ↓
usar el nodo conquistado como nueva ancla
        ↓
buscar siguiente ciudad
```

La Sequence es completamente independiente del número global de ronda: desde su punto de vista existen ocho frentes persistentes que reciben nuevas unidades a lo largo de toda la partida. Esa arquitectura permite que el modo Zombies continúe indefinidamente después de R16 sin crear una máquina táctica nueva por cada ronda.

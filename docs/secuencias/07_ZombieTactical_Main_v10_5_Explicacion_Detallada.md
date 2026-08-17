# Secuencia 7 — `ZombieTactical_Main_v10_5_WALL_STUCK_GATE`

`ZombieTactical_Main_v10_5_WALL_STUCK_GATE` es la Sequence que controla la **IA táctica de las hordas del modo Zombies** una vez que las unidades ya han sido creadas por el sistema de oleadas.

Su responsabilidad principal es mantener a cada horda orientada hacia un Foro enemigo, detectar cuándo la marcha queda bloqueada por una muralla, localizar una `Gate`, iniciar y vigilar el asedio, hacer avanzar a las tropas a través de la brecha y, finalmente, capturar el Foro mediante una reducción controlada de `loyalty`.

La Sequence también detecta cuándo una horda ha sido completamente destruida. En ese momento prepara el evento que consumirá `ZombieRewards_Main_48H_40R`, indicando:

- qué jugador debe recibir la recompensa;
- qué ronda correspondía a la horda;
- qué Foro estaba siendo defendido;
- las coordenadas de ese Foro.

La versión documentada implementa cuatro fases tácticas:

```text
PHASE 0 → MARCHA
PHASE 1 → SIEGE
PHASE 2 → BREACH_ADVANCE
PHASE 3 → CAPTURE
```

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Preparación necesaria en el editor

Hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── ZombieTactical_Main_v10_5_WALL_STUCK_GATE
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

Esta Sequence pertenece al sistema Zombies y **no funciona de forma autónoma**. Necesita que la Sequence encargada de crear las oleadas mantenga los Groups y estados `HW_*` que aquí se consumen.

---

# 2. Group manual obligatorio: `CapitalForum_P1`

Al arrancar se ejecuta:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después se exige:

```cpp
if(stateList.count != 1)
{
    return;
}
```

Por tanto:

```text
CapitalForum_P1
```

debe resolver exactamente a **un objeto**.

Ese objeto se convierte a:

```cpp
Building state;
```

mediante:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 3. Función real de `CapitalForum_P1`

En esta Sequence el objeto contenido en `CapitalForum_P1` funciona como **memoria global del modo Zombies**.

Sobre él se almacenan y consultan variables como:

```text
HW_ACTIVE1..32
HW_TX1..32
HW_TY1..32
HW_OWNER1..32
HW_ROUND1..32
HW_REWARDED1..32

ZR_OWNER1..32
ZR_ROUND1..32
ZR_X1..32
ZR_Y1..32
ZR_PENDING1..32
```

Por tanto el Building utilizado como `state` debe permanecer válido durante toda la partida.

---

# 4. Qué ocurre si `CapitalForum_P1` no está correctamente configurado

En esta Sequence no se muestra un mensaje de error.

Simplemente:

```cpp
if(stateList.count != 1)
{
    return;
}
```

La Sequence termina.

Por tanto, si `CapitalForum_P1`:

```text
no existe
```

o contiene:

```text
0 objetos
```

o:

```text
2 o más objetos
```

la IA táctica Zombies no llegará a arrancar.

---

# 5. Groups de horda utilizados

La Sequence consulta literalmente estos 32 Groups:

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
HW_H9
HW_H10
HW_H11
HW_H12
HW_H13
HW_H14
HW_H15
HW_H16
HW_H17
HW_H18
HW_H19
HW_H20
HW_H21
HW_H22
HW_H23
HW_H24
HW_H25
HW_H26
HW_H27
HW_H28
HW_H29
HW_H30
HW_H31
HW_H32
```

Para cada slot:

```cpp
h =
    Group("HW_H...")
    .GetObjList();
```

---

# 6. Quién debe llenar `HW_H1..HW_H32`

Esta Sequence **no añade unidades** a esos Groups.

No contiene:

```cpp
AddToGroup("HW_H...")
```

Su función es exclusivamente leerlos.

Por tanto los Groups `HW_H1..HW_H32` deben ser creados o poblados por la Sequence responsable de las oleadas.

En el sistema completo la relación esperada es:

```text
ZombieWaves_Main
↓
crea las unidades de una horda
↓
las registra en HW_Hx
↓
HW_ACTIVEx = 1
↓
ZombieTactical_Main
↓
controla tácticamente ese Group
```

Si la Sequence de oleadas ya crea dinámicamente y rellena esos Groups, no hay que introducir unidades manualmente en ellos desde el editor.

Lo importante es que ambas Sequences utilicen exactamente los mismos nombres.

---

# 7. No hacen falta Groups para Gates

Las puertas no se preparan manualmente.

La Sequence las busca mediante consultas espaciales:

```cpp
ObjsInRange(
    u,
    "Building",
    1600
)
```

o:

```cpp
ObjsInRange(
    target,
    "Building",
    7000
)
```

y después filtra:

```cpp
IsHeirOf("Gate")
```

Por tanto no hay que crear:

```text
Gate_01
Gate_02
...
```

ni Groups de puertas.

---

# 8. No hacen falta Groups para los Foros objetivo

Los Foros actuales de los jugadores se descubren automáticamente.

Cada segundo se reconstruye:

```cpp
allTownhalls.Clear();

for(pp = 1; pp <= 8; pp += 1)
{
    allTownhalls.AddList(
        ClassPlayerObjs(
            "BaseTownhall",
            pp
        )
        .GetObjList()
    );
}
```

Por tanto se incluyen todos los `BaseTownhall` que actualmente pertenezcan a Players 1..8.

No hace falta registrar individualmente cada ciudad en un Group.

---

# 9. No hacen falta Areas, Holders ni marcadores de brecha

La Sequence no utiliza Areas manuales.

Tampoco necesita:

- Groups de Gates;
- puntos de asedio;
- puntos de brecha;
- marcadores alrededor de las murallas;
- Areas de ciudad.

Todo se calcula dinámicamente mediante:

```text
posición de la horda
posición del Foro
posición de las Gates
DistTo()
ObjsInRange()
```

---

# 10. Player técnico de la horda

Al inicio se define:

```cpp
HP = 12;
```

Ese valor se utiliza en la captura final:

```cpp
target
    .settlement
    .SetPlayer(HP);
```

Por tanto:

```text
Player 12
```

es el jugador técnico al que pasan los Foros capturados por los zombies.

---

# 11. Número de hordas tácticas simultáneas

La Sequence controla:

```cpp
for(H = 1; H <= 32; H += 1)
```

Por tanto dispone de:

```text
32 slots tácticos
```

Cada slot mantiene su propio:

- Group;
- objetivo;
- fase;
- temporizadores;
- estado de asedio;
- estado de atasco;
- ronda;
- recompensa.

---

# 12. Diferencia con `ZombieRewards_Main_48H_40R`

`ZombieRewards_Main_48H_40R` puede consumir:

```text
48 slots ZR_PENDING
```

pero esta Sequence táctica sólo controla:

```text
H = 1..32
```

y por tanto sólo escribe eventos de recompensa:

```text
ZR_PENDING1..ZR_PENDING32
```

Desde esta Sequence no se generan los slots:

```text
33..48
```

Esos slots quedan disponibles para otras partes del sistema o para una ampliación futura.

---

# 13. IntArrays internos

La Sequence declara varios `IntArray`:

```cpp
IntArray phase;
IntArray marchTicks;
IntArray phaseTicks;
IntArray gateX;
IntArray gateY;
IntArray siegeHadHolder;
IntArray lastGateHealth;
IntArray siegeNoProgress;
IntArray lastForumDist;
IntArray captureStuck;
IntArray marchLastDist;
IntArray marchStuck;
```

No son Groups ni objetos que haya que crear en el editor.

Son estructuras internas utilizadas para mantener un estado distinto para cada índice `H`.

---

# 14. Estado táctico por horda

Cada horda dispone de su propia información.

Conceptualmente:

```text
Horda 1
├── phase[1]
├── gateX[1]
├── gateY[1]
├── siegeNoProgress[1]
├── marchStuck[1]
└── ...

Horda 2
├── phase[2]
├── gateX[2]
├── gateY[2]
├── siegeNoProgress[2]
├── marchStuck[2]
└── ...
```

Esto permite que varias hordas estén simultáneamente en estados distintos.

Ejemplo:

```text
HW_H3  → MARCHA
HW_H8  → SIEGE
HW_H12 → CAPTURE
HW_H19 → BREACH_ADVANCE
```

---

# 15. Frecuencia principal de la IA

El bucle ejecuta:

```cpp
while(1)
{
    Sleep(1000);
    ...
}
```

Por tanto el controlador táctico revisa las hordas aproximadamente:

```text
1 vez por segundo
```

Los contadores `phaseTicks`, `marchTicks`, etc. están construidos alrededor de ese intervalo.

---

# 16. Descubrimiento dinámico de todas las ciudades actuales

Cada segundo se reconstruye `allTownhalls`.

Esto es importante porque el mapa territorial puede cambiar.

La consulta incluye:

```text
Player 1
...
Player 8
```

pero no Player 12.

Por tanto un Foro capturado por la horda desaparece automáticamente de `allTownhalls`.

---

# 17. Consecuencia de capturar una ciudad

Cuando un Foro pasa a:

```text
Player 12
```

ya no aparece en:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    1..8
)
```

En el siguiente ciclo esa ciudad deja de ser un objetivo válido.

La horda debe buscar otro Foro.

---

# 18. Variable `HW_ACTIVEH`

Cada slot tiene:

```text
HW_ACTIVE1
...
HW_ACTIVE32
```

La Sequence las lee de forma explícita.

Ejemplo:

```cpp
if(H == 7)
    active =
        EnvReadInt(
            state,
            "HW_ACTIVE7"
        );
```

Si:

```text
active != 1
```

la horda se considera inactiva.

---

# 19. Qué ocurre con un slot inactivo

Cuando:

```cpp
active != 1
```

se reinicia todo su estado táctico:

```text
phase = 0
marchTicks = 4
phaseTicks = 0
gateX = 0
gateY = 0
siegeHadHolder = 0
lastGateHealth = 0
siegeNoProgress = 0
lastForumDist = 0
captureStuck = 0
marchLastDist = 0
marchStuck = 0
```

y se pasa al siguiente slot.

---

# 20. Por qué `marchTicks` se reinicia a 4

En la fase de marcha:

```cpp
marchTicks[H] += 1;

if(marchTicks[H] >= 5)
```

se refresca la orden hacia el Foro.

Al dejarlo en:

```text
4
```

cuando una horda vuelve a activarse, el siguiente ciclo lo lleva a 5 y la orden de marcha se emite rápidamente.

---

# 21. Recuperación del Group de la horda

Cuando el slot está activo se obtiene:

```cpp
h =
    Group("HW_Hx")
    .GetObjList();

h.ClearDead();
```

`ClearDead()` elimina referencias a zombies muertos.

El valor:

```text
h.count
```

representa así el número de unidades vivas que siguen registradas en la horda.

---

# 22. Detección de horda destruida

La condición es:

```cpp
if(h.count == 0)
```

Ese es el criterio de aniquilación.

No depende de:

- que el Foro haya sido capturado;
- que un héroe haya muerto;
- que se pierda un porcentaje de la horda.

La horda está destruida cuando su Group queda vacío después de `ClearDead()`.

---

# 23. Recuperación del último objetivo cuando muere una horda

Si la horda queda vacía, la Sequence lee:

```text
HW_TXH
HW_TYH
```

Estas variables contienen las coordenadas del Foro objetivo asignado a ese slot.

Después intenta encontrar ese Building dentro de `allTownhalls`.

---

# 24. Búsqueda exacta del Foro objetivo

La comprobación es:

```cpp
if(
    cand.pos.x == tx
    &&
    cand.pos.y == ty
)
```

Por tanto el objetivo se identifica mediante coincidencia exacta de coordenadas.

No se utiliza una búsqueda por distancia.

---

# 25. Condición para entregar recompensa por destruir una horda

La recompensa sólo se prepara si se cumple:

```cpp
foundTarget == 1
&&
target.player >= 1
&&
target.player <= 8
&&
rr == 0
```

donde `rr` contiene inicialmente:

```text
HW_REWARDEDH
```

Por tanto deben cumplirse simultáneamente:

1. el Foro objetivo todavía existe entre los Townhall de Players 1..8;
2. sigue perteneciendo a un jugador normal;
3. ese slot todavía no ha generado su recompensa.

---

# 26. Quién recibe la recompensa

Cuando la horda muere:

```cpp
owner = target.player;
```

Por tanto el premio corresponde al **propietario actual del Foro que estaba siendo atacado**.

Esta Sequence no calcula:

- quién mató al último zombie;
- qué jugador hizo más daño;
- qué ejército estaba más cerca.

El criterio real es:

```text
propietario actual del objetivo defendido
```

---

# 27. Comunicación con `ZombieRewards_Main_48H_40R`

Cuando corresponde entregar recompensa, esta Sequence escribe:

```text
ZR_OWNERH
ZR_ROUNDH
ZR_XH
ZR_YH
ZR_PENDINGH = 1
```

Después:

```text
ZombieRewards_Main_48H_40R
```

detecta ese `ZR_PENDINGH` y crea físicamente las unidades.

---

# 28. Qué datos se transfieren

## `ZR_OWNERH`

Jugador que recibirá los refuerzos.

## `ZR_ROUNDH`

Ronda asociada a la horda destruida.

El valor se obtiene de:

```text
HW_ROUNDH
```

## `ZR_XH` y `ZR_YH`

Coordenadas exactas del Foro defendido.

## `ZR_PENDINGH`

Se pone a:

```text
1
```

para indicar que existe un evento pendiente.

---

# 29. `HW_REWARDEDH`

Después de preparar el evento se escribe:

```text
HW_REWARDEDH = 1
```

Esto impide que la misma horda vuelva a generar otra recompensa.

---

# 30. Cierre del slot después de la destrucción

Al terminar el procesamiento de una horda destruida se reinicia su estado táctico y además se escribe:

```text
HW_ACTIVEH = 0
```

El slot deja de estar activo.

La Sequence de oleadas podrá reutilizarlo posteriormente si su diseño lo permite.

---

# 31. Recuperación del objetivo durante una horda activa

Si todavía hay zombies, la Sequence vuelve a leer:

```text
HW_TXH
HW_TYH
```

e intenta localizar el Foro.

Si lo encuentra, mantiene ese objetivo.

Si no lo encuentra, busca uno nuevo.

---

# 32. Por qué un objetivo puede dejar de encontrarse

Un Foro puede desaparecer de `allTownhalls` porque:

- fue conquistado por Player 12;
- cambió a un propietario fuera de 1..8;
- dejó de ser un objeto válido.

En ese caso:

```text
foundTarget = 0
```

y se activa la búsqueda de un objetivo nuevo.

---

# 33. Selección automática de un nuevo objetivo

Cuando no existe objetivo válido, la Sequence calcula:

```cpp
d =
    cand
    .DistTo(
        h[0]
        .AsUnit()
    );
```

para todos los Townhall de Players 1..8.

Selecciona el de menor distancia.

Por tanto el criterio es:

```text
Foro geométricamente más cercano a h[0]
```

---

# 34. La selección no comprueba accesibilidad

La decisión utiliza exclusivamente:

```cpp
DistTo()
```

No existe en esta Sequence una consulta de:

- camino disponible;
- región conectada;
- agua;
- murallas intermedias;
- ruta real.

Por tanto:

```text
más cercano geométricamente
```

no significa necesariamente:

```text
más fácil de alcanzar
```

La lógica de Gates intenta resolver posteriormente los bloqueos por muralla.

---

# 35. Qué ocurre si ya no queda ningún Foro de Players 1..8

Si:

```text
bestD < 0
```

significa que `allTownhalls` no proporcionó ningún objetivo.

Entonces se ponen a cero:

```text
HW_TXH
HW_TYH
HW_OWNERH
```

y la horda no recibe un nuevo objetivo en ese ciclo.

---

# 36. Registro del nuevo objetivo

Cuando se encuentra un nuevo Foro se guardan:

```text
HW_TXH = target.pos.x
HW_TYH = target.pos.y
HW_OWNERH = target.player
```

Esto permite que otras partes del modo Zombies sepan qué ciudad persigue cada horda.

---

# 37. El propietario del objetivo se actualiza continuamente

Incluso cuando el objetivo sigue siendo válido:

```cpp
owner = target.player;
```

y se vuelve a escribir:

```text
HW_OWNERH
```

Por tanto el estado refleja al propietario actual del Foro.

---

# 38. Las cuatro fases tácticas

El sistema utiliza:

```text
phase[H] = 0 → MARCHA
phase[H] = 1 → SIEGE
phase[H] = 2 → BREACH_ADVANCE
phase[H] = 3 → CAPTURE
```

Cada horda puede encontrarse en una fase distinta.

---

# 39. PHASE 0 — MARCHA

La fase 0 intenta llevar a la horda hacia el Foro.

Además tiene dos sistemas para decidir cuándo debe empezar a buscar una Gate:

```text
A. proximidad al Foro
B. atasco de marcha
```

La segunda condición es la principal incorporación de la versión V10.5.

---

# 40. Muestreo de la horda durante la marcha

En vez de analizar todas las unidades para algunas operaciones, se muestrea:

```cpp
for(j = 0; j < h.count; j += 5)
```

Es decir, aproximadamente una de cada cinco unidades.

Para cada muestra calcula:

```cpp
d =
    target
    .DistTo(u);
```

---

# 41. Variables de proximidad

Durante ese muestreo se calculan:

```text
sampleCount
nearCount
nearestD
```

## `sampleCount`

Número de zombies muestreados.

## `nearCount`

Número de muestras situadas a:

```text
<= 2500
```

del Foro.

## `nearestD`

Distancia de la muestra más cercana al Foro.

---

# 42. Condición de proximidad al Foro

Se activa:

```text
nearForumReady = 1
```

si se cumple cualquiera de estas condiciones:

```cpp
sampleCount > 0
&&
nearCount * 3 >= sampleCount
```

o:

```cpp
nearestD <= 1500
```

---

# 43. Significado de la primera condición de proximidad

La expresión:

```text
nearCount * 3 >= sampleCount
```

equivale aproximadamente a exigir que:

```text
al menos un tercio de las muestras
```

estén a 2500 o menos del Foro.

---

# 44. Significado de la segunda condición

Aunque el resto de la horda todavía esté lejos, basta con que una muestra alcance:

```text
1500 o menos
```

para activar la búsqueda de una Gate.

---

# 45. Detector de atasco de marcha

La V10.5 añade un segundo mecanismo:

```text
stuckMarch
```

Su objetivo es detectar ciudades grandes donde la muralla puede estar muy lejos del Foro.

Sin esta lógica, la horda podía quedar parada frente a una muralla sin alcanzar nunca el radio utilizado por la condición de proximidad al Foro.

---

# 46. Frecuencia del detector de atasco

Sólo se mide cuando:

```cpp
phaseTicks[H] % 3 == 0
```

Como el bucle principal funciona cada segundo:

```text
medición cada ~3 segundos
```

---

# 47. Qué considera progreso claro

Se compara:

```text
nearestD actual
```

con:

```text
marchLastDist[H]
```

Se considera progreso claro si:

```cpp
nearestD + 100
<
marchLastDist[H]
```

Es decir, la horda debe haberse acercado al Foro aproximadamente:

```text
más de 100 unidades
```

desde la medición de referencia.

---

# 48. Qué ocurre cuando hay progreso

Si existe progreso claro:

```text
marchLastDist = nearestD
marchStuck = 0
```

El contador de atasco se reinicia.

---

# 49. Qué ocurre cuando no hay progreso suficiente

Si no mejora al menos esas 100 unidades:

```cpp
marchStuck[H] += 1;
```

Puede conservarse una pequeña mejora como nueva referencia, pero el contador sigue aumentando.

---

# 50. Cuándo se considera atascada la horda

La condición es:

```cpp
if(marchStuck[H] >= 4)
    stuckMarch = 1;
```

Como se mide cada tres segundos:

```text
4 mediciones
≈
12 segundos sin progreso claro
```

---

# 51. El atasco no significa automáticamente que exista una Gate

El propio diseño evita asumir:

```text
no avanzo
=
hay muralla
```

`stuckMarch` sólo habilita una búsqueda local.

Esto permite que un falso atasco causado por:

- combate;
- giro de ruta;
- reorganización de unidades;

no obligue automáticamente a entrar en modo de asedio.

---

# 52. Cuándo se inicia una búsqueda de Gate

La Sequence entra en búsqueda si:

```cpp
nearForumReady == 1
||
stuckMarch == 1
```

Por tanto puede buscar una Gate:

- porque la horda ya está suficientemente cerca de la ciudad;
- o porque lleva aproximadamente 12 segundos sin progresar.

---

# 53. Primera búsqueda de Gate: alrededor de la propia horda

La V10.5 realiza primero una búsqueda local.

Para cada zombie muestreado:

```cpp
q =
    ObjsInRange(
        u,
        "Building",
        1600
    )
    .GetObjList();
```

Por tanto busca Buildings en un radio:

```text
1600
```

alrededor de miembros de la horda.

---

# 54. Filtros de una Gate candidata

Para ser válida debe cumplir:

```cpp
q[i].IsHeirOf("Gate")
```

```cpp
q[i].player == target.player
```

y:

```cpp
q[i].health > 1000
```

Por tanto sólo interesan Gates:

- pertenecientes al propietario del Foro objetivo;
- todavía consideradas cerradas/intactas por esta lógica.

---

# 55. Regla de “Gate por delante”

La Gate debe cumplir:

```cpp
cand.DistTo(target)
<
u.DistTo(target)
```

Esto significa que la puerta debe estar:

```text
más cerca del Foro que el zombie
```

Conceptualmente:

```text
zombie
↓
Gate
↓
Foro
```

La finalidad es no mandar a la horda hacia una Gate que haya quedado detrás.

---

# 56. Selección de Gate local

Entre las Gates válidas se selecciona la de menor:

```cpp
cand.DistTo(u)
```

respecto a las muestras examinadas.

Se guarda en:

```cpp
Building gate;
```

y:

```text
ga = 1
```

indica que se encontró una candidata.

---

# 57. Fallback de búsqueda alrededor del Foro

Si:

```text
ga == 0
```

y además:

```text
nearForumReady == 1
```

se utiliza la detección antigua:

```cpp
q =
    ObjsInRange(
        target,
        "Building",
        7000
    )
    .GetObjList();
```

La búsqueda se realiza en un radio de:

```text
7000
```

alrededor del Foro.

---

# 58. Filtros del fallback

También exige:

```text
IsHeirOf("Gate")
player == target.player
health > 1000
```

Después se elige la Gate con menor distancia respecto a las unidades muestreadas.

---

# 59. Diferencia entre búsqueda local y fallback

La búsqueda local contiene explícitamente:

```cpp
cand.DistTo(target)
<
u.DistTo(target)
```

La búsqueda fallback alrededor del Foro **no contiene esa comprobación**.

Por tanto la regla de “Gate por delante” está aplicada de forma explícita en la búsqueda local, pero no en el fallback antiguo.

---

# 60. Número de máquinas de asedio solicitadas

Cuando se encuentra una Gate:

```cpp
nCat =
    h.count / 15;
```

Después:

```cpp
if(nCat <= 0)
    nCat = 1;

if(nCat > 4)
    nCat = 4;
```

La cantidad solicitada queda entre:

```text
1 y 4
```

---

# 61. Escalado de `nCat`

Aproximadamente:

```text
1-29 zombies  → 1
30-44          → 2
45-59          → 3
60 o más       → 4
```

El cálculo real depende de la división entera utilizada por el lenguaje.

---

# 62. Inicio del asedio

La Sequence guarda:

```text
gateX[H]
gateY[H]
```

además de:

```text
lastGateHealth
siegeHadHolder
siegeNoProgress
```

y ejecuta:

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

# 63. La Sequence no utiliza `RunAIHelper`

La cabecera lo indica expresamente.

Toda la lógica de asedio se implementa desde la propia Sequence mediante:

```cpp
ObjList.Siege(...)
```

No se delega en:

```text
RunAIHelper("siege")
```

ni:

```text
RunAIHelper("siege gate")
```

---

# 64. Qué ocurre si no encuentra Gate estando cerca del Foro

Si:

```text
nearForumReady == 1
```

pero no aparece ninguna Gate válida, el código asume que puede existir un paso accesible.

Entonces ordena avanzar hacia puntos próximos al centro del Foro.

---

# 65. `breachPoint`

Para cada unidad se calcula:

```cpp
breachPoint =
    Point(
        target.pos.x
        +
        ((j % 7) - 3) * 60,

        target.pos.y
        +
        (((j / 7) % 7) - 3) * 60
    );
```

Esto distribuye las órdenes alrededor del centro del Foro en vez de enviar todas las unidades exactamente a la misma coordenada.

---

# 66. Protección de combates ya iniciados

Antes de sustituir la orden se comprueba:

```cpp
u.command != "attack"
&&
u.command != "engage"
```

Por tanto una unidad que está combatiendo no recibe inmediatamente una nueva orden de marcha.

---

# 67. Paso a `BREACH_ADVANCE` sin Gate

Después de enviar esos `advance`:

```text
phase = 2
phaseTicks = 0
```

La Sequence supone que existe acceso al interior y da tiempo a las tropas para avanzar.

---

# 68. Falso atasco lejos del Foro

Si la búsqueda se activó únicamente por:

```text
stuckMarch == 1
```

pero:

```text
nearForumReady == 0
```

y no se encuentra Gate, **no** se entra en `BREACH_ADVANCE`.

Se ejecuta:

```text
marchLastDist = nearestD
marchStuck = 0
```

y la horda continúa marchando.

Esto evita convertir un atasco temporal lejos de la ciudad en un falso cruce de muralla.

---

# 69. Refresco de la marcha lejana

Durante PHASE 0:

```cpp
marchTicks[H] += 1;
```

Cuando llega a:

```text
5
```

se vuelve a emitir:

```cpp
u.SetCommand(
    "advance",
    target.pos
);
```

para las unidades que no estén en:

```text
attack
engage
```

---

# 70. Frecuencia de refresco de marcha

Como el bucle funciona cada segundo:

```text
marchTicks >= 5
```

equivale aproximadamente a:

```text
una orden de refresco cada 5 segundos
```

---

# 71. PHASE 1 — `SIEGE`

La fase 1 gestiona el asedio de una Gate concreta.

La Gate se vuelve a localizar utilizando las coordenadas almacenadas:

```text
gateX[H]
gateY[H]
```

---

# 72. Reidentificación de la Gate

La Sequence busca:

```cpp
ObjsInRange(
    target,
    "Building",
    7000
)
```

y exige:

```text
IsHeirOf("Gate")
pos.x == gateX
pos.y == gateY
```

Por tanto la Gate se identifica mediante sus coordenadas exactas.

---

# 73. Cuándo se considera superada la Gate

La condición es:

```cpp
if(
    ga == 0
    ||
    gate.health <= 1000
)
```

Es decir:

```text
Gate ya no encontrada
```

o:

```text
health <= 1000
```

---

# 74. Umbral `health <= 1000`

La cabecera documenta que esta versión utiliza:

```text
health <= 1000
```

como aproximación al estado de Gate rota/transitable.

El criterio de esta Sequence no espera:

```text
health == 0
```

La propia cabecera explica que en runtime se observó una Gate abierta con:

```text
1000 / 5000 HP
```

---

# 75. Qué ocurre cuando la Gate se considera abierta

Se limpian los datos de asedio:

```text
gateX = 0
gateY = 0
siegeHadHolder = 0
lastGateHealth = 0
siegeNoProgress = 0
```

Después se manda a las unidades hacia `breachPoint` alrededor del Foro.

Finalmente:

```text
phase = 2
```

---

# 76. Asedio autorreparable

La V10.5 no confía en que una única llamada a:

```cpp
h.Siege(...)
```

sea suficiente.

La Sequence vigila si el asedio parece realmente activo.

---

# 77. Frecuencia de vigilancia del asedio

La comprobación se realiza cuando:

```cpp
phaseTicks[H] % 2 == 0
```

Es decir:

```text
aproximadamente cada 2 segundos
```

---

# 78. Primera señal de asedio activo: `InHolder()`

Se recorren las unidades:

```cpp
if(u.InHolder())
    bCat = 1;
```

Si alguna está en un Holder:

```text
bCat = 1
```

La Sequence interpreta que existe una máquina/tripulación activa.

---

# 79. Registro de que alguna vez hubo Holder

Cuando:

```text
bCat == 1
```

se guarda:

```text
siegeHadHolder = 1
```

Esto cambia posteriormente el tiempo de espera antes de reintentar el asedio.

---

# 80. Segunda señal de progreso: daño a la Gate

También se compara:

```cpp
gate.health
<
lastGateHealth[H]
```

Si la salud ha descendido:

```text
el asedio está haciendo daño
```

y se reinicia:

```text
siegeNoProgress = 0
```

---

# 81. Cómo aumenta el contador de falta de progreso

Si:

- no hay `InHolder()`;
- y la Gate no ha perdido health;

entonces:

```cpp
siegeNoProgress[H] += 2;
```

Como la comprobación ocurre cada dos segundos, el contador representa aproximadamente segundos sin progreso.

---

# 82. Primer intento sin llegar a aparecer Holder

Si nunca hubo Holder:

```text
siegeHadHolder == 0
```

se espera hasta:

```text
siegeNoProgress >= 12
```

Es decir:

```text
aproximadamente 12 segundos
```

antes de reemitir `Siege()`.

---

# 83. Máquina que existió pero desapareció

Si antes hubo Holder:

```text
siegeHadHolder == 1
```

pero ahora:

```text
bCat == 0
```

se reintenta cuando:

```text
siegeNoProgress >= 4
```

aproximadamente:

```text
4 segundos sin progreso
```

---

# 84. Razón del reintento más rápido

El diseño distingue:

```text
nunca llegó a construirse la máquina
```

de:

```text
la máquina existió y probablemente fue destruida
```

En el segundo caso se considera razonable reconstruir antes.

---

# 85. Reemisión de `Siege()`

Cuando se detecta fallo:

```cpp
h.Siege(
    gate,
    nCat,
    4
);
```

Se mantiene la misma Gate.

Después se reinicia:

```text
siegeHadHolder = 0
siegeNoProgress = 0
lastGateHealth = gate.health
```

La fase sigue siendo:

```text
SIEGE
```

---

# 86. PHASE 2 — `BREACH_ADVANCE`

Esta fase es deliberadamente sencilla.

No emite nuevas órdenes masivas durante unos segundos.

La intención es no pisar los `advance` que ya están llevando a las tropas a través de la brecha.

---

# 87. Duración de `BREACH_ADVANCE`

Se incrementa:

```cpp
phaseTicks[H] += 1;
```

y cuando:

```cpp
phaseTicks[H] >= 8
```

se pasa a:

```text
PHASE 3
```

Por tanto se dejan aproximadamente:

```text
8 segundos
```

para atravesar la brecha.

---

# 88. Qué ocurre durante esos ocho segundos

La Sequence no sustituye las órdenes de avance previamente emitidas.

Esto evita el problema de cambiar demasiado pronto a una orden de captura cuando las unidades todavía están cruzando la puerta.

---

# 89. Paso a CAPTURE

Al finalizar:

```text
phase = 3
phaseTicks = 0
lastForumDist = 0
captureStuck = 0
```

A partir de ese momento el Foro se convierte en el objetivo absoluto.

---

# 90. PHASE 3 — `CAPTURE`

La fase 3 combina tres mecanismos:

```text
1. reducción determinista de loyalty
2. órdenes de capture a unidades disponibles
3. detección de una posible segunda Gate bloqueante
```

---

# 91. Prioridad absoluta del Foro

La cabecera establece que en CAPTURE:

```text
el Foro tiene prioridad absoluta
```

No se vuelve a buscar una Gate por el simple hecho de verla.

Sólo se contempla otra Gate si la horda lleva un tiempo significativo sin avanzar hacia el Foro.

---

# 92. Captura determinista de loyalty

Cada dos segundos:

```cpp
if(
    phaseTicks[H] % 2 == 0
)
```

se cuentan los zombies situados físicamente a:

```text
<= 850
```

del Foro.

---

# 93. Radio de captura utilizado

La condición es:

```cpp
if(
    target.DistTo(u)
    <=
    850
)
```

Por tanto una unidad que siga fuera de ese radio no contribuye a reducir loyalty.

---

# 94. Número de zombies dentro

Se acumula:

```text
zombiesIn
```

Sólo si:

```text
zombiesIn > 0
```

se modifica la loyalty.

Por tanto la Sequence no reduce loyalty a distancia si la horda todavía no ha conseguido entrar físicamente en la ciudad.

---

# 95. Cálculo de reducción de loyalty

Se utiliza:

```cpp
drop = zombiesIn;
```

después:

```cpp
if(drop > 10)
    drop = 10;

if(drop < 1)
    drop = 1;
```

Por tanto:

```text
1 zombie dentro  → -1 loyalty
2 zombies        → -2
...
10 zombies       → -10
20 zombies       → -10
```

por intervalo.

---

# 96. Intervalo de reducción

Como la comprobación se realiza cada:

```text
2 segundos
```

la pérdida máxima es:

```text
10 puntos aproximadamente cada 2 segundos
```

si hay diez o más zombies dentro del radio.

---

# 97. Lectura de loyalty actual

Se obtiene:

```cpp
actualLoyalty =
    target
    .settlement
    .loyalty;
```

Después:

```cpp
actualLoyalty -= drop;
```

---

# 98. Captura final del Settlement

Si:

```cpp
actualLoyalty <= 1
```

se ejecuta en el mismo tick:

```cpp
target
    .settlement
    .SetLoyalty(1);

target
    .settlement
    .SetPlayer(HP);

target
    .settlement
    .SetLoyalty(11);
```

Como:

```text
HP = 12
```

el Foro pasa a Player 12.

---

# 99. Por qué no se deja loyalty en 0

El código no escribe:

```text
loyalty = 0
```

y espera otra iteración.

Hace directamente:

```text
loyalty → 1
owner → Player 12
loyalty → 11
```

Todo dentro de la misma ejecución.

---

# 100. Reinicio después de capturar el Foro

Después de `SetPlayer(12)` se reinician:

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
```

La horda vuelve a estado de marcha.

En el siguiente ciclo ese Foro ya no estará en `allTownhalls`.

---

# 101. Búsqueda automática de la siguiente ciudad

Como el Foro capturado pertenece ahora a Player 12:

```text
foundTarget = 0
```

para el objetivo anterior.

La lógica de nuevo target seleccionará el siguiente `BaseTownhall` más cercano entre Players 1..8.

Así una misma horda superviviente puede continuar atacando ciudades.

---

# 102. Orden `capture` a unidades disponibles

Además de modificar loyalty desde Sequence, cada dos segundos se recorren las unidades.

Sólo se toca una unidad si:

```cpp
u.command == "idle"
||
u.command == "capture"
```

Entonces:

```cpp
u.SetCommand(
    "capture",
    target
);
```

---

# 103. Qué órdenes no se pisan en CAPTURE

No se sustituyen expresamente unidades que todavía estén en:

```text
advance
attack
engage
```

ni otras acciones distintas de:

```text
idle
capture
```

Esto permite que las unidades que todavía están atravesando la brecha terminen su movimiento.

---

# 104. Medición de progreso hacia el Foro

Cada tres segundos se vuelve a muestrear:

```cpp
for(
    j = 0;
    j < h.count;
    j += 5
)
```

y se obtiene la distancia mínima al Foro:

```text
nearestD
```

---

# 105. Qué se considera progreso en CAPTURE

Se considera mejora apreciable si:

```cpp
nearestD + 80
<
lastForumDist[H]
```

Es decir:

```text
aproximadamente 80 unidades más cerca
```

---

# 106. Contador `captureStuck`

Si no hay progreso suficiente:

```cpp
captureStuck[H] += 1;
```

Como la medición se hace cada tres segundos, cinco mediciones consecutivas representan aproximadamente:

```text
15 segundos
```

---

# 107. Protección cuando alguien ya está cerca del Foro

Si:

```cpp
nearestD <= 900
```

se ejecuta:

```text
captureStuck = 0
```

Por tanto, cuando al menos una muestra ya está muy cerca del Foro, la Sequence deja de considerar que existe un bloqueo de Gate.

---

# 108. Condiciones para buscar una segunda Gate

La búsqueda sólo ocurre si se cumplen simultáneamente:

```cpp
phaseTicks[H] >= 15
```

```cpp
captureStuck[H] >= 5
```

```cpp
nearestD > 900
```

y:

```cpp
phaseTicks[H] % 3 == 0
```

---

# 109. Significado práctico

La horda debe llevar:

```text
al menos ~15 segundos en CAPTURE
```

y:

```text
unas 5 mediciones consecutivas sin progreso real
```

sin que ninguna muestra llegue cerca del Foro.

Sólo entonces se sospecha que puede existir una segunda muralla.

---

# 110. Búsqueda local de segunda Gate

Se buscan Buildings alrededor de las muestras:

```cpp
ObjsInRange(
    u,
    "Building",
    1200
)
```

Por tanto el radio es:

```text
1200
```

---

# 111. Filtros de segunda Gate

La candidata debe cumplir:

```text
IsHeirOf("Gate")
player == target.player
health > 1000
```

y además:

```cpp
cand.DistTo(target)
<
u.DistTo(target)
```

Es decir, debe estar por delante de la unidad respecto al Foro.

---

# 112. Evitar salir de la ciudad para destruir una Gate lateral o exterior

Esta condición:

```text
Gate más cerca del Foro que el zombie
```

intenta impedir que una unidad que ya ha entrado en la ciudad decida retroceder para atacar una puerta exterior que ha quedado detrás.

---

# 113. Segunda Gate encontrada

Si se detecta:

```text
nearbyGate = 1
```

se vuelve a calcular:

```text
nCat = 1..4
```

se guardan sus coordenadas y se ejecuta:

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

La horda vuelve al sistema normal de asedio.

---

# 114. Segunda Gate no encontrada

Si no existe una Gate que cumpla las condiciones:

```text
no se inventa otro objetivo
```

La Sequence reinicia:

```text
captureStuck = 0
lastForumDist = nearestD
```

y mantiene el Foro como objetivo.

---

# 115. Soporte para ciudades con doble muralla

El mecanismo de segunda Gate está pensado precisamente para casos donde:

```text
primera Gate
↓
primera muralla superada
↓
horda entra en recinto exterior
↓
segunda Gate bloquea acceso al Foro
```

En ese caso, si no existe progreso durante aproximadamente 15 segundos, se busca una nueva Gate local situada por delante.

---

# 116. Qué no hace esta Sequence con las Gates

No utiliza:

```text
IsBroken
IsVeryBroken
```

desde la propia Sequence.

La versión suministrada utiliza:

```text
health > 1000
```

para buscar Gates cerradas y:

```text
health <= 1000
```

para considerarlas superadas.

---

# 117. Qué no hace con los arietes

La Sequence no busca directamente una clase:

```text
Ram
```

ni cuenta máquinas mediante un Group específico.

La vigilancia del asedio se apoya principalmente en:

```text
alguna unidad InHolder()
```

y:

```text
reducción de health de la Gate
```

---

# 118. No se utiliza `enter`

La cabecera indica expresamente que esta versión no usa una orden especial `enter`.

El cruce se intenta mediante:

```cpp
SetCommand(
    "advance",
    breachPoint
);
```

hacia puntos situados alrededor del Foro.

---

# 119. No se utiliza `RunAIHelper`

Toda la máquina de estados está implementada en la propia Sequence:

```text
MARCHA
SIEGE
BREACH_ADVANCE
CAPTURE
```

La IA táctica no se delega en los helpers nativos.

---

# 120. Relación con los combates encontrados durante la marcha

Las órdenes de movimiento suelen comprobar:

```cpp
u.command != "attack"
&&
u.command != "engage"
```

Por tanto si una unidad se encuentra combatiendo, la Sequence intenta no cancelar continuamente ese combate para imponer movimiento.

---

# 121. Qué ocurre con la horda si el estado de `phase` es inesperado

Al final existe una recuperación de seguridad.

Si `phase[H]` no es:

```text
0
1
2
3
```

se reinicia todo a:

```text
phase = 0
```

con el resto de contadores a sus valores iniciales.

Así un estado inválido vuelve a MARCHA.

---

# 122. Relación con `ZombieRewards_Main_48H_40R`

Las dos Sequences forman una cadena directa.

```text
ZombieTactical_Main
↓
detecta h.count == 0
↓
comprueba target actual
↓
lee HW_ROUNDH
↓
escribe:
    ZR_OWNERH
    ZR_ROUNDH
    ZR_XH
    ZR_YH
    ZR_PENDINGH = 1
↓
ZombieRewards_Main_48H_40R
↓
consume el evento
↓
crea las tropas de recompensa
```

---

# 123. Orden de escritura del evento de recompensa

La Sequence escribe primero:

```text
ZR_OWNER
ZR_ROUND
ZR_X
ZR_Y
```

y después:

```text
ZR_PENDING = 1
```

Este orden es correcto para un sistema productor/consumidor: cuando el consumidor detecta `pending`, los datos principales ya han sido escritos.

---

# 124. La recompensa se asigna a la ciudad defendida

Supongamos:

```text
HW_H6
↓
objetivo = Foro de Player 4
↓
Player 2 ayuda a destruir todos los zombies
↓
el Foro sigue siendo Player 4
```

Cuando:

```text
h.count == 0
```

el código hace:

```cpp
owner = target.player;
```

Por tanto:

```text
la recompensa se prepara para Player 4
```

porque es el propietario actual de la ciudad objetivo.

No para Player 2.

---

# 125. Cambio de dueño del Foro antes de morir la horda

La Sequence actualiza:

```text
HW_OWNERH
```

con:

```cpp
target.player
```

mientras el target siga siendo válido.

Si el edificio cambia entre Players 1..8, el propietario registrado también cambia.

Si pasa a Player 12, desaparece de `allTownhalls` y se selecciona otro objetivo.

---

# 126. Caso límite: horda destruida justo después de que el Foro pase a Player 12

La recompensa por destrucción exige:

```text
foundTarget == 1
```

dentro de `allTownhalls`, que sólo contiene Players 1..8.

Por tanto, si en el momento exacto en que `h.count` llega a 0 las coordenadas almacenadas corresponden a un Foro que ya pasó a Player 12, ese Foro no podrá encontrarse mediante `allTownhalls`.

En ese caso no se prepara una recompensa para ese objetivo.

---

# 127. No existe Group manual para los 32 targets

Los targets se guardan mediante:

```text
HW_TXH
HW_TYH
HW_OWNERH
```

No hay que crear:

```text
HW_Target1
HW_Target2
...
```

---

# 128. No hay límite de una sola horda por ciudad

La Sequence trata cada slot por separado.

Por tanto varias hordas podrían, en principio, guardar las mismas coordenadas `HW_TX/HW_TY` y dirigirse simultáneamente al mismo Foro.

No existe una reserva del objetivo que impida que otra horda lo seleccione.

---

# 129. Qué sucede cuando una de varias hordas captura la ciudad

Si una horda convierte el Foro a Player 12:

```text
la ciudad desaparece de allTownhalls
```

Las otras hordas que todavía tengan esas coordenadas dejarán de encontrar el target en su siguiente ciclo y buscarán un nuevo Foro.

---

# 130. Resumen de Groups necesarios

## Group obligatorio de estado

```text
CapitalForum_P1
```

Debe contener exactamente un `Building`.

## Groups de hordas utilizados

```text
HW_H1
...
HW_H32
```

Esta Sequence no los rellena. Deben ser gestionados por el sistema de oleadas y contener las unidades vivas correspondientes a cada slot.

## No son necesarios

- Groups de Gates.
- Groups de Townhalls.
- Groups de brechas.
- Groups de objetivos.
- Areas de ciudad.
- Holders manuales.

---

# 131. Preparación recomendada del sistema completo

La estructura conceptual debería ser:

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── 1 Building usado como state
│   │
│   └── HW_H1 ... HW_H32
│       └── poblados por la Sequence de oleadas
│
└── Sequences
    ├── ZombieWaves_Main
    │   └── crea hordas y estados HW_*
    │
    ├── ZombieTactical_Main_v10_5_WALL_STUCK_GATE
    │   └── controla marcha, Gates, asedio y captura
    │
    └── ZombieRewards_Main_48H_40R
        └── consume ZR_PENDING y entrega recompensas
```

Si los Groups `HW_Hx` se generan dinámicamente por `ZombieWaves_Main`, no es necesario introducir unidades manualmente en ellos desde el editor.

---

# 132. Flujo completo de una horda

```text
ZombieWaves crea horda
        ↓
HW_ACTIVEH = 1
HW_HH contiene zombies
HW_ROUNDH guarda ronda
        ↓
ZombieTactical detecta slot activo
        ↓
¿hay target válido?
        │
       No
        ↓
buscar BaseTownhall más cercano
        ↓
guardar HW_TX / HW_TY / HW_OWNER
        ↓
PHASE 0 — MARCHA
        ↓
refrescar advance cada ~5 s
        ↓
detectar:
    proximidad al Foro
    o atasco ~12 s
        ↓
buscar Gate
        ↓
¿Gate encontrada?
   │             │
  Sí            No
   │             │
   ↓             ↓
PHASE 1      si cerca del Foro:
SIEGE        PHASE 2
   │
vigilar holder y daño
   │
reintentar Siege si falla
   │
Gate <=1000 o desaparecida
   ↓
PHASE 2 — BREACH_ADVANCE
        ↓
esperar ~8 s
        ↓
PHASE 3 — CAPTURE
        ↓
capture a unidades idle
        ↓
zombies <=850 reducen loyalty
        ↓
si hay atasco real:
buscar segunda Gate
        ↓
si loyalty <=1:
SetPlayer(12)
SetLoyalty(11)
        ↓
volver a PHASE 0
        ↓
seleccionar siguiente ciudad
```

---

# 133. Flujo completo cuando la horda es destruida

```text
HW_ACTIVEH = 1
        ↓
Group HW_HH
        ↓
ClearDead()
        ↓
h.count == 0
        ↓
recuperar HW_TX / HW_TY
        ↓
localizar Foro objetivo actual
        ↓
leer HW_REWARDEDH
        ↓
si:
    Foro existe
    Player 1..8
    todavía no recompensado
        ↓
owner = target.player
round = HW_ROUNDH
        ↓
escribir:
ZR_OWNERH
ZR_ROUNDH
ZR_XH
ZR_YH
ZR_PENDINGH = 1
        ↓
HW_REWARDEDH = 1
        ↓
HW_ACTIVEH = 0
        ↓
ZombieRewards entrega premio
```

---

# 134. Parámetros tácticos principales

La versión suministrada contiene varios umbrales importantes:

| Función | Valor |
|---|---:|
| Bucle principal | 1.000 ms |
| Refresco de marcha | ~5 s |
| Muestreo de horda | 1 de cada 5 unidades |
| Proximidad general | 1/3 de muestras a ≤2500 |
| Proximidad inmediata | una muestra a ≤1500 |
| Medición de atasco en marcha | cada ~3 s |
| Progreso mínimo de marcha | >100 |
| Atasco de marcha | ~12 s |
| Búsqueda local de Gate | radio 1600 |
| Fallback de Gate alrededor del Foro | radio 7000 |
| Gate considerada no abierta | `health > 1000` |
| Gate considerada superada | `health <= 1000` |
| Máquinas solicitadas | 1 a 4 |
| Vigilancia de Siege | cada ~2 s |
| Reintento inicial sin holder | ~12 s |
| Reintento tras perder holder | ~4 s |
| BREACH_ADVANCE | ~8 s |
| Radio de loyalty | 850 |
| Intervalo loyalty | ~2 s |
| Máximo loyalty perdido | 10 |
| Progreso mínimo en CAPTURE | >80 |
| Detección de atasco CAPTURE | ~15 s |
| Búsqueda segunda Gate | radio 1200 |
| Distancia que desactiva segunda Gate | ≤900 |

---

# 135. Qué conviene comprobar al instalarla

Antes de probar el modo Zombies hay que verificar:

1. `CapitalForum_P1` existe.
2. Contiene exactamente un `Building`.
3. `ZombieWaves_Main` utiliza los nombres `HW_H1..HW_H32`.
4. Las hordas realmente se añaden a esos Groups.
5. La Sequence de oleadas escribe `HW_ACTIVEH`.
6. También escribe `HW_ROUNDH`.
7. `ZombieRewards_Main_48H_40R` está activa si se quieren las recompensas.
8. Player 12 está reservado para la horda.
9. Las ciudades jugables son subclases de `BaseTownhall`.
10. Las Gates son detectables mediante `IsHeirOf("Gate")`.

---

# 136. Elementos que no hay que preparar manualmente

No hay que crear:

- Areas para las ciudades.
- marcadores de Gate.
- puntos de brecha.
- Groups de Foros objetivo.
- rutas de entrada.
- un Group por ciudad.
- un Group por puerta.
- un Group de catapultas/arietes.
- una Sequence distinta para cada horda.

La misma Sequence controla los 32 slots.

---

# 137. Resumen funcional

`ZombieTactical_Main_v10_5_WALL_STUCK_GATE` es el controlador táctico central del modo Zombies.

Su funcionamiento puede resumirse así:

```text
leer 32 slots de horda
        ↓
ignorar slots inactivos
        ↓
leer Group HW_Hx
        ↓
si está vacío:
    preparar recompensa
    cerrar slot
        ↓
si sigue vivo:
    localizar o seleccionar Foro
        ↓
marchar hacia el objetivo
        ↓
detectar proximidad o atasco
        ↓
buscar Gate por delante
        ↓
iniciar Siege con 1-4 máquinas
        ↓
vigilar si el asedio realmente progresa
        ↓
reintentar si no aparece holder o no baja HP
        ↓
considerar Gate superada a <=1000 HP
        ↓
dar ~8 s para cruzar
        ↓
capturar el Foro
        ↓
reducir loyalty según zombies a <=850
        ↓
si existe un segundo bloqueo real:
    buscar otra Gate
    volver a Siege
        ↓
si loyalty llega a 1:
    Settlement → Player 12
    loyalty → 11
        ↓
buscar la siguiente ciudad
```

La Sequence no crea las hordas ni genera directamente las recompensas. Actúa como la capa intermedia que conecta la **creación de oleadas**, la **IA táctica de asedio/captura** y el **sistema de recompensas**.

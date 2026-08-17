# Secuencia 4 — Recompensa por control de zonas (`GuardPostsFrontierReward_Main`)

Esta Sequence implementa un sistema de recompensa territorial basado en **10 zonas configuradas manualmente mediante Groups**.

Cada zona está formada por varios objetos del mapa. La Sequence comprueba continuamente si todos los objetos de una zona pertenecen al mismo jugador. Cuando un jugador entre 1 y 8 consigue controlar por completo una zona y todavía no ha recibido la recompensa correspondiente a esa combinación concreta de **zona + jugador**, el sistema genera dos bloques de 50 unidades —100 unidades en total— en el Foro capital de ese jugador.

A diferencia de las Sequences anteriores, esta sí requiere una preparación manual importante en el editor: deben existir los Groups `RewardZone_01` a `RewardZone_10` y los Groups `CapitalForum_P1` a `CapitalForum_P8`.

La Sequence debe configurarse con **`Autorun allowed`**.

---

## 1. Preparación necesaria en el editor

Hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── GuardPostsFrontierReward_Main
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

Además, a diferencia de `Fortresses_Main`, `ForumCaptureReward_Main` y `GuardPosts_Main`, esta Sequence **sí necesita Groups manuales**.

---

# 2. Groups obligatorios

La Sequence hace referencia literalmente a estos 18 Groups:

```text
RewardZone_01
RewardZone_02
RewardZone_03
RewardZone_04
RewardZone_05
RewardZone_06
RewardZone_07
RewardZone_08
RewardZone_09
RewardZone_10

CapitalForum_P1
CapitalForum_P2
CapitalForum_P3
CapitalForum_P4
CapitalForum_P5
CapitalForum_P6
CapitalForum_P7
CapitalForum_P8
```

Si alguno de estos Groups necesarios para una situación concreta no existe o está mal configurado, esa parte del sistema no podrá funcionar como está escrita.

---

# 3. Qué representan los `RewardZone_XX`

Cada `RewardZone_XX` representa una zona territorial cuyo control completo puede conceder una recompensa militar.

La Sequence recorre:

```cpp
for (zoneId = 1; zoneId <= 10; zoneId += 1)
```

y asigna:

```cpp
RewardZone_01
RewardZone_02
...
RewardZone_10
```

según el valor de `zoneId`.

Por ejemplo:

```cpp
if (zoneId == 1)
{
    zone = Group("RewardZone_01").GetObjList();
}
```

La misma lógica se repite hasta `RewardZone_10`.

---

# 4. Qué objetos deben contener los `RewardZone_XX`

El código no comprueba una clase concreta.

No exige explícitamente:

```text
GGuardPost
```

ni:

```text
Outpost
```

ni:

```text
Townhall
```

Lo que sí exige es:

```cpp
zone.count >= 2
```

y posteriormente utiliza:

```cpp
stateBuilding = zone[0].AsBuilding();
```

Por tanto hay una condición importante:

> El primer objeto del Group debe poder convertirse correctamente a `Building`.

Además, la Sequence compara la propiedad:

```cpp
zone[checkIndex].player
```

de todos los objetos del Group.

En consecuencia, los objetos incluidos deben ser entidades cuyo propietario pueda cambiar y cuya propiedad `.player` represente el control territorial que se quiere vigilar.

---

# 5. Cada zona necesita al menos dos objetos

El código ejecuta:

```cpp
if (zone.count < 2)
{
    continue;
}
```

Por tanto:

```text
RewardZone con 0 objetos → ignorada
RewardZone con 1 objeto  → ignorada
RewardZone con 2 o más   → válida
```

No existe un máximo explícito.

Una zona podría tener:

```text
2
3
4
5
...
```

objetos.

La condición de recompensa seguirá siendo que **todos pertenezcan al mismo jugador**.

---

# 6. El primer objeto de cada zona tiene una función adicional

Después de validar el número de objetos se ejecuta:

```cpp
stateBuilding = zone[0].AsBuilding();
owner = zone[0].player;
```

Esto significa que el primer objeto se utiliza para dos cosas:

1. establecer inicialmente quién podría ser el propietario de la zona;
2. almacenar mediante `EnvReadInt()` y `EnvWriteInt()` el estado de recompensas de esa zona.

Por tanto el primer objeto no es simplemente un miembro cualquiera del Group.

Debe ser un `Building` válido.

---

# 7. Recomendación de configuración de los `RewardZone`

Para evitar errores, cada `RewardZone_XX` debería construirse de manera que:

```text
RewardZone_XX
├── objeto 0 → Building válido
├── objeto 1 → objeto territorial de la zona
├── objeto 2 → objeto territorial de la zona
└── ...
```

Todos los objetos incluidos deben representar posiciones cuyo `player` sea relevante para determinar el control territorial.

La Sequence no comprueba automáticamente que todos sean del mismo tipo.

---

# 8. Cómo determina el propietario candidato de una zona

Primero se toma:

```cpp
owner = zone[0].player;
```

Después se comprueba:

```cpp
if (
    owner < 1
    ||
    owner > 8
)
{
    continue;
}
```

Por tanto una zona sólo puede generar recompensa si el primer objeto pertenece actualmente a un jugador real del rango:

```text
Player 1
...
Player 8
```

Si el primer objeto es neutral, la zona se ignora durante ese ciclo.

---

# 9. Cómo comprueba el control completo de la zona

Inicialmente:

```cpp
sameOwner = 1;
```

Después se recorren los demás objetos:

```cpp
for (
    checkIndex = 1;
    checkIndex < zone.count;
    checkIndex += 1
)
{
    if (zone[checkIndex].player != owner)
    {
        sameOwner = 0;
    }
}
```

Si cualquiera pertenece a otro jugador:

```cpp
sameOwner = 0;
```

y la Sequence ejecuta:

```cpp
if (sameOwner == 0)
{
    continue;
}
```

Por tanto la recompensa sólo se activa cuando:

```text
objeto 0 → Player X
objeto 1 → Player X
objeto 2 → Player X
...
todos → Player X
```

---

# 10. Una zona puede estar disputada sin necesidad de una variable especial

No existe un estado explícito llamado:

```text
contested
```

La zona se considera no controlada simplemente cuando:

```text
sameOwner == 0
```

Ejemplo:

```text
RewardZone_03
├── objeto A → Player 4
├── objeto B → Player 4
├── objeto C → Player 6
└── objeto D → Player 4
```

Resultado:

```text
sameOwner = 0
→ no hay recompensa
```

Sólo cuando todos queden bajo Player 4:

```text
sameOwner = 1
```

podrá evaluarse la recompensa de Player 4.

---

# 11. Frecuencia de comprobación

La configuración es:

```cpp
CONTROL_INTERVAL = 1000;
```

y el bucle principal:

```cpp
while (1)
{
    Sleep(CONTROL_INTERVAL);
    ...
}
```

Por tanto las 10 zonas se revisan aproximadamente una vez por segundo.

Una conquista territorial completa debería detectarse como máximo alrededor de un segundo después, salvo que otro procesamiento retrase la ejecución.

---

# 12. Nivel de las tropas de recompensa

Todas las unidades creadas reciben:

```cpp
u.SetLevel(TROOP_LEVEL);
```

con:

```cpp
TROOP_LEVEL = 12;
```

Por tanto toda la recompensa se genera a nivel 12.

---

# 13. El estado de recompensa depende de la combinación zona + jugador

Esta es una de las características más importantes de la Sequence.

No existe una única variable:

```text
GFR_RZ1
```

para indicar que la zona 1 ya ha recompensado.

En su lugar existen claves diferentes para cada combinación:

```text
GFR_RZ1_P1
GFR_RZ1_P2
...
GFR_RZ1_P8

GFR_RZ2_P1
...
GFR_RZ10_P8
```

En total el código contempla:

```text
10 zonas × 8 jugadores = 80 estados independientes
```

---

# 14. Qué significa este sistema de 80 estados

Cada jugador puede recibir la recompensa de cada zona una vez.

Ejemplo:

```text
RewardZone_01
```

Primero la controla Player 4:

```text
GFR_RZ1_P4 = 0
↓
Player 4 recibe recompensa
↓
GFR_RZ1_P4 = 1
```

Más adelante la conquista Player 6:

```text
GFR_RZ1_P6 = 0
↓
Player 6 recibe también recompensa
↓
GFR_RZ1_P6 = 1
```

Si después Player 4 recupera la misma zona:

```text
GFR_RZ1_P4 = 1
↓
NO recibe otra recompensa
```

Por tanto, **la recompensa no es una sola vez por zona**.

Es:

```text
una vez por jugador y por zona
```

---

# 15. Número máximo teórico de recompensas

El código contempla:

```text
10 zonas
×
8 jugadores
=
80 recompensas posibles
```

Eso sólo ocurriría en una partida extremadamente larga en la que cada jugador llegara a controlar completamente las 10 zonas en algún momento.

Como cada recompensa genera 100 unidades:

```text
80 × 100
=
8.000 unidades
```

podrían ser creadas acumulativamente a lo largo de toda la partida en el caso teórico máximo.

No significa que puedan existir simultáneamente; sólo es el máximo de activaciones que permite el sistema actual.

---

# 16. Cómo se guarda el estado

El estado se almacena sobre:

```cpp
stateBuilding = zone[0].AsBuilding();
```

Por ejemplo:

```cpp
EnvReadInt(
    stateBuilding,
    "GFR_RZ3_P6"
);
```

Esto significa que el primer Building del Group actúa como soporte persistente del estado de la zona.

No hay un objeto global de almacenamiento.

---

# 17. Consecuencia de utilizar `zone[0]` como almacenamiento

Conviene que el primer objeto de cada `RewardZone` sea estable durante toda la partida.

Si ese objeto fuese destruido o dejara de ser válido, el sistema podría perder el soporte sobre el que consulta y escribe:

```text
GFR_RZx_Py
```

Por diseño, es preferible utilizar como `zone[0]` un edificio territorial permanente.

---

# 18. Cuándo se rechaza una recompensa ya concedida

Después de leer la clave correspondiente:

```cpp
if (rewarded == 1)
{
    continue;
}
```

Si ese jugador ya obtuvo la recompensa de esa zona, no ocurre nada.

La Sequence no vuelve a generar tropas para esa combinación.

---

# 19. Los Groups `CapitalForum_P1` a `CapitalForum_P8`

Cuando una zona cumple todos los requisitos, la Sequence busca el Foro capital del jugador.

El mapeo es:

```text
Player 1 → CapitalForum_P1
Player 2 → CapitalForum_P2
Player 3 → CapitalForum_P3
Player 4 → CapitalForum_P4
Player 5 → CapitalForum_P5
Player 6 → CapitalForum_P6
Player 7 → CapitalForum_P7
Player 8 → CapitalForum_P8
```

Por ejemplo:

```cpp
if (owner == 6)
{
    capitalList =
        Group("CapitalForum_P6")
        .GetObjList();
}
```

---

# 20. Los `CapitalForum_PX` son obligatorios

Estos Groups sí deben crearse manualmente en el editor.

Cada uno debe contener exactamente un objeto.

La Sequence ejecuta:

```cpp
capitalList.ClearDead();

if (capitalList.count != 1)
{
    continue;
}
```

Por tanto:

```text
0 objetos → no hay recompensa
1 objeto  → correcto
2 objetos → no hay recompensa
3 objetos → no hay recompensa
```

---

# 21. Qué objeto debe contener cada `CapitalForum_PX`

La Sequence ejecuta:

```cpp
capitalForum =
    capitalList[0]
    .AsBuilding();
```

y posteriormente utiliza:

```cpp
capitalForum.pos
capitalForum.settlement
```

Por tanto el objeto debe ser un `Building` con un `Settlement` válido.

Por el nombre y por el uso posterior, el Group debe apuntar al Foro/Townhall que se haya definido como capital del jugador.

---

# 22. La recompensa aparece en la capital, no en la zona conquistada

Esta es una diferencia fundamental respecto a `ForumCaptureReward_Main`.

La zona que activa el premio puede estar en cualquier lugar del mapa.

Sin embargo, las unidades se crean utilizando:

```cpp
capitalForum.pos
```

y:

```cpp
capitalForum.settlement.ForceAddUnit(u);
```

Por tanto la recompensa se entrega en el Foro capital del jugador que ha completado la zona.

Ejemplo:

```text
Player 6 controla completamente RewardZone_04
↓
la Sequence busca CapitalForum_P6
↓
la recompensa germana aparece en esa capital
```

No aparece necesariamente cerca de `RewardZone_04`.

---

# 23. Qué ocurre si el Group de capital está mal configurado

Si:

```text
CapitalForum_P6
```

no existe correctamente o no contiene exactamente un objeto válido:

```cpp
if (capitalList.count != 1)
{
    continue;
}
```

La recompensa no se genera.

Además, en ese caso el código todavía **no marca la combinación como recompensada**, porque las escrituras `EnvWriteInt(..., 1)` están después de la creación del ejército.

Por tanto el sistema volverá a intentarlo en ciclos posteriores.

Esto es útil: corregir el problema de capital puede permitir que la recompensa se active más adelante.

---

# 24. Cálculo previsto de dos puntos de aparición

Una vez obtenido el Foro capital, se calculan:

```cpp
baseAX =
    capitalForum.pos.x
    +
    450;

baseAY =
    capitalForum.pos.y
    -
    350;

baseBX =
    capitalForum.pos.x
    -
    1450;

baseBY =
    capitalForum.pos.y
    -
    350;
```

Después:

```cpp
if (army == 0)
{
    spawnX = baseAX;
    spawnY = baseAY;
}
else
{
    spawnX = baseBX;
    spawnY = baseBY;
}
```

La intención aparente es disponer de dos zonas de despliegue, una a cada lado de la capital.

---

# 25. Observación técnica importante: `spawnX` y `spawnY` no se utilizan

Aunque el código calcula:

```text
baseAX
baseAY
baseBX
baseBY
spawnX
spawnY
```

todas las llamadas reales a `Place()` utilizan:

```cpp
capitalForum.pos
```

Por ejemplo:

```cpp
u = Place(
    "RHastatus",
    capitalForum.pos,
    owner
);
```

No existe:

```cpp
Place(
    "RHastatus",
    Point(spawnX, spawnY),
    owner
);
```

Por tanto, **en esta versión las coordenadas calculadas para los dos ejércitos no tienen ningún efecto**.

---

# 26. Qué ocurre realmente con los dos ejércitos

El bucle:

```cpp
for (army = 0; army < 2; army += 1)
```

sí se ejecuta dos veces.

Cada iteración genera 50 unidades.

Pero ambas utilizan:

```cpp
capitalForum.pos
```

y después:

```cpp
capitalForum.settlement.ForceAddUnit(u);
```

Por tanto el comportamiento real es:

```text
primer bloque de 50
→ creado en la capital
→ añadido al Settlement

segundo bloque de 50
→ creado en la capital
→ añadido al mismo Settlement
```

La Sequence genera efectivamente 100 unidades, pero no dos formaciones exteriores separadas.

---

# 27. No hacen falta marcadores para los dos ejércitos

Dado que el código actual no utiliza los valores `spawnX` y `spawnY`, no hay que crear en el editor:

```text
ArmySpawn_A
ArmySpawn_B
```

ni ningún marcador equivalente.

Si en el futuro se modifica el código para utilizar posiciones exteriores, puede seguir haciéndose mediante coordenadas calculadas sin necesidad de Groups adicionales.

---

# 28. Las tropas son tropas normales

El código no aplica:

```cpp
SetNoAIFlag(true)
```

ni:

```cpp
SetFeeding(false)
```

Esto significa que las tropas:

- pueden ser utilizadas por una IA;
- pueden ser utilizadas por un jugador humano;
- participan en la estrategia normal;
- consumen comida según las reglas normales;
- no quedan bloqueadas como guarnición permanente.

La Sequence sólo las crea y las entrega.

---

# 29. No existe seguimiento posterior de las tropas

Después de:

```cpp
ForceAddUnit(u);
```

la Sequence no guarda las unidades en ningún Group.

No controla:

- si siguen vivas;
- a dónde se mueven;
- qué órdenes reciben;
- si el héroe muere;
- si el jugador las usa ofensivamente;
- si abandonan la capital.

Son una recompensa completamente libre.

---

# 30. Composición de cada bloque de 50

Cada recompensa completa contiene dos bloques idénticos de 50.

La composición depende del Player propietario de la zona.

---

# 31. Player 1 — Roma Imperial

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Hastatus | `RHastatus` | 18 |
| Archer | `RArcher` | 10 |
| Velit | `RVelit` | 8 |
| Praetorian | `RPraetorian` | 6 |
| Scout | `RScout` | 7 |
| Héroe imperial | `MHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
36 RHastatus
20 RArcher
16 RVelit
12 RPraetorian
14 RScout
2 MHero1

TOTAL = 100
```

---

# 32. Player 2 — Cartago

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Libyan Footman | `CLibyanFootman` | 18 |
| Javelin Thrower | `CJavelinThrower` | 11 |
| Berber Assassin | `CBerberAssassin` | 8 |
| Noble | `CNoble` | 5 |
| Numidian Rider | `CNumidianRider` | 7 |
| Héroe | `CHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
36 CLibyanFootman
22 CJavelinThrower
16 CBerberAssassin
10 CNoble
14 CNumidianRider
2 CHero1

TOTAL = 100
```

---

# 33. Player 3 — Iberia

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Defender | `IDefender` | 17 |
| Slinger | `ISlinger` | 11 |
| Militiaman | `IMilitiaman` | 8 |
| Elite Guard | `IEliteGuard` | 6 |
| Cavalry | `ICavalry` | 7 |
| Héroe | `IHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
34 IDefender
22 ISlinger
16 IMilitiaman
12 IEliteGuard
14 ICavalry
2 IHero1

TOTAL = 100
```

---

# 34. Player 4 — Galia

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Woman Warrior | `GWomanWarrior` | 20 |
| Archer | `GArcher` | 11 |
| Axeman | `GAxeman` | 11 |
| Horseman | `GHorseman` | 7 |
| Héroe | `GHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
40 GWomanWarrior
22 GArcher
22 GAxeman
14 GHorseman
2 GHero1

TOTAL = 100
```

---

# 35. Player 5 — Britania

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Bronze Spearman | `BBronzeSpearman` | 15 |
| Highlander | `BHighlander` | 5 |
| Bowman | `BBowman` | 15 |
| Javelineer | `BJavelineer` | 14 |
| Héroe | `BHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
30 BBronzeSpearman
10 BHighlander
30 BBowman
28 BJavelineer
2 BHero1

TOTAL = 100
```

---

# 36. Player 6 — Germania

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Maceman | `TMaceman` | 20 |
| Archer | `TArcher` | 10 |
| Huntress | `THuntress` | 12 |
| Teuton Rider | `TTeutonRider` | 7 |
| Héroe | `THero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
40 TMaceman
20 TArcher
24 THuntress
14 TTeutonRider
2 THero1

TOTAL = 100
```

---

# 37. Player 7 — Roma Republicana

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Hastatus | `RHastatus` | 18 |
| Archer | `RArcher` | 10 |
| Gladiator | `RGladiator` | 8 |
| Tribune | `RTribune` | 6 |
| Scout | `RScout` | 7 |
| Héroe republicano | `RHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
36 RHastatus
20 RArcher
16 RGladiator
12 RTribune
14 RScout
2 RHero1

TOTAL = 100
```

---

# 38. Player 8 — Egipto

Cada bloque contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Guardian | `EGuardian` | 19 |
| Archer | `EArcher` | 10 |
| Axe Thrower | `EAxetrower` | 9 |
| Anubis Warrior | `EAnubisWarrior` | 5 |
| Chariot | `EChariot` | 6 |
| Héroe | `EHero1` | 1 |
| **Total** | | **50** |

Recompensa completa:

```text
38 EGuardian
20 EArcher
18 EAxetrower
10 EAnubisWarrior
12 EChariot
2 EHero1

TOTAL = 100
```

---

# 39. Los héroes también se generan por duplicado

El héroe está dentro del bucle:

```cpp
for (army = 0; army < 2; army += 1)
```

Por tanto cada recompensa genera:

```text
2 héroes
```

junto a:

```text
98 unidades no heroicas
```

Total:

```text
100 unidades
```

---

# 40. Cuándo se marca finalmente la recompensa

A diferencia de `ForumCaptureReward_Main`, donde el estado se escribe antes de crear las tropas, aquí las claves:

```text
GFR_RZx_Py
```

se escriben **después** de generar los dos ejércitos.

Ejemplo:

```cpp
EnvWriteInt(
    stateBuilding,
    "GFR_RZ4_P6",
    1
);
```

Esto ocurre al final del procesamiento de la zona.

---

# 41. Consecuencia de marcar después de crear

Mientras la Sequence se ejecute de manera normal, no hay problema porque todo ocurre dentro de una misma iteración.

La ventaja es que si la recompensa no puede generarse porque:

```text
CapitalForum_PX no contiene exactamente un objeto
```

la clave no queda marcada y el sistema puede volver a intentarlo.

La desventaja teórica es que, si ocurriera un fallo de ejecución después de crear parte o toda la recompensa pero antes de escribir la clave, podría volver a intentarse posteriormente.

El código no implementa una transacción intermedia.

---

# 42. Qué ocurre si una zona cambia de dueño

Ejemplo:

```text
RewardZone_07
↓
Player 3 controla todos sus objetos
↓
Player 3 recibe recompensa
↓
GFR_RZ7_P3 = 1
```

Después Player 4 conquista toda la zona:

```text
GFR_RZ7_P4 = 0
↓
Player 4 recibe su recompensa
↓
GFR_RZ7_P4 = 1
```

Más adelante Player 3 recupera la zona:

```text
GFR_RZ7_P3 = 1
↓
no recibe otra recompensa
```

---

# 43. Qué ocurre si una zona queda parcialmente perdida

Supongamos:

```text
Player 5 controla los 4 objetos de RewardZone_02
↓
recibe recompensa
```

Después pierde uno:

```text
3 objetos → Player 5
1 objeto  → Player 6
```

La zona deja de cumplir `sameOwner`.

No ocurre nada adicional.

Si Player 5 recupera el objeto:

```text
sameOwner = 1
```

pero:

```text
GFR_RZ2_P5 = 1
```

por lo que no recibe otra recompensa.

---

# 44. Qué ocurre si una zona comienza ya controlada por un jugador

La Sequence no distingue entre:

```text
zona conquistada durante la partida
```

y:

```text
zona ya completamente controlada desde el inicio
```

En cuanto comienza el bucle, si todos los objetos de `RewardZone_XX` pertenecen al mismo Player 1-8 y su clave todavía vale 0, se generará la recompensa.

Por tanto, si se quiere que las recompensas sólo correspondan a conquistas realizadas durante la partida, las zonas no deberían comenzar ya completamente unificadas bajo un jugador salvo que ese premio inicial sea deseado.

---

# 45. Qué ocurre si una zona empieza neutral

Si el primer objeto tiene:

```text
owner > 8
```

se ejecuta:

```cpp
continue;
```

No se revisa ninguna recompensa.

Cuando más adelante todos los objetos queden bajo el mismo Player 1-8, podrá activarse.

---

# 46. No se exige que los objetos fueran neutrales al inicio

A diferencia de `ForumCaptureReward_Main`, aquí no se realiza una fotografía inicial del estado territorial.

La Sequence no registra:

```text
quién poseía cada objeto al comenzar
```

Sólo comprueba la situación actual cada segundo.

Por tanto una zona puede estar formada por:

- puestos inicialmente neutrales;
- edificios inicialmente de distintos jugadores;
- posiciones ya ocupadas;
- una combinación de ellas;

siempre que el concepto territorial tenga sentido para el diseño del mapa.

---

# 47. No existe regeneración de la recompensa

Una vez creadas las 100 unidades:

```text
no se regeneran
```

Si mueren:

```text
no reaparecen
```

La única forma de obtener otra recompensa territorial es que el mismo jugador complete otra zona para la que todavía no tenga la clave correspondiente.

---

# 48. No existe límite global de recompensas por jugador

Un Player puede recibir:

```text
RewardZone_01
RewardZone_02
RewardZone_03
...
RewardZone_10
```

una vez cada una.

Por tanto el máximo para un mismo jugador es:

```text
10 zonas × 100 unidades
=
1.000 unidades
```

creadas acumulativamente a lo largo de la partida.

---

# 49. No existe relación directa con la distancia entre zona y capital

El sistema no calcula:

```text
distancia desde RewardZone a CapitalForum
```

La recompensa siempre se entrega en la capital designada.

Una zona situada en el extremo opuesto del mapa puede generar tropas instantáneamente en el Foro capital.

---

# 50. No existe un sistema de mensajes en esta Sequence

El código no utiliza:

```text
GiveNote
RunConv
```

ni otro mecanismo visible de notificación.

El jugador recibe las tropas, pero esta Sequence no muestra por sí misma un mensaje explicando por qué.

Si se quisiera informar al jugador, tendría que añadirse otra lógica.

---

# 51. No existen Areas

La Sequence no usa:

```cpp
ClassPlayerAreaObjs(...)
```

ni Areas con nombre.

Las zonas estratégicas se representan mediante **Groups de objetos**, no mediante regiones geométricas.

Por tanto no hay que crear Areas para este sistema.

---

# 52. No existen Groups dinámicos de tropas

Las tropas de recompensa no se añaden a ningún Group.

Los únicos Groups utilizados son los 18 Groups de configuración territorial y capitales.

---

# 53. Lista exacta de Groups que hay que crear

En el editor deben existir:

```text
RewardZone_01
RewardZone_02
RewardZone_03
RewardZone_04
RewardZone_05
RewardZone_06
RewardZone_07
RewardZone_08
RewardZone_09
RewardZone_10
```

y:

```text
CapitalForum_P1
CapitalForum_P2
CapitalForum_P3
CapitalForum_P4
CapitalForum_P5
CapitalForum_P6
CapitalForum_P7
CapitalForum_P8
```

---

# 54. Configuración recomendada de `CapitalForum_PX`

Cada Group debe contener **exactamente un edificio**.

Ejemplo:

```text
CapitalForum_P1
└── Foro capital de Player 1
```

```text
CapitalForum_P2
└── Foro capital de Player 2
```

y así sucesivamente.

No debe añadirse ningún segundo objeto al mismo Group.

---

# 55. Configuración recomendada de `RewardZone_XX`

Cada Group debe contener todos los edificios/objetos cuyo control conjunto define la zona.

Ejemplo conceptual:

```text
RewardZone_01
├── Guard Post A
├── Guard Post B
├── Guard Post C
└── Guard Post D
```

La recompensa se activa sólo cuando:

```text
A.player
=
B.player
=
C.player
=
D.player
=
Player X
```

El código exige además que el primer elemento pueda convertirse a `Building`, porque se utiliza como `stateBuilding`.

---

# 56. Importancia del orden de los objetos en `RewardZone`

El primer objeto tiene una responsabilidad que los demás no tienen:

```cpp
stateBuilding = zone[0].AsBuilding();
```

Por tanto conviene asegurarse de que el objeto que el editor deja como primer miembro del Group sea un edificio estable.

Si no se puede controlar de forma fiable el orden interno del Group, lo más seguro es que **todos los objetos incluidos sean Buildings válidos**, de modo que cualquiera pueda ocupar la posición `[0]` sin provocar problemas de tipo.

---

# 57. Mapeo de jugadores que debe respetarse

El sistema de composición utiliza:

```text
P1 = Roma Imperial
P2 = Cartago
P3 = Iberia
P4 = Galia
P5 = Britania
P6 = Germania
P7 = Roma Republicana
P8 = Egipto
```

El mismo mapeo debe utilizarse para los Groups:

```text
CapitalForum_P1
...
CapitalForum_P8
```

Si se cambia la asignación de civilizaciones, hay que modificar tanto la composición como la relación conceptual de capitales.

---

# 58. Flujo completo de una zona

El ciclo puede resumirse así:

```text
leer RewardZone_XX
        ↓
¿tiene al menos 2 objetos?
        │
       No
        └── ignorar

       Sí
        ↓
tomar owner de zone[0]
        ↓
¿owner está entre 1 y 8?
        │
       No
        └── ignorar

       Sí
        ↓
¿todos los objetos tienen ese mismo owner?
        │
       No
        └── zona no controlada

       Sí
        ↓
leer GFR_RZx_Py
        ↓
¿ya vale 1?
        │
       Sí
        └── ese jugador ya cobró esa zona

       No
        ↓
buscar CapitalForum_Py
        ↓
¿contiene exactamente 1 objeto?
        │
       No
        └── esperar e intentar de nuevo

       Sí
        ↓
crear dos bloques de 50
        ↓
100 unidades nivel 12
        ↓
añadir al Settlement de la capital
        ↓
GFR_RZx_Py = 1
```

---

# 59. Diferencia respecto a `ForumCaptureReward_Main`

Ambas Sequences utilizan la misma composición militar de 100 unidades, pero su disparador es completamente diferente.

## `ForumCaptureReward_Main`

```text
un Foro que empezó neutral
↓
primera conquista
↓
recompensa una sola vez para ese Foro
```

## Esta Sequence

```text
todos los objetos de una RewardZone
pasan a estar bajo el mismo Player
↓
recompensa una vez para esa combinación zona + jugador
```

Además:

```text
ForumCaptureReward_Main
→ recompensa en el propio Foro conquistado

GuardPostsFrontierReward_Main
→ recompensa en CapitalForum_PX
```

---

# 60. Diferencia respecto a `GuardPosts_Main`

`GuardPosts_Main` administra la defensa individual de cada `GGuardPost`.

Esta Sequence no controla combate ni guardianes.

Sólo observa propiedad territorial mediante Groups.

Por tanto pueden coexistir:

```text
GuardPosts_Main
→ controla cómo se defiende y captura cada Guard Post

GuardPostsFrontierReward_Main
→ observa cuándo un conjunto de esos puestos queda unificado bajo un jugador
→ entrega una recompensa estratégica
```

---

# 61. Observación técnica principal antes de dar la Sequence por cerrada

El código contiene el mismo patrón ya visto en otra Sequence de recompensa:

```cpp
baseAX
baseAY
baseBX
baseBY
spawnX
spawnY
```

se calculan, pero no se utilizan.

Todas las tropas se crean con:

```cpp
Place(
    "...",
    capitalForum.pos,
    owner
);
```

y se añaden con:

```cpp
capitalForum.settlement.ForceAddUnit(u);
```

Por tanto la implementación actual entrega las 100 unidades en el Settlement de la capital.

No despliega físicamente dos ejércitos a izquierda y derecha pese a calcular coordenadas para ello.

Esto es una cuestión del código, no de la configuración del editor.

---

# 62. Preparación exacta en el editor

La estructura necesaria es:

```text
Map
├── Sequences
│   └── GuardPostsFrontierReward_Main
│       ├── pegar código
│       ├── Compile
│       └── Autorun allowed = Sí
│
└── Groups
    ├── RewardZone_01
    ├── RewardZone_02
    ├── RewardZone_03
    ├── RewardZone_04
    ├── RewardZone_05
    ├── RewardZone_06
    ├── RewardZone_07
    ├── RewardZone_08
    ├── RewardZone_09
    ├── RewardZone_10
    │
    ├── CapitalForum_P1
    ├── CapitalForum_P2
    ├── CapitalForum_P3
    ├── CapitalForum_P4
    ├── CapitalForum_P5
    ├── CapitalForum_P6
    ├── CapitalForum_P7
    └── CapitalForum_P8
```

---

# 63. Qué debe contener cada Group

## `RewardZone_01` ... `RewardZone_10`

- Mínimo 2 objetos.
- Todos deben tener una propiedad `.player` significativa.
- El primer objeto debe ser un `Building` válido.
- Es recomendable que todos sean Buildings para evitar problemas con el orden interno.
- Todos los objetos cuyo control conjunto defina la zona deben estar incluidos.

## `CapitalForum_P1` ... `CapitalForum_P8`

- Exactamente 1 objeto.
- Debe ser un `Building`.
- Debe tener un `Settlement` válido.
- Debe corresponder al Foro capital del jugador indicado.

---

# 64. Elementos que no hay que crear

No se necesitan:

- Areas.
- Holders adicionales.
- puntos de spawn manuales;
- Groups de tropas;
- marcadores para los ejércitos;
- una Sequence por zona;
- una Sequence por jugador.

Toda la lógica se centraliza en una única Sequence.

---

# 65. Resumen funcional

La Sequence realiza este trabajo:

```text
vigilar 10 RewardZones cada segundo
        ↓
comprobar si todos sus objetos tienen el mismo propietario
        ↓
aceptar sólo Players 1..8
        ↓
comprobar si ese jugador ya recibió esa zona
        ↓
localizar su CapitalForum_PX
        ↓
crear dos bloques de 50 unidades nivel 12
        ↓
añadir las 100 unidades al Settlement de la capital
        ↓
marcar GFR_RZx_Py = 1
        ↓
permitir que otros jugadores puedan obtener en el futuro
su propia recompensa de esa misma zona
```

Es una Sequence de recompensa territorial global y, a diferencia de las tres anteriores, depende directamente de una configuración manual de Groups en el editor.

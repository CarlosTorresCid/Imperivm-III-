# Secuencia 2 — `ForumCaptureReward_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).** Este documento describe la implementación canónica incluida en `V2.0ImperivmIII.txt`.

`ForumCaptureReward_Main` implementa una recompensa militar asociada a la primera conquista de los Foros que comienzan la partida como neutrales. La Sequence descubre esos Foros automáticamente al arrancar, conserva sus referencias aunque posteriormente cambien de propietario y, cuando detecta que uno de ellos ha pasado por primera vez a un jugador real entre 1 y 8, genera una recompensa de 100 unidades para ese jugador.

La recompensa está dividida lógicamente en dos bloques de 50 unidades. La composición depende exclusivamente del número de jugador que haya conquistado el Foro.

La Sequence debe configurarse con **`Autorun allowed`**.

---

## 1. Preparación necesaria en el editor

Para utilizar esta Sequence hay que crear:

```text
Scenario
└── Map
    └── Sequences
        └── ForumCaptureReward_Main
```

Dentro de esa Sequence:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

### No hay que crear

- Groups para los Foros.
- Groups para los ejércitos de recompensa.
- Areas.
- Holders específicos.
- Marcadores de aparición.
- Una Sequence por ciudad.
- Variables auxiliares en el editor.

La Sequence localiza los Foros automáticamente mediante `ClassPlayerObjs()` y guarda el estado de recompensa directamente sobre cada edificio mediante `EnvReadInt()` y `EnvWriteInt()`.

---

## 2. Qué edificios controla

La búsqueda utiliza la clase base:

```cpp
ClassPlayerObjs("BaseTownhall", ...)
```

Por herencia, el sistema incluye los Townhall culturales:

| Civilización | Clase |
|---|---|
| Britania | `BTownhall` |
| Cartago | `CTownhall` |
| Egipto | `ETownhall` |
| Galia | `GTownhall` |
| Iberia | `ITownhall` |
| Roma Imperial | `MTownhall` |
| Roma Republicana | `RTownhall` |
| Germania | `TTownhall` |

No es necesario buscar estas ocho clases individualmente.

La clase base `BaseTownhall` permite tratarlas todas como miembros de una misma familia.

---

## 3. Qué edificios no controla

El propio diseño de la Sequence excluye los edificios que no pertenecen a la familia `BaseTownhall`.

En particular:

- `MutableVillage` no entra en el sistema.
- Los Outposts no entran en el sistema.
- `GGuardPost` no entra en el sistema.
- `TTent` no entra en el sistema.
- Edificios normales de producción tampoco entran.

La recompensa está asociada específicamente a los Foros/Townhalls neutrales.

---

## 4. Sólo se registran los Foros neutrales al inicio de la partida

La lista inicial se construye así:

```cpp
forums =
    ClassPlayerObjs(
        "BaseTownhall",
        15
    )
    .GetObjList();

forums.AddList(
    ClassPlayerObjs(
        "BaseTownhall",
        16
    )
    .GetObjList()
);
```

Por tanto, sólo se incorporan a `forums` los Townhall que en el momento de arrancar la Sequence pertenezcan a:

```text
Player 15
o
Player 16
```

Esta condición es fundamental.

### Sí recibe recompensa

```text
Foro empieza como Player 15
↓
más tarde lo conquista Player 3
↓
se genera recompensa
```

### No recibe recompensa

```text
Foro empieza como Player 1
↓
más tarde pasa a Player 15
↓
después lo conquista Player 3
↓
NO pertenece a la lista inicial
↓
no genera recompensa
```

La mecánica está diseñada expresamente como una **recompensa por conquistar territorio que era neutral al comenzar la partida**.

---

## 5. Las referencias se conservan después de la conquista

Aunque inicialmente la consulta se realiza sobre Player 15 y Player 16, `forums` guarda referencias a los objetos reales.

Por ejemplo:

```text
ETownhall
player = 15
↓
queda guardado en forums
↓
Player 8 lo conquista
↓
el mismo objeto pasa a player = 8
↓
continúa dentro de forums
```

Por este motivo no es necesario volver a buscar el Foro después de la captura.

El bucle simplemente consulta:

```cpp
owner = forum.player;
```

y conoce en todo momento su propietario actual.

---

## 6. Parámetros principales

La configuración general es:

```cpp
CONTROL_INTERVAL = 2500;
TROOP_LEVEL = 12;

SPAWN_GAP = 450;
FORMATION_WIDTH = 1000;
FORMATION_Y_OFFSET = 350;
```

### `CONTROL_INTERVAL`

```text
2.500 ms
```

La Sequence comprueba aproximadamente cada **2,5 segundos** si alguno de los Foros registrados ha sido conquistado.

La versión v2.0 aumenta deliberadamente este intervalo para reducir el coste permanente del controlador. En condiciones normales, la recompensa puede empezar a procesarse hasta unos 2,5 segundos después de que el cambio de propietario sea visible para la Sequence.

### `TROOP_LEVEL`

```text
12
```

Todas las unidades creadas por esta Sequence reciben:

```cpp
u.SetLevel(TROOP_LEVEL);
```

Por tanto las 100 unidades de cada recompensa son nivel 12.

### Parámetros de formación

El código declara:

```cpp
SPAWN_GAP = 450;
FORMATION_WIDTH = 1000;
FORMATION_Y_OFFSET = 350;
```

Su intención declarada es calcular dos zonas de aparición a izquierda y derecha del Foro.

Sin embargo, existe una diferencia importante entre esa intención y lo que hace realmente el código actual. Se explica en la sección 15.

---

## 7. Bucle principal de vigilancia

Después del descubrimiento inicial, la Sequence entra en:

```cpp
while (1)
{
    Sleep(CONTROL_INTERVAL);

    ...
}
```

Esto significa que permanece activa durante toda la partida.

Cada 2,5 segundos:

1. limpia referencias a objetos destruidos;
2. recorre todos los Foros neutrales registrados al inicio;
3. consulta el propietario actual;
4. comprueba si ya ha dado su recompensa;
5. si corresponde, genera las tropas.

No existe ningún límite temporal para la recompensa.

Un Foro puede permanecer neutral durante dos horas y, si después se conquista, la Sequence seguirá detectándolo.

---

## 8. `forums.ClearDead()`

En cada ciclo se ejecuta:

```cpp
forums.ClearDead();
```

Esto elimina de la lista las referencias a objetos que ya no sean válidos o hayan sido destruidos.

La finalidad es evitar que el bucle continúe intentando operar sobre referencias muertas.

---

## 9. Cuándo se considera conquistado un Foro

Para cada Foro se consulta:

```cpp
owner = forum.player;
```

Después:

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

Por tanto, la Sequence sólo considera una conquista válida cuando el propietario actual está entre:

```text
Player 1
...
Player 8
```

Mientras siga siendo Player 15 o Player 16, no hace nada.

Tampoco entrega la recompensa a un jugador técnico del rango 9-16.

---

## 10. Estado individual de recompensa

Cada Foro guarda su propio indicador:

```cpp
rewarded =
    EnvReadInt(
        forum,
        "FCR_Rewarded"
    );
```

La clave utilizada es:

```text
FCR_Rewarded
```

No hace falta crear una clave distinta como:

```text
FCR_Rewarded_Forum1
FCR_Rewarded_Forum2
FCR_Rewarded_Forum3
```

porque el dato queda almacenado sobre el objeto `forum` concreto.

Conceptualmente:

```text
Foro A
└── FCR_Rewarded = 0

Foro B
└── FCR_Rewarded = 1

Foro C
└── FCR_Rewarded = 0
```

Todos utilizan el mismo nombre de variable sin interferirse.

---

## 11. Cada Foro recompensa una sola vez

Si:

```cpp
rewarded == 1
```

se ejecuta:

```cpp
continue;
```

y ese Foro queda excluido permanentemente de nuevas recompensas.

El flujo es:

```text
Foro neutral
↓
primera conquista
↓
100 unidades
↓
FCR_Rewarded = 1
↓
el Foro puede cambiar de dueño muchas veces
↓
nunca vuelve a recompensar
```

Por tanto, la recompensa está asociada a la **primera conquista desde el estado neutral inicial**, no a cada cambio de propietario.

---

## 12. El Foro se marca antes de crear las tropas

Antes de generar una sola unidad se ejecuta:

```cpp
EnvWriteInt(
    forum,
    "FCR_Rewarded",
    1
);
```

Esto está hecho para evitar duplicados.

Si el bucle principal se ejecutase otra vez mientras todavía se está procesando la recompensa, el Foro ya figuraría como recompensado.

### Consecuencia técnica

La decisión prioriza evitar recompensas duplicadas.

También implica que, si se produjera un fallo de ejecución después de escribir `FCR_Rewarded = 1` pero antes de terminar de crear todas las tropas, la Sequence no volvería a intentar completar automáticamente la recompensa en el siguiente ciclo.

El código actual no implementa un sistema de transacción o recuperación parcial.

---

## 13. Dos ejércitos por Foro

La creación está envuelta en:

```cpp
for (army = 0; army < 2; army += 1)
```

Por tanto, todo el bloque de composición correspondiente al propietario se ejecuta dos veces.

Cada bloque contiene exactamente 50 unidades.

Resultado total:

```text
Ejército A = 50 unidades
Ejército B = 50 unidades

Total = 100 unidades
```

---

## 14. Cálculo previsto de los dos lados del Foro

El código calcula dos puntos base.

### Ejército A

```cpp
baseAX =
    forum.pos.x
    +
    SPAWN_GAP;

baseAY =
    forum.pos.y
    -
    FORMATION_Y_OFFSET;
```

Su intención es situarlo a la derecha del Townhall.

### Ejército B

```cpp
baseBX =
    forum.pos.x
    -
    SPAWN_GAP
    -
    FORMATION_WIDTH;

baseBY =
    forum.pos.y
    -
    FORMATION_Y_OFFSET;
```

La intención es colocarlo a la izquierda y compensar el ancho de la formación.

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

Conceptualmente el diseño pretendido es:

```text
[ EJÉRCITO B ]     [ FORO ]     [ EJÉRCITO A ]
```

---

## 15. Observación técnica importante: el código actual no utiliza `spawnX` ni `spawnY`

Esta es la diferencia más importante entre los comentarios del script y su ejecución real.

Aunque se calculan:

```cpp
spawnX
spawnY
baseAX
baseAY
baseBX
baseBY
```

ninguna llamada a `Place()` utiliza esas coordenadas.

Todas las unidades se crean así:

```cpp
u = Place(
    "ClaseDeUnidad",
    forum.pos,
    owner
);
```

Es decir, el segundo argumento es siempre:

```cpp
forum.pos
```

y no:

```cpp
Point(spawnX, spawnY)
```

ni ninguna formación basada en esos valores.

Por tanto, **en el código actual los parámetros `SPAWN_GAP`, `FORMATION_WIDTH` y `FORMATION_Y_OFFSET` no tienen efecto sobre la posición real de las tropas**.

Se calculan correctamente, pero el resultado no se utiliza.

---

## 16. Qué ocurre realmente con los dos ejércitos en esta versión

El bucle sigue ejecutándose dos veces, por lo que sí se crean 100 unidades.

Sin embargo, ambas iteraciones utilizan:

```cpp
Place(..., forum.pos, owner);
```

y después:

```cpp
forum.settlement.ForceAddUnit(u);
```

Por tanto el comportamiento real del código es:

```text
primera iteración
→ crea 50 unidades en forum.pos
→ las añade al Settlement del Foro

segunda iteración
→ crea otras 50 unidades en forum.pos
→ las añade al mismo Settlement
```

No existe en esta versión una formación física a izquierda y derecha.

### Consecuencia para la documentación

Debe distinguirse entre:

**Diseño comentado en la cabecera:**

```text
dos ejércitos alrededor del Foro
uno a la izquierda
otro a la derecha
```

y:

**Implementación real del código actual:**

```text
dos bloques de 50
creados en forum.pos
y añadidos al Settlement del Foro
```

Si se desea que aparezcan realmente desplegados fuera del Foro, habría que modificar la Sequence. No es una configuración que pueda solucionarse creando Groups o Areas en el editor.

---

## 17. `ForceAddUnit()` en todas las tropas

Después de cada `Place()` se ejecuta:

```cpp
forum.settlement.ForceAddUnit(u);
```

Esto vincula la unidad creada al Settlement del Foro que ha entregado la recompensa.

Es una diferencia importante respecto a una recompensa que simplemente utilizase:

```cpp
Place(...)
```

sobre una posición exterior.

La Sequence no emite posteriormente ninguna orden `move`, `advance` o similar para desplegar esas unidades fuera.

### Escalonado de creación en v2.0

Después de cada unidad creada e introducida en el Foro se ejecuta:

```cpp
Sleep(20);
```

Esto incluye también al héroe de cada bloque. Como la recompensa completa contiene 100 unidades, el código introduce aproximadamente **2 segundos de espera programada acumulada** durante la creación total, además del coste propio de `Place()` y `ForceAddUnit()`.

La finalidad es evitar crear las 100 unidades en un único instante de ejecución y repartir ligeramente la carga del motor.

---

## 18. Son tropas normales

A diferencia de las guarniciones de `Fortresses_Main`, aquí no aparece:

```cpp
u.SetNoAIFlag(true);
```

ni:

```cpp
u.SetFeeding(false);
```

Esto es deliberado.

Las tropas de recompensa:

- utilizan el comportamiento normal del jugador;
- pueden ser utilizadas por la IA;
- pueden ser utilizadas por el jugador humano;
- conservan la alimentación normal;
- no están bloqueadas por la Sequence;
- no reciben órdenes defensivas automáticas de esta Sequence.

`ForumCaptureReward_Main` sólo las crea.

Después de eso deja que funcionen como tropas ordinarias.

---

## 19. No existe control posterior del ejército

Una vez creadas las unidades, la Sequence no guarda referencias individuales a ellas.

No hay:

```cpp
AddToGroup(...)
```

No existe un Group de recompensa.

Tampoco existe un bucle que vigile:

- si siguen vivas;
- dónde están;
- qué órdenes reciben;
- si el héroe ha muerto;
- si consumen comida;
- si vuelven al Foro;
- si participan en otra guerra.

Una vez entregadas, dejan de ser responsabilidad de `ForumCaptureReward_Main`.

---

# 20. Mapeo de Player a civilización

La composición no se obtiene mediante `GetPlayerRace()`.

Está codificada directamente según `owner`.

La Sequence asume este mapa:

| Player | Civilización |
|---:|---|
| 1 | Roma Imperial |
| 2 | Cartago |
| 3 | Iberia |
| 4 | Galia |
| 5 | Britania |
| 6 | Germania |
| 7 | Roma Republicana |
| 8 | Egipto |

Esto es una condición importante del sistema.

### Si cambian los números de jugador

Por ejemplo, si en otro mapa:

```text
Player 1 = Egipto
```

la Sequence seguiría entregándole tropas de Roma Imperial porque sólo comprueba:

```cpp
if (owner == 1)
```

No comprueba realmente la raza actual del jugador.

Por tanto, **antes de reutilizar esta Sequence en otro escenario hay que verificar que la asignación de Players 1-8 coincide con esta tabla**.

---

# 21. Player 1 — Roma Imperial

Cada uno de los dos bloques de recompensa contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Hastatus | `RHastatus` | 18 |
| Archer | `RArcher` | 10 |
| Velit | `RVelit` | 8 |
| Praetorian | `RPraetorian` | 6 |
| Scout | `RScout` | 7 |
| Héroe imperial | `MHero1` | 1 |
| **Total** | | **50** |

Como el bucle `army` se ejecuta dos veces:

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

# 22. Player 2 — Cartago

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Libyan Footman | `CLibyanFootman` | 18 |
| Javelin Thrower | `CJavelinThrower` | 11 |
| Berber Assassin | `CBerberAssassin` | 8 |
| Noble | `CNoble` | 5 |
| Numidian Rider | `CNumidianRider` | 7 |
| Héroe | `CHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

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

# 23. Player 3 — Iberia

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Defender | `IDefender` | 17 |
| Slinger | `ISlinger` | 11 |
| Militiaman | `IMilitiaman` | 8 |
| Elite Guard | `IEliteGuard` | 6 |
| Cavalry | `ICavalry` | 7 |
| Héroe | `IHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

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

# 24. Player 4 — Galia

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Woman Warrior | `GWomanWarrior` | 20 |
| Archer | `GArcher` | 11 |
| Axeman | `GAxeman` | 11 |
| Horseman | `GHorseman` | 7 |
| Héroe | `GHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

```text
40 GWomanWarrior
22 GArcher
22 GAxeman
14 GHorseman
2 GHero1

TOTAL = 100
```

---

# 25. Player 5 — Britania

Britania no utiliza caballería en esta composición.

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Bronze Spearman | `BBronzeSpearman` | 15 |
| Highlander | `BHighlander` | 5 |
| Bowman | `BBowman` | 15 |
| Javelineer | `BJavelineer` | 14 |
| Héroe | `BHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

```text
30 BBronzeSpearman
10 BHighlander
30 BBowman
28 BJavelineer
2 BHero1

TOTAL = 100
```

---

# 26. Player 6 — Germania

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Maceman | `TMaceman` | 20 |
| Archer | `TArcher` | 10 |
| Huntress | `THuntress` | 12 |
| Teuton Rider | `TTeutonRider` | 7 |
| Héroe | `THero1` | 1 |
| **Total** | | **50** |

Recompensa total:

```text
40 TMaceman
20 TArcher
24 THuntress
14 TTeutonRider
2 THero1

TOTAL = 100
```

---

# 27. Player 7 — Roma Republicana

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Hastatus | `RHastatus` | 18 |
| Archer | `RArcher` | 10 |
| Gladiator | `RGladiator` | 8 |
| Tribune | `RTribune` | 6 |
| Scout | `RScout` | 7 |
| Héroe republicano | `RHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

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

# 28. Player 8 — Egipto

Cada ejército contiene:

| Unidad | ID | Cantidad |
|---|---|---:|
| Guardian | `EGuardian` | 19 |
| Archer | `EArcher` | 10 |
| Axe Thrower | `EAxetrower` | 9 |
| Anubis Warrior | `EAnubisWarrior` | 5 |
| Chariot | `EChariot` | 6 |
| Héroe | `EHero1` | 1 |
| **Total** | | **50** |

Recompensa total:

```text
38 EGuardian
20 EArcher
18 EAxetrower
10 EAnubisWarrior
12 EChariot
2 EHero1

TOTAL = 100
```

`EChariot` cumple aquí el papel funcional que en otras civilizaciones ocupa la caballería.

El ID `EAxetrower` está escrito de ese modo en la investigación técnica del roster utilizada para este sistema; no debe corregirse automáticamente a una grafía inglesa más intuitiva sin verificar el ID real del juego.

---

# 29. Los héroes también se generan dos veces

Como la creación del héroe está dentro de:

```cpp
for (army = 0; army < 2; army += 1)
```

cada recompensa genera:

```text
1 héroe en el bloque A
+
1 héroe en el bloque B
=
2 héroes
```

Por tanto no se trata de:

```text
99 soldados + 1 héroe
```

sino de:

```text
98 unidades no heroicas
+
2 héroes
=
100 unidades
```

La Sequence no implementa ningún respawn posterior de esos héroes.

---

# 30. No se aplica `SetFood()`

A diferencia de `Fortresses_Main`, aquí tampoco aparece:

```cpp
u.SetFood(...)
```

La Sequence únicamente hace:

```cpp
u = Place(...);
u.SetLevel(TROOP_LEVEL);
forum.settlement.ForceAddUnit(u);
```

No modifica explícitamente el estado de alimentación inicial de la unidad.

La intención declarada del sistema es que estas tropas funcionen bajo las reglas normales de alimentación.

---

# 31. No existe regeneración

La recompensa es única.

Si el jugador pierde:

```text
70 de las 100 unidades
```

la Sequence no repone ninguna.

Si mueren ambos héroes:

```text
no reaparecen
```

Si todo el ejército es destruido:

```text
FCR_Rewarded sigue siendo 1
```

y el Foro no vuelve a generar tropas.

---

# 32. No existe relación con una defensa posterior del Foro

La Sequence sólo observa el cambio de propietario inicial.

No comprueba:

- enemigos alrededor;
- tropas propias alrededor;
- loyalty;
- número de defensores;
- si el Foro está siendo atacado;
- si el nuevo propietario conserva la ciudad.

Una vez detecta:

```text
neutral inicial
→ Player 1..8
```

entrega la recompensa y termina su responsabilidad sobre ese Foro.

---

# 33. No existe relación con el modo Zombies

Aunque esta Sequence aparece junto a sistemas de hordas en el proyecto, su condición de recompensa no depende de una Horda.

Su disparador es exclusivamente:

```text
Foro neutral al inicio
+
primera captura por Player 1..8
```

Por tanto:

```text
conquistar un Foro neutral sin que haya aparecido ningún zombie
→ también genera la recompensa
```

Es una mecánica independiente.

Si se mantiene activa junto al modo Zombies, ambas recompensas pueden coexistir si el otro sistema tiene su propio mecanismo de premio.

---

# 34. Qué sucede si otro jugador reconquista posteriormente el Foro

Supongamos:

```text
Player 3 conquista el Foro neutral
↓
recibe 100 tropas ibéricas
↓
FCR_Rewarded = 1
↓
Player 5 conquista después el mismo Foro
```

Player 5 no recibe nada.

La comprobación:

```cpp
if (rewarded == 1)
{
    continue;
}
```

impide cualquier segunda activación.

---

# 35. Qué sucede si dos Foros se conquistan casi simultáneamente

Cada edificio guarda su propio `FCR_Rewarded`.

Por tanto:

```text
Foro A conquistado por Player 1
Foro B conquistado por Player 6
```

pueden ser detectados dentro de la misma iteración general del controlador.

Sin embargo, la Sequence es secuencial: primero termina de crear la recompensa de un Foro y después continúa con el siguiente. En v2.0 cada unidad lleva un `Sleep(20)`, de modo que una recompensa completa añade aproximadamente 2 segundos de espera programada antes de que el bucle pueda terminar de procesar la siguiente recompensa pendiente.

No existe un estado global que limite el número de Foros recompensables; simplemente se procesan uno detrás de otro.

---

# 36. Qué sucede si hay nueve Foros neutrales

No hay ningún límite explícito de cantidad.

Si al iniciar la partida hay nueve Townhall de Player 15/16:

```text
forums.count = 9
```

los nueve quedan registrados.

Cada uno podrá entregar su propia recompensa una vez.

Con nueve Foros conquistados:

```text
9 × 100
=
900 unidades de recompensa
```

a lo largo de la partida.

Esto es relevante para el balance y el rendimiento.

---

# 37. Condiciones que deben cumplirse en el mapa

Para que esta Sequence funcione exactamente como está diseñada deben cumplirse varias condiciones.

## 37.1 Los Foros objetivo deben ser Player 15 o Player 16 al inicio

Si utilizan otro identificador neutral, no serán descubiertos.

## 37.2 Los Foros deben existir al arrancar

La lista `forums` se construye una sola vez.

Un Townhall creado dinámicamente después no se incorporaría automáticamente.

## 37.3 La asignación Player → civilización debe coincidir

Debe mantenerse:

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

Si cambia, hay que modificar las ramas `if (owner == N)`.

## 37.4 Debe existir una sola instancia de la Sequence

La configuración normal es:

```text
ForumCaptureReward_Main
└── Autorun allowed = Sí
```

No conviene ejecutar dos copias de la misma Sequence.

Aunque `FCR_Rewarded` reduce el riesgo de duplicación, no es una arquitectura pensada para controladores duplicados.

---

# 38. No hace falta crear Groups

Esta Sequence no depende de ningún Group manual.

No utiliza:

```cpp
Group("...")
```

ni:

```cpp
AddToGroup(...)
```

para la recompensa.

Por tanto, en el editor:

```text
Map
└── Groups
```

no hay que añadir nada para `ForumCaptureReward_Main`.

---

# 39. No hace falta crear Areas

Tampoco existe:

```cpp
ClassPlayerAreaObjs(...)
```

ni consultas a áreas con nombre.

No hay que crear:

```text
RewardArea_01
RewardArea_02
...
```

El Foro es la única referencia espacial que utiliza el código.

---

# 40. No hacen falta marcadores de aparición

Aunque el comentario habla de dos formaciones exteriores, el código actual no utiliza objetos de referencia externos.

No hay que colocar:

```text
RewardSpawn_Left
RewardSpawn_Right
```

ni ningún objeto similar.

Si se decide corregir más adelante el despliegue exterior, puede hacerse directamente mediante coordenadas calculadas; tampoco sería estrictamente necesario crear marcadores manuales.

---

# 41. Flujo completo de un Foro

El ciclo completo puede representarse así:

```text
INICIO DE PARTIDA
        ↓
¿BaseTownhall de Player 15/16?
        │
       Sí
        ↓
guardar referencia en forums
        ↓
esperar
        ↓
¿sigue siendo neutral?
        │
       Sí
        └────────────→ seguir esperando

        No
        ↓
¿owner está entre 1 y 8?
        │
       No
        └────────────→ seguir esperando

       Sí
        ↓
leer FCR_Rewarded
        ↓
¿ya vale 1?
        │
       Sí
        └────────────→ no hacer nada nunca más

       No
        ↓
FCR_Rewarded = 1
        ↓
ejecutar bloque army = 0
        ↓
crear 50 unidades
        ↓
ejecutar bloque army = 1
        ↓
crear otras 50 unidades
        ↓
TOTAL = 100
        ↓
el Foro queda marcado permanentemente
```

---

# 42. Diferencia principal respecto a `Fortresses_Main`

Las dos Sequences crean unidades, pero su filosofía es opuesta.

## `Fortresses_Main`

Las tropas son parte estructural de la fortaleza:

```text
SetNoAIFlag(true)
SetFeeding(false)
defensa automática
regeneración
órdenes reimpuestas
no son ejército libre
```

## `ForumCaptureReward_Main`

Las tropas son una recompensa para el jugador:

```text
sin SetNoAIFlag
sin SetFeeding(false)
sin controlador posterior
sin regeneración
sin defensa automática
uso libre
```

No conviene confundir ambos tipos de unidades.

---

# 43. Observación técnica que debe quedar documentada antes de dar la Sequence por cerrada

El código actual contiene una discrepancia objetiva entre comentario e implementación.

### El comentario afirma

```text
dos ejércitos de 50 alrededor del Foro
uno a cada lado
```

### El código calcula

```cpp
baseAX
baseAY
baseBX
baseBY
spawnX
spawnY
```

### Pero después crea todas las unidades con

```cpp
Place("Clase", forum.pos, owner);
```

y las introduce mediante:

```cpp
forum.settlement.ForceAddUnit(u);
```

Por tanto las coordenadas de los dos ejércitos no se usan.

Esta discrepancia **sigue presente en la versión canónica v2.0**: los comentarios y cálculos de formación exterior permanecen en el código, pero todas las llamadas reales a `Place()` continúan utilizando `forum.pos`.

Esto no requiere crear ningún elemento adicional en el editor. Es una cuestión del propio código.

Si el comportamiento deseado final es que los 100 soldados estén almacenados en el Foro, el cálculo de `SPAWN_GAP`, `FORMATION_WIDTH`, `FORMATION_Y_OFFSET`, `baseAX`, `baseAY`, `baseBX`, `baseBY`, `spawnX` y `spawnY` sobra.

Si el comportamiento deseado final es que aparezcan físicamente en dos formaciones fuera del Foro, habrá que modificar las llamadas a `Place()` y definir offsets reales de formación.

---

# 44. Preparación exacta en el editor

La instalación de esta Sequence queda reducida a:

```text
Map
└── Sequences
    └── ForumCaptureReward_Main
        ├── pegar código
        ├── Compile
        └── Autorun allowed = Sí
```

### Elementos adicionales

- **Groups:** ninguno.
- **Areas:** ninguna.
- **Holders adicionales:** ninguno.
- **Marcadores:** ninguno.
- **Puntos de spawn manuales:** ninguno.

### Comprobaciones antes de probar

1. Los Foros neutrales deben ser `BaseTownhall` o una de sus subclases culturales.
2. Deben comenzar como Player 15 o Player 16.
3. Los Players 1-8 deben corresponder a las civilizaciones codificadas en la Sequence.
4. La Sequence debe tener `Autorun allowed`.
5. Debe probarse conscientemente si se quiere el comportamiento real actual —100 unidades añadidas al Foro— o el comportamiento descrito en los comentarios —dos formaciones exteriores—, porque en esta versión no son lo mismo.

---

# 45. Resumen funcional

`ForumCaptureReward_Main` realiza exactamente este trabajo:

```text
descubre Foros neutrales al inicio
        ↓
conserva sus referencias
        ↓
vigila cambios de propietario cada 2,5 s
        ↓
detecta primera captura por Player 1..8
        ↓
marca el Foro como recompensado
        ↓
selecciona composición por número de Player
        ↓
crea dos bloques de 50 unidades nivel 12
con Sleep(20) entre creaciones
        ↓
añade las unidades al Settlement del Foro
        ↓
no vuelve a controlar esas tropas
        ↓
ese Foro no puede recompensar de nuevo
```

Es una Sequence autónoma que no necesita Groups ni Areas manuales y que puede gestionar simultáneamente todos los Townhall que comiencen la partida como Player 15 o Player 16.

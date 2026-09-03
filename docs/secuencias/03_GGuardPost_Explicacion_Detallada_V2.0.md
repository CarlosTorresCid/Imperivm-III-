# Secuencia 3 — `GGuardPost`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).** En el escenario canónico la Sequence aparece en el editor como `GGuardPost`. La cabecera interna del Source todavía conserva `Sequence: GuardPosts_Main`; en este documento se usa `GGuardPost` como nombre canónico del objeto Sequence y `GuardPosts_Main` únicamente cuando se cita literalmente la cabecera histórica del código.

`GGuardPost` es la Sequence encargada de gestionar todos los `GGuardPost` del mapa como posiciones defensivas persistentes.

El sistema conserva intacta la defensa nativa del propio `GGuardPost` —sus sentinelas/arqueros originales— y añade una segunda capa defensiva formada por **10 guardianes terrestres externos**. Estos guardianes dependen del jugador que controla el puesto, salen a combatir cuando aparecen enemigos, regresan a posiciones defensivas cuando termina el combate y se regeneran lentamente mientras el puesto siga en manos del mismo propietario.

La captura del Guard Post queda bloqueada mientras sobreviva al menos uno de esos 10 guardianes. Cuando muere toda la escolta, la Sequence vuelve a habilitar la captura nativa y espera a que otro jugador conquiste el puesto. En ese momento crea automáticamente una nueva escolta de la civilización del nuevo propietario.

La Sequence debe configurarse con **`Autorun allowed`**.

---

## 1. Preparación necesaria en el editor

Para utilizar esta Sequence hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── GGuardPost
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

### No hay que crear

- Groups manuales para los Guard Posts.
- Groups manuales para sus guardianes.
- Areas.
- Holders.
- Marcadores de posición.
- Puntos de aparición.
- Una Sequence distinta por cada Guard Post.

La propia Sequence encuentra automáticamente todos los `GGuardPost` del mapa y crea un Group dinámico independiente para la escolta de cada uno.

---

# 2. Qué edificios controla

La búsqueda se realiza exclusivamente sobre:

```cpp
ClassPlayerObjs("GGuardPost", p)
```

Por tanto esta Sequence controla únicamente objetos de clase:

```text
GGuardPost
```

No controla:

- `TOutpost`
- `GOutpost`
- `BOutpost`
- `IOutpost`
- `COutpost`
- `ROutpost`
- `EOutpost`
- Townhalls/Foros
- `TTent`
- torres
- murallas
- puertas

Los Outposts culturales normales pertenecen al sistema `Fortresses_Main`, no a esta Sequence.

---

# 3. Por qué `GGuardPost` necesita una Sequence separada

`GGuardPost` no debe tratarse igual que un Outpost convencional.

La razón principal es:

```text
GGuardPost → max_units = 0
```

Eso significa que no está diseñado para almacenar tropas normales en su `Settlement`.

Por tanto esta Sequence **no utiliza**:

```cpp
post.settlement.ForceAddUnit(u);
```

ni:

```cpp
enter_tent
```

para los guardianes terrestres.

La escolta permanece físicamente fuera del edificio durante toda la partida.

El `GGuardPost` conserva además su propio sistema nativo de sentinelas, que esta Sequence no sustituye.

---

# 4. Defensa total del Guard Post

El sistema combina dos capas:

```text
GGuardPost
│
├── defensa nativa
│   └── 12 sentinelas/arqueros del propio juego
│
└── defensa añadida por `GGuardPost`
    └── 10 guardianes terrestres
```

La Sequence sólo administra la segunda capa.

No crea, elimina ni regenera los sentinelas nativos.

El cambio de propietario del propio `GGuardPost` sigue permitiendo que su comportamiento original gestione esos sentinelas.

---

# 5. Composición de los guardianes por civilización

La escolta siempre está formada por:

```text
5 unidades del tipo 1
+
5 unidades del tipo 2
=
10 guardianes
```

La composición depende del número de jugador propietario.

| Player | Civilización | Pool 1 | Pool 2 |
|---:|---|---|---|
| 1 | Roma Imperial | 5 `RHastatus` | 5 `RPraetorian` |
| 2 | Cartago | 5 `CNoble` | 5 `CBerberAssassin` |
| 3 | Iberia | 5 `IDefender` | 5 `IEliteGuard` |
| 4 | Galia | 5 `GWomanWarrior` | 5 `GAxeman` |
| 5 | Britania | 5 `BBronzeSpearman` | 5 `BHighlander` |
| 6 | Germania | 5 `TMaceman` | 5 `THuntress` |
| 7 | Roma Republicana | 5 `RHastatus` | 5 `RTribune` |
| 8 | Egipto | 5 `EGuardian` | 5 `EAnubisWarrior` |

---

# 6. Mapeo fijo de jugadores

La Sequence no utiliza `GetPlayerRace()`.

La composición se decide mediante:

```cpp
if (owner == 1)
...
if (owner == 2)
...
```

Por tanto asume este reparto:

```text
Player 1 = Roma Imperial
Player 2 = Cartago
Player 3 = Iberia
Player 4 = Galia
Player 5 = Britania
Player 6 = Germania
Player 7 = Roma Republicana
Player 8 = Egipto
```

Esta correspondencia debe mantenerse en el mapa.

Si se reutiliza la Sequence en otro escenario con números de jugador diferentes, habrá que modificar estas ramas.

---

# 7. Parámetros globales

La configuración principal es:

```cpp
GUARDIAN_LEVEL = 12;
REGEN_INTERVAL = 30000;
CONTROL_INTERVAL = 2000;
```

## `GUARDIAN_LEVEL`

```text
12
```

Todos los guardianes creados por esta Sequence son nivel 12.

## `REGEN_INTERVAL`

```text
30.000 ms
```

En condiciones de paz se regenera una unidad cada 30 segundos.

## `CONTROL_INTERVAL`

```text
2.000 ms
```

El controlador principal revisa todos los Guard Posts aproximadamente **una vez cada 2 segundos**.

La versión v2.0 reduce así el barrido permanente respecto a revisiones anteriores. Además, las órdenes ya no se reescriben indiscriminadamente en cada ciclo: antes de emitir `move` o `advance` se comprueba el comando actual del defensor.

Esto permite:

- detectar ataques con una latencia máxima aproximada de 2 segundos;
- controlar el estado de captura;
- detener la regeneración cuando aparece una amenaza;
- reducir llamadas repetidas a `SetCommand()`.

---

# 8. Descubrimiento automático de todos los Guard Posts

La Sequence construye una lista:

```cpp
ObjList posts;
```

Después recorre:

```cpp
for (p = 1; p <= 16; p += 1)
```

y añade todos los objetos `GGuardPost` encontrados:

```cpp
posts.AddList(
    ClassPlayerObjs(
        "GGuardPost",
        p
    )
    .GetObjList()
);
```

La búsqueda se realiza una sola vez al arrancar.

### Consecuencia

Todos los `GGuardPost` que deban participar en el sistema deben existir ya al inicio de la partida.

Un Guard Post creado dinámicamente después no entraría automáticamente en `posts`.

---

# 9. Las referencias sobreviven a los cambios de propietario

La lista `posts` conserva la referencia al objeto aunque cambie `.player`.

Por ejemplo:

```text
GGuardPost neutral
Player 15
↓
guardado en posts
↓
Player 4 lo conquista
↓
el mismo objeto pasa a Player 4
↓
continúa dentro de posts
```

No hace falta volver a buscar el edificio después de cada captura.

---

# 10. Group dinámico de cada Guard Post

Cada puesto tiene un Group independiente.

El nombre se construye mediante:

```cpp
groupName =
    "__GP_"
    +
    post.pos.x
    +
    "_"
    +
    post.pos.y;
```

Ejemplo conceptual:

```text
__GP_14500_9200
```

Las unidades se registran con:

```cpp
u.AddToGroup(groupName);
```

y se recuperan posteriormente con:

```cpp
garrison =
    Group(groupName)
    .GetObjList();
```

### Importante

**No hay que crear estos Groups en el editor.**

Son Groups dinámicos utilizados internamente por la Sequence.

---

# 11. Estado persistente de cada Guard Post

La Sequence utiliza `EnvReadInt()` y `EnvWriteInt()` para almacenar información directamente sobre cada edificio.

Las claves son:

| Variable | Función |
|---|---|
| `GP_LastOwner` | Último propietario reconocido por la Sequence |
| `GP_Regen` | Temporizador de regeneración |
| `GP_Turn` | Indica qué pool debe regenerarse a continuación |
| `GP_AwaitingCapture` | Indica que han muerto los 10 guardianes y el puesto espera captura |
| `GP_Init` | Indica si el puesto ya está bajo control del sistema personalizado |

Cada Guard Post mantiene su propio estado.

---

# 12. Preparación inicial de cada puesto

Antes de entrar en el bucle permanente, la Sequence recorre todos los `GGuardPost`.

Para cada uno obtiene:

```cpp
post = posts[i].AsBuilding();
owner = post.player;
```

Después construye su `groupName` y guarda estado inicial:

```cpp
GP_LastOwner
GP_Regen
GP_Turn
GP_AwaitingCapture
```

---

# 13. Qué ocurre si el Guard Post empieza neutral

La condición es:

```cpp
if (
    owner < 1
    ||
    owner > 8
)
```

En ese caso:

```cpp
post.settlement.AllowCapture(true);
```

y:

```cpp
GP_Init = 0;
```

Después la Sequence no crea guardianes.

El resultado es:

```text
GGuardPost neutral
↓
sentinelas nativos intactos
↓
sin escolta terrestre añadida
↓
captura nativa habilitada
```

Por tanto la primera conquista se realiza mediante el comportamiento original del juego.

---

# 14. Qué ocurre si un Guard Post empieza ya conquistado

Si al iniciar la partida:

```text
owner = 1..8
```

la Sequence interpreta que el Guard Post ya pertenece a un jugador real.

En ese caso:

1. selecciona la composición según el Player;
2. crea 5 + 5 guardianes;
3. bloquea la captura;
4. marca el puesto como inicializado.

Por tanto la Sequence soporta Guard Posts que ya pertenezcan a jugadores desde el segundo 0.

---

# 15. Posición inicial de los dos pools

Las primeras cinco unidades aparecen en:

```cpp
post.pos + Point(-400 + j * 200, 450)
```

con:

```text
j = 0..4
```

Por tanto sus posiciones X relativas son:

```text
-400
-200
0
+200
+400
```

y todas están a:

```text
Y = +450
```

respecto al Guard Post.

El segundo pool utiliza:

```cpp
post.pos + Point(-400 + j * 200, -450)
```

Es decir:

```text
Y = -450
```

El despliegue inicial queda aproximadamente así:

```text
Pool 1

●   ●   ●   ●   ●
        |
        |
     Guard Post
        |
        |
●   ●   ●   ●   ●

Pool 2
```

---

# 16. Configuración de cada guardián

Después de `Place()` se ejecuta:

```cpp
u.SetLevel(GUARDIAN_LEVEL);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
u.AddToGroup(groupName);
```

Cada llamada cumple una función.

## `SetLevel(12)`

Todos los guardianes son nivel 12.

## `SetFood(20)`

Reciben comida inicial.

## `SetFeeding(false)`

No dependen del sistema normal de alimentación.

No consumen comida y no mueren de hambre.

## `SetNoAIFlag(true)`

La IA estratégica no puede incorporarlos a sus ejércitos.

## `AddToGroup(groupName)`

Los vincula al Guard Post concreto.

## Creación escalonada con `Sleep(20)`

La versión v2.0 añade después de **cada guardián creado**:

```cpp
Sleep(20);
```

La escolta completa son 10 unidades, por lo que una creación completa introduce aproximadamente:

```text
10 × 20 ms = 200 ms
```

de espera programada acumulada.

Este pequeño escalonado se utiliza tanto en la preparación inicial como después de una conquista y evita concentrar diez operaciones `Place()` consecutivas en una única sección atómica del script.

---

# 17. Por qué no se utiliza `ForceAddUnit()`

El código lo evita deliberadamente.

La razón es:

```text
GGuardPost
max_units = 0
```

Por tanto los guardianes permanecen siempre fuera del edificio.

No existe ningún intento de almacenarlos dentro del `Settlement`.

---

# 18. Bloqueo de captura mientras existen guardianes

Después de crear los 10 guardianes se ejecuta:

```cpp
post
    .settlement
    .AllowCapture(false);
```

Esto bloquea la captura del Guard Post.

La regla general del sistema es:

```text
guardianes > 0
→ AllowCapture(false)

guardianes = 0
→ AllowCapture(true)
```

Por tanto para capturar el puesto es obligatorio destruir primero toda la escolta terrestre añadida por la Sequence.

---

# 19. Inicio del bucle permanente

Después de la preparación inicial comienza:

```cpp
while (1)
{
    Sleep(CONTROL_INTERVAL);
    ...
}
```

Cada 2 segundos se recorren todos los Guard Posts.

Para cada uno se vuelve a leer:

```cpp
owner
initialized
lastOwner
awaitingCapture
```

Esto permite detectar:

- primera conquista;
- reconquista;
- muerte de guardianes;
- aparición de enemigos;
- fin del combate;
- necesidad de regeneración.

---

# 20. Guard Post que todavía sigue neutral

Dentro del bucle se comprueba:

```cpp
if (
    owner > 8
    &&
    initialized == 0
)
```

Mientras continúe neutral:

```cpp
AllowCapture(true);
GP_LastOwner = owner;
continue;
```

La Sequence no interviene.

Esto mantiene intacta la primera fase nativa.

---

# 21. Detección de primera conquista

La condición principal es:

```cpp
owner >= 1
&& owner <= 8
&& (
    initialized == 0
    ||
    owner != lastOwner
)
```

Esta condición cubre dos situaciones:

### Primera conquista

```text
GP_Init = 0
↓
owner pasa a 1..8
```

### Reconquista

```text
GP_Init = 1
↓
owner cambia respecto a GP_LastOwner
```

En ambos casos se crea una nueva escolta completa.

---

# 22. Selección de tropas del nuevo propietario

Al detectar una conquista, la Sequence vuelve a seleccionar:

```cpp
cls1
cls2
```

según el nuevo `owner`.

Ejemplo:

```text
Guard Post pertenecía a Player 3
↓
mueren sus 10 guardianes
↓
Player 6 conquista
↓
owner = 6
↓
cls1 = TMaceman
cls2 = THuntress
```

La nueva guarnición será germana aunque el puesto anteriormente fuese controlado por Iberia.

A diferencia de `Fortresses_Main`, aquí la composición depende de la civilización del **propietario**, no de una cultura fija del edificio.

---

# 23. Limpieza del Group anterior al cambiar de propietario

Al detectar una primera conquista o un cambio de propietario, la versión v2.0 recupera el Group dinámico:

```cpp
garrison =
    Group(groupName)
    .GetObjList();

garrison.ClearDead();
```

Después añade una protección que no estaba descrita en la documentación anterior:

```cpp
for (j = 0; j < garrison.count; j += 1)
{
    garrison[j].RemoveFromGroup(groupName);
}
```

En una captura normal este Group debería estar vacío, porque `AllowCapture(true)` sólo se habilita después de morir los diez guardianes.

La limpieza existe como **seguridad ante un cambio externo o inesperado de propietario**.

Si quedasen supervivientes del dueño anterior:

- **no se matan**;
- **no cambian de Player**;
- **no se transfieren al nuevo dueño**;
- se eliminan únicamente de `__GP_X_Y`;
- dejan de ser controlados como guardianes automáticos de ese puesto.

Después se crea la nueva escolta 5 + 5 para el propietario actual.

Esto evita que defensores antiguos y nuevos permanezcan mezclados dentro del mismo Group dinámico.

---

# 24. Creación inmediata de la nueva escolta

Después de la conquista se crean:

```text
5 unidades cls1
+
5 unidades cls2
```

La escolta se reconstruye completa en ese mismo procesamiento de conquista; no se utiliza la regeneración de 30 segundos para devolverla poco a poco.

En v2.0, cada `Place()` va seguido de:

```cpp
Sleep(20);
```

por lo que las diez unidades se generan de forma ligeramente escalonada, con unos 200 ms de espera programada acumulada.

El nuevo propietario termina ese proceso con:

```text
10 guardianes
```

---

# 25. Reinicio del estado tras una conquista

Después de crear la nueva escolta se actualizan:

```text
GP_LastOwner = nuevo propietario
GP_Init = 1
GP_AwaitingCapture = 0
GP_Regen = 0
GP_Turn = 1
```

Y se vuelve a ejecutar:

```cpp
AllowCapture(false);
```

Así empieza un nuevo ciclo completo.

---

# 26. Estado `GP_AwaitingCapture`

Esta variable es especialmente importante.

Cuando los 10 guardianes han muerto:

```text
GP_AwaitingCapture = 1
```

El Guard Post entra en un estado intermedio:

```text
guarnición destruida
↓
captura habilitada
↓
sin regeneración
↓
esperando que post.player cambie
```

Mientras ese estado está activo:

```cpp
AllowCapture(true);
GP_Regen = 0;
continue;
```

La Sequence no intenta reconstruir la escolta.

---

# 27. Por qué una guarnición destruida no reaparece antes de la conquista

Esta regla evita que un atacante destruya los 10 guardianes pero tenga que volver a luchar contra una nueva escolta antes de poder capturar el puesto.

El flujo es:

```text
10 guardianes
↓
mueren todos
↓
AllowCapture(true)
↓
GP_AwaitingCapture = 1
↓
regeneración detenida
↓
el puesto queda abierto
↓
espera a que cambie post.player
```

No hay regeneración hasta que otro jugador tome realmente el edificio.

---

# 28. Qué ocurre si nadie conquista el puesto después de matar a los 10 guardianes

El sistema permanece indefinidamente en:

```text
GP_AwaitingCapture = 1
```

Por tanto:

- no reaparecen guardianes;
- la captura permanece habilitada;
- la Sequence espera un cambio de propietario.

El puesto no se rearma automáticamente aunque los atacantes se retiren.

Este comportamiento es deliberado según los comentarios de la Sequence.

---

# 29. Detección de enemigos

Si el Guard Post sigue defendido, la Sequence busca enemigos dentro de:

```cpp
post.range
```

Primero:

```cpp
ObjsInRange(
    post,
    "Unit",
    post.range
);
```

Después filtra:

```cpp
EnemyObjs(owner, "Military")
EnemyObjs(owner, "BaseMage")
```

Se consideran, por tanto:

- tropas militares enemigas;
- magos enemigos.

---

# 30. Exclusión de sentinelas enemigos

Después se ejecuta:

```cpp
qEnemies =
    Subtract(
        qEnemies,
        EnemyObjs(
            owner,
            "Sentry"
        )
    );
```

Los `Sentry` no cuentan como una fuerza atacante convencional para este sistema.

---

# 31. Las catapultas también cuentan como ataque

La Sequence hace una segunda consulta:

```cpp
ObjsInRange(
    post,
    "Building",
    post.range
)
```

y la intersecta con:

```cpp
EnemyObjs(
    owner,
    "Catapult"
)
```

Después une esos resultados a `qEnemies`.

Por tanto el Guard Post considera que está bajo ataque si hay:

```text
Military enemigo
BaseMage enemigo
Catapult enemiga
```

dentro de `post.range`.

---

# 32. Reconstrucción de los dos pools

El Group de guarnición se lee mediante:

```cpp
garrison =
    Group(groupName)
    .GetObjList();

garrison.ClearDead();
```

Después:

```cpp
pool1.Clear();
pool2.Clear();
```

y las unidades se clasifican por `IsHeirOf(cls1)` o `IsHeirOf(cls2)`.

Finalmente:

```cpp
count1 = pool1.count;
count2 = pool2.count;
```

La Sequence puede saber, por ejemplo:

```text
Pool 1 = 3/5
Pool 2 = 5/5
```

y regenerar únicamente lo que falta.

---

# 33. Qué ocurre cuando mueren los 10 guardianes

La condición es:

```cpp
if (
    garrison.count == 0
)
```

Entonces:

```cpp
post.settlement.AllowCapture(true);
```

y:

```cpp
GP_AwaitingCapture = 1;
GP_Regen = 0;
```

Después:

```cpp
continue;
```

A partir de ese instante:

```text
el Guard Post queda capturable
```

y la Sequence deja de regenerar.

---

# 34. Qué ocurre mientras quede al menos un guardián

Si:

```text
garrison.count > 0
```

se ejecuta:

```cpp
post.settlement.AllowCapture(false);
```

Por tanto incluso si queda sólo una unidad de las diez:

```text
1 guardián vivo
→ captura bloqueada
```

El atacante debe eliminar toda la escolta.

---

# 35. Defensa automática durante el combate

Si:

```cpp
enemies.count > 0
```

la regeneración se reinicia:

```cpp
GP_Regen = 0;
```

Después se recorren todos los guardianes.

Si una unidad está fuera de:

```cpp
post.range
```

el sistema pretende hacerla regresar al puesto, pero en v2.0 evita repetir la orden si ya está ejecutando un `move`:

```cpp
if(defender.command != "move")
{
    defender.SetCommand(
        "move",
        post.pos
    );
}
```

Si el guardián sigue dentro del radio defensivo, sólo se emite un nuevo `advance` cuando no está ya realizando una orden de combate compatible:

```cpp
if(
    defender.command != "advance"
    &&
    defender.command != "attack"
    &&
    defender.command != "engage"
)
{
    defender.SetCommand(
        "advance",
        enemies[0].pos
    );
}
```

Por tanto la versión v2.0 mantiene la autoridad defensiva de la Sequence, pero **reduce la reimposición constante de órdenes**.

---

# 36. Qué enemigo atacan

La orden utiliza:

```cpp
enemies[0].pos
```

Es decir, todos los guardianes reciben inicialmente una orden de `advance` hacia el primer enemigo de la lista.

La Sequence no reparte blancos de forma individual ni calcula prioridades diferentes por tipo de unidad.

---

# 37. Qué ocurre si un guardián intenta alejarse

La Sequence controla:

```cpp
post.DistTo(defender)
```

Si supera:

```text
post.range
```

la orden de combate se sustituye por:

```cpp
move → post.pos
```

Esto evita que los guardianes persigan indefinidamente a enemigos que se retiran.

---

# 38. Papel defensivo y límite del control de órdenes en v2.0

Los guardianes siguen concebidos como **defensores estructurales del Guard Post**, no como un ejército de recompensa.

Dos mecanismos los mantienen asociados al puesto:

```cpp
u.SetNoAIFlag(true);
```

evita que la IA estratégica los incorpore a sus ofensivas normales, y el controlador revisa su situación aproximadamente cada 2 segundos.

Sin embargo, la versión v2.0 ya **no sobrescribe cualquier orden en cada ciclo**. Comprueba únicamente el tipo de comando actual:

```cpp
defender.command
```

antes de emitir otro `move` o `advance`.

Esto reduce carga y evita spam de órdenes, pero introduce una limitación que conviene documentar con precisión:

> Si un guardián ya tiene una orden `move`, el código no comprueba el destino de ese `move`; sólo ve que el comando ya es `"move"` y no lo sustituye.

Por tanto el código v2.0 expresa claramente una **intención de guarnición defensiva**, pero el confinamiento frente a órdenes manuales no es tan estricto como en una implementación que verificase también el destino real de la orden.

No afecta al control automático de la IA gracias a `SetNoAIFlag(true)`, pero es un detalle relevante para pruebas con un jugador humano.

---

# 39. Comportamiento cuando termina el combate

Cuando:

```text
enemies.count == 0
```

la Sequence entra en estado de paz.

Como `GGuardPost` no admite tropas dentro, no se utiliza:

```cpp
enter_tent
```

En su lugar los guardianes regresan a dos posiciones exteriores.

La versión v2.0 sólo emite la orden si el defensor no está ya ejecutando un `move`:

```cpp
if(defender.command != "move")
{
    defender.SetCommand(...);
}
```

Esto evita repetir la misma clase de orden cada 2 segundos. Como se indicó en la sección anterior, la comprobación se hace por **tipo de comando**, no por destino.

---

# 40. Posiciones de reposo del Pool 1

Todos los miembros de `pool1` reciben:

```cpp
defender.SetCommand(
    "move",
    post.pos + Point(0, 450)
);
```

Por tanto se concentran aproximadamente:

```text
450 unidades al norte
```

del Guard Post.

---

# 41. Posiciones de reposo del Pool 2

Todos los miembros de `pool2` reciben:

```cpp
defender.SetCommand(
    "move",
    post.pos + Point(0, -450)
);
```

Por tanto se concentran aproximadamente:

```text
450 unidades al sur
```

del Guard Post.

---

# 42. Diferencia entre el despliegue inicial y el reposo posterior

Al crearse inicialmente, cada pool forma una línea de cinco unidades:

```text
X = -400, -200, 0, +200, +400
```

Sin embargo, después de un combate todos los miembros de cada pool reciben exactamente el mismo punto:

```text
Pool 1 → Point(0, 450)
Pool 2 → Point(0, -450)
```

Por tanto la formación inicial no se conserva.

### Efecto práctico

Después del primer movimiento o combate, las unidades de cada pool tenderán a agruparse alrededor de un mismo punto.

Si se quiere conservar permanentemente una línea de cinco posiciones distintas, habría que modificar la lógica de reposo para asignar offsets diferentes a cada unidad.

No hace falta crear Groups ni Areas para corregirlo; sería un cambio interno del código.

---

# 43. Regeneración en paz

La regeneración sólo se ejecuta cuando:

```text
no hay enemigos
```

y falta alguna unidad:

```cpp
count1 < max1
||
count2 < max2
```

El temporizador:

```text
GP_Regen
```

aumenta en bloques de 2.000 ms por cada ciclo de control.

Cuando alcanza:

```text
30.000 ms
```

se genera exactamente una unidad.

Después:

```text
GP_Regen = 0
```

y comienza otro ciclo.

---

# 44. Tiempo necesario para recuperar bajas

La regeneración es lineal:

```text
1 baja  → 30 segundos
2 bajas → 60 segundos
3 bajas → 90 segundos
...
```

Si han muerto 6 guardianes:

```text
6 × 30 s
=
180 segundos
=
3 minutos
```

siempre que no aparezca ningún enemigo durante ese periodo.

---

# 45. Qué sucede si comienza otro ataque durante la regeneración

En cuanto se detectan enemigos:

```cpp
GP_Regen = 0;
```

Por tanto el progreso parcial se pierde.

Ejemplo:

```text
han pasado 25 segundos
↓
aparece enemigo
↓
GP_Regen = 0
↓
termina el ataque
↓
hay que esperar otros 30 segundos completos
```

No puede generarse una nueva unidad durante un combate.

---

# 46. Alternancia entre los dos pools

Si faltan unidades en ambos grupos, la Sequence utiliza:

```text
GP_Turn
```

para alternar.

Por ejemplo:

```text
falta Pool 1 y Pool 2
↓
30 s → Pool 1
↓
30 s → Pool 2
↓
30 s → Pool 1
↓
30 s → Pool 2
```

Así se evita completar primero un tipo entero y dejar el segundo vacío durante demasiado tiempo.

---

# 47. Si sólo falta un tipo

Si:

```text
Pool 1 = 5/5
Pool 2 = 3/5
```

el sistema no alterna.

Regenera directamente:

```text
Pool 2
```

hasta recuperar el máximo.

Lo mismo ocurre a la inversa.

---

# 48. Posición de aparición de unidades regeneradas

Las unidades regeneradas no utilizan la formación completa de cinco posiciones.

Pool 1 aparece en:

```cpp
post.pos + Point(0, 450)
```

Pool 2 aparece en:

```cpp
post.pos + Point(0, -450)
```

Esto coincide con las posiciones de reposo.

---

# 48.1. Escalonado de la regeneración en v2.0

Cuando `GP_Regen` alcanza los 30 segundos y se crea una nueva unidad, el código actual añade también:

```cpp
Sleep(20);
```

después de registrarla en el Group dinámico.

Como sólo se regenera **una unidad por ciclo de regeneración**, el impacto temporal es mínimo, pero mantiene la misma política de creación escalonada utilizada en las escoltas completas.

---

# 49. Ciclo completo de un Guard Post neutral

El funcionamiento completo es:

```text
INICIO
↓
GGuardPost neutral
↓
sentinelas nativos
↓
sin guardianes terrestres
↓
AllowCapture(true)
↓
primera conquista por Player 1..8
↓
crear 5 + 5 guardianes
↓
AllowCapture(false)
↓
estado defendido
```

---

# 50. Ciclo durante una defensa normal

```text
10 guardianes
↓
aparece enemigo
↓
GP_Regen = 0
↓
guardianes salen con advance
↓
combate
```

Si la defensa gana:

```text
enemigos = 0
↓
guardianes vuelven a posiciones exteriores
↓
comienza regeneración de bajas
↓
recupera 5 + 5
```

---

# 51. Ciclo de conquista

Si los atacantes destruyen los 10 guardianes:

```text
garrison.count = 0
↓
AllowCapture(true)
↓
GP_AwaitingCapture = 1
↓
sin regeneración
↓
esperar cambio de post.player
```

Cuando otro jugador conquista:

```text
owner != GP_LastOwner
↓
crear nueva escolta 5 + 5
↓
GP_AwaitingCapture = 0
↓
AllowCapture(false)
↓
nuevo ciclo
```

---

# 52. Reconquista ilimitada

El sistema no tiene un contador de conquistas.

Por tanto puede repetirse:

```text
Player 1
↓
Player 4
↓
Player 6
↓
Player 3
↓
Player 8
...
```

Cada nuevo propietario recibe su composición correspondiente.

---

# 53. Relación con los sentinelas nativos

La Sequence no administra directamente:

```text
Sentry
```

ni intenta recrear los 12 sentinelas originales.

Ese sistema se deja al comportamiento nativo del edificio.

La responsabilidad queda separada:

```text
motor original
→ sentinelas del GGuardPost

GGuardPost
→ guardianes terrestres externos
```

---

# 54. Cambio inesperado de propietario mientras quedan guardianes

El funcionamiento normal presupone:

```text
garrison.count > 0
→ AllowCapture(false)
```

por lo que una conquista nativa no debería producirse con guardianes vivos.

Aun así, la versión v2.0 incluye una protección específica para cambios externos de `.player`.

Cuando detecta:

```cpp
owner != lastOwner
```

recupera el Group anterior, limpia muertos y ejecuta:

```cpp
for (j = 0; j < garrison.count; j += 1)
{
    garrison[j].RemoveFromGroup(groupName);
}
```

Después crea los diez guardianes del nuevo propietario.

### Consecuencia

Los supervivientes anteriores **no desaparecen** del mapa y tampoco cambian de bando, pero dejan de formar parte del sistema automático de ese Guard Post.

Esto es más seguro que la versión documentada anteriormente, porque evita mezclar dentro de `__GP_X_Y` unidades de dos propietarios diferentes.

Sigue siendo recomendable que ninguna otra Sequence fuerce `SetPlayer()` sobre un `GGuardPost` defendido salvo que sea deliberado.

---

# 55. No se comprueba la presencia de defensores normales del propietario

A diferencia de `Fortresses_Main`, esta Sequence no utiliza una lista `friends`.

La captura del Guard Post depende exclusivamente de la escolta especial:

```text
queda al menos 1 guardián
→ captura bloqueada

mueren los 10
→ captura habilitada
```

No se comprueba si el propietario tiene otros soldados normales alrededor del Guard Post.

Esto significa que, una vez muertos los 10 guardianes, el edificio puede quedar capturable aunque exista un ejército propio del propietario defendiendo físicamente la zona.

Esa es una diferencia de diseño respecto al sistema de fortalezas.

---

# 56. No existe una captura manual implementada por la Sequence

`GGuardPost` no decide:

```text
newOwner = ...
```

ni utiliza:

```cpp
post.SetPlayer(newOwner);
```

para realizar la conquista.

La Sequence únicamente controla:

```cpp
AllowCapture(false)
```

o:

```cpp
AllowCapture(true)
```

La captura real sigue siendo responsabilidad del comportamiento nativo del `GGuardPost`.

Esto simplifica considerablemente la lógica.

---

# 57. No existen Areas necesarias

No se utiliza ninguna llamada del tipo:

```cpp
ClassPlayerAreaObjs(...)
```

ni nombres de áreas.

Toda la detección espacial se basa en:

```cpp
ObjsInRange(post, ..., post.range)
```

Por tanto no hay que crear Areas en el editor.

---

# 58. No existen Holders necesarios

Los guardianes no se introducen en ningún edificio.

No hay necesidad de definir Holders o grupos de edificios auxiliares.

El propio `GGuardPost` encontrado mediante `ClassPlayerObjs()` es suficiente como referencia central.

---

# 59. No existen marcadores de posición

Las posiciones se calculan respecto a:

```cpp
post.pos
```

mediante `Point(...)`.

Por ejemplo:

```cpp
post.pos + Point(0, 450)
```

Por tanto no hay que colocar objetos decorativos o marcadores para indicar dónde deben aparecer los guardianes.

---

# 60. Condiciones que debe cumplir el mapa

Para utilizar esta Sequence sin modificaciones:

1. Los Guard Posts deben ser realmente objetos `GGuardPost`.
2. Deben existir al comenzar la partida.
3. Los neutrales deben utilizar un Player del rango que el sistema interprete como no jugable, normalmente 15/16.
4. Los Players 1-8 deben corresponder al mapeo cultural codificado.
5. `GGuardPost` debe ejecutarse una sola vez con `Autorun allowed`.
6. No debe existir otra Sequence que fuerce continuamente `AllowCapture()` sobre los mismos Guard Posts.
7. No conviene que otra Sequence ejecute `SetPlayer()` sobre esos edificios mientras tengan guardianes vivos.

---

# 61. Preparación exacta en el editor

La estructura necesaria es:

```text
Map
└── Sequences
    └── GGuardPost
        ├── pegar código
        ├── Compile
        └── Autorun allowed = Sí
```

### Nombre de la Sequence en v2.0

En el escenario canónico actual el objeto del editor se llama:

```text
GGuardPost
```

aunque la primera línea descriptiva del Source conserva históricamente:

```text
Sequence: GuardPosts_Main
```

Para GitHub y para la documentación v2.0 se recomienda usar **`GGuardPost`** como nombre externo canónico, de forma que coincida con el escenario real.

### Elementos adicionales

- **Groups manuales:** ninguno.
- **Areas:** ninguna.
- **Holders:** ninguno.
- **Marcadores de aparición:** ninguno.
- **Puntos de defensa manuales:** ninguno.
- **Sequences adicionales por puesto:** ninguna.

---

# 62. Resumen funcional

`GGuardPost` implementa este ciclo:

```text
descubrir todos los GGuardPost
        ↓
guardar propietario inicial
        ↓
si neutral
    └── dejar comportamiento nativo intacto
        ↓
primera conquista por Player 1..8
        ↓
crear 5 + 5 guardianes externos
con Sleep(20) entre unidades
        ↓
SetFeeding(false)
SetNoAIFlag(true)
        ↓
AllowCapture(false)
        ↓
vigilar enemigos cada 2 s
        ↓
si hay ataque
    ├── detener regeneración
    ├── guardianes salen a combatir
    └── impedir que se alejen
        ↓
si termina el combate
    ├── guardianes regresan alrededor del puesto
    └── regenerar una baja cada 30 segundos
        ↓
si mueren los 10
    ├── AllowCapture(true)
    ├── GP_AwaitingCapture = 1
    └── detener regeneración
        ↓
esperar conquista nativa
        ↓
detectar nuevo propietario
        ↓
crear nueva escolta cultural 5 + 5
        ↓
AllowCapture(false)
        ↓
repetir indefinidamente
```

La Sequence mantiene intactos los sentinelas nativos del `GGuardPost` y añade una segunda capa defensiva completamente independiente, sin necesidad de preparar Groups, Areas o Holders manuales.

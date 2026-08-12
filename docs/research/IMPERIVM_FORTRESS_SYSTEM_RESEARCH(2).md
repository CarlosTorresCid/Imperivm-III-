# Investigación fase 2: sistema de fortalezas regenerables (Imperivm / GBR HD)

Continuación de `IMPERIVM_SCRIPTING_RESEARCH.md`. Aquí no se repite el inventario general; se documenta exclusivamente lo necesario para el sistema de fortalezas regenerables descrito por el usuario. Ningún archivo original fue modificado — todo el código citado se extrajo por lectura directa de bytes (Python ad-hoc) sobre copias en memoria de `Scenarios\Infierno_en_Iberia.BFHP` y `Packs\data.pak`.

Notación de certeza usada en cada afirmación: **CONFIRMADO** (código/sintaxis real citado literalmente) · **INDICIO FUERTE** (varias evidencias independientes apuntan a lo mismo, pero falta una prueba directa) · **INFERIDO** (combinación razonable de piezas confirmadas, no probada como conjunto) · **DESCONOCIDO** (sin evidencia).

---

## 1. Resumen ejecutivo

El hallazgo central de esta fase es que **el motor ya implementa, de forma nativa, un sistema casi idéntico al que el usuario quiere construir**, para la clase de edificio `TTent`. Se recuperó el código fuente completo (sin comprimir, dentro de `Packs\data.pak`, offset ≈2 191 000-2 199 000) de su script de comportamiento: guarnición inicial configurable por clase y cantidad, `SetFeeding(false)`, detección de aniquilación, elección del conquistador, `SetPlayer()`, recompensa de recursos, y hasta un caso de bonus dependiente de la cultura del conquistador. La única pieza que el motor **no** hace de forma nativa es repetir el ciclo indefinidamente tras cada reconquista — esa parte hay que construirla a mano con Sequences, y se encontró una campaña real (`Infierno_en_Iberia.BFHP`) que ya hace algo equivalente (`RunSequence("DefensaCartaginesadenuevo")` dentro de un `while(true)`).

También se recuperó, del mismo escenario, el patrón exacto que el usuario ya había citado (`RunAIHelper("GuardCentralArea", ...)` → `WaitQueryCountBetween(...)` → `.SetPlayer()` → `SpawnGroupInHolder(...)`), repetido **9 veces** (una por cada "foro" regional: edetano, carpetano, lusitano, galaico, etc.), lo que confirma que es un patrón deliberado y reutilizable, no un caso aislado.

El hallazgo negativo más importante: los grupos que usa `SpawnGroupInHolder()` (`jinetes11`, `jinetes22`, `refuerzoscartago`, etc.) **están predefinidos en `map.obj.xml` como grupos de unidades ya colocadas en el mapa** (`<group name="jinetes11" type="1"><obj num="364"/>...`), no se crean de la nada. Esto implica que, tal como se usa en el único ejemplo real disponible, **cada oleada de refuerzo es finita y debe pre-diseñarse a mano** — no se encontró evidencia de que `Place()` (la función de creación dinámica de unidades) sea invocable desde una Sequence de escenario (0 apariciones en el escenario, frente a cientos en el motor). Esto condiciona directamente la viabilidad de una regeneración verdaderamente indefinida (sección 20).

---

## 2. Nuevos descubrimientos (índice rápido)

| # | Descubrimiento | Certeza |
|---|---|---|
| 1 | Comportamiento nativo completo de `TTent`: guarnición configurable, `SetFeeding(false)`, detección de muerte, elección aleatoria del conquistador entre atacantes presentes, `SetPlayer()`, recompensa | CONFIRMADO |
| 2 | `SetNoAIFlag(objetoOLista, true)` — función real, usada 209 veces en el motor, para excluir unidades del control estratégico normal de la IA | CONFIRMADO |
| 3 | `Settlement.loyalty` — estadística real de "lealtad", vinculada en la UI al texto "capturing"; usada como condición de espera para captura por asedio (no aplica a `TTent`, que la bloquea a 100) | CONFIRMADO |
| 4 | Los grupos usados por `SpawnGroupInHolder` están predefinidos en `map.obj.xml` (`type="1"`) con unidades ya colocadas — no son plantillas “vacías” que el motor rellena | CONFIRMADO |
| 5 | `ClassPlayerAreaObjs("Unit", idJugador, "nombreArea")` — función real para contar unidades de un jugador concreto dentro de un área con nombre; usada repetidamente jugador por jugador para "sondear" quién está atacando | CONFIRMADO |
| 6 | `while(<grupo>.obj.player != N);` — espera activa (busy-wait) real sobre la propiedad `.player` de un objeto/holder | CONFIRMADO |
| 7 | `RunSequence("nombre")` — invoca otra Sequence por nombre desde dentro de una Sequence; usada para re-lanzar secuencias de defensa ("...denuevo" = "de nuevo") | CONFIRMADO |
| 8 | `SpawnGroup("nombre")` (sin holder) — variante de `SpawnGroupInHolder` con un solo argumento, para grupos con posición propia ya fijada en el mapa | CONFIRMADO |
| 9 | `while(<obj>.player != N);` combinado con `Settlement.loyalty` — captura en dos fases (lealtad baja → luego cambio real de propietario) en asentamientos que no son `TTent` | CONFIRMADO |
| 10 | Tiempos de entrenamiento reales (`execdelay`) para varias unidades y confirmación de que "Call Valkyries" es un comando `trainex` especial (no un entrenamiento normal) | CONFIRMADO |
| 11 | `Place()` no se encontró ni una sola vez dentro del escenario `Infierno_en_Iberia.BFHP` (0 de 0), sólo `_PlaceEx()` (3 veces, sólo para marcadores no militares) | CONFIRMADO (hallazgo negativo) |
| 12 | Significado de `UnitFlags` — sigue sin evidencia textual directa | DESCONOCIDO (sin cambios respecto a fase 1) |

---

## 3. `Infierno_en_Iberia.BFHP` — reconstrucción del patrón "foro" (prioridad máxima del usuario)

### 3.1 Mapa de secuencias relevantes

Extracción directa de los pares `<sequence name="..." script="CurrentMap/sequences/seqN.vs">` (79 encontrados en todo el archivo; lista completa disponible, aquí sólo las relevantes a fortalezas/foros):

```
inicio                          -> seq0.vs
jinetes1 .. jinetes9             -> seq1,2,5,6,7,8,10.vs   (9 secuencias, una por "foro")
DefensaRomana                    -> seq12.vs
DefensaCartaginesa               -> seq11.vs
DefensaCartaginesa lusitanos     -> seq51.vs
DefensaCartaginesa vetones       -> seq52.vs
DefensaCartaginesa edetanos      -> seq53.vs
DefensaCartaginesa galaicos      -> seq68.vs
conquista foro galaico           -> seq22.vs
conquista foro vetón             -> seq24.vs
conquista foro carpetano         -> seq27.vs
conquista foro lusitano          -> seq28.vs
conquista foro edetano           -> seq32.vs
conquista carpetanos             -> (sin nº capturado, texto embebido más abajo)
conquista galaicos / vetones / lusitanos / edetanos -> variantes regionales
oro foro cartagonova/gadir/romano/carpetano/edetano/veton/lusitano/galaico -> seq19,21,34,37,40,41,46,56.vs
rendicion Cartagonova/Gadir/Ampurias -> seq63,65,62.vs
amuleto en refuerzos carta       -> seq13.vs
mercenarios iberos lado romano/carta -> seq14,16.vs
vida baja de publio/Asdrubal     -> seq18,20.vs
Asdrubal/Publio atrapado ...      -> seq36,38,39,42,45,47,49.vs
temporizador                     -> seq80.vs
```

Es decir: **cada región tiene, como mínimo, tres secuencias separadas** — una de guarnición/defensa inicial (`jinetesN`), una de detección de conquista (`conquista foro X`), y una de entrega de oro (`oro foro X`) — más, en el caso cartaginés, una cuarta capa de refuerzo cíclico (`DefensaCartaginesa X`). Esto es exactamente la separación de responsabilidades que el usuario propone para su propio sistema.

### 3.2 Código recuperado — patrón "guarnición inicial + regeneración única" (secuencias `jinetesN`)

Fragmento real completo (offset ≈3 885 150, correspondiente a la secuencia `jinetes1`; el mismo patrón se repite, con nombres `jinetes2..jinetes9`/`oro2..oro9`, en los offsets 3894882, 3904918, 3923042, 3924578, 3933794, 3941986, 3951714, 3961442):

```
int i;

for (i=0; i<jinetes1.count; i+=1)
    jinetes1.GetObjList()[i].AsUnit.AddItem("Eagle feather");

RunAIHelper("GuardCentralArea", "guard area", "jinetes1", "areajinetes1");

WaitQueryCountBetween(jinetes1, 0, 0, -1);
oro1.SetPlayer(16);
Sleep(1000);
SpawnGroupInHolder("jinetes11", oro1.obj);
Sleep(1000);
jinetes11.SetPlayer(16);

RunAIHelper("GuardCentralArea", "guard area", "honderos1", "areahonderos1");
```

**Variables/objetos usados** (declarados como grupos en `map.obj.xml`, no como variables de programa — ver sección 8):
- `jinetes1` — grupo `type="1"` con 12 `<obj num="...">` de unidades ya colocadas cerca del foro edetano (la guarnición inicial).
- `areajinetes1` — grupo `type="0"` con un único `<obj num="155"/>` (marcador de área).
- `oro1` — grupo `type="0"` con un único `<obj num="...">` (el asentamiento/objeto "foro" en sí — el "holder").
- `jinetes11` — grupo `type="1"` con 12 `<obj num="364".."375">` (la guarnición **de regeneración**, ya colocada en el mapa de antemano, en otra zona).
- `honderos1`/`areahonderos1` — segunda oleada guardiana (slingers), mismo patrón encadenado inmediatamente después.

**Lectura línea por línea:**
1. Da un objeto (`"Eagle feather"`) a cada unidad de la guarnición inicial — cosmético, no relevante al ciclo.
2. `RunAIHelper("GuardCentralArea", "guard area", "jinetes1", "areajinetes1")` — ordena al grupo `jinetes1` que guarde el área marcada por `areajinetes1`. Ver sección 5 para el análisis de qué hace exactamente.
3. `WaitQueryCountBetween(jinetes1, 0, 0, -1)` — bloquea la Sequence hasta que el recuento de unidades vivas de `jinetes1` sea exactamente 0 (todas muertas). `-1` = sin timeout.
4. `oro1.SetPlayer(16)` — cambia el propietario del "holder" (el foro) a **16**, no al conquistador real. Esto es coherente con la convención Player 16 = "neutral capturable con recompensa" documentada en la fase 1: es un paso intermedio que probablemente habilita que **cualquier** jugador pueda entrar/reclamar el foro (o simplemente lo marca como "vacío/disponible"), antes de que la propia mecánica de captura nativa del motor (ver sección 4) le asigne el propietario real cuando alguna unidad entra.
5. `SpawnGroupInHolder("jinetes11", oro1.obj)` — activa/coloca la guarnición de regeneración `jinetes11` anclada al objeto `oro1`.
6. `jinetes11.SetPlayer(16)` — la nueva guarnición también se marca como jugador 16 (neutral), **no** del conquistador — contradice ligeramente el objetivo del usuario ("las unidades pertenecen al conquistador"); en este ejemplo concreto, el diseño narrativo del escenario prioriza que el foro vuelva a ser un objetivo neutral disputado, no que refuerce directamente al conquistador. **Esto es un dato importante: el ejemplo real no asigna la nueva guarnición al jugador que conquistó, sino que la deja neutral otra vez.** Para el objetivo del usuario (asignar al conquistador) haría falta sustituir `jinetes11.SetPlayer(16)` por `jinetes11.SetPlayer(newPlayer)`, siendo `newPlayer` una variable obtenida dinámicamente (ver sección 4).
7. La secuencia termina lanzando la guarnición de refuerzo `honderos1` sobre otra área — no hay bucle `while(1)` en **esta** secuencia concreta; el reciclado indefinido no ocurre aquí.

**Qué falta para "reconstruir la Sequence completa" (lo que el usuario pidió en su punto 1):** el archivo fuente (`seq1.vs`) tiene, según el índice, contenido adicional que no pudo verse en claro (el resto probablemente sigue comprimido); lo citado arriba es exactamente lo que sobrevivió legible en el volcado bruto — no hay razón para pensar que falte lógica intermedia (el bloque empieza con una declaración `int i` típica de inicio de función y termina en una llamada `RunAIHelper` seguida de más contenido de la SIGUIENTE secuencia), pero no se puede garantizar al 100% que no haya bytes comprimidos intercalados que se perdieron en la extracción. Se marca como **INDICIO FUERTE de estar completo**, no CONFIRMADO al 100%.

### 3.3 Código recuperado — bucle de refuerzo cíclico (secuencias `DefensaCartaginesa*` / `DefensaRomana`)

Fragmento real (offset ≈4 181 652, dentro de la región de `DefensaCartaginesa galaicos`, patrón repetido idéntico en offsets 3994663 [`fororomano`], 4184615, 4185639, 4186663, 4212263 con distintos IDs de jugador sondeados):

```
while (true) { 

WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 6, "areaforocartagines"), 10, 1000, -1 );
while(forocartagines.obj.player != 7);
MoveToArea(Asdrubal, "areaforocartagines");
SpawnGroupInHolder("refuerzoscartago1", forocartagines.obj);
Sleep(1800000);

}
RunSequence("DefensaCartaginesadenuevo");
```
y su equivalente para el bando romano (offset 3994663):
```
while (true) { 

WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 1, "areafororomano"), 10, 1000, -1 );
while(fororomano.obj.player != 8);
MoveToArea(Publio, "areafororomano");
SpawnGroupInHolder("refuerzosromanos", fororomano.obj);
Sleep(60000);
refuerzoromanoalheroe.SetCommand("attach", Publio.obj.AsHero());
Sleep(3600000);
}
```

**Lectura:** esto **no** es la detección de conquista en sí — es un sistema de **refuerzo periódico condicionado**: mientras el foro siga siendo del jugador esperado (`7` = Cartago, `8` = Roma en esta campaña), si se junta un ejército propio suficientemente grande cerca (`ClassPlayerAreaObjs(..., 10, 1000, ...)` = entre 10 y 1000 unidades del jugador N en el área), se manda al héroe hacia la zona y se invoca **otra vez** `SpawnGroupInHolder` para dar un refuerzo adicional, y luego se repite el ciclo (`while(true)`) tras una espera larga (30-60 min). Al salir del bucle (lo cual sólo ocurriría si `forocartagines.obj.player` deja de ser 7, es decir, si el foro cambia de dueño), se invoca `RunSequence("DefensaCartaginesadenuevo")` — **una secuencia distinta, "de nuevo"**, que previsiblemente reinstaura la defensa para el nuevo propietario. No se pudo localizar el contenido legible de `DefensaCartaginesadenuevo` en sí (nombre confirmado por la llamada, contenido no recuperado — **DESCONOCIDO** su cuerpo exacto), pero **la sola existencia de una secuencia llamada explícitamente "otra vez"/"de nuevo" invocada tras la pérdida de un foro es la prueba más fuerte encontrada de que el diseño de "rearmar la defensa tras cada reconquista" es un patrón consciente y ya usado en este motor**, aunque no se pueda ver el detalle interno de cómo relanza la guarnición.

También relevante — variante de vigilancia de vida de héroe con el mismo patrón de reinicio (offset 4018774 y 4031068):
```
while (true) { 
while(fororomano.obj.player != 8);
while(Publio.obj.health >= 1000);
MoveToArea(Publio, "areafororomano");
}
RunSequence("vida baja de publio otra vez");
```
Confirma de nuevo el idioma **"detectar condición → actuar → salir del bucle → `RunSequence` de una secuencia hermana con sufijo 'otra vez'"** como forma estándar de este escenario de encadenar comportamiento repetible.

### 3.4 Captura en dos fases para asentamientos "foro" que no son `TTent` puro

Fragmento real (offset ≈4 055 062, secuencia de conquista del foro carpetano):
```
WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 1, "areaforocarpetano"), 10, 1000, -1 );
WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 7, "areaforocarpetano"), 0, 14, -1 );
WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 8, "areaforocarpetano"), 0, 14, -1 );
while(forocarpetano.obj.AsBuilding().settlement.loyalty > 15);
while(forocarpetano.obj.player != 6);
RemoveNote("carpetanos");
RunConv("conquista carpetanos");
```
Aquí el "foro carpetano" es (se confirmó en otro punto del archivo) un `classoffirstbuilding="MTownhall"` con `population="200"`, `maxgold="100000000"` — un asentamiento de tipo "capital", no un `TTent`. Su captura se detecta con **dos condiciones encadenadas**: primero que la `loyalty` del asentamiento caiga a 15 o menos, después que `.player` cambie realmente al valor esperado (6). Esto confirma que el mecanismo de captura de asentamientos "normales" (no `TTent`) depende de `loyalty`, tal y como ya se veía en el motor (sección 4), y que un diseñador de escenario puede simplemente **esperar pasivamente** a que ambas condiciones se cumplan (el motor hace la conquista solo) en vez de programarla desde cero.

---

## 4. Sistema de Queries / identificación del conquistador — reconstrucción completa

Esta sección amplía sustancialmente lo encontrado en la fase 1 (que sólo tenía `newplayer = qEnemies.GetObjList()[0].player;` suelto). Ahora se dispone del **código completo de la función** (`Packs\data.pak`, offset ≈2 191 000-2 196 700, comportamiento nativo de `TTent`).

### 4.1 Declaración e inicialización de `qEnemies` (CONFIRMADO, cita literal)
```
Building this;
Query qRange, qEnemies, qFriends;
ObjList olAll1, olAll2, olDefendersOut1, olDefendersOut2, olOurDefenders;
...
this = This.AsBuilding();
...
qRange = ObjsInRange(this, "Unit", .range);
qEnemies = Intersect(qRange, Union(EnemyObjs(.player, "Military"), EnemyObjs(.player, "BaseMage")));
qEnemies = Subtract(qEnemies, EnemyObjs(.player, "Sentry"));
qFriends = Intersect(qRange, ClassPlayerObjs("Military", .player));

qRange = ObjsInRange(this, "Building", .range);
qRange = Intersect(qRange, EnemyObjs(.player, "Catapult"));
qEnemies = Union(qEnemies, qRange);
```
Respuestas directas a lo que pedía el usuario:
- **¿Qué radio utiliza?** `.range` — una propiedad del propio edificio (`this`/`This`), no una constante fija en el script. **CONFIRMADO** que existe tal propiedad; su valor concreto por clase no se ha localizado (probablemente en la definición `.ENT.XML`/`.SC.XML` de cada clase — **DESCONOCIDO** el valor numérico exacto para `TTent`).
- **¿Qué objetos incluye?** Unidades militares enemigas (`EnemyObjs(.player,"Military")`) + magos enemigos (`"BaseMage"`) dentro del radio, **menos** los `Sentry` enemigos (los centinelas no cuentan como "atacantes" a efectos de detectar conquista — dato nuevo, CONFIRMADO), más catapultas enemigas dentro de rango de **edificios** (no sólo unidades).
- **¿Cómo distingue aliados/enemigos?** `EnemyObjs(jugador, clase)` / `ClassPlayerObjs(clase, jugador)` son funciones reales y opuestas — la primera filtra por relación diplomática "enemigo de", la segunda filtra por pertenencia exacta a un jugador.

### 4.2 Selección del nuevo propietario (CONFIRMADO, cita literal — corrige lo dicho en la fase 1)
```
if (!qEnemies.IsEmpty() && olAll1.count==0 && olAll2.count==0
    && olDefendersOut1.count==0 && olDefendersOut2.count==0
    && .settlement.UnitsCount()==0)
{
    qEnemies.GetObjList().ClearDead();
    if (qEnemies.GetObjList().count>0)
    {
        int new_player;
        new_player = qEnemies.GetObjList()[rand(qEnemies.GetObjList().count)].player;
        if (new_player>8)
        {
            Sleep(10);
            continue;
        }
        .SetPlayer(new_player);
        .settlement.SetFood(nFoodIn);
        if (.race==Carthage) // spwan 20 villagers
        {
            Unit u1; int i;
            for(i=0; i<20; i+=1)
            {
                u1 = Place("CVillager", .pos, new_player);
                u1.SetFood(u1.maxfood);
                .settlement.ForceAddUnit(u1);
            }
        }
    }
}
```
- **¿Cómo se identifica al conquistador?** No es "el primero" de la lista (corrección respecto a la fase 1, donde sólo se había visto un fragmento parcial con `[0]`): en esta función completa es **`qEnemies.GetObjList()[rand(qEnemies.GetObjList().count)].player`** — un **enemigo elegido al azar** entre los presentes dentro de rango en el instante en que se cumple la condición de "todo muerto". **CONFIRMADO.**
- **¿Qué ocurre si atacan dos jugadores simultáneamente?** Gana, literalmente, uno al azar de entre todas las unidades enemigas visibles en rango en ese instante (si el jugador X tiene 8 unidades allí y el jugador Y tiene 2, X tiene 4× más probabilidad de ser elegido porque se sortea sobre unidades individuales, no sobre jugadores). **CONFIRMADO.**
- **¿Cómo evita seleccionar un jugador incorrecto?** `if (new_player>8) { Sleep(10); continue; }` — descarta cualquier resultado que no sea un jugador real de partida (1-8) y vuelve a intentarlo. **CONFIRMADO.**
- **La condición completa de "conquistado"** exige que **cinco** contadores estén a cero simultáneamente (dos grupos de guarnición, dos grupos de "guardias fuera", y el pool interno del asentamiento) — no basta con que una única lista esté vacía. Esto es más estricto que lo que sugería el fragmento parcial visto en la fase 1.
- Tras `.SetPlayer(new_player)`, se ejecuta `.settlement.SetFood(nFoodIn)` (recompensa de comida) y, **sólo si la cultura del nuevo propietario es Cartago**, un bonus de 20 aldeanos. Esta es la única rama "cultura-dependiente" confirmada en el motor, y es sobre la cultura del **conquistador**, no la de la guarnición — dato a tener en cuenta porque el objetivo del usuario es lo inverso (cultura de la fortaleza, no del conquistador, determina las tropas). No hay contradicción: son mecanismos distintos y compatibles.

### 4.3 Alternativa confirmada en Sequences: sondeo por jugador candidato
Como ya se vio en la sección 3, el escenario `Infierno_en_Iberia` **no replica** el mecanismo `rand()` del motor a nivel de Sequence — en su lugar sondea, secuencia por secuencia, jugadores concretos (`ClassPlayerAreaObjs("Unit", 1, area)`, luego `..., 5, ...`, luego `..., 6, ...`), cada uno en su propia instancia de secuencia. Es una alternativa **CONFIRMADA** y más simple de programar a mano si el número de jugadores participantes es conocido de antemano, aunque menos elegante que la solución dinámica del motor.

---

## 5. `GuardCentralArea` / familia de scripts `GUARD` — qué hace realmente

**Limitación importante:** el contenido legible de `GUARD AREA.VS` en sí (el fichero que da nombre al AIHelper) **no se pudo extraer** — sólo se confirmó su existencia como entrada nombrada dentro de `data.pak` (fase 1) y su invocación desde Sequences (`RunAIHelper("GuardCentralArea", "guard area", grupo, area)`, 12 apariciones en `Infierno_en_Iberia.BFHP`, todas con la misma forma de 4 argumentos). El cuerpo del script en sí está comprimido y no se recuperó. Por tanto, todo lo que sigue sobre su comportamiento **interno** es INFERIDO por comparación con el sistema de "sentries" (que sí se recuperó completo, sección 4-B de la fase 1, y sección 6 de este documento) y con el sistema `DefendersOut` de `TTent` (sección 7 de este documento), ambos escritos por el mismo estudio (Haemimont) y con vocabulario/parámetros muy similares (`guardpatrol`, `guardadvance`, `.range`, `.DistTo`).

Lo que **sí está confirmado literalmente**:
- La firma exacta es `RunAIHelper(nombreHelper:str, modo:str, grupoUnidades:str, grupoArea:str)` — 4 parámetros, los dos primeros siempre literales `"GuardCentralArea"`/`"guard area"` en los 12 casos vistos.
- Se invoca de forma **no bloqueante**: en varias secuencias aparecen dos llamadas `RunAIHelper` consecutivas para grupos distintos sin nada entre medias (offset 3904918: `RunAIHelper(...,"guardianesyhonderos",...); RunAIHelper("GuardCent[...]`), lo que descarta que sea una llamada bloqueante que espere a que el grupo muera.
- El grupo "área" (`areajinetes1`, etc.) es, en todos los casos vistos, un grupo `type="0"` con **un solo objeto** (`<obj num="155"/>`) — es decir, es un **punto/marcador**, no una zona poligonal ni un radio explícito en el propio grupo. Esto sugiere (INFERIDO) que el radio de guardia lo decide el propio AIHelper internamente (posiblemente usando `.range` del objeto marcador, por analogía con el sistema de sentries y el de `TTent`, ambos basados en `.range`), no un parámetro visible desde la Sequence.

Sobre las preguntas concretas del usuario:
- **¿Cuándo salen las unidades / persiguen enemigos / regresan después?** DESCONOCIDO de forma directa para `GuardCentralArea`. Por analogía **INFERIDO** con el sistema `DefendersOut` de `TTent` (sección 7), que sí está confirmado al detalle: ese sistema mantiene una cantidad configurable de unidades "fuera" patrullando (`"guardadvance"`/`"guardpatrol"`), las hace volver si se alejan más de `.range` (`if (.DistTo(u) > .range) ... u.SetCommand("move", ...)`), y las repliega del todo con `"enter_tent"` cuando no hay amenazas. Es razonable (pero no demostrado) que `GuardCentralArea` sea una versión genérica/reusable de exactamente este mismo patrón, extraída a un AIHelper común para poder aplicarse a cualquier grupo mediante Sequences en vez de estar sólo cableada dentro de la clase `TTent`.
- **¿Si pueden ser absorbidas por la IA normal?** No se encontró ninguna llamada `SetNoAIFlag()` en el fragmento de Sequence que invoca `RunAIHelper("GuardCentralArea", ...)` — es decir, **no hay evidencia de que el propio `RunAIHelper` aplique automáticamente `SetNoAIFlag`**. Dado que `SetNoAIFlag` es una función real y ampliamente usada en el motor (209 veces, sección 6), y que el diseñador de `Infierno_en_Iberia` nunca la invoca junto a `RunAIHelper` en los 12 casos vistos, esto es una **incógnita relevante**: o bien `GuardCentralArea` aplica `SetNoAIFlag` internamente (no visible desde la Sequence, posible), o bien las unidades guardianas de este escenario sí están, en teoría, disponibles para la IA general (pero en la práctica no se las lleva porque son unidades neutrales/de jugadores 15-16 sin IA estratégica activa gestionándolas, ya que esos "jugadores" no son controlados por ninguna IA real). **DESCONOCIDO** cuál de las dos es la explicación correcta; ver recomendación de prueba en la sección 20 (TEST 9).
- **¿Qué significa exactamente el parámetro "area"?** CONFIRMADO que es el nombre de un grupo con un único objeto marcador; DESCONOCIDO el mecanismo interno exacto por el que ese marcador define un radio/zona.

---

## 6. `SpawnGroupInHolder` — documentación exhaustiva

**39 apariciones** en `Infierno_en_Iberia.BFHP`, **0 apariciones** en `data.pak` (confirma que es una función exclusiva de la capa de Sequences, no del motor de comportamiento de edificios/IA).

### 6.1 Todas las formas de llamada observadas
```
SpawnGroupInHolder("jinetes11", oro1.obj);
SpawnGroupInHolder("jinetes22", oro2.obj);
SpawnGroupInHolder("jinetes33", oro3.obj);
SpawnGroupInHolder("jinetes44", oro4.obj);
... (hasta jinetes99/oro9, 9 pares en total)
SpawnGroupInHolder("refuerzosromanos", fororomano.obj);
SpawnGroupInHolder("refuerzoscartago", forocartagines.obj);
SpawnGroupInHolder("refuerzoscartago1", forocartagines.obj);
SpawnGroupInHolder("tribunos", barco.obj);
```
Patrón invariable: **`SpawnGroupInHolder(nombreDeGrupoExistente: str, objetoHolder: Obj)`** — el segundo argumento es siempre `<algo>.obj`, nunca un grupo directamente ni una coordenada.

### 6.2 El "grupo que se genera" no se genera de la nada (hallazgo clave, CONFIRMADO)
Se verificó directamente en `map.obj.xml` que **todos** los nombres usados como primer argumento (`jinetes11`, `jinetes22`, `jinetes33`, `refuerzosromanos`, `refuerzoscartago`) existen como elementos `<group name="..." type="1">` con objetos ya colocados en el mapa:
```xml
<group name="jinetes11" type="1">
    <obj num="364"/> <obj num="365"/> <obj num="366"/> <obj num="367"/>
    <obj num="368"/> <obj num="369"/> <obj num="370"/> <obj num="371"/>
    <obj num="372"/> <obj num="373"/> <obj num="374"/> <obj num="375"/>
</group>
```
(12 unidades; mismo patrón para `jinetes22` [num 499-510], `jinetes33` [num 455-466], `refuerzosromanos` [num 592-604+], `refuerzoscartago` [num 1504-1516+]).

Respuestas directas:
- **¿Tiene que existir previamente en `map.obj.xml`?** **CONFIRMADO: sí**, en el único ejemplo disponible.
- **¿Funciona como plantilla?** **CONFIRMADO**, en el sentido de "conjunto de unidades pre-diseñado por el autor del mapa, colocado en algún lugar del terreno (probablemente fuera de la vista/zona jugable) y reservado para activarse más tarde".
- **¿Clona unidades?** **DESCONOCIDO / INDICIO FUERTE en contra**: no hay evidencia de clonación; lo más probable, dado que las unidades del grupo `jinetes11` tienen coordenadas propias fijas en el `<scriptobj>` (no necesariamente iguales a las del holder), es que `SpawnGroupInHolder` **mueva/active/teletransporte** esas unidades concretas hacia el holder, no que genere copias nuevas. No se confirmó cuál de las dos cosas ocurre exactamente a nivel de motor (no se localizó el código de `SpawnGroupInHolder` en sí, sólo su uso).
- **¿Conserva Level/Items/UnitFlags/player?** DESCONOCIDO directamente para `SpawnGroupInHolder`. Dato relacionado: en el mismo escenario, las unidades del grupo `jinetes1` (guarnición inicial) reciben explícitamente un ítem vía Sequence (`AddItem("Eagle feather")`) **antes** de llamar a `RunAIHelper`, lo que sugiere que si se necesitan propiedades específicas, el diseñador las aplica manualmente después del spawn en vez de asumir que se heredan. Tras `SpawnGroupInHolder("jinetes11", oro1.obj)` el guion inmediatamente llama `jinetes11.SetPlayer(16)` — si el `player` se heredara automáticamente del holder o de la plantilla no haría falta esa llamada explícita, lo cual es un **indicio (no prueba)** de que el `player` **no** se hereda solo y hay que asignarlo a mano tras el spawn.
- **¿Qué ocurre si se llama varias veces / si el grupo anterior debe estar muerto?** No se observó ningún caso de llamar `SpawnGroupInHolder` dos veces con el **mismo** nombre de grupo en todo el archivo — cada nombre de grupo-plantilla se usa exactamente una vez en el conjunto de Sequences analizado. **DESCONOCIDO** qué pasaría al repetir la llamada (¿error, no-op, duplicaría las unidades otra vez desde sus posiciones originales aunque estén marcadas muertas?). Esto es una **incógnita crítica** para el objetivo de "reconquista indefinida", porque implica que **el único ejemplo real de "regeneración" en todo el juego es de un solo uso** (`jinetes1` → `jinetes11`, y ahí termina esa cadena concreta — no hay `jinetes111`).
- **¿El nombre del grupo nuevo debe ser único?** No se puede confirmar una restricción de unicidad; lo único cierto es que en la práctica cada nombre se usó una sola vez.

### 6.3 `SpawnGroup(nombre)` — variante de un solo argumento (CONFIRMADO, distinta función)
```
SpawnGroupInHolder("tribunos", barco.obj);
RunSequence("Publio muere");
...
SpawnGroup("emboscada");
RunConv("emboscados");
...
SpawnGroup("emboscada1");
```
Existe una función hermana **de un solo argumento**, sin holder — usada para grupos que ya tienen su posición fija en el mapa y no necesitan "anclarse" a nada (una emboscada estática, por ejemplo). Esto refuerza la hipótesis de que `SpawnGroupInHolder` = "`SpawnGroup` + reposicionar/asociar al holder", aunque el mecanismo interno preciso de reposicionamiento sigue sin confirmarse.

---

## 7. Grupos y holders — arquitectura confirmada

Con los datos de las secciones 3 y 6, el modelo completo de "grupo" queda así (CONFIRMADO por inspección directa de `map.obj.xml`):

| `type` del grupo | Contenido típico | Función observada |
|---|---|---|
| `type="0"` | Un único `<obj num="N"/>` | Alias/referencia a UN objeto concreto (un edificio, un marcador de área). Se usa como "handle" para leer/escribir propiedades (`oro1.SetPlayer()`, `oro1.obj`, `while(fororomano.obj.player != N)`) o como zona para `RunAIHelper`/`MoveToArea`/`ClassPlayerAreaObjs`. |
| `type="1"` | Varios `<obj num="...">` (unidades) | Colección de unidades pre-colocadas, usada como plantilla de guarnición/oleada para `SpawnGroup()`/`SpawnGroupInHolder()`, o como el conjunto de defensores cuya muerte se vigila con `WaitQueryCountBetween(grupo, 0, 0, -1)`. |

No se ha encontrado ningún `type` distinto de 0 y 1 en el archivo; **DESCONOCIDO** si existen otros valores válidos o qué significarían.

Respecto al concepto de "holder": es, literalmente, **el objeto de mapa referenciado por un grupo `type="0"`**, accedido vía `.obj`. No hay una entidad "Holder" distinta a nivel de datos — es simplemente el edificio/objeto al que otra función (`SpawnGroupInHolder`) puede anclar unidades. **CONFIRMADO.**

---

## 8. `SetFeeding` — documentación ampliada

27 apariciones en `data.pak`, 0 en `Infierno_en_Iberia.BFHP` (nunca se usa desde Sequences en el único ejemplo disponible — todas las llamadas confirmadas están en scripts de comportamiento del motor).

Todos los usos reales siguen el mismo idioma, aplicado **unidad por unidad, justo después de `Place()`**, nunca sobre un grupo entero de una vez:
```
u = Place(sDefenderCls1, .pos, .player);
.settlement.ForceAddUnit(u);
u.SetFood(20);
u.SetFeeding(false);
u.SetLevel(old_level_1);
```
(idéntico patrón en el "ejército capturado" de `TTent` documentado en la fase 1, en el sistema de aldeanos ambientales, y en las "Hen"/gallinas ambientales de escenografía).

- **¿Cuándo lo utiliza el juego?** Siempre sobre unidades creadas por script que **no** deben depender de la economía de comida del jugador: guarniciones fijas de `TTent`, "ejército capturado" al conquistar un `TTent`, aldeanos/animales puramente decorativos.
- **¿Persiste después de `SetPlayer()`?** No se encontró ningún caso donde se llame `SetFeeding` **antes** de `SetPlayer` sobre la misma unidad para comprobar si sobrevive al cambio; en el ejemplo del "ejército capturado" el orden es `Place(..., newplayer)` (el jugador ya se asigna en la creación) → `SetFeeding(false)` — es decir, la unidad nace ya con el propietario correcto y luego se marca `SetFeeding(false)`, nunca al revés. **DESCONOCIDO** si `SetFeeding(false)` sobrevive a un `SetPlayer()` posterior sobre una unidad que ya tenía `SetFeeding(false)` puesto antes.
- **¿Persiste en grupos generados con `SpawnGroupInHolder`?** DESCONOCIDO — no se encontró ninguna llamada a `SetFeeding` en ninguna de las 39 secuencias que usan `SpawnGroupInHolder` en `Infierno_en_Iberia.BFHP`. Es decir, **el único ejemplo real de "regeneración de guarnición" del juego no usa `SetFeeding` en absoluto** sobre las unidades regeneradas — puede que no haga falta (si `SetFeeding(false)` se conservó de cuando esas unidades se colocaron originalmente en el editor, algo que no podemos verificar desde aquí porque los atributos del `<scriptobj>` no incluyen ningún flag de alimentación visible en el XML) o puede que simplemente el diseñador de esa campaña no lo necesitara narrativamente. **Recomendación (ver sección 20):** aplicar `SetFeeding(false)` explícitamente, iterando el grupo tras el spawn, por seguridad:
  ```
  int i;
  for (i=0; i<grupo.count; i+=1)
      grupo.GetObjList()[i].AsUnit.SetFeeding(false);
  ```
  Esta línea es **INFERIDA** (combina `.count`/`.GetObjList()[i]`/`.AsUnit` — confirmados por el propio bucle de `AddItem` en la sección 3.2 — con `SetFeeding(false)`, confirmado en el motor) — no está probada como conjunto.

---

## 9. Regeneración temporizada — patrones reales encontrados

No se encontró en ningún sitio (ni motor ni escenario) un ejemplo literal de *"crear una unidad, esperar T, comprobar población, crear otra, hasta un máximo"* aplicado a una guarnición neutral tras la muerte de sus miembros. Lo más cercano confirmado son dos sistemas distintos, ninguno idéntico a lo pedido:

**A) Sistema de "sentries" de muro/torre** (recuperado íntegro en la fase 1, `data.pak`): mantiene una cantidad de centinelas activos (`num_slots`) y, cuando faltan (`count == 0` en su bucle `while(1)`), llama `Place(sentry_class_name, ...)` para crear **uno nuevo**, sin ningún `Sleep` de "tiempo de entrenamiento" — el respawn es prácticamente inmediato (sólo `Sleep(750)`/`Sleep(1500)` de "tick" del bucle, no un tiempo proporcional al coste de la unidad).

**B) Sistema `DefendersOut` de `TTent`** (sección 7 más abajo, recuperado íntegro en esta fase): **no regenera unidades muertas** — sólo gestiona cuántas de las que **ya existen** en el pool interno del asentamiento (`.settlement.Units()`) están activas "fuera" patrullando en un momento dado (`while (olDefendersOut1.count < nDefendersOut1 && .settlement.UnitsCount()>0 ...)`). Cuando el pool se agota, no hay más — de ahí que la guarnición sea estrictamente finita (10, o las que sean) y, al agotarse, se dispare la captura.

**Conclusión de esta sección:** el motor tiene ejemplos de "reponer una unidad que falta hasta un máximo" (A) y de "gestionar cuántas de un pool fijo están activas" (B), pero **ningún ejemplo confirmado combina ambos con una espera proporcional al tiempo de entrenamiento real de la unidad**. Un temporizador de regeneración con `Sleep(tiempoDeEntrenamiento)` + `Place()` uno a uno hasta un máximo es una composición **INFERIDA** de piezas confirmadas (bucle `while(1)`, `Sleep(ms)`, `Place()`, `.count`), no algo que exista ya hecho en el juego.

---

## 10. Tiempos reales de entrenamiento (`Packs\data.pak`, bloque `<commands>` de cada facción)

Formato real confirmado de cada comando de entrenamiento (ejemplo literal, `trainBSwordsman`):
```xml
<cmd name="trainBSwordsman" priority="3"
    button="actions/train BSwordsman.bmp"
    traincommand="yes"
    costgold="50" costfood="0" costpop="1"
    execdelay="8000"
    method="train"
    param="BSwordsman"
    sclass="BSwordsman">
    <src obj="BBarracks"/>
</cmd>
```
`execdelay` está en **milisegundos** y es, para los comandos con `method="train"`, el tiempo real de entrenamiento de esa unidad en esa fuente (`<src obj="...">` = edificio que la produce).

| Unidad | Comando | `execdelay` (tiempo) | `costgold` | `costpop` | Fuente | Certeza |
|---|---|---|---|---|---|---|
| Briton Swordsman | `trainBSwordsman` | 8000 ms (8 s) | 50 | 1 | BBarracks | CONFIRMADO |
| Briton Bowman | `trainBBowman` | 4000 ms (4 s) | 60 | 1 | BBarracks | CONFIRMADO |
| Roman Hastatus | `trainRHastatus` | 6000 ms (6 s) | 100 | 1 | RBarracks | CONFIRMADO |
| Macedonian/Mace Hastatus | `trainMHastatus` | 6000 ms (6 s) | 100 | 1 | MBarracks | CONFIRMADO |
| Gaul Swordsman | `trainGSwordsman` | 6000 ms (6 s) | 60 | 1 | GBarracks | CONFIRMADO |
| Carthage Maceman | `trainCMacemen` | 16000 ms (16 s) | 130 | 0 | CBarracks | CONFIRMADO |
| Iberian Slinger | `trainISlinger` | 16000 ms (16 s) | 200 | 1 | IBarracks | CONFIRMADO |
| Teuton Rider | `trainTTeutonRider` | 20000 ms (20 s) | — (no capturado) | 1 | TBarracks | CONFIRMADO (parcial) |
| **Teuton Valkyrie** | **`Call Valkyries`** (no es `trainTValkyrie`) | **20000 ms**, `method="trainex"` (entrenamiento por lote, no unidad-a-unidad), `param="5, 10, TValkyrie, TValkyrie,Fights"` | 1000 | 0 | `TSanctuaryOfVotan` (no una barraca normal) | CONFIRMADO |

**Hallazgo importante para el ejemplo del usuario (fortaleza germana = Valquirias):** las Valquirias **no se entrenan** con el comando genérico `method="train"` como el resto de unidades — se "llaman" (`"Call Valkyries"`) con `method="trainex"`, un método de entrenamiento por lote distinto, desde un edificio especial (`TSanctuaryOfVotan`, no una barraca), y requieren la investigación previa `"Legendary Valkyries"` para subir de nivel. Si el sistema de fortalezas quiere replicar "tiempo de entrenamiento real" para una guarnición de Valquirias, el valor de referencia más directo confirmado es **20 000 ms por invocación de "Call Valkyries"** (aunque el lote parece producir varias unidades a la vez según `param="5, 10, ..."`, cuyo significado exacto de los números 5/10 no se ha determinado — **DESCONOCIDO**).

**Modificadores confirmados:** las tecnologías `"Barrack Level 1/2/3"` aplican `BarrackTrainTimeDecrease` de **50% / 75% / 87%** sobre el tiempo base (no es un tiempo absoluto nuevo, es un multiplicador sobre `execdelay`). Esto es relevante si se quiere que la regeneración de la fortaleza escale con las mejoras tecnológicas del conquistador — **INFERIDO** que sería posible pero no se ha visto ningún caso real que lo haga para una guarnición neutral (las guarniciones de `TTent` usan `SetLevel()` fijo, no pasan por el sistema de comandos/tecnologías en absoluto).

---

## 11. Captura nativa: comparación `TTent` vs. `Outpost` vs. asentamientos normales

| Clase | Mecanismo de captura confirmado | Guarnición vinculada | Recurso entregado | `loyalty` | Certeza |
|---|---|---|---|---|---|
| `TTent` | Aniquilación de **hasta 2 pools de defensores configurables** (`sDefenderCls1/2`, `nDefendersMax1/2`) + `.settlement.UnitsCount()==0`; elección aleatoria del conquistador entre enemigos en `.range` | Sí — `.settlement.ForceAddUnit()` + pool interno gestionado por el propio script (`olDefendersOut1/2`) | `nFoodIn` (comida fija vía `.GetOutpostFood()`) + 20 aldeanos si el conquistador es Cartago | **Bloqueada a 100** explícitamente (`.settlement.SetLoyalty(100); //will not be able to capture it the normal way`) — la única vía de captura es matar a todos los defensores | CONFIRMADO (código completo recuperado) |
| `IOutpost`/`BOutpost`/`GOutpost`/`ROutpost`/`EOutpost`/`COutpost`/`TOutpost` | No confirmado un script de "defensores" propio — el script recuperado (economía de Outpost, offset ≈2 198 200) sólo gestiona compra/venta de oro/comida y **no toca `player` ni `loyalty`**; se apoya en el sistema genérico de `loyalty` del motor (visto en Sequences de escenario, sección 3.4) | No confirmada guarnición nativa vinculada (en los mapas oficiales inspeccionados en la fase 1 los Outposts tenían `population="0"`) | Oro/comida acumulados (`gold`/`food` del `<settlement>`) | Se usa con normalidad (no bloqueada) — cae por asedio/tiempo | INDICIO FUERTE |
| `GGuardPost` | No se recuperó su script de comportamiento; su nombre de clase de sentinela (`GUARDPOSTSENTRY.SC.XML`, fase 1) sugiere que usa el **sistema de sentries de muro/torre** (slots + `GetSentryClassName()`/`AddMaxSentries()`), no el sistema de doble pool de `TTent` | Probablemente sí, vía sentries (1 unidad centinela a la vez por slot, no un lote fijo de N) | DESCONOCIDO | DESCONOCIDO | INDICIO FUERTE (por el nombre de clase, no por código de comportamiento recuperado) |
| Asentamientos "capital"/`MTownhall` u otros normales | `loyalty` cae por asedio sostenido hasta un umbral, luego `.player` cambia — visto empíricamente desde una Sequence de escenario (`while(...loyalty > 15); while(...player != 6);`), no desde el propio script del motor | No aplica (guarnición = tropas normales entrenadas por el jugador) | No aplica | Mecanismo estándar, sin bloqueo | CONFIRMADO (visto en uso, no en el código fuente del motor que lo implementa) |

**Recomendación directa derivada de esta tabla:** de todas las clases inspeccionadas, **`TTent` es, con diferencia, la que más se parece a lo que el usuario quiere** (guarnición configurable por clase y cantidad, `SetFeeding(false)` nativo, captura exclusivamente por aniquilación de defensores, elección de conquistador entre atacantes presentes, entrega de recompensa). La diferencia principal frente al objetivo del usuario es que el motor **no** repite el ciclo tras la primera captura (sección 12) — eso hay que añadirlo aparte, con Sequences.

---

## 12. `UnitFlags` — resultado de la búsqueda dirigida

- `UnitFlags="262144"` (0x40000) — visto en `Map 1_vs_1_varios_by_LukkyFrost.BFHP` sobre las 10 `TValkyrie`/`EChariot`/`IMountaineer`/`CWarElephant` (jugador 9, `Level="999"`).
- `UnitFlags="131072"` (0x20000) — visto extensamente en `Infierno_en_Iberia.BFHP` sobre decenas de unidades de ejércitos de PNJ (Cartago, Roma) con `Level` variable (3 a 19), asociadas a jugadores reales de la campaña (2, 7), no a guarniciones neutrales.
- `UnitFlags="393216"` (0x60000 = 0x40000 | 0x20000, es decir, la **combinación de ambos bits anteriores**) — visto sobre un `CNoble` (héroe/noble), jugador 7.
- Búsqueda de la cadena `UnitFlags` dentro de `data.pak` (código del motor): **0 apariciones**. Esto significa que el motor no referencia `UnitFlags` por nombre en ningún script legible encontrado — si estos bits tienen efecto, se interpretan en código C++ compilado (`gbr.exe`), fuera del alcance de esta investigación (que excluye explícitamente la descompilación del ejecutable).

**Conclusión: DESCONOCIDO.** No hay ninguna evidencia textual de qué significa cada bit. La correlación observada (262144 en unidades "guardia estacionaria de héroe/élite" del mapa comunitario; 131072 en tropas de ejércitos de IA de una campaña; la combinación 393216 en un héroe) es sugerente pero **no se marca como INDICIO FUERTE** porque la muestra es demasiado pequeña (un solo mapa comunitario, un solo autor) para descartar que sea simplemente un valor arbitrario copiado por el editor al duplicar unidades, sin significado funcional real. **No se recomienda basar ninguna parte del diseño del sistema de fortalezas en un valor concreto de `UnitFlags` hasta probarlo experimentalmente** (ver TEST en sección 20).

---

## 13. Reconquistas / bucles — qué existe realmente

Ya documentado en detalle en la sección 3.3. Resumen de la respuesta directa a la pregunta del usuario ("¿existe algún escenario que ya implemente A→B→A y vuelva a activar defensores?"):

- **No se encontró un ciclo A→B→A completo y auto-contenido** en una sola Sequence con regeneración indefinida demostrada.
- **Sí se encontró** un patrón de **un solo relanzamiento** confirmado al 100% (`jinetes1` agotado → `SpawnGroupInHolder("jinetes11", ...)`, sección 3.2), y **la intención clara** (nombre de la secuencia, invocación real) de un relanzamiento **posterior e indefinido** vía `RunSequence("DefensaCartaginesadenuevo")` tras la pérdida del foro (sección 3.3), cuyo contenido interno no se pudo leer.
- El bucle `while(true) { ...; Sleep(1800000); }` sí demuestra que Sequences con bucles infinitos de larga duración **son técnicamente viables y se usan en producción** en al menos una campaña oficial/semi-oficial del juego — no es un patrón teórico.

---

## 14. Interacción con la IA — cómo evitar que la CPU vacíe la fortaleza

Hallazgo confirmado más importante de toda esta fase para este punto concreto: **`SetNoAIFlag(objetoOLista: Obj|ObjList, activar: bool)`** — función real, **209 apariciones** en `data.pak`, usada de forma constante y consistente en todo el motor para dos propósitos:
1. Retirar unidades/héroes de la asignación automática de la IA estratégica cuando un script quiere control manual temporal (ejemplo literal: `hh.SetNoAIFlag(true); hh.DetachArmy();` al robar un héroe para una misión; se revierte con `hero.SetNoAIFlag(false)` cuando `EnvReadInt(set,"StopTacticScript")==1`).
2. Proteger una lista de unidades recién creadas por script de ser "recicladas" por el reclutamiento normal (ejemplo literal, offset 306454): 
```
ol = Union(ObjsInCircle(area_center, area_radius, "IOutpost"), ObjsInCircle(area_center, area_radius, "BOutpost"));
...
SetNoAIFlag(ol, true);
while (ol.count > 0) {
    Sleep(2000);
    ol.ClearDead();
    ...
}
```

**No se encontró ninguna llamada `SetNoAIFlag` dentro de las Sequences de `Infierno_en_Iberia.BFHP`** (ni junto a `RunAIHelper("GuardCentralArea",...)` ni en ningún otro sitio) — es decir, el único ejemplo real de "guarnición de fortaleza" disponible **no la usa explícitamente**. Esto dejó abierta la pregunta de si `RunAIHelper("GuardCentralArea",...)` la aplica internamente.

**Recomendación directa (parte de la solución que pide el usuario):** dado que `SetNoAIFlag` es una función real, confirmada, de uso masivo, y su propósito documentado por el propio código es exactamente "excluir del control estratégico normal de la IA", la vía más segura y explícita para blindar la guarnición de una fortaleza propia sería aplicarla manualmente sobre el grupo justo tras crearlo:
```
SetNoAIFlag(grupoGuarnicion, true);
```
Esto es **INFERIDO** (combinación directa de dos piezas confirmadas — la función y el grupo — nunca vista exactamente así en ningún script real), no una cita literal, pero de bajísimo riesgo dado lo bien atestiguada que está la función y lo directo de su semántica documentada en los propios comentarios del motor (`SetNoAIFlag(ol2, true); ol.AddList(ol2);` aparece repetidamente justo después de crear unidades "especiales" que no deben mezclarse con el ejército gestionado por la IA).

No se encontró ninguna propiedad de "grupo reservado" a nivel de `<group>` en el XML (los grupos `type="1"` no tienen ningún atributo de "excluir de IA" visible) — la protección, si existe, se aplica **a las unidades**, no al grupo como concepto de datos.

---

## 15. Arquitectura propuesta (basada exclusivamente en lo confirmado/inferido arriba)

```
FortalezaX (asentamiento, idealmente basado en la clase TTent o similar)
 ├─ Grupo "FortalezaX_area"       (type=0, 1 objeto marcador)   — zona de guardia
 ├─ Grupo "FortalezaX_holder"     (type=0, 1 objeto: el propio edificio) — para .obj / SetPlayer
 ├─ Grupo "FortalezaX_garrison_0" (type=1, 10 unidades pre-colocadas)  — guarnición inicial (jugador 15/16)
 ├─ Grupo "FortalezaX_garrison_1" (type=1, 10 unidades pre-colocadas)  — 1ª guarnición de regeneración
 ├─ Grupo "FortalezaX_garrison_2" (type=1, 10 unidades pre-colocadas)  — 2ª guarnición de regeneración
 └─ ... (tantas como reconquistas se quieran soportar de forma garantizada)

Sequence "FortalezaX_ciclo" (while(true)):
  RunAIHelper("GuardCentralArea","guard area", garrisonActual, "FortalezaX_area")
  SetNoAIFlag(garrisonActual, true)              [INFERIDO]
  for cada unidad: SetFeeding(false)             [INFERIDO — por seguridad, aunque el único ejemplo real no lo hizo]
  WaitQueryCountBetween(garrisonActual, 0, 0, -1)
  newPlayer = <mecanismo de identificación, sección 4>
  FortalezaX_holder.SetPlayer(newPlayer)
  SpawnGroupInHolder(siguienteGuarnicionPreDiseñada, FortalezaX_holder.obj)
  siguienteGuarnicion.SetPlayer(newPlayer)
  (bucle vuelve a empezar con la nueva guarnición)
```

**Limitación estructural más importante de este diseño, heredada directamente de la evidencia (sección 6.2):** al depender de grupos `type="1"` pre-diseñados, el número de reconquistas que se pueden regenerar de esta forma es **finito** (tantas como grupos `_garrison_N` se hayan colocado a mano en el editor). Si se necesita regeneración verdaderamente infinita sin límite de reconquistas, hace falta resolver primero la incógnita de la sección 16 (si `Place()`/`_PlaceEx()` puede crear unidades militares completas desde una Sequence).

---

## 16-18. Código confirmado / inferido / incógnitas — prototipo "Fortaleza Germana de Prueba"

### A) CÓDIGO CONFIRMADO (sintaxis citada literalmente, tomada de los fragmentos de las secciones 3, 4, 6, 8, 14; aquí ensamblada en el orden en que aparece en los originales, sin alterar ninguna línea)
```
// -- patrón real, Infierno_en_Iberia.BFHP, offset 3885154 --
int i;
for (i=0; i<jinetes1.count; i+=1)
    jinetes1.GetObjList()[i].AsUnit.AddItem("Eagle feather");

RunAIHelper("GuardCentralArea", "guard area", "jinetes1", "areajinetes1");

WaitQueryCountBetween(jinetes1, 0, 0, -1);
oro1.SetPlayer(16);
Sleep(1000);
SpawnGroupInHolder("jinetes11", oro1.obj);
Sleep(1000);
jinetes11.SetPlayer(16);

// -- patrón real, data.pak, offset ~2193289 (motor, no Sequence) --
Unit u1;
u1 = Place(sDefenderCls1, .pos, .player);
.settlement.ForceAddUnit(u1);
u1.SetFood(20);
u1.SetFeeding(false);
u1.SetLevel(old_level_1);

// -- selección de conquistador real, data.pak, offset ~2197230 --
int new_player;
new_player = qEnemies.GetObjList()[rand(qEnemies.GetObjList().count)].player;
if (new_player > 8) { Sleep(10); continue; }
.SetPlayer(new_player);

// -- protección frente a la IA, data.pak, offset ~306454 --
SetNoAIFlag(ol, true);

// -- reciclado de la secuencia, Infierno_en_Iberia.BFHP, offset ~4181652 --
while (true) {
    WaitQueryCountBetween(ClassPlayerAreaObjs("Unit", 6, "areaforocartagines"), 10, 1000, -1);
    while (forocartagines.obj.player != 7);
    Sleep(1800000);
}
RunSequence("DefensaCartaginesadenuevo");
```

### B) ESQUELETO INFERIDO (combina piezas de A; cada línea marcada indica exactamente qué falta probar)
```
while (true) {

    // [INFERIDO] RunAIHelper es no-bloqueante (confirmado que se puede
    // encadenar sin esperar), así que aquí no bloquea:
    RunAIHelper("GuardCentralArea", "guard area", "FortGer_garrison", "FortGer_area");

    // [INFERIDO — combinación no vista literalmente así, pero SetNoAIFlag
    // acepta un grupo/lista de forma confirmada en otros contextos]
    SetNoAIFlag(FortGer_garrison, true);

    // [INFERIDO — el único ejemplo real (sección 8) nunca lo hizo sobre un
    // grupo recién spawneado, sólo sobre unidades Place()adas una a una]
    int i;
    for (i = 0; i < FortGer_garrison.count; i += 1)
        FortGer_garrison.GetObjList()[i].AsUnit.SetFeeding(false);

    WaitQueryCountBetween(FortGer_garrison, 0, 0, -1);

    // [INFERIDO — plantilla de identificación dinámica del conquistador;
    // el mecanismo con rand() confirmado sólo se vio en código de MOTOR
    // (data.pak), NUNCA se vio invocado ni replicado desde una Sequence.
    // No hay prueba de que qEnemies/rand()/EnemyObjs() sean invocables
    // igual desde el lenguaje de Sequences.]
    // newPlayer = <mecanismo por determinar experimentalmente>

    FortGer_holder.SetPlayer(newPlayer);

    // [CONFIRMADO que la sintaxis es correcta; DESCONOCIDO si el grupo
    // "FortGer_garrison_N" siguiente puede reutilizarse indefinidamente
    // o si cada uno sólo sirve una vez]
    SpawnGroupInHolder("FortGer_garrison_N", FortGer_holder.obj);
    FortGer_garrison_N.SetPlayer(newPlayer);

    Sleep(1000);
}
```

### C) INCÓGNITAS que impiden hoy escribir una Sequence funcional completa
1. **Cómo obtener `newPlayer` desde una Sequence sin conocer de antemano la lista de jugadores candidatos.** El único mecanismo dinámico confirmado (`qEnemies.GetObjList()[rand(...)].player`) sólo se vio en código de **motor** (comportamiento de clase de edificio), nunca en una Sequence. El único mecanismo confirmado **en Sequences** (`ClassPlayerAreaObjs("Unit", idJugador, area)`) requiere sondear jugador por jugador, uno a uno, por lo que hace falta escribir tantas ramas/hilos como jugadores humanos participen en la partida (viable, pero no "genérico").
2. **Si `SpawnGroupInHolder` puede reutilizarse sobre un grupo ya "gastado", o si cada nombre de grupo-plantilla sólo puede spawnearse una vez.** Sin esto no se sabe si hacen falta N grupos pre-diseñados (uno por reconquista tolerada) o si un solo grupo basta y se puede re-spawnear indefinidamente.
3. **Si `Place()` (creación dinámica sin plantilla previa) es invocable desde una Sequence.** 0 apariciones en el único escenario con Sequences legibles disponible; sólo se vio `_PlaceEx()` (3 veces, sólo para marcadores no militares). Esto es la incógnita más importante para la regeneración *verdaderamente* indefinida sin límite de reconquistas.
4. **Radio y comportamiento exacto de `GuardCentralArea`** (sección 5) — sin el código fuente de `GUARD AREA.VS` no se puede predecir con certeza si las unidades perseguirán enemigos fuera del área, ni cuánto tardan en volver.
5. **Si `SetFeeding(false)` sobrevive a `SetPlayer()`** cuando se aplica antes del cambio de propietario.

---

## 19. Escenario de laboratorio — instrucciones concretas para el editor

Nombres sugeridos (siguiendo la convención `FortTest_*` propuesta por el usuario):

```
Objeto/edificio central:      FortTest              (recomendado: classoffirstbuilding = TTent,
                                                       por ser la clase con más comportamiento nativo
                                                       reutilizable — sección 11)
Grupo type=0 (holder):        FortTest_Holder        -> <obj num="ID del edificio FortTest">
Grupo type=0 (área guardia):  FortTest_Area          -> <obj num="ID de un marcador junto a FortTest">
Grupo type=1 (guarnición 0):  FortTest_Garrison0     -> 10x <scriptobj class="TValkyrie" player="15" .../>
                                                          colocados pegados a FortTest
Grupo type=1 (guarnición 1):  FortTest_Garrison1     -> 10x TValkyrie más, colocadas en otro punto
                                                          del mapa (p.ej. fuera del área jugable) para
                                                          servir de "plantilla" de regeneración
Jugadores de prueba:           Player 1 y Player 2 (humanos o IA), FortTest en Player 15 o 16 al inicio
```

### TEST 1 — `GuardCentralArea`
**Procedimiento:** crear una Sequence mínima que sólo llame `RunAIHelper("GuardCentralArea","guard area","FortTest_Garrison0","FortTest_Area")` al empezar la partida. No añadir nada más.
**Resultado esperado:** las 10 `TValkyrie` deberían quedarse quietas/patrullando cerca de `FortTest` en vez de deambular o ser reclutadas por ninguna IA (no hay IA jugando el bando 15 de todas formas, pero sirve para ver el radio de patrulla).
**Cómo verificar:** observar en el editor/partida si las unidades se alejan del punto marcado por `FortTest_Area` y hasta qué distancia.
**Qué mirar en Logs si falla:** `Logs\<sesión>\vx.log` — buscar `"pr("` (las funciones de depuración `pr(...)` vistas en el motor vuelcan mensajes a este log si el script llega a ejecutarse; su ausencia total indicaría que `RunAIHelper` no se está ni siquiera invocando).

### TEST 2 — detección de muerte
**Procedimiento:** añadir `WaitQueryCountBetween(FortTest_Garrison0, 0, 0, -1);` justo después del TEST 1, seguido de un `pr("GUARNICION MUERTA");` (función de depuración confirmada) o `GiveNote("test2ok")` (confirmada, usada para notas de misión) para verificar visualmente que se desbloqueó.
Matar manualmente las 10 unidades con otro jugador.
**Resultado esperado:** el aviso/nota aparece exactamente cuando muere la décima unidad, ni antes ni después.
**Cómo verificar:** la nota de misión aparece en pantalla, o revisar la sección "Sequence status" del `vx.log` (fase 1, sección 7) tras forzar un crash — debería listar esta Sequence como `finished` en ese punto en vez de `running`.

### TEST 3 — detectar conquistador
**Procedimiento:** en dos partidas de prueba separadas, atacar `FortTest` con Player 1 solo, y luego con Player 1 y Player 2 simultáneamente. Usar `ClassPlayerAreaObjs("Unit", 1, "FortTest_Area")` y `ClassPlayerAreaObjs("Unit", 2, "FortTest_Area")` en dos ramas paralelas (o secuencialmente) para ver cuál dispara primero.
**Resultado esperado:** con un solo atacante, siempre se detecta correctamente. Con dos, comprobar experimentalmente el orden/prioridad (dado que el mecanismo `rand()` visto en el motor no está confirmado como accesible desde Sequences, hay que verificar empíricamente qué ocurre con el enfoque de sondeo por jugador).
**Qué mirar si falla:** que ninguna de las dos ramas se desbloquee — revisar si `ClassPlayerAreaObjs` exige que las unidades estén *dentro* del grupo-área (`FortTest_Area`) en sentido estricto de colisión/radio, y no simplemente "cerca".

### TEST 4 — `SetPlayer`
**Procedimiento:** tras el TEST 3, ejecutar `FortTest_Holder.obj.SetPlayer(1);` (fijo, sin variable, para aislar el test).
**Resultado esperado:** el edificio `FortTest` cambia de color/bandera al de Player 1 inmediatamente.
**Cómo verificar:** visualmente, o consultando el panel de información del edificio en el juego (debería mostrar el nuevo propietario).

### TEST 5 — `SpawnGroupInHolder`
**Procedimiento:** tras el TEST 4, `SpawnGroupInHolder("FortTest_Garrison1", FortTest_Holder.obj);`.
**Resultado esperado:** las 10 `TValkyrie` de `FortTest_Garrison1` (colocadas originalmente lejos) aparecen/se desplazan junto a `FortTest`.
**Cómo verificar:** observar si aparecen instantáneamente en la posición del holder o si se desplazan caminando desde su posición original (esto responde por sí solo a la incógnita de si "clona" o "mueve" las unidades).
**Repetir el TEST 5 una segunda vez con el mismo nombre de grupo** (llamar `SpawnGroupInHolder("FortTest_Garrison1", ...)` otra vez tras matar esa guarnición) para resolver la incógnita C.2 de la sección 18.

### TEST 6 — `SetFeeding(false)`
**Procedimiento:** tras el TEST 5, iterar la guarnición y aplicar `SetFeeding(false)` a cada unidad. Dejar pasar varios minutos de partida sin que Player 1 tenga excedente de comida.
**Resultado esperado:** las `TValkyrie` no muestran icono/aviso de "comida insuficiente" ni pierden salud por hambre, a diferencia de las tropas normales de Player 1 si a este le falta comida.
**Cómo verificar:** comparar su comportamiento con una unidad normal del mismo jugador bajo escasez de comida forzada.

### TEST 7 — reconquista
**Procedimiento:** con Player 2, atacar y matar la guarnición `FortTest_Garrison1` (ya en manos de Player 1), repitiendo TEST 3-5 con Player 2 como conquistador y una tercera plantilla `FortTest_Garrison2`.
**Resultado esperado:** el ciclo se repite sin errores de script.
**Cómo verificar:** igual que TEST 3-5; además revisar que no queden unidades "fantasma" de la guarnición anterior.

### TEST 8 — regeneración
**Procedimiento:** dado que no hay un mecanismo confirmado de regeneración unidad-a-unidad, probar el patrón inferido de la sección 9-B: tras spawnear `FortTest_Garrison1` completa, matar sólo 3 de las 10 unidades manualmente y ejecutar un bucle de prueba `while(1) { Sleep(20000); if (FortTest_Garrison1.count < 10) { /* intentar Place() o _PlaceEx() aquí */ } }`.
**Resultado esperado / qué se está probando en realidad:** si `Place()`/`_PlaceEx()` fallan o no compilan dentro de una Sequence, esto confirma la incógnita C.3 de la sección 18 de forma definitiva.
**Qué mirar en Logs si falla:** `Logs\<sesión>\vx.log` — el juego genera estos volcados ante errores de motor; un error de parser de script debería, según lo visto en la fase 1, aparecer aquí aunque no se haya observado ningún caso real todavía.

### TEST 9 — comportamiento de la IA
**Procedimiento:** poner a Player 1 controlado por IA (no humano) y repetir TEST 1 y TEST 5 con Player 1 como conquistador. Observar durante 15-20 minutos si la IA de Player 1 mueve, recluta desde, o reutiliza las `TValkyrie` de `FortTest_Garrison1` como parte de su ejército general (por ejemplo, llevándoselas a atacar en otro frente).
**Resultado esperado si el sistema es viable sin intervención extra:** la IA ignora esas unidades y las deja defendiendo `FortTest`.
**Si la IA se las lleva:** confirma que hace falta aplicar `SetNoAIFlag(FortTest_Garrison1, true)` explícitamente (sección 14) — repetir el test con esa línea añadida para confirmar que corrige el problema.
**Qué mirar si falla:** ninguna traza directa en Logs para esto — es puramente observacional en partida.

---

## 20. Conclusión de viabilidad

Se mantiene la tabla de la fase 1, actualizada con los hallazgos de esta fase:

| Capacidad | Veredicto (actualizado) | Novedad de esta fase |
|---|---|---|
| Detectar cambio de propietario | **Confirmado como posible** | Se recuperó el código completo de motor que lo hace para `TTent`, y una variante de Sequence (`while(obj.player != N)`) que lo hace por sondeo. |
| Identificar **dinámicamente** al conquistador (sin conocerlo de antemano) | **Confirmado como posible únicamente a nivel de motor**; a nivel de Sequence sólo se demostró el sondeo jugador-por-jugador (funcional pero no genérico) | Antes sólo teníamos `[0]`; ahora sabemos que el motor usa `rand()` sobre los enemigos en rango — pero no hay prueba de que ese patrón sea replicable literalmente desde una Sequence. |
| Crear/reactivar unidades | **Confirmado como posible, pero con matiz importante** | `SpawnGroupInHolder` funciona pero requiere grupos-plantilla pre-diseñados y finitos; **no hay prueba de que `Place()` funcione desde una Sequence** para creación verdaderamente dinámica e ilimitada. |
| Asignarlas al nuevo propietario | **Confirmado como posible** | Confirmado tanto a nivel de motor como de Sequence (`grupo.SetPlayer(id)`). |
| Hacerlas no dependientes de comida | **Confirmado como posible** | Se recuperó el patrón exacto y su contexto de uso real; pendiente confirmar si sobrevive a `SetPlayer()` posterior. |
| Detectar número de defensores vivos | **Confirmado como posible** | `WaitQueryCountBetween` documentado con múltiples variantes de rango (no sólo 0,0). |
| Ordenar que permanezcan/defiendan una zona | **Confirmado como posible a nivel de invocación**; el comportamiento interno exacto (radio, persecución, retorno) sigue sin verificarse porque el cuerpo de `GUARD AREA.VS` no se pudo leer | Se documentó en detalle el sistema equivalente de `TTent` (`DefendersOut`), que sirve de referencia fiable por analogía. |
| Regenerar una unidad cada cierto tiempo, hasta un máximo | **Probablemente posible, no demostrado tal cual** (sin cambios respecto a fase 1) | Se descartaron dos candidatos nativos (sentries, `DefendersOut`) como NO siendo exactamente esto — ninguno "repone lo que falta con una espera proporcional al entrenamiento". Sigue siendo una composición a construir. |
| Repetir todo el proceso tras cada reconquista, indefinidamente | **Parcialmente confirmado como posible, con una limitación estructural real** | El motor nativo explícitamente **no** lo hace (la función de `TTent` termina con `return` tras la primera captura). Se encontró una campaña real que sí re-lanza secuencias de defensa tras perder un objetivo (`RunSequence("...denuevo")`), pero el mecanismo de creación de unidades que usaría para ello (`SpawnGroupInHolder` sobre grupos finitos pre-diseñados) **no es ilimitado por diseño** salvo que se demuestre que `Place()` funciona desde Sequences (incógnita abierta, TEST 8). |

**Conclusión general:** el sistema es construible con alta confianza para un número **acotado** de reconquistas (tantas como guarniciones-plantilla se diseñen a mano en el editor, siguiendo exactamente el patrón de `jinetes1`→`jinetes11` documentado en la sección 3, multiplicado por cuantas veces se quiera soportar). Para una regeneración **verdaderamente sin límite**, la pieza que falta demostrar es si `Place()` (o `_PlaceEx()`) puede invocarse desde una Sequence para crear unidades sin depender de una plantilla física pre-colocada — el TEST 8 de la sección 19 es la forma más directa de despejar esa duda antes de comprometerse a un diseño concreto.

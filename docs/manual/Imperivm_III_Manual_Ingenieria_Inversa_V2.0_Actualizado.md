# Manual técnico de scripting de Imperivm III

> **Revisión canónica del proyecto: v2.0 — 03/09/2026.** Esta edición integra los hallazgos obtenidos de las 23 Sequences de la compilación estable `Carlos Guerra Total prueba zombie`, incluyendo la arquitectura actual de Zombies + Easter Egg, `IntArray` en Sequences, claves dinámicas de `EnvReadInt`, cinematográficas, Conversations, anuncios, notificaciones, items y coordinación entre Sequences.

> **Documento vivo.** Este manual consolida los descubrimientos obtenidos mediante ingeniería inversa, lectura de scripts nativos, análisis de escenarios y pruebas directas en el editor de Imperivm III / Great Battles of Rome HD.
>
> La intención no es describir C++ estándar, sino documentar **el lenguaje y la API que realmente utiliza el juego**, qué se ha observado en sus datos internos y qué partes han sido verificadas desde Sequences.

---


## Índice

1. [Criterio de certeza y alcance](#1-criterio-de-certeza-y-alcance)
2. [CKS/VS y Sequences](#2-cksvs-y-sequences)
3. [Editor: Sequences y Groups](#3-editor-sequences-y-groups)
4. [Modelo de objetos, clases y herencia](#4-modelo-de-objetos-clases-y-herencia)
5. [Tipos principales: Obj, Unit, Building y Settlement](#5-tipos-principales-obj-unit-building-y-settlement)
6. [Query y ObjList](#6-query-y-objlist)
7. [Creación dinámica de unidades](#7-creación-dinámica-de-unidades)
8. [Comandos de unidades](#8-comandos-de-unidades)
9. [IA y control de unidades](#9-ia-y-control-de-unidades)
10. [Groups dinámicos y estado persistente](#10-groups-dinámicos-y-estado-persistente)
11. [Outposts y fortalezas](#11-outposts-y-fortalezas)
12. [GGuardPost y sistema de sentinelas](#12-gguardpost-y-sistema-de-sentinelas)
13. [Captura, loyalty y control territorial](#13-captura-loyalty-y-control-territorial)
14. [Limitaciones y precauciones observadas](#14-limitaciones-y-precauciones-observadas)
15. [Patrones reutilizables](#15-patrones-reutilizables)
16. [Referencia de funciones y métodos](#16-referencia-de-funciones-y-métodos)
17. [Referencia de clases y unidades](#17-referencia-de-clases-y-unidades)
18. [Metodología de ingeniería inversa](#18-metodología-de-ingeniería-inversa)
19. [Escenarios oficiales como referencia de scripting](#19-escenarios-oficiales-como-referencia-de-scripting)
20. [Arquitectura real de fortalezas y guarniciones regenerables](#20-arquitectura-real-de-fortalezas-y-guarniciones-regenerables)
21. [Townhall, “Foro” y asentamientos neutrales](#21-townhall-foro-y-asentamientos-neutrales)
22. [Helpers exclusivos de Sequences, Groups y activación diferida](#22-helpers-exclusivos-de-sequences-groups-y-activación-diferida)
23. [Roster técnico, héroes, roles y restricciones culturales](#23-roster-técnico-héroes-roles-y-restricciones-culturales)
24. [Forénsica de PAK/BFHP, inventarios de API e incógnitas abiertas](#24-forénsica-de-pakbfhp-inventarios-de-api-e-incógnitas-abiertas)
25. [Hordas, jugadores técnicos y seguimiento de ejércitos dinámicos](#25-hordas-jugadores-técnicos-y-seguimiento-de-ejércitos-dinámicos)
26. [Gates, catapultas, arietes y asedio desde Sequences](#26-gates-catapultas-arietes-y-asedio-desde-sequences)
27. [IA nativa de conquista: capas, AI Helpers y límites de Sequence](#27-ia-nativa-de-conquista-capas-ai-helpers-y-límites-de-sequence)
28. [Tropas auxiliares de Outposts: salida, defensa y retorno automático](#28-tropas-auxiliares-de-outposts-salida-defensa-y-retorno-automático)
29. [Formatos internos, logs y forénsica de escenarios](#29-formatos-internos-logs-y-forénsica-de-escenarios)
30. [Caso de estudio: arquitectura canónica v2.0 del modo Zombies](#30-caso-de-estudio-arquitectura-canónica-v20-del-modo-zombies)
31. [Catálogo canónico de IDs técnicos para `Place()`](#31-catálogo-canónico-de-ids-técnicos-para-place)
32. [Cinemáticas, Conversations, anuncios y control de interfaz](#32-cinemáticas-conversations-anuncios-y-control-de-interfaz)
33. [Items, notificaciones y recompensas de unidades](#33-items-notificaciones-y-recompensas-de-unidades)
34. [Estado compartido, `IntArray`, claves dinámicas y máquinas de estados](#34-estado-compartido-intarray-claves-dinámicas-y-máquinas-de-estados)


---

# 1. Criterio de certeza y alcance

Imperivm III utiliza scripts `.vs` escritos en un lenguaje que en este proyecto denominamos **CKS/VS**. Su sintaxis recuerda a C/C++, pero **no debe asumirse que sea C++ completo**: dispone de tipos, funciones, conversiones y restricciones propias.

Una función o patrón se considera fiable cuando existe al menos una de estas evidencias:

1. **Prueba directa en el editor o en partida.**
2. **Uso literal en una Sequence real.**
3. **Uso literal en un script nativo `.vs`.**
4. **Definición recuperada de los datos del juego.**

Conviene distinguir siempre entre tres niveles:

- **Confirmado en Sequence:** sabemos que compila y/o funciona dentro del editor de escenarios.
- **Confirmado en script nativo:** existe en el motor o en scripts internos del juego, pero puede requerir comprobar su disponibilidad exacta desde Sequence.
- **Inferido:** composición razonable de piezas confirmadas que todavía no se ha validado como conjunto.

Esta distinción es importante: **que una llamada exista en un script nativo no garantiza automáticamente que pueda usarse con la misma firma dentro de una Sequence**.

---

# 2. CKS/VS y Sequences

Una **Sequence** permite ejecutar lógica programada sobre objetos del mapa.

Ejemplo mínimo:

```cpp
while (1)
{
    Sleep(1000);
}
```

`Sleep()` utiliza milisegundos y es una de las herramientas fundamentales para construir bucles de polling sin ejecutar lógica en cada frame.

Una estructura habitual es:

```cpp
ObjList objects;
Building building;
Unit unit;
int i;

objects = ClassPlayerObjs("TOutpost", 15).GetObjList();

for (i = 0; i < objects.count; i += 1)
{
    building = objects[i].AsBuilding();
}
```

Este patrón resume buena parte del trabajo habitual:

1. localizar objetos;
2. convertirlos al tipo necesario;
3. leer estado;
4. actuar;
5. repetir periódicamente si la mecánica es persistente.

## 2.1 Autorun

Una Sequence que deba iniciarse con el escenario debe configurarse en el editor con `Autorun allowed`.

Flujo:

```text
crear Sequence
→ asignar nombre
→ pegar Source
→ marcar Autorun si procede
→ Compile
→ guardar escenario
```


## 2.3 Evidencia oficial de que Sequences y scripts nativos comparten el mismo lenguaje operativo

Una de las dudas iniciales de la investigación era si el código `.vs` interno del motor y el código
pegado en una Sequence eran dos entornos suficientemente distintos como para impedir reutilizar
patrones entre ambos.

La búsqueda posterior en **48 escenarios, aventuras y conquistas** resolvió esta cuestión con evidencia
mucho más fuerte.

Tres campañas oficiales utilizan `Place()` directamente desde Sequences:

```text
Great_loses_Spain.BFHP
Great_loses_Boudicca.BFHP
mediterranean.BFHP
```

y, de forma especialmente importante, `Great_loses_Spain` contiene una reimplementación casi literal
del comportamiento nativo de `TTent`, con los mismos comentarios, variables, `Settlement`, Queries,
`Place()`, `SetFeeding(false)` y lógica de captura.

La conclusión práctica es:

```text
script nativo .vs
        y
Sequence .vs
```

comparten un vocabulario y una semántica suficientemente próximos como para reutilizar código real
entre ambos contextos, aunque algunas funciones sigan siendo exclusivas de uno de los dos.

Esto **corrige una incertidumbre de las primeras fases**, originada porque `Infierno_en_Iberia.BFHP`
no utiliza `Place()` en ninguna de sus Sequences. La ausencia en ese único escenario no significaba
que `Place()` fuese incompatible con Sequences; simplemente ese mapa empleaba otra arquitectura
basada en Groups precolocados.

## 2.2 Compilar no equivale a funcionar

El compilador valida sintaxis y tipos conocidos, pero el comportamiento final debe probarse en partida.

Dos errores frecuentes:

- asumir que una función nativa está disponible en Sequence;
- olvidar que un elemento de `ObjList` sigue teniendo tipo estático `Obj`.

Ejemplo:

```cpp
ObjList units;
units = fort.settlement.Units();
```

Para usar un método específico de `Unit`:

```cpp
units[j].AsUnit().InHolder()
```

---

# 3. Editor: Sequences y Groups

## 3.1 Crear una Sequence

```text
Scenario
└── Map
    └── Sequences
```

Proceso recomendado:

1. crear Sequence;
2. nombrarla;
3. abrir `Source`;
4. escribir o pegar código;
5. activar `Autorun allowed` si procede;
6. pulsar `Compile`;
7. corregir el primer error;
8. guardar;
9. verificar en partida.

## 3.2 Groups

Los **Groups** dan un nombre estable a uno o varios objetos del mapa.

```text
Scenario
└── Map
    └── Groups
```

Lectura básica:

```cpp
ObjList objects;
objects = Group("MiGrupo").GetObjList();
```

Un Group puede servir como:

- referencia a un edificio;
- conjunto de unidades;
- marcador;
- conjunto territorial;
- punto de aparición;
- identidad lógica de una mecánica.

## 3.3 Groups dinámicos

```cpp
u.AddToGroup("MiGrupoDinamico");
```

Recuperación:

```cpp
Group("MiGrupoDinamico").GetObjList();
```

Eliminación:

```cpp
u.RemoveFromGroup("MiGrupoDinamico");
```

Esta técnica permite asociar dinámicamente guarniciones, auxiliares, hordas u otros objetos sin precrear cientos de Groups manuales.

---

# 4. Modelo de objetos, clases y herencia

Las entidades del juego se organizan mediante clases.

Ejemplos:

```text
Unit
Military
Building
Outpost
GOutpost
TOutpost
GGuardPost
```

## 4.1 `IsHeirOf`

```cpp
if (fort.IsHeirOf("EOutpost"))
{
    // tratamiento específico egipcio
}
```

También:

```cpp
if (obj.IsHeirOf("Military"))
{
    // unidad militar
}
```

Permite construir scripts genéricos que reconocen subtipos concretos.

## 4.2 Conversión explícita

Los elementos de `ObjList` son `Obj`.

```cpp
Building fort;
fort = objects[i].AsBuilding();
```

o:

```cpp
Unit u;
u = objects[i].AsUnit();
```

## 4.3 Outposts culturales conocidos

| Clase | Cultura / función |
|---|---|
| `TOutpost` | Germania |
| `GOutpost` | Galia |
| `BOutpost` | Britania |
| `IOutpost` | Iberia |
| `COutpost` | Cartago |
| `ROutpost` | Roma |
| `EOutpost` | Egipto |
| `GGuardPost` | Guard Post especial |

`GGuardPost` hereda de `Outpost`, pero su comportamiento propio obliga a tratarlo como caso especial.

---

# 5. Tipos principales: Obj, Unit, Building y Settlement

## 5.1 `Obj`

Tipo genérico habitual en listas y consultas.

```cpp
obj.player
obj.pos
obj.IsHeirOf("...")
obj.AddToGroup("...")
obj.RemoveFromGroup("...")
```

## 5.2 `Unit`

Conversión:

```cpp
Unit u;
u = obj.AsUnit();
```

Operaciones documentadas:

```cpp
u.SetLevel(20);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
u.SetCommand("move", point);
u.SetCommand("advance", point);
u.SetCommand("enter_tent", building);
u.SetPlayer(player);
u.InHolder();
u.GetCommanded();
```

### `SetLevel`

```cpp
u.SetLevel(12);
```

### `SetFood`

```cpp
u.SetFood(20);
```

### `SetFeeding(false)`

```cpp
u.SetFeeding(false);
```

Se usa cuando una unidad no debe depender de la alimentación normal.

### `SetNoAIFlag(true)`

```cpp
u.SetNoAIFlag(true);
```

Se utiliza para excluir una unidad del control estratégico normal de la IA en los contextos donde ha sido validado.

### `InHolder()`

```cpp
if (u.InHolder())
{
    // unidad dentro de holder
}
```

## 5.3 `Building`

```cpp
Building fort;
fort = obj.AsBuilding();
```

Datos usados:

```cpp
fort.player
fort.pos
fort.range
fort.settlement
fort.DistTo(unit)
fort.SetPlayer(player)
```

## 5.4 `Settlement`

Operaciones importantes:

```cpp
fort.settlement.Units()
fort.settlement.UnitsCount()
fort.settlement.ForceAddUnit(u)
fort.settlement.SetLoyalty(100)
fort.settlement.AllowCapture(false)
```

### `Units()`

```cpp
ObjList units;
units = fort.settlement.Units();
```

### `UnitsCount()`

```cpp
int count;
count = fort.settlement.UnitsCount();
```

### `ForceAddUnit`

```cpp
fort.settlement.ForceAddUnit(u);
```

### `SetLoyalty`

```cpp
fort.settlement.SetLoyalty(100);
```

### `AllowCapture`

```cpp
fort.settlement.AllowCapture(false);
```

o:

```cpp
fort.settlement.AllowCapture(true);
```

## 5.5 Excepción: `GGuardPost`

`GGuardPost` tiene:

```text
max_units = 0
```

Por ello no debe tratarse como almacén normal de tropas aunque herede de `Outpost`.

---

# 6. Query y ObjList

- **Query** construye selecciones mediante filtros.
- **ObjList** representa una lista concreta recorrible.

## 6.1 Query espacial

```cpp
qRange = ObjsInRange(fort, "Unit", fort.range);
```

## 6.2 Enemigos militares y magos

```cpp
qEnemies =
    Intersect(
        qRange,
        Union(
            EnemyObjs(owner, "Military"),
            EnemyObjs(owner, "BaseMage")
        )
    );
```

Excluir sentinelas:

```cpp
qEnemies =
    Subtract(
        qEnemies,
        EnemyObjs(owner, "Sentry")
    );
```

## 6.3 Operaciones conocidas sobre Query

```text
ObjsInRange(...)
EnemyObjs(...)
ClassPlayerObjs(...)
Intersect(...)
Union(...)
Subtract(...)
```

Patrón habitual:

```text
universo
→ filtro espacial
→ filtro de relación/clase
→ exclusiones
→ GetObjList()
```

## 6.4 `ObjList`

```cpp
ObjList enemies;
enemies = qEnemies.GetObjList();
enemies.ClearDead();
```

Operaciones documentadas:

```cpp
list.count
list[i]
list.Clear()
list.ClearDead()
list.Add(obj)
list.AddList(otherList)
list.Contains(obj)
```

`ClearDead()` es importante en sistemas persistentes.

## 6.5 `ClassPlayerObjs`

```cpp
ObjList forts;
forts = ClassPlayerObjs("TOutpost", 15).GetObjList();
```

En sistemas universales puede ser útil descubrir inicialmente objetos y conservar referencias aunque después cambien de propietario.

---

# 7. Creación dinámica de unidades

La creación dinámica permite generar tropas, defensores, refuerzos y ejércitos de recompensa sin precolocarlos en el editor.

La función central documentada es `Place()`.

## 7.1 `Place(class, pos, player)`

Patrón básico:

```cpp
Unit u;

u = Place(
    "TValkyrie",
    fort.pos,
    owner
);
```

También puede recibir un `Point` construido explícitamente:

```cpp
u = Place(
    "RHastatus",
    Point(spawnX, spawnY),
    owner
);
```

Los tres argumentos representan:

| Argumento | Significado |
|---|---|
| `class` | ID técnico de la clase a crear |
| `pos` | posición de aparición |
| `player` | propietario inicial |

La cadena utilizada debe corresponder al **ID técnico real de la clase**, no necesariamente a su nombre visible en la interfaz.

## 7.2 Configuración posterior

Una unidad recién creada puede configurarse inmediatamente:

```cpp
u.SetLevel(20);
u.SetFood(20);
```

Para una guarnición permanente se utiliza además:

```cpp
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

En cambio, para un ejército que deba comportarse como tropa normal del jugador o de la IA, **no deben aplicarse automáticamente esas dos llamadas**.

La diferencia conceptual es:

```text
guarnición estructural
→ sin hambre
→ excluida de la estrategia normal de IA

ejército normal
→ alimentación normal
→ control normal del jugador/IA
```

## 7.3 Introducir una unidad en un Settlement

Cuando el edificio admite unidades:

```cpp
fort.settlement.ForceAddUnit(u);
```

Esto permite asociar la unidad generada al Settlement/holder.

No debe extrapolarse este patrón a `GGuardPost`, cuya definición conocida fija `max_units=0`.

## 7.4 Coordenadas y `Point(x,y)`

Las Sequences utilizan directamente:

```cpp
Point(x, y)
```

como valor de posición.

Para cálculos más complejos resulta más robusto mantener las coordenadas separadas:

```cpp
int spawnX;
int spawnY;
```

y construir el punto sólo cuando se utiliza:

```cpp
u = Place(
    "RHastatus",
    Point(spawnX, spawnY),
    owner
);
```

Este patrón evita depender de mutaciones o asignaciones parciales de un `Point`.

## 7.5 Formaciones mediante offsets

Si muchas unidades aparecen exactamente en la misma posición pueden amontonarse.

Los ejércitos dinámicos pueden distribuirse mediante offsets:

```cpp
Point(
    spawnX + offsetX,
    spawnY + offsetY
)
```

El principio se utiliza en refuerzos y recompensas militares para crear una formación inicial en vez de superponer todas las unidades.

## 7.6 Patrón completo de creación de guarnición

```cpp
Unit u;

u = Place(
    "IDefender",
    fort.pos,
    owner
);

u.SetLevel(20);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);

fort.settlement.ForceAddUnit(u);
```

No todos los sistemas necesitan las cinco operaciones. Deben elegirse según el papel de la unidad.



## 7.7 `Place()` confirmado en escenarios oficiales

La compatibilidad de `Place()` con Sequences está confirmada por múltiples escenarios oficiales.

Ejemplo de un Outpost controlado por Sequence:

```cpp
Unit u1;

u1 = Place(
    sDefenderCls1,
    .pos,
    .player
);

u1.SetFeeding(false);
.settlement.ForceAddUnit(u1);
u1.SetLevel(old_level_1);
```

Este patrón aparece repetido en numerosas instancias de Outpost dentro de campañas oficiales.

Ejemplo independiente de regeneración periódica:

```cpp
if (Archers.count < ArchCount)
{
    int revive;
    revive = ArchCount - Archers.count;

    for (i = 1; i <= revive; i += 1)
    {
        Unit u;

        u = Place(
            "BBowman",
            Point(
                b.GetCentralBuilding().pos.x,
                b.GetCentralBuilding().pos.y - 150
            ),
            1
        ).AsUnit();

        b.ForceAddUnit(u);
        u.AddToGroup("BonuseU");
    }
}
```

La importancia de este segundo ejemplo es que demuestra un ciclo real:

```text
contar supervivientes
→ calcular bajas
→ Place()
→ ForceAddUnit()
→ AddToGroup()
→ repetir tras temporizador
```

Es la base más directa encontrada para una guarnición regenerable sin depender de unidades
precolocadas.

## 7.8 Regenerar una unidad o todas las bajas

El escenario `mediterranean` repone **todas las bajas de golpe** cuando vence el temporizador:

```cpp
revive = ArchCount - Archers.count;
```

Nada obliga a mantener esa política.

Para una regeneración gradual, el mismo patrón puede adaptarse conceptualmente a:

```text
si count < máximo
→ crear 1 unidad
→ reiniciar temporizador
```

La creación de una sola unidad cada ciclo es una modificación de diseño sobre piezas confirmadas;
no se encontró un escenario oficial que use exactamente esa variante.


# 8. Comandos de unidades

Forma general:

```cpp
unit.SetCommand("comando", argumento);
```

La investigación posterior de `Unit`, `RamUnit`, `unit_capture.vs` y escenarios oficiales permite
distinguir con más precisión entre **movimiento**, **ataque a objetos**, **entrada** y **captura**.

## 8.1 `advance`

Uso confirmado:

```cpp
unit.SetCommand("advance", point);
```

`advance` debe documentarse como un comando de **desplazamiento hacia un punto**. Hay evidencia y
comportamiento observado de reacción táctica frente a unidades enemigas durante el recorrido, pero
**no debe asumirse que convierte automáticamente un edificio bloqueante en objetivo de ataque**.

Esta corrección es especialmente importante para puertas:

```text
advance hacia un Foro detrás de una Gate
≠
orden automática de destruir la Gate
```

Una Gate cerrada puede actuar simplemente como obstáculo de pathfinding. Si debe ser destruida,
la Sequence tiene que emitir una orden específica de ataque o de asedio.

## 8.2 `move`

```cpp
unit.SetCommand("move", point);
```

Movimiento normal hacia una posición. Es el comando más apropiado para retornos, reposicionamiento y
control territorial cuando no se quiere expresar una intención ofensiva contra un objeto concreto.

## 8.3 `attack`

La clase base `Unit` declara `attack` como comando válido contra `Building`:

```xml
<defaultcmd target="Building">
    <cmd name="attack_independent"/>
    <cmd name="capture"/>
    <cmd name="attack"/>
    <cmd name="enter"/>
    <cmd name="approach"/>
</defaultcmd>
```

Por tanto es válido:

```cpp
unit.SetCommand("attack", building);
```

y, por herencia:

```cpp
unit.SetCommand("attack", gate);
```

También se observa en el comportamiento nativo de sentinelas:

```cpp
sentry.SetCommand("attack", target);
```

La existencia del comando contra `Building` está **confirmada**. La velocidad o eficacia concreta del
daño depende de la clase atacante y no debe inferirse sólo por la existencia de la orden.

## 8.4 `capture`

La investigación de `data/subai/unit_capture.vs` confirmó que la captura normal de Townhall se activa
desde la **unidad atacante**, no desde un observador pasivo del edificio.

```cpp
unit.SetCommand("capture", building);
```

Para un Townhall no independiente, esta orden puede reducir `Settlement.loyalty` y, al llegar a 0
dentro del propio bucle de captura, ejecutar:

```cpp
building.settlement.SetPlayer(unit.player);
building.settlement.SetLoyalty(11);
```

Consecuencia crítica:

> una unidad perteneciente a un jugador técnico 9-16 **sí puede transferir un Townhall a ese jugador**
> si recibe `capture` y completa el proceso.

Esto corrige la extrapolación antigua desde `TTent`, cuyo comportamiento de conquista sí filtra
jugadores superiores a 8. **La regla de `TTent` no debe aplicarse a Townhall.**

## 8.5 `enter`

`enter` está declarado como comando válido contra `Building` y aparece en Sequences reales:

```cpp
unit.SetCommand("enter", building);
```

Es relevante en asentamientos amurallados: una arquitectura de conquista puede separar:

```text
destruir Gate
→ entrar
→ capturar
```

en lugar de ordenar `capture` desde fuera de las murallas y confiar en que el pathfinding resuelva
también el asedio.

## 8.6 `enter_tent`

También existe el patrón específico:

```cpp
defender.SetCommand("enter_tent", fort);
```

utilizado en sistemas de Outpost/holder. No debe confundirse con el comando genérico `enter` contra
un `Building`.

## 8.7 `build_catapult`

El sistema nativo de catapultas-edificio usa:

```cpp
unit.SetCommand("build_catapult", catapultObj);
```

después de crear el objeto con `PlaceCatapult(...)`. Es un flujo distinto del de `RamUnit`, que es una
unidad móvil y recibe `attack` normalmente.

## 8.8 `attack_independent`

Existe en el `defaultcmd` de `Unit`, pero está asociado al mismo sistema de captura que
`unit_capture.vs`. No debe utilizarse como sinónimo de “atacar físicamente un edificio”.

Para destruir una Gate:

```text
usar attack
o
usar ObjList.Siege(...)
```

no `attack_independent`.

## 8.9 Reimposición de órdenes

Una **guarnición obligatoria** puede necesitar que el script reimponga periódicamente su función defensiva.

Una **tropa normal del jugador** no debe quedar permanentemente secuestrada por el script.

La misma idea se aplica a ejércitos dinámicos:

```text
objetivo estratégico persistente
≠
repetir ciegamente el mismo SetCommand en todo momento
```

En un asedio es más robusto conservar un objetivo final —por ejemplo el Foro— y cambiar temporalmente
el **subobjetivo**:

```text
Foro final
→ Gate viva: attack / Siege
→ Gate destruida: enter
→ dentro: capture
```

Este patrón reproduce mejor la separación que utiliza la IA nativa entre navegación, asedio, entrada
y captura.


# 9. IA y control de unidades

Crear una unidad y asignarle propietario no determina por sí solo qué papel estratégico debe tener.

En los sistemas investigados se distinguen tres modelos:

1. **unidad normal**, gestionada con las reglas habituales;
2. **guarnición estructural**, reservada para defensa;
3. **tropa auxiliar**, controlada por script sólo durante una situación concreta.

## 9.1 `SetNoAIFlag(true)`

```cpp
u.SetNoAIFlag(true);
```

Se utiliza en unidades que pertenecen funcionalmente a una estructura y no deben convertirse en parte del ejército estratégico normal de la IA.

En la documentación actual se usa en:

- guarniciones de fortalezas;
- guardianes terrestres añadidos a Guard Posts.

No se utiliza en:

- tropas auxiliares normales almacenadas por el jugador;
- ejércitos de recompensa.

## 9.2 `SetFeeding(false)`

```cpp
u.SetFood(20);
u.SetFeeding(false);
```

Evita que la unidad dependa del sistema normal de alimentación.

Es adecuado para defensores persistentes cuya existencia forma parte de una mecánica de edificio.

No debe aplicarse si se quiere que la unidad funcione como ejército normal y participe en la logística ordinaria.

## 9.3 Control estricto de guarnición

Una guarnición puede necesitar que la Sequence reimponga periódicamente su comportamiento:

```cpp
defender.SetCommand(
    "advance",
    enemy.pos
);
```

La Sequence sigue siendo la autoridad principal sobre esas tropas.

Modelo:

```text
amenaza detectada
→ orden defensiva
→ control continuo del script
→ repliegue
→ regreso al holder
```

## 9.4 Control temporal de tropas auxiliares

Las tropas normales almacenadas no deben quedar permanentemente secuestradas por la Sequence.

En este modelo:

```text
tropa normal almacenada
→ aparece amenaza
→ Sequence da una orden inicial
→ jugador/IA puede intervenir
→ desaparece amenaza
→ lógica de repliegue
```

La diferencia frente a una guarnición no es sólo técnica: determina si la unidad sigue siendo una tropa normal del jugador.

## 9.5 `GetCommanded()`

La documentación investigada identifica:

```cpp
u.GetCommanded()
```

como mecanismo útil para detectar estado de orden/intervención en unidades.

Su uso permite diseñar lógicas que eviten sobrescribir de forma indiscriminada órdenes manuales.

## 9.6 Regla práctica

Antes de generar o controlar una unidad debe decidirse explícitamente qué categoría representa:

| Papel | `SetFeeding(false)` | `SetNoAIFlag(true)` | Reimposición periódica |
|---|---:|---:|---:|
| Guarnición estructural | Sí | Sí | Puede ser necesaria |
| Auxiliar normal | No | No | Sólo mientras proceda |
| Ejército de recompensa | No | No | No como regla general |

Esta separación evita que una mecánica defensiva se convierta accidentalmente en un bloqueo del control normal de tropas.



## 9.7 Evidencia real de `SetNoAIFlag`

La investigación encontró más de 200 apariciones de `SetNoAIFlag` en scripts del juego y varias
categorías claras de uso:

| Contexto | Patrón observado |
|---|---|
| Héroe controlado temporalmente por misión | `hero.SetNoAIFlag(true)` y restauración posterior |
| Refuerzos creados por script | aplicación sobre una `ObjList` |
| Guarniciones | unidades excluidas de la gestión estratégica normal |
| Outposts oficiales controlados por Sequence | `Place()` → `SetFeeding(false)` → `SetNoAIFlag(true)` → `ForceAddUnit()` |

Ejemplo especialmente relevante:

```cpp
u1 = Place(
    sDefenderCls1,
    .pos,
    .player
);

u1.SetFeeding(false);
u1.SetNoAIFlag(true);
.settlement.ForceAddUnit(u1);
```

Por tanto, `SetNoAIFlag(true)` no es una solución hipotética: existe un precedente oficial
prácticamente idéntico al uso de una guarnición personalizada.

## 9.8 Qué puede afirmarse y qué no

La evidencia de uso es consistente con:

> “Excluir la unidad de la gestión estratégica normal de ejércitos de la IA”.

Sin embargo, no se recuperó el cuerpo interno de la función, por lo que esa descripción sigue siendo
una interpretación funcional del patrón de uso, no una especificación formal del motor.

Sí está claro que `SetNoAIFlag(true)` **no impide al propio script seguir dando órdenes**. Las unidades
marcadas pueden recibir después:

```cpp
SetCommand(...)
```

con normalidad.

No se encontró evidencia suficiente para afirmar que:

- un `SetPlayer()` posterior conserve o borre el flag;
- el flag pueda aplicarse directamente a un Group nombrado;
- `RunAIHelper("GuardCentralArea", ...)` lo aplique internamente.

Los usos reales confirmados aplican el flag sobre:

```text
Unit
Hero
ObjList
```

pero no directamente sobre un nombre de Group.


# 10. Groups dinámicos y estado persistente

Los scripts persistentes necesitan:

1. identificar objetos pertenecientes a cada instancia;
2. guardar estado entre ciclos.

## 10.1 Identidad dinámica

```cpp
groupName =
    "__FRT_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

Añadir:

```cpp
u.AddToGroup(groupName);
```

Recuperar:

```cpp
garrison = Group(groupName).GetObjList();
```

Eliminar:

```cpp
u.RemoveFromGroup(groupName);
```

## 10.2 `EnvWriteInt`

```cpp
EnvWriteInt(
    fort,
    "FG_Regen",
    0
);
```

## 10.3 `EnvReadInt`

```cpp
regenClock =
    EnvReadInt(
        fort,
        "FG_Regen"
    );
```

Usos:

- inicialización;
- relojes;
- propietario esperado;
- alternancia de pools;
- flags;
- estados de fase.

## 10.4 Limitación crítica: claves dinámicas

Esto no compila:

```cpp
EnvReadInt(obj, "PREFIJO"+indice)
```

Error observado:

```text
No matching function with name EnvReadInt
```

En cambio:

```cpp
EnvWriteInt(obj, "PREFIJO"+indice, valor)
```

sí compila y funciona.

La lectura debe desenrollarse:

```cpp
active = 0;

if (H == 1)
    active = EnvReadInt(state, "HW_ACTIVE1");

if (H == 2)
    active = EnvReadInt(state, "HW_ACTIVE2");
```

---

# 11. Outposts y fortalezas

## 11.1 Base `Outpost`

`Outpost` es una clase capturable asociada a Settlement.

Variantes culturales:

```text
GOutpost
TOutpost
BOutpost
IOutpost
COutpost
ROutpost
EOutpost
```

Pueden variar:

- clases defensoras;
- máximos;
- niveles;
- recursos;
- comportamiento adicional.

## 11.2 Sistema universal

Un sistema general puede:

1. localizar todos los Outposts;
2. reconocer su subtipo;
3. crear una identidad dinámica por fortaleza;
4. gestionar su guarnición y estado.

Esto evita una Sequence por edificio.

## 11.3 Guarniciones con dos pools

Ejemplos documentados:

```text
IOutpost
12 ISlinger
10 IDefender
```

```text
EOutpost
10 EHorusWarrior
10 EAnubisWarrior
```

Cada tipo puede mantener máximo propio.

## 11.4 Neutralidad y primera conquista

Cuando la lógica neutral nativa ya es válida, el script puede no intervenir hasta que el edificio sea conquistado por Player 1..8.

```text
neutral
→ comportamiento nativo
→ conquista
→ gestión personalizada
```

`EOutpost` requiere tratamiento especial según la documentación actual.

---


## 11.5 `TTent`: precedente nativo de fortaleza con defensores

La investigación recuperó el comportamiento completo de `TTent`, que implementa de forma nativa
gran parte de lo necesario para una fortaleza defensiva:

- hasta dos clases de defensores;
- máximos independientes;
- unidades almacenadas en el `Settlement`;
- unidades que salen a patrullar;
- `SetFeeding(false)`;
- detección de enemigos;
- retorno de defensores al holder;
- bloqueo de la captura normal mediante loyalty;
- transferencia al conquistador tras exterminar la defensa.

Su arquitectura real se documenta con detalle en el capítulo 20.

## 11.6 Un Outpost normal puede recibir comportamiento tipo `TTent`

Un hallazgo fundamental de las campañas oficiales es que no hace falta crear una clase nueva.

Los diseñadores utilizaron:

```text
ROutpost / Briton Outpost normal
+
Sequence de escenario
+
lógica copiada de TTent
```

para crear fortalezas con composiciones completamente personalizadas.

Esto establece un patrón general:

```text
clase visual/mecánica existente
+
Sequence que añade comportamiento
```

y evita modificar clases globales del juego.


# 12. `GGuardPost` y sistema de sentinelas

La investigación exhaustiva de `GGuardPost` corrigió una simplificación anterior: aunque la clase
hereda de `Outpost`, **no utiliza el mismo sistema defensivo que los Outposts culturales normales**.

Definición recuperada:

```xml
<class id="GGuardPost" cpp_class="CVXOutpost" parent="Outpost">
```

Propiedades relevantes:

```text
range = 1000
max_units = 0
settlement_maxfood = 0
settlement_maxgold = 10000
```

Comportamientos propios:

```text
data/subai/settlement_behavior_horses.vs
data/subai/GGuardPost_Sentries.vs
```

La propiedad `max_units=0` es estructural: un `GGuardPost` **no debe tratarse como holder normal de
tropas**, aunque herede de `Outpost`.

## 12.1 Tres sistemas defensivos distintos coexistentes

La investigación permite separar tres mecanismos que antes podían confundirse:

| Sistema | Ejemplo | Mecanismo |
|---|---|---|
| pools de defensores de Outpost | `GOutpost`, `TOutpost`, etc. | `defender_cls_N`, `defenders_max_N`, `defenders_out_N`, niveles |
| sentinelas genéricos de muro/Gate | `Gate`, torres y Settlement de muralla | `AddMaxSentries`, `AddSentries`, slots y `sentry_class_name` |
| sentinelas propios de `GGuardPost` | `GGuardPost` | script `GGuardPost_Sentries.vs`, 12 slots hardcodeados |

Por tanto:

```text
AddMaxSentries()
```

puede ser real y útil en el sistema genérico de murallas, pero **no aumenta los arqueros nativos de
`GGuardPost`**, porque su comportamiento no consulta ese contador.

## 12.2 Doce sentinelas hardcodeados

`GGuardPost_Sentries.vs` mantiene explícitamente:

```text
s0 ... s11
```

y crea cada unidad con el patrón:

```cpp
Place(
    sRace + "GuardPostSentry",
    post.pos + Point(offsetX, offsetY),
    owner
);
```

Las doce posiciones están fijadas en dos `IntArray` internos del script nativo.

Esto demuestra dos cosas:

1. el número nativo es exactamente **12**;
2. no existe un parámetro de Sequence conocido que convierta esos 12 slots en 16, 20, etc.

Si se quiere reforzar el puesto, el patrón seguro es **añadir defensores externos**, no intentar
ampliar el pool nativo.

## 12.3 `IntArray` confirmado también en Sequences

La compilación estable v2.0 resuelve una incertidumbre anterior: `IntArray` **sí compila y se utiliza desde Sequences**.

Ejemplo real de `ZombieEE_Portals_Main`:

```cpp
IntArray portalClosed;

portalClosed[portal] =
    EnvReadInt(
        state,
        "EE_PORTAL_CLOSED" + portal
    );
```

`ZombieTactical_Main` utiliza además numerosos arrays persistentes durante toda la vida de la Sequence:

```cpp
IntArray phase;
IntArray marchTicks;
IntArray gateX;
IntArray gateY;
IntArray anchorNode;
IntArray targetNode;
IntArray goalNode;
IntArray nodeX;
IntArray nodeY;
IntArray edgeW;
IntArray routeDist;
IntArray routePrev;
IntArray routeUsed;
IntArray routePath;
IntArray frontActive;
```

También está confirmado el acceso indexado directo:

```cpp
nodeX[1] = 1025;
nodeY[1] = 1194;
phase[H] = 0;
frontActive[H] = active;
```

Por tanto la regla canónica pasa a ser:

```text
IntArray en scripts nativos
→ CONFIRMADO

IntArray en Sequences
→ CONFIRMADO en la compilación v2.0
```

No se debe extender automáticamente esta conclusión a tipos de colección distintos de `IntArray` que no hayan sido probados.

## 12.4 Regeneración casi inmediata

En cada ciclo del comportamiento:

```cpp
if (!s0.IsValid())
{
    s0 = Place(...);
}
```

y el bucle principal termina con un ritmo aproximado de:

```cpp
Sleep(1500);
```

Por ello un sentinela muerto se repone normalmente en el siguiente ciclo: del orden de **1,5 segundos**
más pequeñas esperas internas.

Esta regeneración no utiliza el sistema de guarniciones del Settlement.

## 12.5 Cultura y propietario de los sentinelas

La clase no fija los arqueros permanentemente a Galia.

El script determina la raza a partir del propietario actual:

```cpp
pNumber = .player;
pRace = GetPlayerRace(pNumber);
sRace = GetRaceStrPref(pRace);
```

y construye:

```text
<PrefijoRaza>GuardPostSentry
```

Ejemplo:

```text
GGuardPostSentry
```

Por tanto el `race="Gaul"` de la definición de `GGuardPost` no obliga a que el puesto capturado siga
teniendo centinelas galos.

## 12.6 Cambio de propietario: destruir y recrear, no convertir

El script conserva el dueño anterior en `pNumber`. Cuando detecta:

```cpp
.player() != pNumber
```

elimina los sentinelas antiguos aplicándoles daño mortal:

```cpp
postSentries[i].Damage(
    postSentries[i].AsUnit().maxhealth
);
```

Después:

```cpp
EnvWriteInt(this, "sentriesLevel", 1);
pNumber = .player;
```

recalcula la raza y, en la siguiente iteración, crea los 12 sentinelas del nuevo dueño.

El comportamiento real es:

```text
cambio de dueño del puesto
→ mueren los 12 sentinelas anteriores
→ nivel de sentinelas vuelve a 1
→ se calcula la raza del nuevo dueño
→ se generan 12 nuevos
```

No se produce una simple llamada `SetPlayer()` sobre los arqueros existentes.

## 12.7 Nivel automático

El estado se persiste sobre el propio `Building`:

```cpp
EnvReadInt(this, "sentriesLevel")
EnvWriteInt(this, "sentriesLevel", value)
```

El contador incrementa aproximadamente una vez cada 90 segundos y tiene como máximo observado:

```text
36
```

Al cambiar de propietario se resetea a 1.

Una posible manipulación desde Sequence mediante:

```cpp
EnvWriteInt(post, "sentriesLevel", 20);
```

es **inferida**, no validada experimentalmente en el material aportado. Debe mantenerse como test,
no como API de producción confirmada.

## 12.8 Comportamiento táctico

Cada sentinela:

1. busca un objetivo con `BestTargetInRange`;
2. valida el objetivo;
3. si procede, recibe:

```cpp
sentry.SetCommand("attack", target);
```

4. en ausencia de objetivo, el script lo recoloca/orienta alrededor de su slot.

No hay `SetNoAIFlag(true)` dentro de `GGuardPost_Sentries.vs`.

Tampoco se encontró una lógica de persecución territorial larga: el comportamiento está diseñado en
torno a los 12 puntos del puesto.

## 12.9 Captura del `GGuardPost`

El script de sentinelas **no causa la captura**. Sólo reacciona a:

```text
edificio roto
o
cambio de .player
```

`GGuardPost` hereda de `Outpost`:

```text
can_be_captured = 1
capture_health_percent = 50
```

sin override conocido.

Por ello deben separarse:

```text
mecánica de captura del Outpost
≠
mecánica de los 12 sentinelas
```

Matar un arquero no ejecuta por sí mismo `SetPlayer()`.

## 12.10 Qué puede controlarse desde Sequence

Confirmado en el ecosistema de Sequences:

```text
SetPlayer
SetLoyalty
AllowCapture
AddMaxSentries
AddSentries
```

Pero la aplicabilidad depende del sistema.

Para `GGuardPost`:

- `AllowCapture(false/true)` es una palanca razonable y genérica de captura;
- `SetPlayer()` puede cambiar el propietario del Settlement/edificio;
- `AddMaxSentries()` y `AddSentries()` pertenecen al sistema genérico de sentinelas y **no modifican
  el bucle hardcodeado `s0..s11`**;
- `ForceAddUnit()` no es el mecanismo apropiado porque `max_units=0`.

## 12.11 Patrón de extensión recomendado

Si se quiere transformar un Guard Post en puesto fronterizo más fuerte sin sustituir su comportamiento
nativo:

```text
GGuardPost nativo
→ conservar 12 sentinelas
+
Sequence externa
→ crear 4-6 defensores normales con Place()
→ gestionar amenaza/retorno fuera del Settlement
```

La ventaja es que la Sequence externa no toca `s0..s11`, variables privadas del behavior nativo.

## 12.12 Regla canónica

`GGuardPost` debe considerarse:

```text
Outpost capturable a nivel de clase
+
Settlement con max_units=0
+
sistema defensivo exclusivo de 12 sentinelas
```

y no:

```text
Outpost cultural normal con más arqueros
```

Esta distinción evita mezclar `ForceAddUnit`, pools `defender_cls_N` y `AddMaxSentries` en un edificio
que no usa ninguno de esos tres mecanismos para sus 12 defensores visibles.


# 13. Captura, loyalty y control territorial

La investigación de `Settlement.loyalty` y de `data/subai/unit_capture.vs` resolvió una de las
incógnitas principales del manual: **la captura normal de un Townhall está ejecutada por el comando
`capture` de la unidad atacante**.

No existe evidencia de un observador pasivo de `Settlement` que, por sí solo, cambie el propietario
simplemente porque `loyalty` llegue a 0.

## 13.1 `Settlement.loyalty`

Lectura:

```cpp
int loyalty;
loyalty = forum.settlement.loyalty;
```

El juego la muestra mediante un getter de UI en vivo:

```xml
<value1
    script="return .AsBuilding.settlement.loyalty;"
    rollover="Loyalty"/>
```

Esto implica que una llamada a:

```cpp
forum.settlement.SetLoyalty(50);
```

modifica la misma propiedad que la interfaz consulta para representar la barra.

El tutorial oficial utiliza precisamente un valor intermedio:

```cpp
Village.obj.AsBuilding.settlement.SetLoyalty(50);
```

Por tanto `SetLoyalty()` no está restringido a 0/100.

## 13.2 Valores confirmados

Se observaron valores reales:

```text
0
10
11
50
100
```

`11` es especialmente importante porque es el valor que la captura nativa asigna inmediatamente
después de transferir un Townhall.

No se recuperó un clamp explícito, aunque el rango operativo normal observado es 0-100.

## 13.3 La captura normal vive en `unit_capture.vs`

Fragmento confirmado para un `Building` capturable no independiente:

```cpp
while (u.IsAlive() && .IsValidCaptureTarget(u))
{
    if (.player == u.player)
        return;

    if (.Goto(u, 250, 5000, true, 2500))
    {
        if (.player == b.player)
            return;

        bEnemy = .IsEnemy(u);

        while (bEnemy == .IsEnemy(u))
        {
            if (b.settlement.loyalty == 0)
            {
                b.settlement.SetPlayer(.player);
                b.settlement.SetLoyalty(11);
                return;
            }

            .Face(b.pos);
            .Taunt(2000);
            b.settlement.DecreaseLoyalty(1);
        }
    }
}
```

La arquitectura real es:

```text
unidad recibe capture
→ se aproxima
→ mientras siga siendo atacante válido
→ DecreaseLoyalty(1)
→ loyalty == 0
→ SetPlayer(atacante)
→ SetLoyalty(11)
```

## 13.4 `DecreaseLoyalty(int)`

Nueva API confirmada:

```cpp
building.settlement.DecreaseLoyalty(1);
```

Su existencia está demostrada en `unit_capture.vs` y `hero_capture.vs`.

No debe confundirse con:

```cpp
SetLoyalty(value)
```

que fija directamente un valor elegido por el script.

## 13.5 `SetLoyalty(0)` no captura por sí solo

La investigación permite formular una regla más precisa:

```text
SetLoyalty(0)
por una Sequence
```

**no equivale automáticamente** a:

```text
SetPlayer(atacante)
```

El cambio de propietario confirmado está dentro del bucle de una unidad que ya está ejecutando
`capture`.

Riesgo:

- si una Sequence deja un Townhall en `loyalty=0`;
- y otra unidad enemiga ya está ejecutando `capture` contra él;

esa unidad puede observar el 0 en su siguiente iteración y ejecutar el cambio de propietario.

Por ello, si una mecánica personalizada necesita forzar una transición sin entregar la ciudad al
atacante nativo, es más seguro no dejar el valor 0 persistente.

## 13.6 Corrección importante: jugadores técnicos 9-16 y Townhall

Una hipótesis anterior extrapolaba a Townhall el filtro observado en `TTent`:

```cpp
if (new_player > 8)
    continue;
```

La recuperación de `unit_capture.vs` demuestra que esa extrapolación era incorrecta.

En la rama normal de Townhall aparece:

```cpp
b.settlement.SetPlayer(.player);
```

**sin filtro `player > 8`.**

Por tanto:

```text
TTent / Outpost independiente
→ comportamiento especial
→ puede filtrar jugadores > 8 en su lógica propia

Townhall normal
→ unit_capture.vs
→ el atacante que ejecuta capture puede convertirse en propietario
→ también si su player es 9-16
```

Esta es una corrección canónica del manual.

## 13.7 Rama especial para Outpost independiente y `TTent`

Dentro del mismo `unit_capture.vs` existe una rama diferente:

```cpp
if (b.settlement.IsOutpost())
{
    if (!b.settlement.IsIndependent())
        break;
    range = b.range;
}
else
{
    if (!b.IsHeirOf("TTent"))
        break;
    range = b.sight;
}
```

En esa ruta, `capture` acerca a la unidad y la pone en combate/`engage`, dejando la conquista al
behavior del propio `Outpost`/`TTent`.

Esto explica por qué no puede utilizarse una única fórmula de captura para todos los asentamientos.

## 13.8 Cómo identifica `TTent` al conquistador

El comportamiento nativo de `TTent` construye una Query de atacantes:

```cpp
qRange =
    ObjsInRange(
        this,
        "Unit",
        .range
    );

qEnemies =
    Intersect(
        qRange,
        Union(
            EnemyObjs(.player, "Military"),
            EnemyObjs(.player, "BaseMage")
        )
    );

qEnemies =
    Subtract(
        qEnemies,
        EnemyObjs(.player, "Sentry")
    );
```

También contempla catapultas enemigas como `Building`.

La transferencia sólo se ejecuta cuando han desaparecido los pools de defensores y las unidades del
Settlement.

El nuevo jugador se extrae de una unidad enemiga presente:

```cpp
new_player =
    qEnemies
    .GetObjList()[
        rand(qEnemies.GetObjList().count)
    ]
    .player;
```

y en esta mecánica sí se rechazan propietarios superiores a 8.

Si hay varios jugadores atacando, el sistema no calcula “más daño” ni “primero que llegó”: selecciona
una **unidad atacante** de la lista; un jugador con más unidades presentes tiene más entradas posibles.

## 13.9 Constantes reales de loyalty

Se recuperaron:

```ini
LoyaltyIncreasePerUnit = 10
LoyaltyUnitsOutTreshold = 151
WagonLoyaltyIncreasePerUnit = 10
WagonLoyaltyCapInterval = 500
LoyaltyInterval = 2000
LoyaltyWagonsInitial = 100
WagonLoyaltyInterval = 1000
LoyaltyCapInterval = 2000
LoyaltyChangeCap = 10
LoyaltyRadiusTownhall = 850
WagonLoyaltyChangeCap = 5
LoyaltyRadius = 1000
LoyaltySettlementsInitial = 10
```

La existencia y los valores están **confirmados**. El punto exacto de lectura de varias de estas
constantes permanece dentro de código no recuperado o C++ compilado.

## 13.10 Radio de referencia de Townhall

La constante:

```text
LoyaltyRadiusTownhall = 850
```

es distinta del radio físico/selección del edificio y debe tratarse como la mejor referencia conocida
para sistemas que quieran aproximar la zona de captura de un Townhall.

No equivale a una función `CanCaptureAtDistance`; es una constante de configuración recuperada.

## 13.11 Velocidad de captura

No se recuperó un cronómetro total explícito, pero las constantes permiten una estimación marcada como
**INFERIDA**.

Con:

```text
LoyaltyChangeCap = 10
LoyaltyCapInterval = 2000 ms
LoyaltyInterval = 2000 ms
```

el límite rápido sería aproximadamente:

```text
100 / 10 * 2 s = 20 s
```

y una captura de un único atacante, suponiendo decremento de 1 por intervalo, rondaría:

```text
100 * 2 s = 200 s
```

Por tanto, el rango orientativo obtenido es:

```text
~20 s con muchos atacantes saturando el cap
hasta
~200 s con un único atacante
```

Debe mantenerse como inferencia hasta medirlo en partida.

## 13.12 Defensores y sentinelas: no extrapolar entre sistemas

`unit_capture.vs` no contiene por sí mismo un conteo explícito de defensores. Parte de la validez de la
captura está encapsulada en:

```cpp
.IsValidCaptureTarget(...)
```

cuyo cuerpo no se recuperó.

Además:

- `TTent` excluye explícitamente `Sentry` de su Query de atacantes;
- `BaseTownhall` tiene `townhall_sentries_control.vs`;
- ese script no fue recuperado completo.

Por tanto no puede afirmarse que los sentinelas de Townhall cuenten exactamente igual que los de
`TTent`.

## 13.13 `SetPlayer()` y qué NO se ha demostrado

Está confirmado que:

```cpp
forum.SetPlayer(newOwner);
```

cambia el propietario.

No está confirmado, para Townhall, qué efectos secundarios exactos tiene sobre:

```text
gold
food
population
unidades almacenadas
sentries
textura/skin
```

Es razonable que varias propiedades permanezcan en el mismo `Settlement`, pero el manual no debe
presentarlo como hecho hasta una prueba directa.

## 13.14 Patrón seguro para una transición manual a neutral

Si una mecánica personalizada quiere mostrar una ocupación progresiva con la barra de loyalty pero
terminar en un jugador neutral concreto, puede evitar el camino nativo:

```cpp
forum.settlement.SetLoyalty(1);
forum.SetPlayer(15);
forum.settlement.SetLoyalty(100);
```

Ventajas:

1. no deja `loyalty=0` persistente;
2. no permite que `unit_capture.vs` elija el propietario;
3. deja la ciudad en el estado final decidido por la Sequence.

Este patrón es una **composición de piezas confirmadas**, no un flujo nativo idéntico encontrado en un
escenario. Debe clasificarse como diseño de Sequence.

## 13.15 Interrupción de una captura simulada

Si el script implementa su propia barra mediante `SetLoyalty`, la política más conservadora es:

```text
hay defensores/amenaza
→ congelar decremento

vuelve a estar despejado
→ continuar
```

La recuperación progresiva de loyalty está sugerida por constantes como `LoyaltyIncreasePerUnit`, pero
su algoritmo nativo exacto no fue recuperado.

## 13.16 Dos paradigmas reales de captura

La referencia canónica queda:

```text
TTent / Outpost independiente
→ capture lleva a la unidad al objetivo
→ behavior del edificio gestiona combate/aniquilación y transferencia

Townhall normal
→ capture ejecuta unit_capture.vs
→ DecreaseLoyalty
→ loyalty 0
→ SetPlayer(atacante)
→ SetLoyalty(11)
```

Esta distinción debe comprobarse antes de diseñar cualquier mecánica territorial.


# 14. Limitaciones y precauciones observadas

Este capítulo reúne tanto restricciones del lenguaje como limitaciones funcionales observadas durante el diseño de escenarios grandes.

## 14.1 CKS/VS no es C++ completo

La similitud sintáctica no implica compatibilidad con todas las características de C++.

No deben darse por supuestas:

- conversiones;
- sobrecargas;
- semántica de `null`;
- operaciones dinámicas con strings;
- métodos encontrados únicamente en código interno del motor.

Cada función importante debe comprobarse en su contexto real.

## 14.2 El tipo estático importa

Los elementos de un `ObjList` son `Obj`.

Por tanto:

```cpp
list[i]
```

puede necesitar conversión:

```cpp
list[i].AsUnit()
```

o:

```cpp
list[i].AsBuilding()
```

antes de acceder a métodos especializados.

## 14.3 Claves dinámicas en `EnvReadInt` y `EnvWriteInt`: limitación antigua superada

Una versión anterior del manual documentaba un error de compilación con:

```cpp
EnvReadInt(obj, "KEY" + index)
```

La compilación estable v2.0 contiene y utiliza correctamente lecturas dinámicas de esta forma. Ejemplos reales:

```cpp
portalClosed[portal] =
    EnvReadInt(
        state,
        "EE_PORTAL_CLOSED" + portal
    );
```

y:

```cpp
paidMask =
    EnvReadInt(
        state,
        "ZR_PAIDMASK" + roundNow
    );
```

La escritura dinámica también se utiliza de forma extensiva:

```cpp
EnvWriteInt(
    state,
    "ZR_MASK" + w,
    roundMask
);
```

Por tanto la regla canónica actual es:

```text
EnvReadInt(obj, "PREFIJO" + int)
→ CONFIRMADO en v2.0

EnvWriteInt(obj, "PREFIJO" + int, value)
→ CONFIRMADO
```

El error antiguo debe considerarse dependiente del contexto o de una versión previa del código, no una limitación general del lenguaje.

## 14.4 Scripts nativos y Sequences no son el mismo contexto

Encontrar una función en un script nativo demuestra que pertenece al sistema CKS/VS, pero no garantiza que sea invocable desde una Sequence con idéntica firma.

Debe distinguirse:

```text
existe en motor
≠
confirmado en Sequence
```

## 14.5 `GGuardPost` no es un holder normal

Su definición conocida establece:

```text
max_units = 0
```

A pesar de heredar de `Outpost`, su sistema nativo de defensa está construido alrededor de doce sentinelas propios.

## 14.6 Destruir la guarnición no equivale a controlar el territorio

Un edificio puede seguir estando defendido por tropas normales aunque la guarnición especial haya desaparecido.

La captura robusta debe considerar:

- guarnición;
- tropas normales amigas;
- enemigos;
- propietario;
- loyalty;
- captura permitida.

## 14.7 Limitaciones estratégicas de Outposts en mapas grandes

La lógica original ofrece una utilización limitada de los Outposts como red defensiva territorial en escenarios extensos.

Durante el desarrollo se observaron carencias prácticas en:

- persistencia defensiva;
- aprovechamiento estratégico por la IA;
- gestión de posiciones disputadas;
- coordinación entre tropas almacenadas y defensa del edificio.

Las Sequences personalizadas amplían estos comportamientos sin modificar el ejecutable.

## 14.8 Agua y navegación

El mapa puede contener:

- masas de agua;
- puertos;
- barcos;
- zonas aptas para transporte naval.

Sin embargo, la investigación práctica observa una utilización estratégica muy limitada de estos sistemas por la IA frente al movimiento terrestre.

Esto reduce el valor real de:

- rutas marítimas;
- desembarcos;
- puertos como nodos estratégicos;
- transporte militar por mar.

Debe considerarse una **limitación de diseño del escenario**, no una afirmación de que el motor carezca de barcos o navegación.

## 14.9 Compilación y runtime

Una Sequence que compila correctamente todavía puede comportarse de forma distinta a la esperada en partida.

La validación útil requiere:

```text
compilar
→ ejecutar
→ observar
→ aislar fallo
→ comparar con scripts/escenarios reales
```


# 15. Patrones reutilizables

Esta sección reúne fragmentos pequeños que han demostrado ser útiles como bloques de construcción.

## 15.1 Descubrir objetos por clase y jugador

```cpp
ObjList objects;

objects =
    ClassPlayerObjs(
        "TOutpost",
        15
    )
    .GetObjList();
```

## 15.2 Iterar un `ObjList`

```cpp
for (i = 0; i < objects.count; i += 1)
{
    // objects[i]
}
```

## 15.3 Convertir tipos

A edificio:

```cpp
Building fort;
fort = objects[i].AsBuilding();
```

A unidad:

```cpp
Unit u;
u = objects[i].AsUnit();
```

## 15.4 Grupo dinámico por coordenadas

```cpp
groupName =
    "__FRT_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

## 15.5 Crear una unidad

```cpp
u = Place(
    "IDefender",
    fort.pos,
    owner
);
```

## 15.6 Crear una guarnición sin hambre

```cpp
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

## 15.7 Detectar enemigos en radio

```cpp
qRange =
    ObjsInRange(
        fort,
        "Unit",
        fort.range
    );

qEnemies =
    Intersect(
        qRange,
        EnemyObjs(
            owner,
            "Military"
        )
    );
```

## 15.8 Excluir categorías de una Query

```cpp
qEnemies =
    Subtract(
        qEnemies,
        EnemyObjs(owner, "Sentry")
    );
```

## 15.9 Limpiar referencias muertas

```cpp
units.ClearDead();
```

Debe hacerse de forma sistemática en listas persistentes.

## 15.10 Guardar estado

```cpp
EnvWriteInt(
    fort,
    "MyState",
    1
);

state =
    EnvReadInt(
        fort,
        "MyState"
    );
```

## 15.11 Leer estado indexado

La versión v2.0 confirma que puede utilizarse una clave dinámica formada por string + entero:

```cpp
active =
    EnvReadInt(
        state,
        "EE_PORTAL_CLOSED" + portal
    );
```

También sigue siendo válido desenrollar lecturas cuando se desea máxima explicitud o cuando las claves tienen nombres no uniformes:

```cpp
if (H == 1)
    active = EnvReadInt(state, "HW_ACTIVE1");

if (H == 2)
    active = EnvReadInt(state, "HW_ACTIVE2");
```

En `ZombieTactical_Main` se mantiene este segundo patrón para varios estados de frente, mientras otras Sequences usan claves dinámicas. Ambos enfoques están confirmados.

## 15.12 Entrada en edificio

```cpp
u.SetCommand(
    "enter_tent",
    fort
);
```

## 15.13 Defensa temporal de tropas almacenadas

```cpp
if (
    obj.AsUnit().InHolder()
    &&
    obj.IsHeirOf("Military")
)
{
    obj.AsUnit().SetCommand(
        "advance",
        enemy.pos
    );
}
```

## 15.14 Captura de una posición realmente perdida

```cpp
if (
    garrison.count == 0
    &&
    enemies.count > 0
    &&
    friends.count == 0
)
{
    // transferencia
}
```

Este patrón evita confundir:

```text
guarnición automática destruida
```

con:

```text
territorio sin ningún defensor real
```

## 15.15 Formación de unidades generadas

Patrón conceptual:

```cpp
u = Place(
    unitClass,
    Point(spawnX + offsetX, spawnY + offsetY),
    owner
);
```

Los offsets permiten distribuir refuerzos sin superponerlos.


# 16. Referencia de funciones y métodos

Esta tabla recopila nombres **empleados o encontrados durante la investigación**. La mera presencia en
esta sección no elimina la distinción entre función probada en Sequence, función observada sólo en
motor y composición todavía pendiente de validación.

## 16.1 Funciones globales y Queries

| Nombre | Ámbito | Uso documentado |
|---|---|---|
| `Sleep(ms)` | global | pausa la ejecución |
| `Place(class,pos,player)` | motor + Sequence | crea dinámicamente objetos/unidades compatibles |
| `PlaceCatapult(x,y,player,race)` | motor confirmado | crea la `Catapult`-Building vacía que después construyen unidades |
| `Point(x,y)` | constructor | construye una posición |
| `ClassPlayerObjs(class,player)` | Query | objetos de clase/jugador |
| `ClassPlayerAreaObjs(class,player,area)` | Sequence | objetos de jugador dentro de un área |
| `EnemyObjs(player,class)` | Query | objetos enemigos |
| `ObjsInRange(obj,class,range)` | Query | objetos en radio |
| `Intersect(a,b)` | Query | intersección |
| `Union(a,b)` | Query | unión |
| `Subtract(a,b)` | Query | resta |
| `Group(name)` | global | accede a un Group |
| `EnvReadInt(obj,key)` | global | lee entero persistente |
| `EnvWriteInt(obj,key,value)` | global | escribe entero persistente |
| `GetPlayerRace(player)` | global | obtiene raza |
| `GetRaceStrPref(race)` | global | prefijo de raza usado por scripts |
| `rand(n)` | motor + Sequence | pseudoaleatorio; evidencia fuerte de rango `[0,n)` |
| `GetTime()` | Sequence confirmado | tiempo; existe una cita real en Tutorial |
| `GetConst(name)` | motor | lee constantes globales |
| `DiplCeaseFire(a,b,bool)` | Sequence | activa/desactiva alto el fuego; no es `SetEnemy` |
| `GetSettlement(name)` | Sequence | obtiene un Settlement nombrado |
| `RunSequence(name)` | Sequence | ejecuta/encadena otra Sequence |
| `ShowAnnouncement(id,text)` | Sequence | muestra/actualiza un anuncio identificado |
| `HideAnnouncement(id)` | Sequence | oculta el anuncio identificado |
| `UserNotification(text,subtext,point,player)` | Sequence | notificación dirigida a un Player y asociada a una posición; en v2.0 el segundo string se usa vacío |
| `BlockUserInput()` | Sequence | bloquea temporalmente el control del jugador |
| `UnblockUserInput()` | Sequence | devuelve el control al jugador |
| `StartViewFollow(unit)` | Sequence | inicia seguimiento de cámara sobre una Unit |
| `StopViewFollow()` | Sequence | termina el seguimiento de cámara |
| `PlayMovie(path)` | Sequence | reproduce un vídeo; usado en la intro v2.0 |
| `Translate(text)` | Sequence | usado para construir/resolver la ruta pasada a `PlayMovie` |
| `pr(text)` | Sequence / debug | escribe trazas de depuración utilizadas por varias Sequences v2.0 |
| `RunAIHelper(...)` | Sequence | invoca un AI Helper cuando se conoce su firma/modo |

## 16.2 Métodos de `Obj`, `Unit` y `Building`

| Nombre | Receptor aproximado | Uso documentado |
|---|---|---|
| `AsUnit()` | `Obj` | cast a `Unit` |
| `AsBuilding()` | `Obj` | cast a `Building` |
| `IsHeirOf(class)` | `Obj` | comprueba herencia |
| `IsAlive()` | `Obj` | comprueba vida |
| `IsValid()` | `Obj` | comprueba validez de referencia |
| `Erase()` | `Obj` / `ObjList` | elimina objeto(s) |
| `AddToGroup(name)` | `Obj` | añade a Group |
| `RemoveFromGroup(name)` | `Obj` | elimina de Group |
| `RemoveFromAllGroups()` | `Obj` | elimina de todos |
| `SetPlayer(player)` | `Obj` / `Unit` / `Building` | cambia propietario |
| `SetHealth(value)` | `Obj` / `Unit` / `Building` | fija salud |
| `Damage(value)` | `Obj` / `Unit` | aplica daño |
| `AddItem(itemName)` | `Unit` | añade un item por nombre técnico/registrado; confirmado en recompensas finales v2.0 |
| `SetLevel(level)` | `Unit` | fija nivel |
| `SetFood(value)` | `Unit` | fija comida |
| `SetFeeding(bool)` | `Unit` | alimentación |
| `SetNoAIFlag(bool)` | `Unit` | excluye de gestión estratégica en contextos confirmados |
| `SetCommand(cmd,arg)` | `Unit` | orden principal |
| `AddCommand(...)` | `Unit` | añade orden a cola |
| `GetCommanded()` | `Unit` | consulta estado usado por scripts |
| `InHolder()` | `Unit` | está dentro de holder |
| `DistTo(obj)` | `Building`/`Obj` | distancia; dirección confirmada `Building.DistTo(Unit)` |

## 16.3 Métodos de `Settlement`

| Nombre | Uso |
|---|---|
| `Units()` | unidades asociadas/contenidas |
| `UnitsCount()` | recuento |
| `ForceAddUnit(unit)` | incorpora unidad |
| `SetLoyalty(value)` | fija loyalty |
| `DecreaseLoyalty(value)` | decrementa loyalty; confirmado en `unit_capture.vs` |
| `AllowCapture(bool)` | habilita/deshabilita captura |
| `AddMaxSentries(n)` | capacidad del sistema genérico de sentinelas |
| `AddSentries(n)` | añade sentinelas en sistema compatible |
| `SetPlayer(player)` | cambia propietario del Settlement |
| `IsIndependent()` | comprueba independencia |
| `IsOutpost()` | utilizado por `unit_capture.vs` |
| `GetCentralBuilding()` | edificio central |
| `SetGold(value)` | oro |
| `SetFood(value)` | comida |

## 16.4 `ObjList`

| Nombre | Uso |
|---|---|
| `GetObjList()` | materializa Query/Group |
| `Clear()` | vacía |
| `ClearDead()` | elimina referencias muertas |
| `Add(obj)` | añade |
| `AddList(list)` | añade lista |
| `Contains(obj)` | pertenencia; confirmado en `OutpostAuxDefense_Main` v2.0 para evitar duplicar unidades entre guarnición y auxiliares |
| `FilterClosest(point,n)` | filtra objetos cercanos; confirmado en lógica nativa de catapultas |
| `Siege(target,n,param)` | asedio de alto nivel; confirmado en Sequence contra Gates |
| `count` | número de elementos |
| `[i]` | acceso por índice |

### `ObjList.Siege`

Firma confirmada:

```cpp
objList.Siege(target, nCatapults, param3);
```

Ejemplo real de Sequence:

```cpp
catapultaromana
    .GetObjList()
    .Siege(puertaeste.obj, 1, 4);
```

El tercer parámetro se ha observado como `4` en Sequences y `0` en motor; su significado exacto
permanece desconocido.

## 16.5 Comandos documentados de `SetCommand`

| Comando | Argumento | Estado |
|---|---|---|
| `"advance"` | `Point` | movimiento hacia punto; no asume ataque automático a Building |
| `"move"` | `Point` | movimiento |
| `"attack"` | `Obj` / `Building` | ataque explícito |
| `"capture"` | `Building` | activa captura; Townhall puede transferirse al atacante |
| `"enter"` | `Building` | entrada genérica |
| `"enter_tent"` | holder/outpost | entrada específica |
| `"build_catapult"` | objeto `Catapult` | construcción de catapulta-edificio |
| `"approach"` | objeto | declarado en `defaultcmd` de varias clases |
| `"attack_independent"` | `Building` | variante ligada a captura independiente, no ataque físico genérico |
| `"stand_position"` | sin argumento | detiene/fija temporalmente la unidad; confirmado en la cinemática de `ZombieIntro_Main` |

## 16.6 Funciones adicionales confirmadas en Sequences

| Nombre | Uso |
|---|---|
| `WaitQueryCountBetween(query,min,max,timeout)` | espera por recuento |
| `SpawnGroup(name)` | activa Group predefinido |
| `SpawnGroupInHolder(name,holder)` | activa/asocia Group a holder |
| `MoveToArea(obj,area)` | movimiento a área |
| `GiveNote(id)` | nota/objetivo en sistemas compatibles |
| `RemoveNote(id)` | elimina nota |
| `RunAIHelper("GuardCentralArea","guard area",group,area)` | defensa territorial confirmada |

### Estado de `RunAIHelper`

La investigación posterior recuperó el cuerpo de varios AI Helpers y, además, **sus llamadas reales en
campañas oficiales**. Por tanto, ya no debe tratarse a `siege`/`siege gate` como firmas desconocidas.

Llamadas confirmadas:

```cpp
RunAIHelper(
    "GuardCentralArea",
    "guard area",
    "NombreGrupo",
    "NombreArea"
);
```

```cpp
RunAIHelper(
    "InstanciaUnica",
    "siege gate",
    "NombreGrupo",
    "NombreGate"
);
```

```cpp
RunAIHelper(
    "InstanciaUnica",
    "siege",
    "NombreGrupo",
    settlement.name
);
```

Semántica confirmada:

| Modo | Cuarto argumento | Qué hace |
|---|---|---|
| `"guard area"` | nombre de área | defensa territorial |
| `"siege gate"` | nombre de una `Gate` concreta | reúne el grupo, asedia esa Gate, repone el arma de asedio y, tras `IsBroken`, avanza hacia el edificio central |
| `"siege"` | **nombre del `Settlement`** | obtiene el Settlement con `GetSettlement(Target)`, elige `BestGate` internamente si es Stronghold y ejecuta el ciclo de asedio/captura |

El cuarto argumento de `"siege"` es `str`. Las campañas oficiales pasan tanto literales (`"S_Memfis"`)
como nombres calculados en runtime (`set.name`, `Sett.name`, `TargSett.name`). **No hay precedente de
pasar directamente un `Building` o un `Settlement` como objeto**.

Las campañas encadenan varias llamadas `RunAIHelper(...)` consecutivas aunque los helpers contienen
bucles propios de larga duración. Eso es **INDICIO FUERTE** de que `RunAIHelper` lanza una ejecución
concurrente y devuelve el control a la Sequence llamadora.

## 16.7 Tipos y constructores: `point`, `Point` e `IntArray`

Se mantiene la distinción:

```cpp
point p;
p = Point(1000, 1000);
```

`point` es el tipo y `Point(x,y)` el constructor.

La compilación v2.0 confirma además `IntArray` dentro de Sequences:

```cpp
IntArray nodeX;
IntArray nodeY;
IntArray phase;

nodeX[1] = 1025;
nodeY[1] = 1194;
phase[H] = 0;
```

También se utiliza como estructura dispersa para pesos de aristas:

```cpp
IntArray edgeW;
edgeW[22] = 6541;
edgeW[41] = 6541;
```

Por tanto `IntArray` deja de ser engine-only y pasa a API/tipo confirmado en Sequence.

## 16.8 Nombres engine-only relevantes

Los inventarios separan funciones que aparecen en motor pero no en las 48 Sequences inspeccionadas:

```text
BestGate
NumGates
InvadeThroughGate
IsArmyOutside
RamBestTarget
GetCatapultAttackPoint
Goto
GotoAttack
GotoEnter
GetEnterPoint
GetExitPoint
GetParty
GetSquad
GetSquads
Squadize
MilEval
GetGAIKA
RunStrat
RunTacticScript
```

No deben copiarse a una Sequence sólo porque existan en el motor.


# 17. Referencia de clases y unidades

Los IDs de esta sección son nombres técnicos utilizados por el juego y por las Sequences.

Su utilidad principal es:

- consultas por clase;
- comprobaciones con `IsHeirOf`;
- generación mediante `Place()`;
- identificación de rosters culturales;
- distinguir correctamente unidades móviles de edificios de asedio.

## 17.1 Outposts

| ID | Referencia |
|---|---|
| `TOutpost` | Outpost germano |
| `GOutpost` | Outpost galo |
| `BOutpost` | Outpost britano |
| `IOutpost` | Outpost íbero |
| `COutpost` | Outpost cartaginés |
| `ROutpost` | Outpost romano |
| `EOutpost` | Outpost egipcio |
| `GGuardPost` | Guard Post, `Outpost` con behavior propio y `max_units=0` |

## 17.2 Categorías genéricas

| ID | Referencia |
|---|---|
| `Unit` | unidad genérica |
| `Military` | unidad militar |
| `BaseMage` | clase base mágica |
| `Sentry` | sentinela |
| `Building` | edificio |
| `Gate` | puerta; hereda `BaseBuilding → Building` |
| `Catapult` | **edificio** de asedio (`CVXCatapult`), no `Unit` |
| `RamUnit` | **unidad militar móvil** de asedio |

La distinción:

```text
Catapult
≠
RamUnit
```

es crítica para evitar usar `Place()`/`SetCommand()` como si ambos fueran el mismo tipo de objeto.

## 17.3 Roma

| ID | Unidad |
|---|---|
| `RHastatus` | Hastatus |
| `RArcher` | Archer |
| `RVelit` | Velit |
| `RGladiator` | Gladiator |
| `RPraetorian` | Praetorian |
| `RTribune` | Tribune |
| `RScout` | Scout |
| `RLiberatus` | Liberati |
| `MHero1` | héroe romano imperial |
| `RHero1` | héroe romano republicano |

## 17.4 Germania

| ID | Unidad |
|---|---|
| `TMaceman` | Maceman |
| `THuntress` | Huntress |
| `TArcher` | Archer |
| `TTeutonRider` | Teuton Rider |
| `TValkyrie` | Valkyrie |
| `THero1` | héroe germano |

## 17.5 Galia

| ID | Unidad |
|---|---|
| `GWomanWarrior` | Woman Warrior |
| `GAxeman` | Axeman |
| `GArcher` | Archer |
| `GHorseman` | Horseman |
| `GTridentWarrior` | Trident Warrior / Fand |
| `GHero1` | héroe galo |

## 17.6 Britania

| ID | Unidad |
|---|---|
| `BBronzeSpearman` | Bronze Spearman |
| `BHighlander` | Highlander |
| `BBowman` | Bowman |
| `BJavelineer` | Javelineer |
| `BHero1` | héroe britano |

En la investigación de roster no se encontró una clase de caballería britana jugable.

## 17.7 Iberia

| ID | Unidad |
|---|---|
| `IDefender` | Defender |
| `IEliteGuard` | Elite Guard |
| `ISlinger` | Slinger |
| `IMilitiaman` | Militiaman |
| `ICavalry` | Cavalry |
| `IHero1` | héroe íbero |

## 17.8 Cartago

| ID | Unidad |
|---|---|
| `CLibyanFootman` | Libyan Footman |
| `CJavelinThrower` | Numidian Javelin Thrower |
| `CBerberAssassin` | Berber Assassin |
| `CNoble` | Noble |
| `CNumidianRider` | Numidian Rider |
| `CMacemen` | guerrero con maza listado en documentación de Outpost |
| `CHero1` | héroe cartaginés |

## 17.9 Egipto

| ID | Unidad |
|---|---|
| `EGuardian` | Guardian |
| `EArcher` | Archer |
| `EAxetrower` | Axe Thrower |
| `EAnubisWarrior` | Anubis Warrior |
| `EHorusWarrior` | Horus Warrior |
| `EChariot` | Chariot |
| `EHero1` | héroe egipcio |

`EChariot` funciona como equivalente móvil/caballería para diseño, aunque su clase base no sea `Horse`.

## 17.10 Sentinelas de Guard Post

El script nativo construye el ID con:

```text
<PrefijoRaza>GuardPostSentry
```

Ejemplo:

```text
GGuardPostSentry
```

Estos sentinelas pertenecen al sistema específico `GGuardPost_Sentries.vs`.

## 17.11 Catapultas como edificios

Familia confirmada:

| ID | Tipo |
|---|---|
| `BCatapult` | Building, Britania |
| `CCatapult` | Building, Cartago |
| `ECatapult` | Building, Egipto |
| `GCatapult` | Building, Galia |
| `ICatapult` | Building, Iberia |
| `RCatapult` | Building, Roma |
| `TCatapult` | Building, Germania |

La clase base:

```xml
<class id="Catapult" cpp_class="CVXCatapult" parent="Building">
```

tiene, entre otras propiedades:

```text
range = 800
min_range = 301
maxhealth = 1000
max_units = 10
can_be_captured = 0
```

Necesita tripulación/construcción; no debe tratarse como una `Unit`.

## 17.12 Arietes móviles: `RamUnit`

Clase base:

```xml
<class id="RamUnit" cpp_class="CVXUnit" parent="Military">
```

Propiedades recuperadas:

```text
range = 80
min_range = 0
speed = 40
damage = 300
damage_type = siege
maxhealth = 1000
feeds = 0
does_not_regenerate = 1
```

Sólo se encontraron dos variantes `Unit` reales:

```text
BCatapultUnit
TCatapultUnit
```

No existen en el corpus inspeccionado:

```text
RCatapultUnit
GCatapultUnit
ICatapultUnit
CCatapultUnit
ECatapultUnit
```

Si se necesita una máquina de asedio generable como unidad móvil mediante `Place()`, las variantes
confirmadas son `BCatapultUnit` y `TCatapultUnit`.


# 18. Metodología de ingeniería inversa

El conocimiento de este manual no procede únicamente de prueba y error.

La investigación combina varias fuentes para reducir falsos supuestos.

## 18.1 Inspección de `Packs\data.pak`

Se buscan definiciones como:

```xml
<class id="...">
<properties ...>
<behavior script="...">
<method ...>
```

Esto permite recuperar:

- herencia;
- `cpp_class`;
- `entity`;
- propiedades;
- scripts de comportamiento;
- IDs técnicos;
- relaciones entre clases y sistemas internos.

## 18.2 Inspección de escenarios `.BFHP`

Los mapas se utilizan como corpus de ejemplos reales.

Se buscan cadenas como:

```text
Place(
SetCommand(
ClassPlayerObjs(
AllowCapture(
AddMaxSentries(
EnvReadInt(
EnvWriteInt(
```

Encontrar una llamada dentro de una Sequence real aumenta mucho la confianza respecto a encontrar únicamente su nombre en los datos del juego.

## 18.3 Comparación entre escenarios

La investigación ha cruzado:

- escenarios;
- aventuras;
- conquistas;
- mapas comunitarios disponibles;
- el escenario en desarrollo.

Un patrón repetido en distintos BFHP es evidencia más fuerte que una única aparición aislada.

## 18.4 Pruebas mínimas en editor

Las funciones críticas se verifican mediante Sequences pequeñas diseñadas para responder una sola pregunta.

Ejemplos investigados de este modo:

```cpp
Place(...)
SetFeeding(false)
SetPlayer(...)
SetNoAIFlag(true)
ForceAddUnit(...)
SetCommand(...)
```

El objetivo es aislar:

```text
¿compila?
¿se ejecuta?
¿produce el efecto?
¿la IA altera el resultado?
```

## 18.5 Scripts nativos

Los scripts internos permiten reconstruir comportamientos que no están documentados públicamente.

Ejemplo central:

```text
GGuardPost_Sentries.vs
```

Su análisis permitió identificar:

- doce sentinelas;
- posiciones propias;
- regeneración;
- nivel progresivo;
- sustitución al cambiar de propietario.

## 18.6 Jerarquía de evidencia

Las evidencias no tienen el mismo peso.

Prioridad utilizada:

```text
prueba directa en partida/editor
        ↓
Sequence real de escenario
        ↓
script nativo
        ↓
definición de clase / inventario
        ↓
inferencia
```

Por eso una función encontrada en el motor no se presenta automáticamente como confirmada desde Sequence.

## 18.7 Identificación de nombres técnicos de unidades

Para determinar strings válidos se cruzan:

- `class id`;
- `display_name`;
- `entity`;
- `class="..."` en BFHP;
- tablas de IA;
- llamadas literales a `Place()`.

Esto evita utilizar nombres traducidos o visibles que no correspondan al identificador interno.

## 18.8 Metodología para un descubrimiento nuevo

Proceso recomendado:

1. formular una pregunta concreta;
2. buscar el nombre o comportamiento en `data.pak`;
3. buscar ejemplos en BFHP;
4. comprobar el tipo y la firma;
5. escribir una Sequence mínima;
6. compilar;
7. ejecutar en partida;
8. documentar resultado y contexto;
9. sólo después incorporarlo a código de producción.

## 18.9 Registrar resultados negativos

Un fallo también aporta información.

Debe registrarse cuando:

- una firma no compila;
- una propiedad no es accesible desde Sequence;
- una clase existe pero no aparece en escenarios;
- un comando produce comportamiento distinto al esperado.

Ejemplo histórico ya superado:

```text
EnvReadInt(obj, "KEY"+index)
```

se documentó inicialmente como fallo de compilación. La compilación estable v2.0 utiliza con éxito lecturas dinámicas equivalentes, por lo que el resultado negativo debe conservarse sólo como antecedente de una versión/contexto anterior.

Los resultados negativos evitan repetir investigaciones ya cerradas.



## 18.10 Corpus utilizado en la fase profunda

Una fase posterior amplió la búsqueda a **48 archivos `.BFHP`** entre:

```text
Scenarios
Adventures
Conquests
ConquestMaps
```

Esto permitió pasar de conclusiones basadas en un único mapa a patrones respaldados por campañas
oficiales y escenarios distintos.

## 18.11 Inventario automático de API

Se generaron dos corpus heurísticos de identificadores seguidos de `(`:

```text
engine
→ Packs\data.pak
→ Packs\Buildings.pak
→ Packs\Units.pak

sequence
→ 48 archivos BFHP
```

Resultados de aquella pasada:

```text
API motor:      2137 identificadores únicos
API Sequence:    920 identificadores únicos
Comunes:         223
Sólo Sequence:   697
Sólo motor:     1914
```

Estos números **no equivalen a una especificación formal**: el extractor puede contar falsos
positivos presentes en comentarios o texto embebido.

Su utilidad es de descubrimiento:

```text
inventario automático
→ candidato
→ búsqueda literal
→ cita real
→ prueba
```

Nunca debe promoverse una función a “confirmada” únicamente porque aparezca en ese inventario.



# 19. Escenarios oficiales como referencia de scripting

La ingeniería inversa de Imperivm III resulta mucho más fiable cuando los escenarios oficiales se
tratan como **ejemplos de producción**.

No sólo contienen objetos y datos del mapa: muchos `.BFHP` incorporan Sequences completas escritas
por los desarrolladores.

## 19.1 Corrección de una conclusión temprana sobre `Place()`

Una investigación inicial examinó `Infierno_en_Iberia.BFHP` y encontró:

```text
Place( = 0 apariciones
```

La interpretación prudente en aquel momento fue:

> “No hay evidencia de que `Place()` funcione desde Sequence”.

La ampliación a 48 escenarios encontró, entre otros:

| Archivo | `Place(` | `ForceAddUnit(` | `SetNoAIFlag(` | `SetFeeding(` |
|---|---:|---:|---:|---:|
| `Great_loses_Spain.BFHP` | 27 | 27 | 0 | 18 |
| `Great_loses_Boudicca.BFHP` | 28 | 27 | 18 | 6 |
| `mediterranean.BFHP` | 5 | 5 | 0 | 1 |

La conclusión anterior queda **superada**:

```text
Place() desde Sequence = CONFIRMADO
```

y no sólo por una prueba de laboratorio, sino por uso oficial repetido.

## 19.2 Evidencia de runtime común

`Great_loses_Spain` contiene código casi idéntico al comportamiento nativo de `TTent`.

La copia conserva incluso comentarios del código original.

Eso proporciona una evidencia excepcional de que:

```text
código .vs de comportamiento nativo
```

y:

```text
código .vs de Sequence
```

comparten el lenguaje operativo suficiente para trasladar algoritmos de un contexto al otro.

## 19.3 APIs comunes y APIs específicas de Sequence

El inventario heurístico mostró tres grupos.

### Comunes

Ejemplos verificados manualmente:

```text
Place
SetPlayer
SetFeeding
ForceAddUnit
SetNoAIFlag
ObjsInRange
EnemyObjs
Intersect
Union
Subtract
rand
Sleep
GetTime
Group
AddToGroup
GetSettlement
```

### Observadas sólo en Sequences del corpus

```text
RunAIHelper
SpawnGroup
SpawnGroupInHolder
ClassPlayerAreaObjs
RunSequence
RunConv
GiveNote
RemoveNote
MoveToArea
ExploreAll
SetFog
_PlaceEx
```

### Dominantes del motor / IA estratégica

El corpus interno contiene una gran cantidad de vocabulario de IA global que no aparece en las
Sequences analizadas:

```text
GetGAIKAStrat
AIVar
SetAIVar
DiplGetCeaseFire
...
```

La ausencia en el corpus de Sequences no demuestra por sí sola que una función sea inaccesible, pero
sí permite priorizar la investigación.

## 19.4 Prueba directa sigue teniendo prioridad

Incluso con escenarios oficiales disponibles, el orden de confianza del manual se mantiene:

```text
prueba en runtime
→ Sequence oficial
→ script nativo
→ definición de clase
→ inventario automático
→ inferencia
```

---

# 20. Arquitectura real de fortalezas y guarniciones regenerables

Este capítulo consolida los hallazgos de las distintas fases sobre `TTent`, Outposts personalizados,
regeneración y defensa.

## 20.1 La pieza central: comportamiento nativo de `TTent`

`TTent` implementa un sistema de fortaleza con dos pools configurables.

Su máquina de estados puede resumirse así:

```text
INIT
│
├─ obtener clases de defensor
├─ máximos por clase
├─ nº de defensores activos fuera
├─ comida de recompensa
├─ nivel inicial/final
└─ loyalty = 100
       ↓
SPAWN INICIAL
│
├─ Place()
├─ SetFeeding(false)
├─ ForceAddUnit()
└─ SetLevel()
       ↓
BUCLE
│
├─ ClearDead()
├─ progresión de nivel
├─ detectar enemigos
├─ sacar defensores del pool
├─ devolver defensores si no hay amenaza
├─ limitar alejamiento
└─ comprobar aniquilación total
       ↓
CAPTURA
│
├─ elegir atacante
├─ SetPlayer()
├─ restaurar comida
├─ bonus cultural opcional
└─ return
```

El detalle crítico es el último:

```cpp
return;
```

Tras la primera captura, ese hilo de comportamiento termina.

No queda evidencia de un listener separado que vuelva a arrancarlo al añadir unidades posteriormente.

## 20.2 El mismo patrón fue reimplementado como Sequence oficial

Campañas oficiales aplican una versión prácticamente literal de este comportamiento a Outposts
normales.

Eso demuestra que:

```text
Outpost normal
+
Sequence
=
fortaleza personalizada completa
```

sin necesidad de crear una nueva clase.

## 20.3 Dieciocho configuraciones reales de Outpost

La investigación identificó 18 instancias oficiales configuradas manualmente.

| Objeto | Cultura | Defensor 1 | Máx. | Fuera | Nivel | Defensor 2 | Máx. | Fuera | Nivel |
|---|---|---|---:|---:|---|---|---:|---:|---|
| `ROutpost1` | Roma | `RScout` | 12 | 4 | 4→24 | `RArcher` | 33 | 11 | 4→24 |
| `ROutpost2` | Roma | `RChariot` | 9 | 3 | 8→24 | `RGladiator` | 24 | 8 | 8→24 |
| `ROutpost3` | Roma | `RLiberatus` | 15 | 5 | 8→24 | `RTribune` | 24 | 8 | 8→24 |
| `ROutpost4` | Roma | `RHastatus` | 15 | 5 | 8→24 | `RPrinciple` | 24 | 8 | 8→24 |
| `ROutpost5` | Roma | `RVelit` | 21 | 7 | 8→24 | `RPraetorian` | 12 | 4 | 8→24 |
| `ROutpost6` | Roma | `RHastatus` | 30 | 10 | 10→24 | `RPraetorian` | 12 | 4 | 10→24 |
| `ROutpost7` | Roma | `RArcher` | 30 | 10 | 6→24 | `RTribune` | 20 | 5 | 6→24 |
| `ROutpost8` | Roma | `RGladiator` | 20 | 10 | 6→24 | `RLiberatus` | 20 | 10 | 6→24 |
| `ROutpost9` | Roma | `RPraetorian` | 20 | 10 | 6→24 | `RVelit` | 20 | 10 | 6→24 |
| `RomanOut1` | Roma | `RScout` | 24 | 6 | 4→24 | `RArcher` | 44 | 11 | 4→24 |
| `RomanOut2` | Roma | `RHastatus` | 24 | 6 | 4→24 | `RLiberatus` | 24 | 6 | 4→24 |
| `RomanOut3` | Roma | `RPraetorian` | 18 | 6 | 4→12 | `RPrinciple` | 21 | 7 | 4→12 |
| `RomanOut4` | Roma | `RVelit` | 30 | 10 | 4→10 | `RGladiator` | 40 | 10 | 4→10 |
| `RomanOut5` | Roma | `RPrinciple` | 28 | 14 | 4→13 | `RScout` | 16 | 4 | 4→13 |
| `RomanOut6` | Roma | `RGladiator` | 30 | 6 | 4→15 | `RVelit` | 25 | 5 | 4→15 |
| `BritonOutPost1` | Britania | `BVikingLord` | 9 | 3 | 8→12 | `BBowman` | 20 | 10 | 8→12 |
| `BritonOutPost2` | Britania | `BHighlander` | 16 | 4 | 8→12 | `BBronzeSpearman` | 20 | 10 | 8→12 |
| `BritonOutPost3` | Britania | `BJavelineer` | 30 | 10 | 8→12 | `BShieldBearer` | 30 | 10 | 8→12 |

La lección de diseño es clara: **una misma plantilla puede gestionar fortalezas con rosters,
cantidades y niveles completamente distintos**.

## 20.4 `Settlement` como almacén real de guarnición

`ForceAddUnit()` no es sólo una asociación nominal.

La arquitectura oficial utiliza:

```cpp
.settlement.ForceAddUnit(u);
```

y después recupera ese mismo pool con:

```cpp
.settlement.Units()
```

y:

```cpp
.settlement.UnitsCount()
```

El bucle decide qué unidades:

```text
permanecen dentro
```

y cuáles:

```text
salen a patrullar/defender
```

El Settlement es, por tanto, un almacén real sobre el que opera la lógica de defensa.

## 20.5 Salida y retorno de defensores

El comportamiento utiliza órdenes directas para mover defensores entre ambos estados.

Conceptualmente:

```text
Settlement.Units()
→ elegir unidad
→ orden ofensiva / guardia
→ unidad queda fuera

sin amenaza
→ "enter_tent"
→ vuelve al pool
```

El comentario recuperado en el código indica además que `"enter_tent"` puede forzar la entrada aunque
el edificio no permita normalmente unidades en su interior.

## 20.6 La guarnición nativa no regenera bajas del pool

El comportamiento tipo `TTent` administra un **pool inicial finito**.

Si muere una unidad:

```text
máximo original
↓
pool vivo disminuye
```

pero el script no llama a `Place()` para reemplazar automáticamente esa baja.

Por ello deben distinguirse dos conceptos:

```text
gestionar cuántos defensores están fuera
≠
regenerar defensores muertos
```

La regeneración real de bajas necesita añadir el patrón encontrado en `mediterranean`.

## 20.7 Patrón real de regeneración temporal

El patrón oficial encontrado es:

```cpp
if (time >= ReviveT)
{
    if (Archers.count < ArchCount)
    {
        revive = ArchCount - Archers.count;

        for (i = 1; i <= revive; i += 1)
        {
            u = Place(...).AsUnit();
            settlement.ForceAddUnit(u);
            u.AddToGroup("BonuseU");
        }

        time = 0;
    }
}

Sleep(6000);
time += 6000;
```

En su uso original repone todas las bajas al cumplirse el temporizador.

Un sistema de “una unidad cada N segundos” es una adaptación directa y sencilla, aunque no se observó
esa variante exacta en producción.

## 20.8 Detección de amenaza recomendada

La técnica más respaldada es la usada por `TTent` y por sus clones de Sequence:

```cpp
qEnemies =
    Intersect(
        ObjsInRange(
            this,
            "Unit",
            .range
        ),
        EnemyObjs(
            .player,
            "Military"
        )
    );
```

Puede ampliarse con `BaseMage`, excluir `Sentry` y añadir `Catapult`.

Es preferible a inventar un sistema nuevo porque existen numerosas instancias oficiales que ya usan
esa arquitectura.

## 20.9 Reconquista y finalización del comportamiento

El `return` de `TTent` significa que no hay regeneración automática después de la primera captura.

No se encontraron funciones reales con nombres del estilo:

```text
RestartBehavior
RunBehavior
ResetScript
SetScript
Reinit
```

para volver a arrancar el comportamiento de clase.

La herramienta real observada es:

```cpp
RunSequence("Nombre");
```

Esto conduce al patrón más seguro:

```text
Sequence persistente propia
→ detecta propietario
→ rearma guarnición
→ sigue viva
```

en vez de intentar reiniciar el comportamiento interno del objeto.

## 20.10 `SpawnGroupInHolder` como alternativa finita

Un escenario oficial utiliza:

```cpp
SpawnGroupInHolder(
    "Q_RoyalGuard",
    "S_UnbreakableRomanTown"
);

while (1)
{
    Sleep(5000);

    if (Q_RoyalGuard.count < 30)
    {
        SpawnGroupInHolder(
            "Q_RoyalGuard",
            "S_UnbreakableRomanTown"
        );
    }

    GetSettlement(
        "S_UnbreakableRomanTown"
    ).SetLoyalty(100);
}
```

Esto confirma que **sí puede reinvocarse sobre el mismo Group**.

Sin embargo, el Group está formado por unidades precolocadas en `map.obj.xml`.

Por tanto esta solución depende de un pool finito diseñado en el mapa y no es equivalente a una
regeneración ilimitada con `Place()`.

## 20.11 Comparación de arquitecturas

| Arquitectura | Regeneración ilimitada | Requiere precolocar unidades | Evidencia |
|---|---:|---:|---|
| Sequence + `Place()` | Sí, sin límite estructural conocido | No | Muy alta |
| `SpawnGroupInHolder` reutilizable | Limitada por plantilla | Sí | Alta |
| Varios Groups de reserva | Limitada por nº de Groups | Sí | Alta |
| Clase nueva tipo `TTent` | Desconocida | No necesariamente | Muy baja |
| Rearmar comportamiento nativo tras `return` | No resuelto | No | Baja |

La ruta mejor respaldada para un sistema completamente dinámico es:

```text
Sequence propia
+
Place()
+
Settlement
+
SetNoAIFlag
+
Query de enemigos
+
timer de regeneración
```

## 20.12 Tiempos reales de entrenamiento recuperados

Los comandos de entrenamiento definen:

```xml
execdelay="..."
```

en milisegundos.

Ejemplos documentados:

| Unidad / comando | Tiempo base |
|---|---:|
| Briton Swordsman | 8000 ms |
| `BBowman` | 4000 ms |
| `RHastatus` | 6000 ms |
| Macedonian/Imperial Hastatus equivalente citado | 6000 ms |
| Gaul Swordsman | 6000 ms |
| Carthaginian Maceman citado | 16000 ms |
| `ISlinger` | 16000 ms |
| `TTeutonRider` | 20000 ms |
| `Call Valkyries` | 20000 ms por invocación especial |

`TValkyrie` no utiliza un entrenamiento ordinario `train`; aparece bajo un comando especial:

```text
Call Valkyries
method="trainex"
```

desde `TSanctuaryOfVotan`.

No se encontró un mecanismo que permita consultar automáticamente el `execdelay` desde una Sequence.
Si se quiere usar ese tiempo para regeneración, debe tratarse como un dato de diseño conocido.

---

# 21. Townhall, “Foro” y asentamientos neutrales

## 21.1 No existe una clase técnica llamada `Forum`

La búsqueda exhaustiva no encontró una clase `Forum`.

La equivalencia se confirmó mediante tablas de traducción de escenarios:

```text
Townhall
→ Foro
```

Por tanto “Foro” es un nombre de interfaz/localización para la familia técnica de Townhall.

## 21.2 Clase base `BaseTownhall`

La definición recuperada incluye:

```xml
<class
    id="BaseTownhall"
    cpp_class="CVXTownHall"
    parent="BaseTownBuilding">
```

Propiedades relevantes:

```text
is_central_building = 1
can_be_captured     = 1
can_be_attacked     = 1
produces_gold       = 1
max_units           = 10000
population          = 40
max_population      = 100
radius              = 160
selection_radius    = 165
```

También dispone de comportamientos de:

- guardia;
- ambiente;
- caballos;
- autoentrenamiento;
- sentinelas;
- curación;
- refresco;
- entrenamiento militar.

## 21.3 Subclases culturales de Townhall

| ID | Civilización |
|---|---|
| `BTownhall` | Britania |
| `CTownhall` | Cartago |
| `ETownhall` | Egipto |
| `GTownhall` | Galia |
| `ITownhall` | Iberia |
| `MTownhall` | Roma Imperial |
| `RTownhall` | Roma Republicana |
| `TTownhall` | Germania |

Todas heredan de:

```text
BaseTownhall
```

y comparten `cpp_class="CVXTownHall"`.

## 21.4 `MutableStronghold`

Existe una variante:

```text
MutableStronghold
parent = BaseTownhall
race   = Mutable
```

Por herencia forma parte de la familia Townhall.

En los mapas inspeccionados no se encontró como pieza neutral habitual, pero una consulta sobre
`BaseTownhall` debe incluirla si existe con esa jerarquía.

## 21.5 `MutableVillage` es otra familia

`MutableVillage` comparte `cpp_class="CVXTownHall"`, pero hereda de:

```text
BaseVillage
```

no de:

```text
BaseTownhall
```

Por tanto:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    player
)
```

**no debe suponerse que incluya `MutableVillage`**.

Si una mecánica quiere tratar Village como Foro, necesita una consulta separada.

## 21.6 Descubrimiento por clase base y herencia

Una Sequence oficial usa:

```cpp
ClassPlayerObjs(
    cBaseTownhall,
    6
).SetPlayer(2);
```

Esto confirma que `ClassPlayerObjs` acepta una clase base y devuelve objetos pertenecientes a
subclases de esa jerarquía.

El orden real de argumentos es:

```cpp
ClassPlayerObjs(
    clase,
    jugador
);
```

Esta evidencia corrige pruebas antiguas donde se había considerado el orden contrario.

## 21.7 Neutralidad: Players 15 y 16

Los mapas investigados utilizan tanto Player 15 como Player 16 para asentamientos independientes.

No debe asumirse que exista un único ID neutral obligatorio.

La API ofrece una opción más semántica:

```cpp
settlement.IsIndependent()
```

que permite preguntar por el estado independiente sin depender exclusivamente del número.

Para descubrir específicamente objetos colocados con jugadores neutrales conocidos puede seguir
usándose:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    15
);
```

y:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    16
);
```

## 21.8 El mismo objeto cambia de propietario

Un Townhall neutral y un Townhall controlado no son clases distintas.

La captura cambia principalmente:

```text
.player
```

sin sustituir necesariamente el objeto por otra clase.

Por ello puede conservarse la referencia inicial a un Foro neutral y observar posteriormente:

```cpp
forum.player
```

aunque haya cambiado de dueño.

## 21.9 Detectar captura mediante polling

Una campaña oficial utiliza directamente:

```cpp
while (
    forogalaico.obj.player != 3
);
```

Otro patrón espera primero a la loyalty y después al propietario.

Esto confirma que una Sequence no necesita un evento especial de captura:

```text
guardar referencia
→ comprobar .player periódicamente
→ detectar cambio
```

es un patrón real.

## 21.10 `Settlement` de un Townhall

Uso real:

```cpp
forogalaico
    .obj
    .AsBuilding()
    .settlement
    .SetGold(
        forogalaico
        .obj
        .AsBuilding()
        .settlement
        .gold
        + 20
    );
```

Esto confirma acceso desde Sequence a:

```text
Building
→ settlement
→ gold
→ SetGold()
```

en un Townhall.

## 21.11 Estado “primera conquista”

Una mecánica de recompensa única puede registrar en el arranque qué Townhall eran neutrales.

Modelo:

```text
inicio
→ descubrir Townhall independientes
→ guardar referencias
→ marcar WasNeutral
→ bucle
→ si player pasa a 1..8 y Rewarded=0
→ recompensa
→ Rewarded=1
```

La parte importante es marcar la neutralidad **al principio**, no deducirla después, porque un Foro
capturado ya no es independiente.

## 21.12 `EnvReadInt` / `EnvWriteInt` asociados a objetos

Se encontraron usos de:

```cpp
EnvWriteInt(
    GetSettlement("Numantia"),
    "no_villagers",
    1
);
```

y, en scripts nativos, de:

```cpp
EnvReadInt(
    this,
    "sentriesLevel"
);
```

Esto demuestra que el sistema `Env*` puede asociar estado a objetos del motor, no sólo a variables
globales.

La combinación exacta `Building + EnvReadInt` dentro de Sequence fue inicialmente inferida cruzando
ambas evidencias y después se utilizó extensamente en las Sequences del proyecto.

## 21.13 Posiciones, `radius` y `range`

No deben confundirse:

```text
radius / selection_radius
→ tamaño físico / selección de clase

range
→ alcance funcional usado por comportamientos
```

Un `GGuardPost`, por ejemplo, puede tener un `range` muy superior a su tamaño físico.

Para Townhall se recuperaron:

```text
radius = 160
selection_radius = 165
```

No se encontró una API de Sequence confirmada para consultar dinámicamente ese `radius`.

## 21.14 Aparición de ejércitos alrededor de un Townhall

Si se generan muchas unidades como recompensa, una estrategia segura es crear puntos opuestos al
edificio y distribuir las unidades mediante offsets.

Ejemplo conceptual:

```cpp
baseA =
    Point(
        forum.pos.x + 450,
        forum.pos.y
    );

baseB =
    Point(
        forum.pos.x - 450,
        forum.pos.y
    );
```

La distancia exacta es una decisión de diseño. El valor `450` surgió como margen práctico frente al
radio conocido del Townhall, no como constante del motor.

## 21.15 Caso de estudio del mapa investigado

En la versión del mapa analizada durante esta investigación se encontraron:

```text
25 Townhall neutrales
+
3 MutableVillage neutrales
```

repartidos entre Players 15 y 16.

Este dato es **específico de aquella versión del escenario**, no una propiedad general del motor.

---

# 22. Helpers exclusivos de Sequences, Groups y activación diferida

## 22.1 Dos tipos de Group observados en `map.obj.xml`

En el escenario profundamente analizado aparecieron:

| `type` | Uso observado |
|---|---|
| `0` | alias/referencia a un único objeto: edificio, marcador o punto |
| `1` | colección de varias unidades |

No se observaron otros valores en ese archivo concreto.

Ejemplo conceptual:

```text
type=0
→ holder / edificio / marcador

type=1
→ grupo de tropas
```

## 22.2 `.obj` en Groups de un solo objeto

Un Group `type=0` permite patrones como:

```cpp
foro.obj.player
```

o:

```cpp
SpawnGroupInHolder(
    "refuerzos",
    foro.obj
);
```

También se observaron métodos aplicados directamente al Group:

```cpp
foro.SetPlayer(3);
```

cuando el Group actúa como referencia de ese objeto.

## 22.3 `SpawnGroup(name)`

Activa un Group predefinido:

```cpp
SpawnGroup(
    "emboscada"
);
```

Las unidades no se crean de la nada: el Group existe en los datos del mapa.

## 22.4 `SpawnGroupInHolder(name, holder)`

Patrón:

```cpp
SpawnGroupInHolder(
    "jinetes11",
    oro1.obj
);
```

La investigación verificó que los Groups usados como primer argumento contenían IDs de unidades
precolocadas.

Por ello el término “spawn” no debe interpretarse automáticamente como:

```text
clonar unidades ilimitadamente
```

Su mecanismo interno exacto —mover, activar, teletransportar, revivir o una combinación— no se
recuperó.

## 22.5 Reutilización del mismo Group

El patrón `Q_RoyalGuard` demuestra que un mismo nombre puede volver a pasarse a
`SpawnGroupInHolder()` cuando su `.count` baja.

Esto resuelve una duda antigua.

Sin embargo, sigue sin conocerse qué ocurre cuando todos los miembros predefinidos del pool han sido
consumidos definitivamente.

## 22.6 `WaitQueryCountBetween`

Uso:

```cpp
WaitQueryCountBetween(
    jinetes1,
    0,
    0,
    -1
);
```

En este contexto espera hasta que el grupo tenga exactamente cero unidades vivas.

El último argumento `-1` se usa como espera sin timeout en los ejemplos estudiados.

También aparece combinado con:

```cpp
ClassPlayerAreaObjs(...)
```

para esperar a que exista una cantidad determinada de tropas en una región.

## 22.7 `ClassPlayerAreaObjs`

Ejemplo:

```cpp
ClassPlayerAreaObjs(
    "Unit",
    6,
    "areaforocartagines"
);
```

Permite sondear unidades de un Player en un área nombrada.

Es útil cuando se conoce de antemano qué jugadores deben comprobarse.

Para detección universal de enemigos alrededor de un edificio, las Queries con `EnemyObjs` son más
genéricas.

## 22.8 `RunSequence`

```cpp
RunSequence(
    "DefensaCartaginesadenuevo"
);
```

Permite lanzar otra Sequence por nombre.

Los escenarios la utilizan para encadenar comportamientos y recrear ciclos del tipo:

```text
esperar condición
→ actuar
→ lanzar Sequence hermana
```

## 22.9 `RunAIHelper`

`RunAIHelper` es una de las APIs de mayor nivel disponibles desde Sequence.

Tres modos cuentan ya con precedentes literales:

```cpp
RunAIHelper("GuardCentralArea", "guard area", "jinetes1", "areajinetes1");
```

```cpp
RunAIHelper("SiphaxSiegeGate1", "siege gate", "Q_MaySiege", "NO_Gate1");
```

```cpp
RunAIHelper("SmallAttack", "siege", "SmallTownArmy", set.name);
```

Para `"siege gate"`, el helper realiza internamente:

```text
resolver Gate por nombre
→ reunir al grupo
→ construir/operar asedio
→ reponerlo si se pierde
→ esperar Gate.IsBroken
→ avanzar hacia el edificio central
→ emitir capture
```

Para `"siege"`:

```text
GetSettlement(Target)
→ si Outpost: asedio/captura del edificio central
→ si Stronghold: BestGate(primera unidad)
→ asedio/reposición
→ esperar IsBroken
→ advance hacia el centro
→ capture
```

Esto convierte a `"siege"` en el puente confirmado entre una Sequence y varias piezas de IA que por
separado son engine-only (`BestGate`, lógica de `GAIKA`, etc.).

**Precaución:** si la facción técnica no debe quedarse con la ciudad, no debe delegarse sin más el final
`capture` del helper, porque el comando nativo transfiere el Settlement al jugador de la unidad atacante.
En ese diseño conviene usar `"siege gate"` sólo para abrir la brecha, o una variante propia que termine
con la lógica de neutralización deseada.

## 22.10 `GetSettlement`

Ejemplo:

```cpp
GetSettlement(
    "S_UnbreakableRomanTown"
).SetLoyalty(100);
```

Permite obtener directamente un `Settlement` a partir de una referencia nombrada del escenario.

## 22.11 `MoveToArea`

Aparece en patrones de campaña:

```cpp
MoveToArea(
    Asdrubal,
    "areaforocartagines"
);
```

Es una herramienta de alto nivel para dirigir objetos hacia áreas nombradas.

---

# 23. Roster técnico, héroes, roles y restricciones culturales

Esta sección amplía el catálogo de clases con información obtenida al cruzar:

- definiciones de `data.pak`;
- `parent`;
- estadísticas;
- `entity`;
- tablas de IA;
- apariciones reales en BFHP.

## 23.1 Jerarquías funcionales importantes

### Distancia larga

```text
parent="Ranged"
```

### Distancia corta / escaramuza

```text
parent="ShortRanged"
```

### Caballería

```text
parent="Horse"
```

### Héroes

Las ocho culturas disponen de una clase base abstracta y de clases concretas numeradas.

La base suele tener:

```text
entity=""
```

y no debe asumirse instanciable directamente.

## 23.2 Héroes genéricos recomendados

| Civilización | Base abstracta | Clase concreta segura | Nombre citado |
|---|---|---|---|
| Roma Imperial | `ImperialRomanHero` | `MHero1` | Rutilanus |
| Roma Republicana | `RepublicanRomanHero` | `RHero1` | Anteros |
| Germania | `GermanHero` | `THero1` | — |
| Galia | `GaulHero` | `GHero1` | — |
| Britania | `BritonHero` | `BHero1` | Gawain |
| Iberia | `IberianHero` | `IHero1` | — |
| Cartago | `CarthaginianHero` | `CHero1` | Mago |
| Egipto | `EgyptianHero` | `EHero1` | Mentuhotep |

Las clases base abstractas dieron cero usos reales en el corpus de escenarios y carecen de `entity`
propia.

## 23.3 Particularidad de Britania

`BritonHero` hereda de:

```text
Hero
```

no de:

```text
HeroMounted
```

y utiliza proyectil de flecha.

La búsqueda completa del roster britano tampoco encontró una clase jugable con:

```text
parent="Horse"
```

Por tanto:

```text
Britania
→ sin caballería nativa confirmada
```

no es una decisión de balance inventada, sino una limitación real del roster analizado.

## 23.4 Particularidad de Egipto

No se encontró caballería `parent="Horse"`.

`EChariot` es:

```text
parent="Ranged"
```

pero cumple funcionalmente el papel de unidad móvil pesada:

```text
HP 600
damage 40
speed 120
```

Por eso puede utilizarse como equivalente de caballería en composiciones de diseño, siempre
documentando que técnicamente no es `Horse`.

## 23.5 Particularidad de Cartago

No se encontraron:

```text
CArcher
CSlinger
CBowman
```

como unidad de largo alcance.

La opción confirmada de proyectil es:

```text
CJavelinThrower
parent="ShortRanged"
```

Por tanto Cartago no posee un arquero/hondero puro equivalente al de otras facciones en el roster
investigado.

## 23.6 Diferenciación real entre las dos Romas

Las tablas de IA revelan una distinción útil:

```text
RVelit
→ habilitado para Roma Imperial

RGladiator
→ habilitado para Roma Republicana
```

mientras otras clases como `RArcher` o `RScout` aparecen disponibles para ambas.

Esto permite diseñar ejércitos romanos distintos utilizando una diferencia que ya existe en los datos
del juego.

## 23.7 Unidades con propiedades especiales que afectan al diseño

### `IMountaineer`

Tiene:

```xml
<properties feeds="0"/>
```

Por tanto no consume comida normalmente.

Si una mecánica exige que las tropas de recompensa participen en la logística ordinaria, esta clase
no es equivalente a una tropa normal.

### Mercenarios cartagineses

Clases como `CMaceman`/variantes mercenarias investigadas y `CBerberAssassin` poseen referencias a
scripts `ondie` de mercenario.

Esto no significa automáticamente que sean inutilizables, pero deben distinguirse de unidades sin
comportamiento adicional.

## 23.8 Clases fantasma / typos detectados

Se encontraron nombres con indicios claros de ser variantes erróneas o no utilizadas:

```text
RLiberatas
TValkyria
BHighlandar
IDefendar
```

Los motivos incluyen:

- typo en `parent`;
- cero apariciones reales;
- existencia de una variante correctamente escrita usada en mapas.

Para scripting de producción deben preferirse:

```text
RLiberatus
TValkyrie
BHighlander
IDefender
```

## 23.9 Unidades reales pero sin precedente de colocación

Algunas clases existen con definición completa pero dieron cero apariciones en el corpus de BFHP.

Ejemplos citados:

```text
IScout
TTeutonWolf
```

La clasificación correcta es:

```text
clase real
pero
uso práctico no respaldado por escenarios inspeccionados
```

No deben confundirse con las clases fantasma.

## 23.10 Tabla de roles recomendados por cultura

| Civilización | Línea | Distancia | Ligera / élite | Movilidad | Héroe |
|---|---|---|---|---|---|
| Roma Imperial | `RHastatus` | `RArcher` | `RVelit` / `RPraetorian` | `RScout` | `MHero1` |
| Roma Republicana | `RHastatus` | `RArcher` | `RGladiator` / `RTribune` | `RScout` | `RHero1` |
| Germania | `TMaceman` | `TArcher` | `THuntress` | `TTeutonRider` | `THero1` |
| Galia | `GWomanWarrior` | `GArcher` | `GAxeman` / `GTridentWarrior` | `GHorseman` | `GHero1` |
| Britania | `BBronzeSpearman` | `BBowman` | `BJavelineer` / `BHighlander` | — | `BHero1` |
| Iberia | `IDefender` | `ISlinger` | `IMilitiaman` / `IEliteGuard` | `ICavalry` | `IHero1` |
| Cartago | `CLibyanFootman` | `CJavelinThrower` | `CNoble` / `CBerberAssassin` | `CNumidianRider` | `CHero1` |
| Egipto | `EGuardian` | `EArcher` | `EAxetrower` / `EAnubisWarrior` | `EChariot`* | `EHero1` |

\* equivalente funcional, no `parent="Horse"`.

## 23.11 Composición de referencia de 50 unidades

Una investigación de balance construyó una plantilla técnica por civilización a partir de clases
reales y evitando, cuando era requisito, unidades que no consumen comida normalmente.

### Roma Imperial

```text
18 RHastatus
10 RArcher
 8 RVelit
 6 RPraetorian
 7 RScout
 1 MHero1
```

### Roma Republicana

```text
18 RHastatus
10 RArcher
 8 RGladiator
 6 RTribune
 7 RScout
 1 RHero1
```

### Germania

```text
20 TMaceman
10 TArcher
12 THuntress
 7 TTeutonRider
 1 THero1
```

### Galia

```text
20 GWomanWarrior
11 GArcher
11 GAxeman
 7 GHorseman
 1 GHero1
```

### Britania

```text
15 BBronzeSpearman
 5 BHighlander
15 BBowman
14 BJavelineer
 1 BHero1
```

### Iberia

```text
17 IDefender
11 ISlinger
 8 IMilitiaman
 6 IEliteGuard
 7 ICavalry
 1 IHero1
```

### Cartago

```text
18 CLibyanFootman
11 CJavelinThrower
 8 CBerberAssassin
 5 CNoble
 7 CNumidianRider
 1 CHero1
```

### Egipto

```text
19 EGuardian
10 EArcher
 9 EAxetrower
 5 EAnubisWarrior
 6 EChariot
 1 EHero1
```

Esta tabla pertenece al **trabajo de diseño del proyecto**, no a una formación nativa obligatoria del
juego. Su utilidad dentro del manual es mostrar qué IDs se consideraron suficientemente validados
para generar ejércitos normales.

---

# 24. Forénsica de PAK/BFHP, inventarios de API e incógnitas abiertas

## 24.1 Los `.pak` no se resolvieron como un contenedor trivial

Una fase temprana interpretó ciertos campos de la entrada inicial como si identificaran directamente:

```text
offset
tamaño comprimido
tamaño descomprimido
```

para cada archivo.

La extracción posterior mostró que esa interpretación era incorrecta para las entradas no resueltas:
los bloques obtenidos contenían nombres pertenecientes a otras entradas.

Esta conclusión anterior queda corregida.

## 24.2 Códec de compresión no identificado

Los payloads inspeccionados no coincidieron de forma directa con cabeceras típicas de:

```text
zlib
gzip
LZIS de partidas guardadas
```

No se identificó el códec exacto.

Recuperar con certeza determinadas entradas comprimidas requeriría investigar la rutina de
descompresión del ejecutable, trabajo que quedó fuera del alcance de aquellas fases.

## 24.3 `imperivm_pak_tool.py`

Se creó una herramienta de inspección no destructiva con varias funciones.

### `list`

Lista de forma fiable la entrada resuelta y ofrece inventario heurístico para el resto.

### `extract`

Extracción exacta sólo cuando la entrada puede identificarse con seguridad; para otros nombres,
volcado heurístico del bloque legible cercano.

### `scan`

Busca bloques ASCII contiguos.

Fue uno de los métodos que más hallazgos produjo porque muchos fragmentos `.vs` y XML permanecen
legibles dentro de los contenedores.

### `strings`

Volcado de cadenas ASCII con offsets.

La herramienta no debe presentarse como un desempaquetador completo del formato.

## 24.4 Inventarios de API

Los ficheros generados:

```text
engine_vs_api_inventory.txt
sequence_api_inventory.txt
common_api.txt
sequence_only_api.txt
engine_only_api.txt
```

sirven como índice de búsqueda.

No son documentación formal.

Un nombre procedente únicamente del inventario debe clasificarse como:

```text
candidato
```

hasta encontrar:

- una cita literal;
- una firma contextual;
- o una prueba directa.

## 24.5 Hallazgos negativos importantes

### No se encontró un mecanismo simple para declarar nuevas clases desde un BFHP

Las clases están vinculadas a:

```text
cpp_class
entity
herencia
```

y no apareció una sintaxis de escenario equivalente a:

```text
class nueva
→ comportamiento propio
→ registrar globalmente
```

Por ello la estrategia recomendada es extender clases existentes mediante Sequences.

### No se encontró función de “reiniciar comportamiento de objeto”

Búsquedas dirigidas de nombres equivalentes a:

```text
RunBehavior
Restart
SetScript
Reinit
CreateScript
```

no encontraron un mecanismo utilizable.

### `GUARD AREA.VS` no pudo recuperarse completo

Se conoce su nombre y se conocen llamadas a `GuardCentralArea`, pero no su implementación.

### `UnitFlags` sigue sin semántica documentada

Se observaron combinaciones consistentes con una máscara de bits, pero no se encontró evidencia
textual suficiente para asignar significado fiable a cada bit.

## 24.6 Incógnitas que siguen abiertas

1. Implementación interna exacta de `SpawnGroupInHolder` y qué ocurre cuando se agota por completo un pool precolocado.
2. Si `SetFeeding(false)` sobrevive siempre a un `SetPlayer()` posterior en todos los tipos de unidad.
3. Semántica completa de `UnitFlags`.
4. Códec exacto de los bloques comprimidos de `HMMSYS PackFile` y del formato `LZIS`.
5. Efectos secundarios completos de `Townhall.SetPlayer()` sobre recursos, población, tropas y sentinelas.
6. Cuerpo y reglas completas de `townhall_sentries_control.vs`.
7. Significado exacto del tercer parámetro de `ObjList.Siege(target,n,param)`.
8. Algoritmo interno de `BestGate`; el helper `"siege"` lo usa por nosotros, pero el criterio exacto sigue sin recuperarse.
9. Significado completo de `GAIKA`, aunque ya se han recuperado `GetGAIKAStrat.vs`, `GS_Siege.vs` y sus firmas en `AI.INI`.
10. Fórmula de recuperación nativa de loyalty sugerida por `LoyaltyIncreasePerUnit`.
11. Acceso directo desde una Sequence escrita a mano a `Gate.IsBroken`/`IsVeryBroken`: están confirmadas dentro de AI Helpers, pero no se ha consolidado una prueba directa independiente en una Sequence de producción.
12. Condición de victoria exacta cuando existe un Player técnico 9-14 con unidades vivas pero sin Townhall propio.
13. Límite práctico de rendimiento/pathfinding con grandes cantidades de unidades técnicas durante partidas de muchas horas.
14. Efectos exactos de `PlayMovie()` sobre audio, input y cámara fuera del patrón ya probado por `ZombieIntro_Main`.
15. Semántica completa del segundo argumento de `UserNotification`; la v2.0 utiliza `""`.
16. Persistencia exacta de `IntArray` ante guardado/carga frente al estado explícito guardado con `EnvWriteInt`; en v2.0 los arrays se usan como estado de ejecución de la Sequence y los flags críticos se guardan en el Building.


### Incógnitas resueltas desde versiones anteriores

Además de las resoluciones históricas ya documentadas, la compilación v2.0 resuelve tres dudas importantes:

```text
IntArray en Sequence
→ CONFIRMADO

EnvReadInt con clave "PREFIJO" + entero
→ CONFIRMADO

Groups con nombre calculado en runtime
→ CONFIRMADOS en los sistemas __FRT_X_Y y __FRT_AUX_X_Y
```

Ya **no** debe figurar como abierta la fórmula básica de captura de Townhall.

Se recuperó `unit_capture.vs` y quedó confirmado:

```text
capture
→ DecreaseLoyalty(1)
→ loyalty == 0
→ SetPlayer(atacante)
→ SetLoyalty(11)
```

Tampoco es ya una incógnita que una Gate pueda ser atacada por una `Unit`: `attack` está declarado para
`target="Building"` y `Gate` hereda de `Building`.

## 24.7 Regla para futuras ampliaciones

Cuando un informe nuevo contradiga uno antiguo:

```text
no borrar la historia
```

pero en el manual canónico debe quedar:

```text
conclusión más reciente
+
nota de qué hipótesis antigua corrige
```

Ejemplo ya resuelto:

```text
“Place quizá no funciona desde Sequence”
            ↓
SUPERADO
            ↓
Place confirmado en campañas oficiales
```

Ese enfoque convierte el manual en una referencia útil sin ocultar cómo se llegó a la conclusión.


# 25. Hordas, jugadores técnicos y seguimiento de ejércitos dinámicos

La investigación de `HordeWaves_Main` aporta patrones generales reutilizables para cualquier sistema
que necesite crear muchos ejércitos temporales controlados por Sequence.

No debe leerse como una composición concreta de “zombis”, sino como una referencia sobre:

```text
jugador técnico
spawn dinámico
objetivo persistente
estado por ejército
retargeting
muerte del grupo
temporizadores
```

## 25.1 Jugadores técnicos 9-14

Para separar una facción de scripting de los jugadores normales y de los neutrales usados por el mapa,
el rango 9-14 es una elección limpia cuando está libre.

Ventajas:

- no coincide con jugadores jugables 1-8;
- evita mezclar la facción técnica con objetos que ya usan 15/16;
- puede poseer unidades reales creadas con `Place()`.

Ejemplo:

```cpp
int HORDE_PLAYER;
HORDE_PLAYER = 12;
```

La hostilidad automática entre un jugador técnico y 1-8 está respaldada por evidencia fuerte de
`EnemyObjs` y comportamiento neutral, pero debe seguir clasificándose como **INDICIO FUERTE** si no se
ha probado directamente en el mapa concreto.

La única escritura diplomática confirmada de este ámbito es:

```cpp
DiplCeaseFire(a, b, true);
```

que establece un alto el fuego. No existe una función confirmada `SetEnemy()`/`SetWar()`.

## 25.2 Creación de un ejército técnico

Patrón:

```cpp
Unit u;

u = Place(
    "RHastatus",
    spawnPoint,
    HORDE_PLAYER
).AsUnit();

u.SetLevel(level);
u.SetFeeding(false);
u.SetNoAIFlag(true);
u.SetCommand("advance", target.pos);
```

Cada llamada debe elegirse por intención:

```text
SetFeeding(false)
→ la unidad no depende de logística

SetNoAIFlag(true)
→ evita que una IA estratégica normal secuestre la unidad

SetCommand(...)
→ la Sequence conserva control táctico
```

`SetNoAIFlag` no sustituye a `SetCommand`; sólo resuelve una capa distinta de control.

## 25.3 Objetivo final y subobjetivo

Un patrón robusto mantiene dos niveles conceptuales:

```text
objetivo final
= asentamiento que se quiere alcanzar

subobjetivo temporal
= enemigo, Gate, entrada, punto de reunión...
```

La horda no debería “olvidar” el asentamiento porque momentáneamente tenga que atacar una puerta.

Esto es coherente con la arquitectura de la IA nativa:

```text
GS_Siege
GS_EnterSettlement
GS_Capture
```

que representa estados diferentes sobre un mismo objetivo estratégico.

## 25.4 Seguimiento de supervivientes

`ObjList.ClearDead()` es la pieza central:

```cpp
hordeUnits.ClearDead();

if (hordeUnits.count == 0)
{
    hordeActive = false;
}
```

Debe llamarse antes de usar:

```text
.count
[i]
leader
```

si la lista ha participado en combate.

## 25.5 Unidad de referencia

No se encontró una función de centroide confirmada para un ejército.

La solución más segura es conservar una unidad concreta como referencia:

```cpp
Unit leader;
```

por ejemplo la primera creada.

Para comparar distancia, la dirección con precedente literal es:

```cpp
distance = forum.DistTo(leader);
```

No debe asumirse que existe un objeto abstracto `Army` con `.pos` accesible desde Sequence.

## 25.6 Selección de objetivo por distancia

Con varios Townhall conocidos, puede compararse explícitamente:

```cpp
Building best;
int bestDist;
int d;

bestDist = -1;

if (forum1.player >= 1 && forum1.player <= 8)
{
    d = forum1.DistTo(leader);

    if (bestDist == -1 || d < bestDist)
    {
        bestDist = d;
        best = forum1;
    }
}
```

Si el conjunto de Foros está definido mediante referencias nombradas, repetir el bloque de manera
explícita es más seguro que depender de una colección de alto nivel no confirmada en Sequence.

## 25.7 Arrays confirmados en Sequences

La compilación v2.0 confirma definitivamente el uso de `IntArray` dentro del editor de Sequences.

`ZombieTactical_Main` mantiene estado independiente para ocho frentes y una red de 18 nodos mediante arrays:

```cpp
IntArray phase;
IntArray marchTicks;
IntArray gateX;
IntArray gateY;
IntArray anchorNode;
IntArray targetNode;
IntArray goalNode;
IntArray nodeX;
IntArray nodeY;
IntArray edgeW;
IntArray routeDist;
IntArray routePrev;
IntArray routeUsed;
IntArray routePath;
IntArray frontActive;
```

Esto permite escribir sistemas multiinstancia sin duplicar manualmente decenas de variables:

```cpp
phase[H] = 0;
anchorNode[H] = 0;
frontActive[H] = active;
```

La recomendación anterior de evitar arrays en Sequence queda superada para `IntArray`.

## 25.8 Estado indexado para múltiples frentes

La versión estable ya no necesita 24 slots duplicados. `ZombieTactical_Main` gestiona ocho frentes persistentes:

```text
HW_H1
HW_H2
...
HW_H8
```

y utiliza `IntArray` para el estado táctico por frente:

```cpp
phase[H]
marchTicks[H]
gateX[H]
gateY[H]
anchorNode[H]
targetNode[H]
goalNode[H]
goalOwner[H]
```

Los flags que deben ser compartidos con otras Sequences siguen almacenándose sobre `CapitalForum_P1` mediante `EnvReadInt`/`EnvWriteInt`.

## 25.9 Groups dinámicos confirmados

La compilación v2.0 confirma tanto la pertenencia dinámica como el uso de nombres calculados en runtime.

`Fortresses_Main` construye:

```cpp
groupName =
    "__FRT_"
    + fort.pos.x
    + "_"
    + fort.pos.y;
```

y después utiliza:

```cpp
u.AddToGroup(groupName);
garrison = Group(groupName).GetObjList();
```

`OutpostAuxDefense_Main` aplica el mismo patrón con:

```text
__FRT_X_Y
__FRT_AUX_X_Y
```

Por tanto la creación/uso de Groups lógicos con nombre calculado debe considerarse confirmada en el entorno actual del proyecto.

## 25.10 Estado persistente sobre un líder

Una alternativa es asociar datos al objeto:

```cpp
EnvWriteInt(
    hordeLeader,
    "HW_Target",
    targetIndex
);
```

y leerlos después:

```cpp
targetIndex =
    EnvReadInt(
        hordeLeader,
        "HW_Target"
    );
```

La técnica está compuesta a partir de `EnvReadInt/EnvWriteInt` confirmados, aunque el uso exacto sobre
un “líder de horda” es una aplicación de diseño, no una cita nativa literal.

## 25.11 Temporizadores de oleadas

El patrón más fiable sigue siendo:

```cpp
int elapsed;
elapsed = 0;

while (1)
{
    Sleep(1000);
    elapsed += 1000;

    // eventos según elapsed
}
```

`GetTime()` ya tiene una cita real, pero un acumulador con `Sleep` sigue siendo una solución simple y
bien alineada con escenarios oficiales.

Los valores de cadencia, número de oleadas y composición pertenecen al **diseño del mapa**, no a la API
del motor, y por tanto no deben fijarse en este manual como reglas universales.

## 25.12 `rand(n)`

Se observó:

```cpp
rand(qEnemies.GetObjList().count)
rand(360)
```

El primer uso funciona directamente como índice, por lo que existe evidencia muy fuerte de:

```text
rand(N) → 0 ... N-1
```

Ejemplo de selección de spawn:

```cpp
int spawn;
spawn = rand(8);
```

## 25.13 No existe pathfinding de alto nivel para Sequence

No se encontraron funciones Sequence confirmadas equivalentes a:

```text
CanReach
FindPath
HasPath
PathTo
SameArea
```

Varios nombres de navegación existen únicamente en el inventario engine-only.

Por tanto, un sistema de hordas debe diseñar su reacción a bloqueos mediante señales observables:

```text
unidad no avanza
Gate cercana
objetivo sigue lejos
```

no mediante una función inexistente de “¿hay ruta?”.

## 25.14 Regla de diseño

La arquitectura general recomendada es:

```text
spawn
→ guardar ObjList + líder + objetivo
→ emitir orden
→ limpiar muertos periódicamente
→ mantener objetivo final
→ cambiar sólo subobjetivo cuando sea necesario
→ liberar slot cuando count == 0
```

Este patrón es reutilizable para invasiones, refuerzos, patrullas temporales y oleadas.


# 26. Gates, catapultas, arietes y asedio desde Sequences

La investigación profunda del asedio corrige varios supuestos tempranos. La regla central es:

```text
Gate viva
≠
Gate que todavía bloquea el paso
```

La IA nativa y sus AI Helpers no esperan a que una Gate desaparezca del mundo: utilizan estados de daño
específicos de la clase.

## 26.1 `Gate` es un `Building`

Cadena confirmada:

```text
Gate
→ BaseBuilding
→ Building
```

Por tanto una Gate es un objetivo válido para comandos que aceptan `Building`, como:

```cpp
u.SetCommand("attack", gate);
```

Las variantes inspeccionadas heredan `maxhealth=5000` si no lo overridean.

## 26.2 `IsBroken` e `IsVeryBroken`: los umbrales reales de brecha

El código recuperado de `GS_Siege.vs` y de los AI Helpers distingue:

```text
Gate.IsVeryBroken
Gate.IsBroken
```

La capa estratégica de `Squad` utiliza `IsVeryBroken` para comenzar `InvadeThroughGate` antes de la
rotura completa. Los AI Helpers accesibles desde Sequence esperan al umbral más tardío:

```cpp
while (!oTarget.AsGate.IsBroken)
{
    // mantener el asedio
}
```

Esto corrige un patrón anterior basado en:

```cpp
if (!gate.IsAlive())
```

`IsAlive()` responde a si el objeto sigue existiendo/vivo; **no es la condición que usa el motor para
decidir que la brecha ya es atravesable**. Por eso una Gate puede seguir mostrando salud residual y,
sin embargo, haber alcanzado el estado de rotura relevante.

El acceso directo a `IsBroken` desde una Sequence escrita por el usuario todavía debe probarse en el
editor; su uso está confirmado dentro de AI Helpers `.vs` que el motor ejecuta desde `RunAIHelper`.

## 26.3 Dos familias de asedio distintas

### `Catapult`

```text
parent = Building
cpp_class = CVXCatapult
```

Se crea mediante:

```cpp
PlaceCatapult(x, y, player, race)
```

y necesita unidades que ejecuten:

```cpp
u.SetCommand("build_catapult", cat);
```

La catapulta-edificio necesita tripulación y tiene `min_range=301`.

### `RamUnit`

```text
parent = Military
cpp_class = CVXUnit
```

Variantes reales encontradas:

```text
BCatapultUnit
TCatapultUnit
```

Se pueden tratar como unidades militares móviles y darles:

```cpp
ram.SetCommand("attack", gate);
```

`RamUnit` tiene `feeds=0`, por lo que no consume comida por diseño.

## 26.4 `ObjList.Siege()` y reposición automática del arma

La llamada confirmada:

```cpp
soldiers.Siege(target, nCatapults, param3);
```

no debe entenderse como un proceso permanente. El AI Helper nativo mantiene un pequeño estado local:

```cpp
bool bSieging;
bool bCat;
```

En cada tick recalcula si existe actividad de asedio:

```text
alguna unidad InHolder
O
alguna unidad con command == "build_catapult"
→ bCat = true
```

Si el helper creía estar asediando pero ya no existe ninguna de esas señales:

```cpp
if (bSieging && !bCat)
    bSieging = false;
```

En la iteración siguiente vuelve a cumplirse:

```cpp
if (!bSieging)
{
    ol.Siege(oTarget, nMaxCatapults, 0);
    bSieging = true;
}
```

Éste es el mecanismo real de **reposición del asedio destruido**. No se encontró un evento
`SiegeEnded` ni una función `NumCatapults` necesaria para ello.

## 26.5 AI Helper `"siege gate"`: firma y comportamiento confirmados

Cuerpo recuperado de `SIEGE GATE.VS`; firma interna:

```text
void, str GroupName, str Target
```

Llamadas reales:

```cpp
RunAIHelper(
    "SiphaxSiegeGate1",
    "siege gate",
    "Q_MaySiege",
    "NO_Gate1"
);
```

El cuarto argumento es el **nombre de una Gate concreta**. Internamente:

```text
Group(GroupName)
→ GetNamedObj(Target)
→ comprobar que es Gate
→ obtener su Settlement
→ reunir al menos ~2/3 del grupo
→ advance hacia la Gate para los que están lejos/fuera de GAIKA
→ mantener Siege hasta Gate.IsBroken
→ detener catapulta restante
→ cambiar objetivo al edificio central
→ advance a puntos alrededor del centro
→ capture del edificio central
```

El helper contiene un tratamiento explícito para unidades lejanas:

```cpp
if (GetGAIKA(u) != set.GetGaika || u.DistTo(oTarget) > 1000)
{
    // avanzar hacia la Gate
}
```

Por tanto, no es correcto afirmar de forma general que `"siege gate"` requiera que el grupo ya esté
pegado a la ciudad.

## 26.6 AI Helper `"siege"`: asedio completo de un Settlement

Firma confirmada por llamadas oficiales:

```cpp
RunAIHelper(
    etiqueta,
    "siege",
    nombreGrupo,
    settlement.name
);
```

Ejemplos reales:

```cpp
RunAIHelper("SmallAttack", "siege", "SmallTownArmy", set.name);
RunAIHelper(AISiege, "siege", SiegeGroup, TargSett.name);
RunAIHelper("M_Siege_S_Memfis", "siege", "T_MarkAntonyArmy", "S_Memfis");
```

El cuarto argumento es **siempre un `str` que identifica el Settlement**. El helper ejecuta:

```cpp
set = GetSettlement(Target);
if (!set.IsValid) return;
```

Ramas principales:

```text
Outpost
→ edificio central
→ reunir grupo
→ Siege/capture

Stronghold
→ set.BestGate(ol[0].pos)
→ reunir grupo
→ Siege/reposición
→ esperar Gate.IsBroken
→ edificio central
→ advance/capture
```

Esto confirma que `BestGate` puede aprovecharse **indirectamente** desde una Sequence aunque la función
no aparezca como API directa de escenario.

## 26.7 Corrección de una hipótesis sobre el cuarto argumento

Una fase intermedia propuso pasar directamente:

```cpp
RunAIHelper(..., "siege", ..., targetForum);
```

como posible solución a un problema de naming. Esa hipótesis **no debe usarse como recomendación
canónica**. La evidencia de mayor calidad es la firma real `str Target` y más de veinte llamadas de
producción que pasan:

```text
"S_Memfis"
set.name
Sett.name
TargSett.name
```

Regla actual:

```text
Building dinámico
→ targetForum.settlement
→ targetForum.settlement.name
→ RunAIHelper(..., "siege", ..., eseNombre)
```

siempre que ese `Settlement` sea válido.

## 26.8 Después de `IsBroken` no se usa un “punto de brecha” especial

El helper `"siege gate"` no llama a:

```text
GetEnterPoint
GetExitPoint
InvadeThroughGate
```

Tras romper la Gate hace:

```text
objetivo = edificio central
→ advance hacia puntos alrededor del Foro
→ capture
```

La conclusión operativa es que, **una vez alcanzado `IsBroken`**, el AI Helper confía en el pathfinding
normal. `InvadeThroughGate` pertenece a la capa `Squad` engine-only y permite una entrada más sofisticada
antes de llegar a ese umbral, pero no es necesaria para reproducir el patrón del helper accesible.

## 26.9 Doble Gate: diferencia entre motor estratégico y AI Helper

La capa nativa `GS_Siege.vs` recalcula:

```cpp
gate = set.BestGate(squad.pos);
```

para cada `Squad` y en cada iteración. Así puede pasar de Gate A a Gate B después de cruzar el primer
recinto.

El helper `"siege"`, en cambio, obtiene:

```cpp
oTarget = set.BestGate(ol[0].pos);
```

una sola vez para esa ejecución. Tras `IsBroken` pasa al edificio central y no vuelve a seleccionar otra
Gate.

Por tanto, una ciudad con doble anillo puede exigir:

```text
RunAIHelper(..., "siege gate", ..., GateExterior)
→ esperar/probar avance
→ RunAIHelper(..., "siege gate", ..., GateInterior)
```

o una Sequence táctica propia que gestione varias Gates.

## 26.10 Riesgo de `ol[0]` y `BestGate`

El helper genérico elige la Gate según:

```cpp
set.BestGate(ol[0].pos)
```

No se ha recuperado el algoritmo interno de `BestGate` ni se ha demostrado que `GetObjList()[0]` sea
la unidad más cercana al objetivo. En grupos muy dispersos, la primera unidad puede influir en la Gate
seleccionada.

Esto conserva una parte válida de la investigación exploratoria posterior: si el grupo se mueve de
forma coherente hacia un lado inesperado de una ciudad, conviene comprobar **qué unidad ocupa `ol[0]` y
qué Gate acaba eligiendo el helper**, no asumir automáticamente que el Settlement es inválido.

## 26.11 `RunAIHelper` parece concurrente

Los helpers contienen bucles potencialmente largos, pero campañas oficiales lanzan muchas llamadas
consecutivas. Si la llamada fuera bloqueante, sólo la primera podría progresar.

Clasificación:

```text
RunAIHelper concurrente / no bloqueante
→ INDICIO FUERTE
```

No existe una documentación formal que lo declare, por lo que se mantiene por debajo de
“CONFIRMADO por firma”.

## 26.12 Cuándo NO usar el helper `"siege"`

El helper termina emitiendo:

```cpp
u.SetCommand("capture", oTarget);
```

Esto es correcto para una IA normal que debe conquistar la ciudad. No es correcto para una facción
técnica cuyo diseño sea:

```text
abrir la ciudad
→ neutralizarla
→ NO conservarla como Player técnico
```

En ese caso hay tres opciones:

1. usar `"siege gate"` sólo para abrir la puerta y después asumir el control de la lógica;
2. reproducir el bucle `bSieging/bCat` con `ObjList.Siege()` y cortar antes de `capture`;
3. permitir la captura momentánea y neutralizar de inmediato, aceptando los efectos secundarios que
   tenga `capture` sobre loyalty/propiedad — menos recomendable si no se han probado todos esos efectos.

## 26.13 Flujo canónico de asedio

### IA normal que sí debe conquistar

```text
RunAIHelper(..., "siege", grupo, settlement.name)
```

es la pieza de mayor nivel confirmada.

### Facción técnica que no debe quedarse la ciudad

```text
objetivo final = Townhall
→ localizar Gate
→ "siege gate" o Siege manual
→ esperar brecha real
→ advance al interior
→ aplicar neutralización propia
```

## 26.14 Regla canónica actualizada

Ante un atasco de asedio hay que responder, en este orden:

```text
1. ¿el objetivo del helper es un Settlement/Gate válido?
2. ¿se eligió una Gate concreta?
3. ¿el asedio se repone cuando se pierde?
4. ¿estamos esperando IsBroken o erróneamente IsAlive==false?
5. ¿hay una segunda Gate que el helper no va a recalcular?
```

Éste es el diagnóstico más cercano al flujo real del motor recuperado hasta ahora.


# 27. IA nativa de conquista: capas, AI Helpers y límites de Sequence

La capa estratégica de la CPU pudo reconstruirse con mucho más detalle gracias a `AI.INI`,
`GetGAIKAStrat.vs` y `GS_Siege.vs`.

## 27.1 No existe una llamada pública `AIPlayer.AttackSettlement()`

La búsqueda cruzada no encontró funciones equivalentes a:

```text
AIPlayer.AttackSettlement(target)
Army.CaptureSettlement(target)
SendArmyToCapture(target)
StrategicAttack(target)
```

La inteligencia superior de la CPU existe, pero no está expuesta como una llamada única desde una
Sequence.

## 27.2 Las tres capas reales

### Capa 1 — subAI por unidad

Ejecuta comandos concretos:

```text
unit_capture.vs
unit_advance.vs
unit_ai_attack_gate.vs
unit_ai_killall.vs
unit_enter.vs
build_catapult.vs
ram_attack.vs
...
```

### Capa 2 — AI Helpers

Expuesta mediante:

```cpp
RunAIHelper(...);
```

Incluye helpers como:

```text
GUARD AREA.VS
SIEGE GATE.VS
SIEGE.VS
CAPTURE.VS
ENTERSETTLEMENT.VS
KILLENEMIES.VS
```

Los modos `"siege"` y `"siege gate"` cuentan ya con firma y llamadas de producción confirmadas.

### Capa 3 — IA estratégica `GAIKA`/`Squad`

Trabaja con tipos y métodos no disponibles directamente en escenarios:

```text
GAIKA
Squad
SquadList
BestGate
InvadeThroughGate
GetSquads
MilEval
RunStrat
RunTacticScript
...
```

## 27.3 `AI.INI`: catálogo de estrategias y firmas

Se recuperó la sección `[Scripts]`:

```ini
GetGAIKAStrat.vs = int, GAIKA gaika, int idPlayer
GS_EnterSettlement.vs = void, GAIKA gaika
GS_Capture.vs = void, GAIKA gaika
GS_KillEnemies.vs = void, GAIKA gaika
GS_Siege.vs = void, GAIKA gaika
GS_Guard.vs = void, GAIKA gaika
```

Variables relevantes:

```ini
AIV_Sleep_GS=1500
AIMV_NoCapture=0
AIMV_NoAttack=0
AIMV_NoAttackStrongholds=0
AIMV_NoAttackVillages=0
AIMV_NoAttackOutposts=0
```

`AIV_Sleep_GS=1500` confirma una cadencia estratégica nativa de aproximadamente 1,5 segundos para esa
capa.

## 27.4 Corrección fundamental: una invasión enemiga NO transita a `GS_EnterSettlement`

Una hipótesis inicial representaba:

```text
GS_Siege
→ GS_EnterSettlement
→ GS_Capture
```

como cadena de invasión. El código real demuestra que **no funciona así**.

`GS_EnterSettlement` se selecciona cuando el Settlement **ya es propio** (`bOurSet`), por ejemplo:

```text
no hay enemigos
→ meter/refugiar tropas

o
somos muy débiles frente al enemigo
→ retirarse dentro del Settlement propio
```

La invasión de un Stronghold enemigo permanece dentro de una única ejecución de `GS_Siege.vs`.

## 27.5 Estados `GS_*` frente a estados `SS_*`

Dentro de `GS_Siege.vs`, cada `Squad` recibe un estado táctico local:

```text
SS_Siege
SS_Catapult
SS_Enter
SS_KillAll
SS_Capture
SS_IDLE
```

La decisión relevante es:

```cpp
if (gate.Inside(squad))
{
    if (bEnemiesOut) state = SS_KillAll;
    else state = SS_Capture;
}
else
{
    if (gate.IsVeryBroken) state = SS_Enter;
    else state = SS_Siege;
}
```

Por tanto:

```text
GS_Siege
    contiene internamente
    SS_Siege → SS_Enter → SS_Capture
```

sin cambiar a `GS_EnterSettlement`.

## 27.6 `GS_Siege.vs`: flujo real

El ejecutor estratégico realiza:

```text
1. reunir squads que se aproximan
2. reevaluar fuerza propia/aliada/enemiga
3. elegir BestGate para cada squad
4. si está fuera y Gate no muy rota → Siege
5. si Gate.IsVeryBroken → InvadeThroughGate
6. si ya está dentro y quedan enemigos exteriores → KillAll
7. si está dentro y la zona está limpia → Capture
8. limpiar estados y volver a enviar squads al GAIKA
```

La CPU normal resuelve la puerta porque **elige explícitamente esa Gate como subobjetivo táctico**; no
porque `advance` tenga un pathfinding especial que destruya edificios por sí solo.

## 27.7 `GetGAIKAStrat.vs`: por qué el alto nivel sigue en `GS_Siege`

El clasificador calcula:

```cpp
bGates = Set.NumGates > 0;
bCanEnter = bOurSet || !bGates;
```

Para un Settlement enemigo que tiene Gates, `bCanEnter` sigue siendo falso a nivel del clasificador
aunque una Gate concreta ya esté dañada. No necesita cambiar de estado porque `GS_Siege.vs` contiene por
sí mismo toda la lógica de entrada y captura.

Esto explica por qué intentar modelar la invasión como una sucesión de `GS_*` era conceptualmente
incorrecto.

## 27.8 `BestGate` e `InvadeThroughGate`: engine-only, pero explotables indirectamente

Directamente desde Sequence no se encontró precedente de:

```text
BestGate
InvadeThroughGate
GetSquads
Squadize
```

Sin embargo:

```cpp
RunAIHelper(..., "siege", ..., settlement.name);
```

llama internamente a `set.BestGate(...)` y permite aprovechar esa decisión sin exponer el método al
script de escenario.

No ocurre lo mismo con `InvadeThroughGate`: los AI Helpers recuperados esperan a `IsBroken` y luego
usan `advance`; sólo `GS_Siege.vs` usa la entrada adelantada con `IsVeryBroken`.

## 27.9 El target de `"siege"` es un nombre de Settlement

La firma recuperada y las campañas oficiales resuelven una incertidumbre anterior:

```text
Target = str
```

Llamadas válidas observadas:

```cpp
RunAIHelper("SmallAttack", "siege", "SmallTownArmy", set.name);
RunAIHelper(AISiege, "siege", SiegeGroup, TargSett.name);
```

Por tanto, la ruta canónica para un Townhall dinámico es:

```cpp
Building target;
Settlement set;

set = target.settlement;
RunAIHelper("MiSiege", "siege", "MiGrupo", set.name);
```

La propuesta exploratoria de pasar `target` como objeto directamente queda descartada como
recomendación: no tiene precedente y contradice la firma `str Target` recuperada.

## 27.10 Qué ocurre si `GetSettlement(Target)` falla

El helper hace:

```cpp
set = GetSettlement(Target);
if (!set.IsValid) return;
```

Por tanto un nombre incorrecto produce un fallo silencioso del helper.

Esto sigue siendo una explicación válida para una horda que conserva una orden anterior o queda sin la
lógica de asedio esperada. La forma de evitarlo no es pasar un Building, sino **obtener un Settlement
válido y utilizar su `.name`**, como hacen las campañas oficiales.

## 27.11 Grupos lejanos y punto de reunión

`SIEGE GATE.VS` contiene lógica explícita para unidades:

```text
fuera del GAIKA del Settlement
O
más de 1000 unidades de distancia de la Gate
```

A esas unidades les emite `advance` hacia el objetivo hasta que aproximadamente dos tercios del grupo
han llegado.

Por eso la hipótesis “el helper sólo funciona si el grupo ya está cerca” **no puede elevarse a regla**.
La investigación exploratoria sobre grupos lejanos conserva utilidad diagnóstica, pero el código
recuperado demuestra que al menos `"siege gate"` incorpora un gather propio.

## 27.12 Doble puerta

Motor estratégico:

```text
BestGate(squad.pos)
→ se recalcula por squad/tick
→ puede seleccionar una segunda Gate al cambiar la posición
```

AI Helper:

```text
BestGate(ol[0].pos)
→ se calcula una vez
→ después de IsBroken va al edificio central
```

Ésta es una diferencia real de capacidad entre la CPU completa y la superficie delegable desde una
Sequence.

## 27.13 Separación correcta de responsabilidades

La CPU normal tiene:

```text
estrategia GAIKA
→ decide Siege / Guard / Capture
→ asigna estados a Squads
→ usa subAI por unidad
```

Una Sequence puede elegir entre:

```text
A) delegar gran parte del asedio a RunAIHelper("siege")
B) delegar sólo una Gate a RunAIHelper("siege gate")
C) reproducir manualmente el bucle con ObjList.Siege + SetCommand
```

La opción correcta depende de si el atacante debe quedarse con la ciudad y de si el mapa tiene una o
varias líneas de muralla.

## 27.14 Ledger actualizado

| Pieza | Estado desde Sequence |
|---|---|
| `RunAIHelper(x,"siege",Group,SettlementName)` | **CONFIRMADA** en campañas oficiales |
| `RunAIHelper(x,"siege gate",Group,GateName)` | **CONFIRMADA** en campañas oficiales |
| `RunAIHelper(x,"guard area",Group,Area)` | **CONFIRMADA** |
| `ObjList.Siege(target,n,param)` | **CONFIRMADA** |
| `SetCommand("attack",Gate)` | **CONFIRMADA** |
| `SetCommand("capture",Building)` | **CONFIRMADA** |
| `BestGate` directo | engine-only en el corpus; usable indirectamente mediante `"siege"` |
| `InvadeThroughGate` | engine-only |
| `GetGAIKAStrat` / `GS_Siege` | engine-only |
| `Gate.IsBroken` directo en una Sequence del usuario | pendiente de prueba directa; confirmado dentro de helpers |
| `AIPlayer.AttackSettlement` | no encontrado |

## 27.15 Regla canónica

La diferencia entre una CPU y una horda scriptada no es otro comando de captura.

La diferencia es:

```text
CPU completa
→ GAIKA + Squad + BestGate + InvadeThroughGate

Sequence
→ acceso a Unit/ObjList
→ y a una capa puente muy potente: RunAIHelper
```

Con `"siege"` y `"siege gate"` confirmados, la frontera real es bastante más favorable de lo que se
creía en las primeras fases: no se puede llamar a la estrategia completa, pero sí delegar **gran parte
del asedio nativo** sin reimplementarlo a mano.


# 28. Tropas auxiliares de Outposts: salida, defensa y retorno automático

Tres campañas oficiales contienen un patrón casi idéntico al sistema de “tropas normales guardadas en
un Outpost que salen a defender y vuelven después”. Es uno de los precedentes más valiosos del corpus
porque combina almacenamiento, salida selectiva, patrulla, retirada manual y retorno.

## 28.1 Leer las tropas asociadas al Settlement

APIs confirmadas:

```cpp
ObjList units;
units = fort.settlement.Units();

int n;
n = fort.settlement.UnitsCount();
```

`Units()` devuelve un `ObjList`. En un escenario oficial se combina además con:

```cpp
if (u.InHolder() && u.IsHeirOf("Military"))
```

por lo que el patrón más seguro para “quién está físicamente dentro ahora” es:

```text
Settlement.Units()
→ IsValid
→ InHolder()
→ IsHeirOf(...)
```

## 28.2 Meter unidades mediante script

Para una unidad creada por `Place()`:

```cpp
fort.settlement.ForceAddUnit(u);
```

La entrada manual del jugador no necesita `ForceAddUnit`; el motor ya la incorpora por la mecánica
normal del edificio.

`GGuardPost` es la excepción conocida: `max_units=0`, por lo que este capítulo se refiere a Outposts que
sí admiten tropas almacenadas.

## 28.3 Sacar unidades: el mecanismo real es darles una orden

El patrón oficial no invoca `unitsout`. Selecciona una unidad concreta de `settlement.Units()` y hace:

```cpp
u.SetCommand("advance", p);
```

Después añade patrulla:

```cpp
u.AddCommand(false, "patrol", p2);
u.AddCommand(false, "patrol", p3);
```

Como el script selecciona una unidad cada vez, la salida puede ser:

```text
selectiva
progresiva
por clase
por cantidad deseada
```

No hace falta expulsar a todas las tropas del holder.

## 28.4 Qué es realmente `unitsout`

`BaseTownhall` y `Outpost` declaran:

```xml
<method sig="unitsout" vs="data/subai/townhall_unitsout.vs"/>
<defaultcmd target="">
    <cmd name="unitsout"/>
</defaultcmd>
```

Es el comando de edificio asociado al botón de sacar unidades. No se encontró una Sequence oficial que
lo utilice como API para salida selectiva.

Regla práctica:

```text
salida programática selectiva
→ SetCommand("advance", punto) sobre cada Unit
```

## 28.5 `InHolder()`

Semántica confirmada:

```cpp
if (u.InHolder())
{
    // físicamente dentro de un holder
}
```

También existe el patrón de espera:

```cpp
u.SetCommand("enter", building);
while (u.InHolder() == false)
{
    Sleep(1);
}
```

## 28.6 Volver a entrar: `enter_tent` frente a `enter`

### Entrada forzada

```cpp
u.SetCommand("enter_tent", fort);
```

El comentario original del código oficial indica que puede forzar la entrada incluso cuando el tipo de
“tent” no la permitiría normalmente.

### Entrada normal

```cpp
u.SetCommand("enter", fort);
```

También está confirmada en escenarios.

Para Outposts del sistema de defensa, `enter_tent` tiene el precedente más directo y evita parte de las
restricciones normales de entrada.

## 28.7 El jugador puede “recuperar” una unidad auxiliar

La Sequence oficial vigila:

```cpp
u.GetCommanded()
```

Cuando detecta que la unidad ha recibido control/orden externa, deja de gestionarla como defensora
automática.

Patrón conceptual:

```text
unidad sacada por el sistema
→ pertenece a auxOut
→ jugador le da una orden
→ GetCommanded() indica intervención
→ eliminarla del seguimiento automático
→ no volver a sobrescribir sus órdenes
```

Ésta es la forma correcta de evitar que una Sequence “se pelee” con el jugador.

## 28.8 Mantener a los defensores cerca

Los scripts oficiales combinan:

```cpp
fort.DistTo(u)
```

con el radio del edificio para impedir que una unidad defensora se aleje demasiado.

La filosofía no es reemitir `attack` cada segundo, sino:

```text
orden inicial
→ dejar actuar al subAI normal
→ sólo corregir si abandona la zona o si termina la amenaza
```

## 28.9 Groups y listas temporales

Operaciones confirmadas:

```cpp
u.AddToGroup("Nombre");
u.RemoveFromGroup("Nombre");
u.RemoveFromAllGroups();
```

También existen listas locales:

```cpp
ObjList auxOut;
auxOut.Add(u);
auxOut.ClearDead();
```

Para un sistema autocontenido, una `ObjList` local es normalmente más segura que construir nombres de
Groups que quizá no existan previamente. Los Groups con nombre son útiles cuando **otras Sequences**
necesitan consultar las mismas unidades.

`Contains()` aparece ya en el prototipo de hordas del mapa de trabajo, pero no se había encontrado en
las campañas oficiales iniciales; su uso debe considerarse confirmado por ese código de Sequence, no
por el primer corpus histórico.

## 28.10 Cambio de propietario

El comportamiento oficial termina (`return`) cuando cambia el dueño, porque sólo necesita gestionar la
defensa hasta la primera captura.

Para un sistema persistente hay que adaptar esa parte:

```cpp
if (old_player != fort.player)
{
    auxOut.Clear();
    old_player = fort.player;
}
```

Las auxiliares que estaban fuera **no deben cambiarse al nuevo jugador**. Permanecen como tropas del
propietario antiguo; lo único que debe hacer la Sequence es dejar de considerarlas “sus auxiliares”.

Si se usan Groups con nombre, conviene retirarlas de esos Groups antes de limpiar la lista.

## 28.11 Arquitectura canónica

```text
PAZ
→ no tocar tropas almacenadas

AMENAZA
→ leer Settlement.Units()
→ filtrar InHolder + Military/BaseMage
→ sacar sólo las necesarias con advance
→ registrar auxOut
→ dar patrulla inicial

DURANTE COMBATE
→ ClearDead
→ si GetCommanded(): liberar del sistema
→ si se aleja demasiado: corregir

SIN AMENAZA
→ enter_tent
→ opcionalmente esperar InHolder
→ limpiar auxOut

CAMBIO DE DUEÑO
→ dejar de tocar auxiliares antiguas
→ reiniciar seguimiento para el nuevo owner
```

## 28.12 APIs que NO deben inventarse

Se encontraron tokens como `ExitHolder`/`EnterHolder`, pero sin precedentes literales fiables de
invocación en las Sequences analizadas.

No deben sustituir a las piezas confirmadas:

```text
salir → SetCommand("advance", ...)
entrar → SetCommand("enter_tent", ...)
comprobar → InHolder()
```


# 29. Formatos internos, logs y forénsica de escenarios

Este capítulo consolida la investigación documental de la instalación y explica qué puede extraerse sin
modificar los archivos originales.

## 29.1 `.BFHP`: contenedor `HPFS`

Magic confirmado:

```text
48 50 46 53
"HPFS"
```

Un escenario funciona como un pequeño sistema de archivos con entradas como:

```text
Custom.xml
Local
Maps
Notes.xml
player0.xml ... player15.xml
Resources
Sequences
Conversations
env.42
game.xml
itemsCustom.xml
```

Dentro de `Maps/<Mapa>/` aparecen, entre otros:

```text
labels.xml
map.obj.xml
map.xml
Notes.xml
Sequences
Terrain.decor.grid
Terrain.height.grid
Terrain.light.grid
Terrain.pass.grid
Terrain.terrain.grid
Terrain.trans.grid
warehouse.rle
```

Buena parte del XML está almacenada sin comprimir, con relleno `0x00`, lo que permite recuperar grupos,
objetos, Settlements y metadatos con búsquedas directas.

## 29.2 `.pak`: `HMMSYS PackFile`

Cabecera:

```text
"HMMSYS PackFile\n" + 0x1A
```

Para la primera entrada estudiada se confirmó:

```text
uint32 tamaño_comprimido
uint32 tamaño_sin_comprimir
uint16 longitud_nombre
char nombre[longitud_nombre]
byte datos[tamaño_comprimido]
```

El layout de las entradas posteriores no quedó completamente resuelto; parece usar compresión de
prefijos para los nombres. Por tanto, las herramientas actuales son de **forénsica heurística**, no un
unpacker general de precisión total.

## 29.3 No todo `data.pak` está comprimido

Se recuperaron bloques extensos de:

```text
XML de clases
scripts .vs
AI.INI
```

en texto legible. Además, una técnica posterior mejoró el método: en lugar de exigir un bloque largo
100% imprimible, se volcó una ventana de bytes alrededor de un marcador conocido y se sustituyeron sólo
los bytes no imprimibles. Así se recuperaron casi completos `GS_Siege.vs`, `GetGAIKAStrat.vs` y los
helpers de asedio.

Lección metodológica:

```text
scan ASCII continuo falla
≠
contenido necesariamente comprimido
```

Puede haber código legible intercalado con bytes de control.

## 29.4 `LZIS`

Magic:

```text
LZIS
```

Aparece en:

```text
Profiles/PlayerA/*.snr
*.con
*.adv
*.usr
Packs/RandomMapSettlements.bfhp
```

No coincide con zlib/gzip estándar. El algoritmo exacto sigue sin identificarse.

## 29.5 Catálogo real de scripts

Entre los nombres recuperados en `data.pak` aparecen:

```text
GUARD AREA.VS
SIEGE GATE.VS
SIEGE.VS
CAPTURE.VS
ENTERSETTLEMENT.VS
KILLENEMIES.VS
TOWER_GUARD.VS
GAIKAMONITOR.VS
TACTICMONITOR.VS
BUILDARMY.VS
RECRUITER.VS
SEARCH.VS
HERORECRUIT.VS
```

Los nombres son evidencia de existencia; la firma debe obtenerse de código, `AI.INI` o llamadas reales
antes de documentar una invocación.

## 29.6 Logs `vx.log`

Los ficheros:

```text
Logs/Txarly-*/vx.log
```

son volcados de crash de `gbr.exe`, no simples logs de depuración.

Contienen dos fuentes muy útiles.

### Árbol `Environment`

Claves como:

```text
SentriesLevel
IEliteGuard
SupplyStronghold
SupplyOutpost
Bld<N>/Build/<UnitClass>
GoldSpentOnArmy4
```

coinciden con los datos consultados mediante:

```cpp
EnvReadInt(...)
EnvWriteInt(...)
```

### `Sequence status`

Puede listar cada Sequence activa como:

```text
waiting
running [Line N]
finished
```

Esto permite comprobar qué lógica estaba viva en el instante de un crash y localizar Sequences por
nombre incluso cuando su payload no se recupera cómodamente del BFHP.

## 29.7 `Logs/comp_out.txt`

Una fase posterior encontró un registro de compilación real con cientos de líneas:

```text
Now compiling '...'
```

Ese archivo confirmó nombres exactos de scripts de `data/subai/`, por ejemplo:

```text
unit_capture.vs
unit_ai_attack_gate.vs
hero_ai_attack_gate.vs
unit_ai_killall.vs
build_catapult.vs
ram_attack.vs
gate_open.vs
townhall_behavior_guard.vs
```

Su valor es distinto del inventario de strings: demuestra que el motor **compiló realmente** esos
scripts en una sesión.

## 29.8 No existe manual interno recuperado

La búsqueda no encontró:

```text
README técnico
CHM
PDF de scripting
manual del editor
carpeta gamedev con ejemplos
```

La carpeta `gamedev` relevante estaba prácticamente vacía. Por eso los escenarios oficiales y los
scripts del motor son la documentación primaria de facto.

## 29.9 Regla de confianza forense

```text
nombre encontrado como string
→ existencia probable

nombre + firma en AI.INI/XML
→ existencia estructural fuerte

llamada literal en campaña
→ API de producción

prueba directa en editor/partida
→ comportamiento confirmado
```


# 30. Caso de estudio: arquitectura canónica v2.0 del modo Zombies

La compilación estable `Carlos Guerra Total prueba zombie` v2.0 sustituye el prototipo histórico de 24/48 slots por una arquitectura de **23 Sequences** coordinadas.

La versión canónica se organiza en cuatro capas:

```text
MECÁNICAS GENERALES
→ Fortresses_Main
→ ForumCaptureReward_Main
→ GGuardPost
→ GuardPostsFrontierReward_Main
→ OutpostAuxDefense_Main

ZOMBIES
→ ZombieWaves_Main
→ ZombieTactical_Main
→ ZombieRewards_Main

INTRO / ORQUESTACIÓN
→ ZombieIntro_Main

EASTER EGG
→ ZombieEE_FirstHordeTrigger
→ ZombieEE_PriestKeeper
→ ZombieEE_PriestInteraction_Main
→ ZombieEE_Dialogue01..04
→ ZombieEE_DialogueFinal
→ ZombieEE_Sacrifice_Main
→ ZombieEE_AnubisAttack_Main
→ ZombieEE_Portals_Main
→ ZombieEE_Amulet_Main
→ ZombieEE_FinalAssault_Main
→ ZombieEE_FinalAssault_Run
```

## 30.1 Autorun canónico

La arquitectura actual separa claramente servicios permanentes y fases lanzadas bajo demanda.

```text
AUTORUN SÍ
Fortresses_Main
ForumCaptureReward_Main
GGuardPost
GuardPostsFrontierReward_Main
OutpostAuxDefense_Main
ZombieRewards_Main
ZombieTactical_Main
ZombieIntro_Main

AUTORUN NO
ZombieWaves_Main
ZombieEE_FirstHordeTrigger
ZombieEE_PriestKeeper
ZombieEE_PriestInteraction_Main
ZombieEE_Dialogue01
ZombieEE_Sacrifice_Main
ZombieEE_AnubisAttack_Main
ZombieEE_Dialogue02
ZombieEE_Portals_Main
ZombieEE_Dialogue03
ZombieEE_Amulet_Main
ZombieEE_Dialogue04
ZombieEE_FinalAssault_Main
ZombieEE_FinalAssault_Run
ZombieEE_DialogueFinal
```

`ZombieIntro_Main` es el punto de sincronización del modo Zombies y ejecuta:

```cpp
RunSequence("ZombieEE_PriestKeeper");
...
RunSequence("ZombieEE_PriestInteraction_Main");
RunSequence("ZombieEE_FirstHordeTrigger");
RunSequence("ZombieWaves_Main");
```

## 30.2 Ocho frentes persistentes

La versión estable usa exactamente:

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

Cada `HordeSpawn_01..08` corresponde a uno de esos frentes. Las rondas posteriores refuerzan los mismos grupos, no crean decenas de slots nuevos.

Estado compartido relevante:

```text
HW_ACTIVE1..8
HW_TX1..8
HW_TY1..8
HW_OWNER1..8
HW_ROUND1..8
```

`HW_TX/TY` representa el subobjetivo táctico actual y `HW_OWNER` conserva el Player final asociado al frente para el sistema de recompensas.

## 30.3 Red territorial de 18 nodos

`ZombieTactical_Main` utiliza `IntArray` para representar una red fija de 18 nodos:

```text
O1..O9
N1..N9
```

Las coordenadas se almacenan en:

```cpp
IntArray nodeX;
IntArray nodeY;
```

y las aristas ponderadas en:

```cpp
IntArray edgeW;
```

La ruta se calcula con arrays temporales de estilo Dijkstra:

```cpp
IntArray routeDist;
IntArray routePrev;
IntArray routeUsed;
IntArray routePath;
```

Este es el precedente más fuerte del proyecto para algoritmos de grafos dentro de una Sequence.

## 30.4 Descubrimiento dinámico de Townhall

Cada ciclo táctico reconstruye el universo territorial con:

```cpp
for(pp = 1; pp <= 8; pp += 1)
{
    allTownhalls.AddList(
        ClassPlayerObjs("BaseTownhall", pp).GetObjList()
    );
}

allTownhalls.AddList(
    ClassPlayerObjs("BaseTownhall", 12).GetObjList()
);

allTownhalls.AddList(
    ClassPlayerObjs("BaseTownhall", 15).GetObjList()
);

allTownhalls.AddList(
    ClassPlayerObjs("BaseTownhall", 16).GetObjList()
);
```

Esto permite que la topología territorial reaccione a conquistas durante la partida.

## 30.5 Máquina táctica por frente

Cada frente conserva una fase en:

```cpp
phase[H]
```

La arquitectura funcional es:

```text
0 → marcha
1 → asedio
2 → avance a través de la brecha
3 → captura
```

La Sequence controla además:

```text
atasco de marcha
Gate conocida
salud de Gate
presencia de unidades InHolder
progreso de cruce
acceso al Foro
atasco de captura
```

## 30.6 Asedio actual

La versión estable utiliza:

```cpp
h.Siege(
    gate,
    nCat,
    4
);
```

`nCat` se calcula aproximadamente como:

```text
h.count / 15
```

limitado a:

```text
1..4
```

La Sequence no fuerza una salida insegura de la tripulación cuando la Gate ya está rota. Esta limitación fue aceptada para evitar crashes; el scheduler R16+ ya no espera a que desaparezca todo `HW_R16`, por lo que una unidad residual en holder no bloquea nuevas rondas.

## 30.7 Waves R1-R15

Configuración principal:

```text
START_DELAY   = 1.800.000 ms  = 30 min
WAVE_INTERVAL =   120.000 ms  = 2 min
BLOCK_BREAK   =   600.000 ms  = 10 min
BATCH_INTERVAL=    20.000 ms  = 20 s
```

R1-R15:

```text
8 batches
cada spawn aparece exactamente una vez
orden aleatorio
20 s entre batches
```

Sólo existen descansos especiales después de:

```text
R5
R10
```

R15 ya no inicia un descanso largo.

## 30.8 Endless desde R16

Desde R16:

```text
16 batches
cada uno de los 8 spawns aparece exactamente dos veces
```

La composición base por batch contiene 50 unidades, por lo que una ronda endless normal despliega:

```text
50 × 16 = 800 unidades
```

El nivel es:

```text
20 + (round - 16)
```

con máximo:

```text
60
```

Cada cinco rondas a partir de R20 se añaden:

```text
+10 RHastatus
+10 TMaceman
```

por batch, elevando esa ronda especial a:

```text
70 × 16 = 1120 unidades
```

No existe `MAX_ROUNDS`: el bucle es endless hasta que el Easter Egg deshabilita los nuevos spawns.

## 30.9 Parada por portales

`ZombieWaves_Main` consulta repetidamente:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

Cuando el cuarto portal queda cerrado, `ZombieEE_Portals_Main` escribe:

```cpp
EnvWriteInt(
    state,
    "EE_ZOMBIE_SPAWNS_DISABLED",
    1
);
```

Waves detiene **nuevas apariciones**, pero no borra zombies ya existentes.

Después confirma su propia parada mediante:

```text
ZWAVES_STOPPED_BY_PORTALS = 1
```

## 30.10 Arquitectura de recompensas

R1-R15 utilizan:

```text
HW_R1..HW_R15
```

y esperan a que el Group de ronda quede vacío.

R16+ usa una arquitectura no bloqueante basada en generación:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_DEPLOYED_GENERATION
ZR_ENDLESS_REWARDED_GENERATION
ZR_ENDLESS_ROUND
ZR_ENDLESS_MASK
ZR_ENDLESS_PAIDMASK
```

La recompensa endless se autoriza cuando el despliegue completo de una generación ha sido confirmado; **no espera a `HW_R16.count == 0`**.

Este diseño elimina el bloqueo histórico causado por unidades residuales de asedio.

## 30.11 Máscaras de Players

Las recompensas usan una máscara de bits para representar qué Players eran objetivos de los ocho frentes.

Pesos:

```text
P1 = 1
P2 = 2
P3 = 4
P4 = 8
P5 = 16
P6 = 32
P7 = 64
P8 = 128
```

Waves construye la máscara después del despliegue y Rewards evita entregar dos veces la misma recompensa mediante `paidMask`.

## 30.12 Intro cinematográfica como punto de arranque

`ZombieIntro_Main` confirma una superficie de API de cinematográficas desde Sequence:

```cpp
BlockUserInput();
PlayMovie(Translate("movies\\ZombieIntro.avi"));
StartViewFollow(u_capitan);
StopViewFollow();
UnblockUserInput();
```

Además crea actores temporales con `Place()`, los mueve mediante `SetCommand("move",...)`, los detiene con:

```cpp
SetCommand("stand_position");
```

y los elimina con:

```cpp
Erase();
```

## 30.13 Conversations

La intro y los cinco diálogos del Easter Egg usan:

```cpp
Conversation conv;

conv.Init("ZombieEE_Conv01");
conv.SetActor("Capitan", u_capitan);
conv.SetActor("Sacerdote", u_sacerdote);
conv.Run();
```

La asignación de actores por nombre desacopla la definición textual de la Conversation de las Units concretas del mapa.

## 30.14 Estado centralizado en `CapitalForum_P1`

El Easter Egg usa un `Building` compartido como pizarra de estado:

```text
CapitalForum_P1
```

Sobre él se almacenan flags mediante:

```text
EnvReadInt
EnvWriteInt
```

Ejemplos:

```text
EE_FIRST_HORDE_READY
EE_PRIEST_PENDING
EE_DIALOGUE01_COMPLETED
EE_SACRIFICE_ENABLED
EE_SACRIFICE_COMPLETED
EE_ANUBIS_ATTACK_COMPLETED
EE_PORTALS_COMPLETED
EE_AMULET_DELIVERED
EE_FINAL_ASSAULT_COMPLETED
EE_COMPLETED
```

## 30.15 `EE_PRIEST_PENDING` como bus narrativo

El gestor permanente `ZombieEE_PriestInteraction_Main` interpreta:

```text
1 → ZombieEE_Dialogue01
2 → ZombieEE_Dialogue02
3 → ZombieEE_Dialogue03
4 → ZombieEE_Dialogue04
5 → ZombieEE_DialogueFinal
```

Una fase no lanza normalmente el diálogo directamente. Escribe un `pending` y el gestor exige que César se acerque físicamente al sacerdote a:

```text
DistTo <= 180
```

Antes de lanzar la Sequence del diálogo pone:

```text
EE_PRIEST_PENDING = 0
```

para evitar activaciones duplicadas.

## 30.16 Sacerdote persistente y ocultación temporal

`ZombieEE_PriestKeeper` mantiene al sacerdote con:

```cpp
SetNoAIFlag(true);
SetFeeding(false);
SetHealth(1000);
```

y corrige su posición si se aleja demasiado.

La desaparición narrativa utiliza:

```text
EE_PRIEST_HIDDEN = 1
```

antes de:

```cpp
RemoveFromGroup("ZombieEE_Priest01");
Erase();
```

La posición y propietario se guardan en:

```text
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
```

para poder recrearlo después del asalto final.

## 30.17 Fase de sacrificio

`ZombieEE_Sacrifice_Main` contabiliza la entrega de 50 almas mediante estado persistente:

```text
EE_SOULS_DELIVERED
```

Al llegar al objetivo:

```text
EE_SACRIFICE_ENABLED = 0
EE_SACRIFICE_COMPLETED = 1
```

y lanza:

```cpp
RunSequence("ZombieEE_AnubisAttack_Main");
```

## 30.18 Ataque especial de Anubis

La fase crea:

```text
50 EAnubisWarrior
Player 12
nivel 40
```

en `HordeSpawn_01`, los añade a:

```text
EE_AnubisWave01
```

y sólo reimpone `advance` a unidades que queden `idle`.

Al morir todos:

```text
EE_ANUBIS_ATTACK_COMPLETED = 1
EE_PRIEST_PENDING = 2
```

## 30.19 Portales

La fase reutiliza:

```text
HordeSpawn_01..08
```

como ocho posiciones de portal.

Un portal abierto se activa cuando un:

```text
RPriest de Player 1
```

entra a:

```text
<=220
```

Se generan:

```text
10 EAnubisWarrior
10 EHorusWarrior
nivel 20
Player 12
```

Tras matar a los 20, ese portal queda cerrado y se entrega dentro del Foro:

```text
20 RPraetorian
15 RHastatus
15 RArcher
nivel 25
```

mediante:

```cpp
state.settlement.ForceAddUnit(u);
```

Cerrar cuatro portales cualesquiera termina la fase y detiene nuevas hordas.

## 30.20 Campamento cartaginés / objetivo de Gem of Power

La v2.0 simplifica la mecánica anterior de objeto físico. `ZombieEE_Amulet_Main` documenta expresamente:

```text
NO existe Gem of power como objeto de inventario.
```

La fase crea un ejército cartaginés de 50 unidades encabezado por:

```text
CHero1
nivel 25
```

El resto del ejército queda a nivel 20.

El único requisito narrativo es matar al caudillo. Su Group exclusivo:

```text
ZombieEE_AmuletCarrier
```

permite detectar su muerte sin exigir eliminar al resto del ejército.

`EE_AMULET_DELIVERED` se conserva por compatibilidad semántica con Dialogue04, pero en esta versión significa:

```text
0 = caudillo vivo
1 = caudillo muerto / objetivo recuperado
```

## 30.21 Asalto final activo

`ZombieEE_Dialogue04` lanza:

```text
ZombieEE_FinalAssault_Run
```

no el antiguo `ZombieEE_FinalAssault_Main`.

La implementación activa genera:

```text
8 tandas × 25 = 200 unidades
```

con niveles:

```text
20, 26, 32, 38, 44, 50, 55, 60
```

Todas pertenecen a:

```text
Player 12
Group EE_FinalAssault
```

y reciben:

```cpp
SetCommand("advance", targetPos);
```

Sólo las unidades `idle` reciben de nuevo `advance`, de modo que `attack/engage` no se pisa continuamente.

## 30.22 Reaparición del sacerdote

Al quedar:

```text
EE_FinalAssault.count == 0
```

la Sequence reutiliza un sacerdote existente o crea:

```cpp
Place(
    "EPriest",
    priestPos,
    priestOwner
)
```

lo añade a:

```text
ZombieEE_Priest01
```

y escribe:

```text
EE_PRIEST_HIDDEN = 0
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_ASSAULT_ENABLED = 0
EE_PRIEST_PENDING = 5
```

## 30.23 Final y recompensas

`ZombieEE_DialogueFinal` concede cuatro campeones a Player 1:

```text
BVikingLord
GTridentWarrior
TValkyrie
RPraetorian
```

Todos:

```text
nivel 60
SetFeeding(false)
Group ZombieEE_FinalRewards
```

y reciben cuatro items mediante `AddItem()`:

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

El cierre definitivo escribe:

```text
EE_DIALOGUE_FINAL_COMPLETED = 1
EE_COMPLETED = 1
```

`EE_COMPLETED` permite que servicios persistentes como `ZombieEE_PriestKeeper` terminen su bucle.

## 30.24 Lecciones reutilizables de la v2.0

La arquitectura actual confirma varios patrones generales:

```text
1. Una Sequence puede actuar como servicio permanente.
2. RunSequence permite encadenar fases bajo demanda.
3. Un Building puede funcionar como memoria compartida entre Sequences.
4. IntArray permite estado indexado complejo dentro de una Sequence.
5. Groups dinámicos sirven como identidad de unidades generadas.
6. El gameplay puede separarse en productor, controlador táctico y consumidor de recompensas.
7. Un flag de generación evita bloquear un scheduler por unidades residuales.
8. La narrativa puede modelarse como máquina de estados con pending + proximidad física.
9. Cinemática, Conversation y gameplay pueden coexistir dentro del mismo runtime de Sequence.
10. Las Sequences largas deben refrescar Groups/handles después de esperas prolongadas cuando exista riesgo de que los objetos hayan muerto o sido recreados.
```

# 31. Catálogo canónico de IDs técnicos para `Place()`

Este capítulo fija una lista limpia de IDs que han sido contrastados mediante definiciones de clase,
tablas de IA y presencia real en BFHP. Sirve para evitar typos y nombres visibles de interfaz.

## 31.1 Lista principal

| Civilización | Nombre visible | ID técnico |
|---|---|---|
| Roma Imperial | Hastatus | `RHastatus` |
| Roma Imperial | Praetorian | `RPraetorian` |
| Roma Republicana | Hastatus | `RHastatus` |
| Roma Republicana | Tribune | `RTribune` |
| Germania | Maceman | `TMaceman` |
| Germania | Huntress | `THuntress` |
| Galia | Woman Warrior | `GWomanWarrior` |
| Galia | Axeman | `GAxeman` |
| Britania | Bronze Spearman | `BBronzeSpearman` |
| Britania | Highlander | `BHighlander` |
| Iberia | Defender | `IDefender` |
| Iberia | Elite Guard | `IEliteGuard` |
| Cartago | Noble | `CNoble` |
| Cartago | Berber Assassin | `CBerberAssassin` |
| Egipto | Guardian | `EGuardian` |
| Egipto | Anubis Warrior | `EAnubisWarrior` |

## 31.2 Roma Imperial y Republicana comparten prefijo `R`

No existe un prefijo de clase separado `IR`/`RR`.

Ejemplos:

```text
RHastatus
RPraetorian
RTribune
RArcher
RScout
```

La distinción de civilización se hace por la raza del jugador:

```text
ImperialRome
RepublicanRome
```

Por ello una Sequence que necesite decidir composición romana debe consultar `GetPlayerRace()`/la raza,
no intentar deducirla del prefijo del ID.

## 31.3 Clases fantasma que no deben usarse

| Correcta | Fantasma / typo | Regla |
|---|---|---|
| `BHighlander` | `BHighlandar` | usar `BHighlander` |
| `IDefender` | `IDefendar` | usar `IDefender` |
| `TValkyrie` | `TValkyria` | usar `TValkyrie` |
| `RLiberatus` | `RLiberatas` | usar `RLiberatus` |

Los duplicados fantasma no tienen el mismo nivel de evidencia de uso real y algunos contienen errores de
herencia como `parent="Melef"`.

## 31.4 Caso especial: Maceman cartaginés

Para Cartago existen dos nodos distintos:

```text
CMaceman
CMacemen
```

No deben tratarse automáticamente como un simple typo: aparecen en contextos diferentes del sistema de
unidades/mercenarios. Si una mecánica futura necesita “Maceman de Cartago”, hay que elegir según el
contexto técnico concreto.

## 31.5 Patrón de prueba

```cpp
Unit u;

u = Place(
    "TMaceman",
    Point(1000, 1000),
    owner
);

u.SetLevel(10);
```

`SetFeeding(false)` sólo debe añadirse si el diseño exige una unidad estructural que no consuma comida.
Para tropas normales o recompensas destinadas al jugador/IA, debe conservarse la alimentación estándar.

## 31.6 IDs adicionales confirmados por la compilación v2.0

Las 23 Sequences actuales amplían el catálogo de IDs usados directamente con `Place()`:

| ID | Uso v2.0 |
|---|---|
| `RPriest` | sacerdote romano temporal de la intro / activación de portales por clase |
| `EPriest` | sacerdote egipcio recreado tras el asalto final |
| `RVelit` | escolta de la intro |
| `RArcher` | recompensa por portal |
| `RLiberatus` | tropas Zombies / asalto final |
| `GTridentWarrior` | Zombies, asalto final y campeón final |
| `TValkyrie` | Zombies, asalto final y campeón final |
| `EHorusWarrior` | guardianes de portal / Zombies / asalto final |
| `CNumidianRider` | campamento cartaginés / Zombies |
| `CJavelinThrower` | campamento cartaginés |
| `CLibyanFootman` | intro y campamento cartaginés |
| `CWarElephant` | campamento cartaginés / endless / asalto final |
| `CHero1` | caudillo cartaginés de la fase Gem of Power |
| `BVikingLord` | campeón final |

La aparición de estos IDs en la compilación estable los convierte en referencias prácticas válidas para el proyecto actual.


## 31.7 Lista compacta

```text
ROMA IMPERIAL
RHastatus
RPraetorian

ROMA REPUBLICANA
RHastatus
RTribune

GERMANIA
TMaceman
THuntress

GALIA
GWomanWarrior
GAxeman

BRITANIA
BBronzeSpearman
BHighlander

IBERIA
IDefender
IEliteGuard

CARTAGO
CNoble
CBerberAssassin

EGIPTO
EGuardian
EAnubisWarrior
```


# 32. Cinemáticas, Conversations, anuncios y control de interfaz

La compilación v2.0 confirma un conjunto de APIs de presentación y narrativa directamente desde Sequences.

## 32.1 `BlockUserInput()` / `UnblockUserInput()`

Patrón canónico:

```cpp
BlockUserInput();

// cámara, movimiento o Conversation

UnblockUserInput();
```

Se utiliza en:

```text
ZombieIntro_Main
ZombieEE_Dialogue01
ZombieEE_Dialogue02
ZombieEE_Dialogue03
ZombieEE_Dialogue04
ZombieEE_DialogueFinal
```

Regla práctica: cualquier salida temprana posterior a un `BlockUserInput()` debe revisar si necesita ejecutar `UnblockUserInput()` antes de `return` para no dejar al jugador bloqueado.

## 32.2 Cámara: `StartViewFollow` y `StopViewFollow`

Uso confirmado:

```cpp
StartViewFollow(u_sacerdote);
Sleep(1000);
StopViewFollow();
```

También puede seguir a César durante una entrada/retirada cinematográfica:

```cpp
StartViewFollow(u_capitan);
```

La cámara puede detenerse sin desbloquear todavía el input; ambas capas son independientes.

## 32.3 Vídeo: `PlayMovie` + `Translate`

La intro utiliza:

```cpp
PlayMovie(
    Translate("movies\\ZombieIntro.avi")
);
```

Esto confirma `PlayMovie()` desde Sequence y el uso de `Translate()` sobre la ruta del recurso.

No debe inferirse de este único patrón la semántica completa de `Translate`; lo confirmado es que produce un argumento válido para `PlayMovie` en esta ruta.

## 32.4 `Conversation`

Patrón completo:

```cpp
Conversation conv;

conv.Init("ZombieEE_Conv03");
conv.SetActor("Capitan", u_capitan);
conv.SetActor("Sacerdote", u_sacerdote);
conv.Run();
```

La Conversation se identifica por nombre y los actores por etiquetas que deben coincidir con su definición.

La intro usa tres actores:

```text
Mensajero
Capitan
Sacerdote
```

Los diálogos del Easter Egg utilizan:

```text
Capitan
Sacerdote
```

## 32.5 Handles y Conversations largas

Una Conversation introduce una espera no trivial. Algunas Sequences v2.0 vuelven a obtener Groups después de `conv.Run()` antes de seguir actuando sobre objetos susceptibles de desaparecer.

Patrón recomendado cuando existe riesgo:

```text
conv.Run()
↓
Group(...).GetObjList()
↓
ClearDead()
↓
validar count
↓
volver a AsUnit()/AsBuilding()
```

No todas las Sequences actuales lo hacen de la misma manera, por lo que debe elegirse según el riesgo real de desaparición del actor.

## 32.6 `ShowAnnouncement(id,text)`

Uso confirmado:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "VE A HABLAR CON EL SACERDOTE EGIPCIO"
);
```

El primer argumento funciona como identificador/canal lógico del anuncio.

IDs usados en v2.0:

```text
ZombieCountdown
ZombieAlert
ZombieBreak
ZombieHelp
ZombieEEObjective
```

## 32.7 `HideAnnouncement(id)`

Uso:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

Permite retirar un anuncio persistente o sustituirlo limpiamente en una transición de fase.

## 32.8 Recordatorios por tiempo

`ZombieEE_PriestInteraction_Main` implementa un recordatorio sin crear otra Sequence:

```cpp
reminderAt = GetTime() + 15000;

if(GetTime() >= reminderAt)
{
    ShowAnnouncement(...);
    reminderAt = GetTime() + 15000;
}
```

Este patrón es reutilizable para objetivos periódicos o avisos no bloqueantes.

## 32.9 `UserNotification`

Firma observada:

```cpp
UserNotification(
    "Texto",
    "",
    point,
    player
);
```

Ejemplos v2.0:

```cpp
UserNotification(
    "HORDA ANIQUILADA - REFUERZOS RONDA " + roundNow,
    "",
    forum.pos,
    owner
);
```

La cuarta posición permite dirigir la notificación a un Player concreto. El significado completo del segundo string no está documentado; en el código actual se deja vacío.

## 32.10 `pr(...)`

Varias Sequences usan:

```cpp
pr("mensaje de debug");
```

Debe tratarse como salida de diagnóstico, no como UI para el jugador. Para mensajes de gameplay se prefieren `ShowAnnouncement` o `UserNotification`.

## 32.11 `Erase()` para actores temporales

La intro confirma:

```cpp
if(u.IsAlive())
    u.Erase();
```

Dialogue04 usa además:

```cpp
u_sacerdote.RemoveFromGroup(
    "ZombieEE_Priest01"
);

u_sacerdote.Erase();
```

Cuando un objeto forma parte de una arquitectura de Groups persistentes, conviene retirar primero su identidad lógica si otras Sequences consultan ese Group.

## 32.12 `stand_position`

La intro utiliza:

```cpp
u.SetCommand(
    "stand_position"
);
```

para detener a los actores antes de una Conversation.

Este comando queda confirmado desde Sequence.


# 33. Items, notificaciones y recompensas de unidades

## 33.1 `Unit.AddItem(itemName)`

La recompensa final v2.0 confirma:

```cpp
u.AddItem(
    "Fur gloves of health"
);
```

También:

```text
Concentration stone
King's belt
Elephant tusk
```

Por tanto `AddItem()` puede utilizarse directamente sobre una `Unit` creada por `Place()`.

## 33.2 Patrón de campeón equipado

```cpp
u = Place(
    "BVikingLord",
    Point(x, y),
    1
).AsUnit();

u.SetLevel(60);
u.SetFeeding(false);
u.AddItem("Fur gloves of health");
u.AddItem("Concentration stone");
u.AddItem("King's belt");
u.AddItem("Elephant tusk");
u.AddToGroup("ZombieEE_FinalRewards");
```

La misma combinación se utiliza para cuatro campeones.

## 33.3 IDs de items confirmados

| Nombre pasado a `AddItem()` | Estado |
|---|---|
| `Fur gloves of health` | confirmado v2.0 |
| `Concentration stone` | confirmado v2.0 |
| `King's belt` | confirmado v2.0 |
| `Elephant tusk` | confirmado v2.0 |

No debe asumirse que el nombre visible traducido de cualquier item sea automáticamente su identificador aceptado por `AddItem()`; los cuatro anteriores sí están probados por el código actual.

## 33.4 Recompensa idempotente

Antes de crear los campeones:

```cpp
if(
    EnvReadInt(
        state,
        "EE_REWARDS_SPAWNED"
    )
    !=
    1
)
```

Después de crearlos:

```cpp
EnvWriteInt(
    state,
    "EE_REWARDS_SPAWNED",
    1
);
```

Este patrón evita duplicar recompensas al reejecutar accidentalmente una fase.

## 33.5 Marcar antes o después de crear

Existen dos estrategias reales en la v2.0:

```text
marcar ANTES de crear
→ evita duplicados incluso si otra ejecución entra mientras se está generando
→ riesgo: una interrupción puede dejar recompensa parcial sin reintento
```

Ejemplo: recompensa individual de portal.

```text
marcar DESPUÉS de crear
→ permite completar toda la generación antes de registrar el éxito
→ requiere que la fase no pueda ejecutarse concurrentemente
```

Ejemplo: campeones finales.

La elección depende del riesgo dominante.

## 33.6 `UserNotification` para recompensas dirigidas

`ZombieRewards_Main` combina spawn con:

```cpp
UserNotification(
    "REFUERZOS RONDA " + roundNow,
    "",
    forum.pos,
    owner
);
```

Esto permite comunicar una recompensa únicamente al Player que la recibe, a diferencia de un anuncio global.

## 33.7 Recompensas dentro de Settlement

Cuando interesa evitar unidades atrapadas alrededor de un edificio:

```cpp
u = Place(
    rewardClass,
    state.pos,
    1
).AsUnit();

state.settlement.ForceAddUnit(u);
```

La fase de portales usa este patrón para insertar 50 unidades por portal dentro del Foro.


# 34. Estado compartido, `IntArray`, claves dinámicas y máquinas de estados

## 34.1 Dos niveles de estado

La v2.0 separa claramente:

```text
estado local de una Sequence
→ variables normales / IntArray

estado compartido entre Sequences
→ EnvReadInt / EnvWriteInt sobre CapitalForum_P1
```

Ejemplo táctico local:

```cpp
phase[H] = 2;
routePrev[node] = uNode;
```

Ejemplo compartido:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    3
);
```

## 34.2 `CapitalForum_P1` como state board

La arquitectura actual utiliza:

```text
CapitalForum_P1
```

como objeto compartido entre numerosos sistemas.

Ventajas:

```text
referencia estable
Env* asociado a un objeto real
acceso desde varias Sequences
sin necesidad de variables globales compartidas
```

## 34.3 Claves dinámicas confirmadas

Ejemplo de lectura:

```cpp
portalClosed[portal] =
    EnvReadInt(
        state,
        "EE_PORTAL_CLOSED" + portal
    );
```

Ejemplo de escritura:

```cpp
EnvWriteInt(
    state,
    "ZR_MASK" + w,
    roundMask
);
```

Esto permite familias de estados compactas.

## 34.4 Cuándo seguir usando claves literales

`ZombieTactical_Main` continúa leyendo varios estados con ramas explícitas:

```cpp
if(H == 1)
    active = EnvReadInt(state, "HW_ACTIVE1");

if(H == 2)
    active = EnvReadInt(state, "HW_ACTIVE2");
```

La forma literal sigue siendo útil cuando:

```text
los nombres no siguen exactamente un patrón
se quiere depuración explícita
se desea minimizar una regresión en código ya estable
```

## 34.5 `IntArray` como estado multiinstancia

Ejemplo:

```cpp
IntArray phase;
IntArray gateX;
IntArray gateY;
IntArray anchorNode;
IntArray targetNode;
IntArray goalNode;
```

Un único bucle puede gestionar:

```cpp
for(H = 1; H <= 8; H += 1)
```

y mantener estado independiente por frente.

## 34.6 `IntArray` como matriz dispersa

`edgeW` demuestra un segundo patrón: codificar una matriz en un índice entero.

La red de 18 nodos guarda pesos de aristas mediante posiciones como:

```cpp
edgeW[22]  = 6541;
edgeW[41]  = 6541;
edgeW[133] = 7612;
```

La codificación concreta pertenece al algoritmo de `ZombieTactical_Main`, pero el patrón general permite implementar tablas/matrices sin una sintaxis multidimensional.

## 34.7 Flags de `started`, `enabled`, `completed`

Varias fases usan el patrón:

```text
ENABLED
STARTED
COMPLETED
```

Ejemplo:

```text
EE_FINAL_ASSAULT_ENABLED
EE_FINAL_ASSAULT_STARTED
EE_FINAL_ASSAULT_COMPLETED
```

Ventajas:

```text
ENABLED
→ controla si la fase puede ejecutarse

STARTED
→ evita doble spawn concurrente

COMPLETED
→ impide repetir una fase ya terminada
```

## 34.8 Reconstruir contadores desde flags individuales

`ZombieEE_Portals_Main` no confía únicamente en:

```text
EE_PORTALS_CLOSED
```

Al arrancar reconstruye el total desde:

```text
EE_PORTAL_CLOSED1..8
```

Este patrón es más robusto ante una carga/interrupción que dejar un contador global como única fuente de verdad.

## 34.9 Generaciones en schedulers no bloqueantes

El sistema endless separa:

```text
generación creada
última generación desplegada
última generación recompensada
```

mediante:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_DEPLOYED_GENERATION
ZR_ENDLESS_REWARDED_GENERATION
```

Esto evita que la siguiente ronda dependa de la desaparición física de todos los miembros del Group anterior.

Es un patrón reutilizable para cualquier sistema donde puedan quedar objetos residuales legítimos.

## 34.10 Refresco de handles después de esperas largas

Una Sequence puede conservar un `Unit` o `Building`, pero tras:

```text
Sleep largos
Conversation
combates
Erase/Recreate en otra Sequence
```

conviene volver a obtener el Group si el objeto puede haber desaparecido.

Patrón:

```cpp
stateList = Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count != 1)
    return;

state = stateList[0].AsBuilding();
```

La v2.0 aplica este patrón en varias transiciones largas del Easter Egg y de recompensas.

## 34.11 Un Group especial como snapshot narrativo

`EE_FirstHorde_Spawn01` demuestra que un Group puede representar un conjunto único que no volverá a rellenarse.

Para evitar confundir:

```text
vacío porque todavía no se creó
```

con:

```text
vacío porque ya murió todo
```

Waves escribe primero:

```text
EE_FIRST_HORDE_READY = 1
```

El trigger sólo empieza a interpretar `count == 0` después de ese flag.

Este patrón es especialmente útil en triggers de una sola vez.

## 34.12 Bus narrativo mediante entero

`EE_PRIEST_PENDING` demuestra una máquina de estados compacta:

```text
0 = nada pendiente
1 = Dialogue01
2 = Dialogue02
3 = Dialogue03
4 = Dialogue04
5 = DialogueFinal
```

La Sequence consumidora borra el valor **antes** de lanzar la siguiente fase:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    0
);
```

Esto evita ejecuciones duplicadas entre ciclos consecutivos.


# Estado del manual

Esta versión integra:

- los 17 capítulos iniciales de `docs/manual/`;
- la compilación estable v2.0 de 03/09/2026 con sus 23 Sequences actuales;
- la investigación experimental de viabilidad de guarniciones;
- las fases 2 y 3 de ingeniería inversa de fortalezas;
- la investigación de Townhall/Foros neutrales;
- la investigación profunda de rosters para recompensas territoriales;
- la investigación exhaustiva de `GGuardPost`;
- la investigación de `HordeWaves_Main`;
- la reconstrucción de `Settlement.loyalty` y `unit_capture.vs`;
- la investigación de Gates, catapultas, `RamUnit` y `ObjList.Siege()`;
- la reconstrucción de las capas de IA nativa de conquista;
- `GS_Siege.vs`, `GetGAIKAStrat.vs`, `AI.INI` y los estados `SS_*`;
- las firmas reales de `RunAIHelper(...,"siege",...)` y `RunAIHelper(...,"siege gate",...)`;
- la mecánica oficial de tropas auxiliares de Outposts (`Units`/`InHolder`/`enter_tent`/`GetCommanded`);
- la forénsica de formatos HPFS, HMMSYS PackFile, LZIS y logs `vx.log`;
- la arquitectura canónica v2.0 de Zombies: 8 frentes persistentes, red de 18 nodos, R1-R15 + endless R16+, recompensas por generación y parada por cuatro portales;
- el Easter Egg completo coordinado mediante `RunSequence`, `EE_PRIEST_PENDING`, Conversations y estado persistente;
- las APIs v2.0 de cinematográfica (`PlayMovie`, cámara, bloqueo de input), anuncios, `UserNotification` y `AddItem`;
- el catálogo canónico de IDs técnicos de unidades para `Place()`.

Los hallazgos más importantes incorporados en esta revisión son:

```text
Place() confirmado en Sequences oficiales
SetNoAIFlag() confirmado en guarniciones oficiales
patrón real de regeneración con Place()
arquitectura completa de TTent
18 configuraciones reales de Outpost controlado por Sequence
GGuardPost = Outpost con max_units=0 + 12 sentinelas hardcodeados
GGuardPost mata y recrea sentinelas al cambiar de dueño
IntArray confirmado tanto en scripts de motor como en Sequences v2.0
Forum = familia Townhall, no clase “Forum”
unit_capture.vs recuperado
DecreaseLoyalty(1) confirmado
Townhall capturado: SetPlayer(atacante) + SetLoyalty(11)
corrección: player 9-16 sí puede capturar Townhall si ejecuta capture
SetLoyalty(0) no transfiere por sí solo sin una unidad en capture
LoyaltyRadiusTownhall = 850
Gate = BaseBuilding → Building
Catapult = Building, RamUnit = Military
BCatapultUnit / TCatapultUnit = únicos arietes-Unit encontrados
PlaceCatapult() + build_catapult confirmados
ObjList.Siege(target,n,param) confirmado en Sequence contra Gates
attack / enter / capture confirmados contra Building
BestGate / InvadeThroughGate / GotoEnter = engine-only directos
RunAIHelper("siege") confirmado: SettlementName → BestGate interno → Siege → IsBroken → advance/capture
RunAIHelper("siege gate") confirmado: GateName → gather → Siege/reposición → IsBroken → avance final
GS_Siege contiene SS_Siege / SS_Enter / SS_Capture; GS_EnterSettlement NO es la fase de invasión enemiga
Gate.IsBroken es el umbral real usado por los helpers, no IsAlive()==false
patrón bSieging/bCat confirmado para reconstruir asedio perdido
no existe API pública AIPlayer.AttackSettlement
modelo de tres capas: subAI → AI Helpers → IA estratégica
Outpost auxiliares: Units + advance + InHolder + enter_tent + GetCommanded confirmados en campañas
HPFS / HMMSYS PackFile / LZIS y vx.log documentados
arquitectura Zombies v2.0: ZombieWaves_Main + ZombieTactical_Main + ZombieRewards_Main
8 frentes persistentes HW_H1..8; eliminados los antiguos 24/48 slots
IntArray confirmado dentro de Sequences
EnvReadInt con claves dinámicas confirmado en v2.0
Groups calculados dinámicamente confirmados en Fortresses/OutpostAuxDefense
red táctica de 18 nodos implementada con IntArray y ruta Dijkstra-like
R16+ endless no bloqueante por generaciones
RunSequence confirmado como orquestador de fases del Easter Egg
Conversation.Init / SetActor / Run confirmados
BlockUserInput / UnblockUserInput confirmados
StartViewFollow / StopViewFollow confirmados
PlayMovie(Translate(path)) confirmado en ZombieIntro_Main
ShowAnnouncement / HideAnnouncement / UserNotification confirmados
Unit.AddItem confirmado en recompensas finales
SetCommand("stand_position") confirmado en cinemática
Erase + RemoveFromGroup usados para ocultación/recreación de actor persistente
```

### Correcciones canónicas introducidas en esta revisión

1. **Townhall y `TTent` no comparten la misma regla de nuevo propietario.**
   El filtro `new_player > 8` de `TTent` no existe en la rama normal de `unit_capture.vs`.

2. **`advance` no es una orden de asedio.**
   No debe esperarse que ataque automáticamente una Gate por bloquear el camino.

3. **`Catapult` no es una unidad.**
   Es un `Building`; los arietes móviles son `RamUnit`.

4. **`IntArray` está confirmado también en Sequences.**
   `ZombieTactical_Main` y `ZombieEE_Portals_Main` lo utilizan directamente en la compilación estable v2.0.

5. **La fórmula básica de captura de Townhall ya no es una incógnita.**
   Se recuperó el bucle que decrementa loyalty y transfiere el Settlement.

6. **La IA nativa no se invoca con una única orden estratégica pública.**
   Su ventaja procede de capas internas y de estados de asedio/entrada/captura.

7. **`IntArray` sí funciona desde Sequence.**
   `ZombieTactical_Main` y `ZombieEE_Portals_Main` lo utilizan en la compilación estable.

8. **Las claves dinámicas de `EnvReadInt` sí funcionan en v2.0.**
   Existen lecturas reales como `"EE_PORTAL_CLOSED" + portal` y `"ZR_PAIDMASK" + roundNow`.

9. **El prototipo de 24/48 slots queda obsoleto.**
   La arquitectura canónica usa ocho frentes persistentes y un scheduler endless por generaciones.

A partir de aquí, los siguientes informes deben seguir integrándose en **este mismo manual**.

La regla editorial se mantiene:

1. ampliar secciones existentes cuando el hallazgo pertenezca a un concepto ya documentado;
2. crear un capítulo nuevo sólo si introduce un subsistema realmente distinto;
3. marcar expresamente las conclusiones antiguas que hayan sido superadas;
4. mantener separados:
   - hecho confirmado;
   - evidencia parcial;
   - inferencia;
   - decisión de diseño del proyecto.

# Manual técnico de scripting de Imperivm III

Manual unificado generado a partir de los capítulos de `docs/manual/`.

---

# 1. Introducción a CKS/VS

Imperivm III utiliza scripts `.vs`/CKS para definir comportamientos de unidades, edificios, escenarios y Sequences.

En el editor de escenarios, una Sequence permite ejecutar lógica programada sobre objetos del mapa.

Ejemplo mínimo:

```cpp
while (1)
{
    Sleep(1000);
}
```

La sintaxis recuerda a C/C++, pero no debe asumirse que sea C++ completo. CKS dispone de sus propios tipos, funciones, métodos y restricciones.

## Principio de trabajo

En este proyecto se considera una función o patrón fiable cuando existe al menos una de estas evidencias:

- compilación y prueba directa en el editor;
- uso literal en una Sequence real;
- uso literal en un script nativo `.vs`;
- definición recuperada de los datos del juego.

## Estructura típica

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

## Scripts nativos y Sequences

No son exactamente el mismo contexto.

Una llamada observada en un script nativo demuestra que forma parte del lenguaje/sistema, pero no siempre garantiza que sea invocable de la misma forma desde una Sequence.

Por ello la documentación separa, cuando es necesario:

- uso confirmado en Sequence;
- uso confirmado en scripts nativos;
- comportamiento inferido a partir de archivos de clase.


---

# 2. Editor: Sequences y Groups

## Crear una Sequence

En el árbol del editor:

```text
Scenario
└── Map
    └── Sequences
```

1. Crear una nueva Sequence.
2. Asignar un nombre.
3. Abrir `Source`.
4. Pegar el código.
5. Activar `Autorun allowed` si debe ejecutarse automáticamente.
6. Pulsar `Compile`.
7. Guardar el escenario.

## Errores de compilación

El editor muestra en la parte inferior el primer error encontrado.

Es importante distinguir entre el tipo estático de una expresión y el tipo real del objeto.

Ejemplo:

```cpp
ObjList units;
units = fort.settlement.Units();
```

`units[j]` es un `Obj`.

Para llamar a un método específico de `Unit`:

```cpp
units[j].AsUnit().InHolder()
```

## Crear un Group

En:

```text
Scenario
└── Map
    └── Groups
```

un Group permite reunir objetos del mapa bajo un nombre.

Acceso:

```cpp
ObjList objects;

objects =
    Group("MiGrupo")
    .GetObjList();
```

## Groups dinámicos

Un objeto puede añadirse a un grupo desde código:

```cpp
u.AddToGroup("MiGrupoDinamico");
```

El grupo puede recuperarse más tarde:

```cpp
Group("MiGrupoDinamico").GetObjList();
```

Esto permite identificar guarniciones, auxiliares o estados sin crear manualmente cientos de Groups.


---

# 3. Objetos, clases y herencia

Las entidades del juego se organizan por clases.

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

## `IsHeirOf`

Permite comprobar herencia:

```cpp
if (fort.IsHeirOf("EOutpost"))
{
    // lógica egipcia
}
```

También es útil para clasificar unidades:

```cpp
if (obj.IsHeirOf("Military"))
{
    // unidad militar
}
```

## Conversión de tipo

Un `ObjList` contiene `Obj`.

Según el uso puede ser necesario convertir:

```cpp
Building fort;
fort = objects[i].AsBuilding();
```

o:

```cpp
Unit u;
u = objects[i].AsUnit();
```

## Clases de Outpost usadas

```text
TOutpost  Germania
GOutpost  Galia
BOutpost  Britania
IOutpost  Iberia
COutpost  Cartago
ROutpost  Roma
EOutpost  Egipto
GGuardPost Guard Post especial
```

`GGuardPost` también hereda de `Outpost`, pero sustituye parte importante del comportamiento normal mediante propiedades y scripts propios.


---

# 4. Obj, Unit, Building y Settlement

## `Obj`

Tipo genérico usado por listas y consultas.

Propiedades/métodos comunes observados:

```cpp
obj.player
obj.pos
obj.IsHeirOf("...")
obj.AddToGroup("...")
obj.RemoveFromGroup("...")
```

## `Unit`

Conversión:

```cpp
Unit u;
u = obj.AsUnit();
```

Operaciones utilizadas:

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

## `Building`

Conversión:

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

## `Settlement`

Los Outposts disponen de un Settlement asociado.

Operaciones importantes:

```cpp
fort.settlement.Units()
fort.settlement.UnitsCount()
fort.settlement.ForceAddUnit(u)
fort.settlement.SetLoyalty(100)
fort.settlement.AllowCapture(false)
```

`GGuardPost` es una excepción importante porque su clase fija `max_units="0"`, de modo que no debe tratarse como almacén de tropas normal.


---

# 5. Query y ObjList

## `Query`

Se utiliza para construir selecciones de objetos.

Ejemplo de enemigos:

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

## `ObjList`

Conversión:

```cpp
ObjList enemies;

enemies =
    qEnemies
    .GetObjList();

enemies.ClearDead();
```

Operaciones usadas:

```cpp
list.count
list[i]
list.Clear()
list.ClearDead()
list.Add(obj)
list.AddList(otherList)
list.Contains(obj)
```

## `ClassPlayerObjs`

Ejemplo:

```cpp
ObjList forts;

forts =
    ClassPlayerObjs(
        "TOutpost",
        15
    )
    .GetObjList();
```

En los sistemas universales se consulta la misma clase para distintos jugadores para conservar referencias incluso después de cambios de propietario.


---

# 6. Comandos de unidades

Los comandos se envían con:

```cpp
unit.SetCommand("comando", argumento);
```

## `advance`

Movimiento ofensivo:

```cpp
defender.SetCommand(
    "advance",
    enemy.pos
);
```

Se utiliza para sacar defensores y dirigirlos hacia una amenaza.

## `move`

Movimiento normal:

```cpp
defender.SetCommand(
    "move",
    fort.pos
);
```

## `attack`

Aparece en scripts nativos, especialmente en sentinelas:

```cpp
sentry.SetCommand(
    "attack",
    target
);
```

## `enter_tent`

Entrada en un holder/Outpost:

```cpp
defender.SetCommand(
    "enter_tent",
    fort
);
```

Este comando es fundamental para devolver guarniciones o auxiliares al edificio.

## Reimposición de órdenes

En una guarnición obligatoria puede ser útil reimponer la orden periódicamente.

En tropas normales del jugador no debe hacerse, porque impediría que el jugador recupere el control.

Esta diferencia es la base de `Fortresses_Main` frente a `OutpostAuxDefense_Main`.


---

# 7. Groups y estado persistente

## Groups como identidad

Los Groups dinámicos permiten mantener asociaciones entre objetos.

Ejemplo de guarnición única por fortaleza:

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
garrison =
    Group(groupName)
    .GetObjList();
```

Eliminar:

```cpp
u.RemoveFromGroup(groupName);
```

## Estado persistente con `EnvReadInt` / `EnvWriteInt`

Guardar:

```cpp
EnvWriteInt(
    fort,
    "FG_Regen",
    0
);
```

Leer:

```cpp
regenClock =
    EnvReadInt(
        fort,
        "FG_Regen"
    );
```

Esto permite mantener variables individuales por edificio sin arrays ni una Sequence por fortaleza.

Usos del proyecto:

- inicialización;
- reloj de regeneración;
- propietario esperado;
- alternancia entre pools;
- flags de recompensa;
- temporizadores de ausencia de enemigos.


---

# 8. Outposts y fortalezas

## Base `Outpost`

La investigación de `data.pak` muestra que `Outpost` es una clase de edificio capturable con Settlement.

Los Outposts culturales heredan de ella y añaden propiedades específicas.

## Variantes

```text
GOutpost
TOutpost
BOutpost
IOutpost
COutpost
ROutpost
EOutpost
```

Cada cultura puede definir:

- clases de defensor;
- máximos;
- niveles iniciales/finales;
- recursos;
- comportamientos adicionales.

## Guarnición universal

`Fortresses_Main` no depende de una Sequence por Outpost.

Descubre todas las estructuras y crea una identidad dinámica para cada una.

## Dos pools

Algunas guarniciones utilizan dos tipos:

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

Cada pool mantiene su propio máximo, y la regeneración puede alternar entre ambos.

## Neutralidad y primera conquista

Para los Outposts cuya lógica neutral nativa ya es útil, la Sequence evita intervenir hasta que el edificio cambia por primera vez a un jugador 1..8.

`EOutpost` requiere tratamiento especial por su comportamiento de captura.


---

# 9. `GGuardPost` y sentinelas

## Definición

La clase recuperada de `data.pak` muestra:

```xml
<class id="GGuardPost" cpp_class="CVXOutpost" parent="Outpost">
```

y propiedades relevantes:

```text
max_units = 0
range = 1000
```

Además utiliza:

```text
data/subai/GGuardPost_Sentries.vs
```

## Sistema propio de 12 sentinelas

El script mantiene:

```text
s0 ... s11
```

con posiciones relativas fijas alrededor del edificio.

Cada sentinela se crea mediante una clase de la forma:

```text
<raza>GuardPostSentry
```

## Regeneración

Si un sentinela deja de ser válido, el script lo vuelve a crear en el siguiente ciclo.

## Cambio de propietario

El script detecta que:

```text
.player() != pNumber
```

y elimina los sentinelas anteriores antes de crear nuevos para el propietario actual.

## Nivel

El script utiliza:

```text
sentriesLevel
```

almacenado con `EnvReadInt`/`EnvWriteInt` y aumenta progresivamente el nivel hasta un máximo observado de 36.

## Diferencia frente al sistema de muros

`GGuardPost` no usa el mismo mecanismo que `AddMaxSentries()` de puertas/murallas.

Sus 12 posiciones están codificadas directamente en su comportamiento propio.


---

# 10. Captura, loyalty y control territorial

## `SetLoyalty`

Ejemplo:

```cpp
fort.settlement.SetLoyalty(100);
```

Se utiliza para estabilizar el Settlement cuando la Sequence controla explícitamente el cambio de propietario.

## `SetPlayer`

```cpp
fort.SetPlayer(newOwner);
```

Permite transferir un edificio desde script.

## `AllowCapture`

En Settlements compatibles:

```cpp
fort.settlement.AllowCapture(false);
```

o:

```cpp
fort.settlement.AllowCapture(true);
```

## Posición disputada

El sistema de fortalezas distingue entre destruir la guarnición y controlar el terreno.

Se detectan tropas propias:

```cpp
qFriends =
    Intersect(
        qRange,
        Union(
            ClassPlayerObjs("Military", queryOwner),
            ClassPlayerObjs("BaseMage", queryOwner)
        )
    );
```

Captura:

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

Esto permite que un ejército de campaña continúe defendiendo un Outpost aunque la guarnición especial haya sido aniquilada.


---

# 11. Creación dinámica de unidades

## `Place`

Patrón básico:

```cpp
Unit u;

u = Place(
    "TValkyrie",
    fort.pos,
    owner
);
```

También puede utilizar coordenadas construidas:

```cpp
u = Place(
    "RHastatus",
    Point(spawnX, spawnY),
    owner
);
```

## Configuración posterior

```cpp
u.SetLevel(20);
u.SetFood(20);
```

Para guarniciones:

```cpp
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

Para ejércitos normales no se aplican esas dos llamadas.

## `ForceAddUnit`

Cuando el edificio admite unidades:

```cpp
fort.settlement.ForceAddUnit(u);
```

## Posiciones

En Sequences se ha usado `Point(x,y)` directamente como valor de coordenada.

Para cálculos complejos es más seguro mantener `x` e `y` en variables enteras y construir `Point(...)` en la llamada que lo necesite.

## Formaciones

Las recompensas militares utilizan offsets para evitar que todas las unidades aparezcan en el mismo punto.


---

# 12. IA y control de unidades

## `SetNoAIFlag(true)`

Usado para unidades que deben pertenecer a una estructura y no convertirse en parte del ejército estratégico de la IA.

Ejemplo:

```cpp
u.SetNoAIFlag(true);
```

Se usa en:

- guarniciones de `Fortresses_Main`;
- guardianes externos de `GuardPosts_Main`.

No se usa en:

- tropas auxiliares normales del jugador;
- ejércitos de recompensa.

## `SetFeeding(false)`

Evita que una unidad dependa del sistema normal de alimentación.

Adecuado para guarniciones persistentes:

```cpp
u.SetFood(20);
u.SetFeeding(false);
```

No debe usarse si se desea que el ejército funcione con las reglas normales.

## Control estricto frente a control temporal

### Guarnición

Se pueden reimponer órdenes cada intervalo:

```cpp
defender.SetCommand(
    "advance",
    enemy.pos
);
```

### Auxiliar

Se da una orden inicial y después se permite al jugador intervenir.

`GetCommanded()` aparece como mecanismo útil para detectar intervención manual en unidades.


---

# 13. Limitaciones estratégicas observadas

Este capítulo recoge limitaciones funcionales que motivaron el desarrollo del proyecto.

## Fortalezas

En mapas grandes, la lógica original ofrece una utilización limitada de los Outposts como red defensiva territorial:

- gestión defensiva poco persistente;
- reducido aprovechamiento estratégico por parte de la IA;
- falta de una lógica avanzada de posición disputada;
- poca coordinación entre tropas almacenadas y defensa del edificio.

Las Sequences del proyecto amplían estos comportamientos sin modificar el ejecutable.

## Agua y navegación

El mapa puede contener:

- grandes masas de agua;
- puertos;
- barcos;
- zonas aptas para transporte naval.

Sin embargo, durante el diseño se ha observado una utilización estratégica muy limitada de estos sistemas por la IA, especialmente comparada con el movimiento terrestre.

Esto restringe el valor práctico de:

- rutas marítimas;
- desembarcos;
- puertos como nodos estratégicos;
- transporte militar por mar.

## `GGuardPost`

Su diseño nativo limita el almacenamiento:

```text
max_units = 0
```

pero ofrece un comportamiento defensivo propio mediante 12 sentinelas.

El proyecto aprovecha esta característica para darle un papel diferenciado como puesto fronterizo.


---

# 14. Patrones reutilizables

## Descubrir objetos por clase y jugador

```cpp
ObjList objects;

objects =
    ClassPlayerObjs(
        "TOutpost",
        15
    )
    .GetObjList();
```

## Iterar un `ObjList`

```cpp
for (i = 0; i < objects.count; i += 1)
{
    // objects[i]
}
```

## Convertir a `Building`

```cpp
Building fort;

fort =
    objects[i]
    .AsBuilding();
```

## Convertir a `Unit`

```cpp
Unit u;

u =
    objects[i]
    .AsUnit();
```

## Grupo dinámico por coordenadas

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

## Crear una unidad

```cpp
u = Place(
    "IDefender",
    fort.pos,
    owner
);
```

## Guarnición sin hambre

```cpp
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
```

## Detectar enemigos en radio

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

## Limpiar muertos

```cpp
units.ClearDead();
```

## Estado persistente

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

## Entrada en edificio

```cpp
u.SetCommand(
    "enter_tent",
    fort
);
```

## Defensa temporal de tropas almacenadas

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


---

# 15. Referencia de funciones y métodos

Esta tabla recopila las funciones y métodos empleados o encontrados durante la investigación.

| Nombre | Receptor/ámbito | Uso |
|---|---|---|
| `Sleep(ms)` | global | pausa la ejecución de la Sequence |
| `Place(class,pos,player)` | global | crea un objeto/unidad |
| `ClassPlayerObjs(class,player)` | global | obtiene objetos de una clase y jugador |
| `EnemyObjs(player,class)` | global | consulta objetos enemigos |
| `ObjsInRange(obj,class,range)` | global | consulta objetos dentro de un radio |
| `Intersect(a,b)` | global/Query | intersección de consultas |
| `Union(a,b)` | global/Query | unión de consultas |
| `Subtract(a,b)` | global/Query | resta de consultas |
| `Group(name)` | global | accede a un Group |
| `EnvReadInt(obj,key)` | global | lee estado entero persistente |
| `EnvWriteInt(obj,key,value)` | global | escribe estado entero persistente |
| `GetPlayerRace(player)` | global | obtiene la raza asociada al jugador |
| `GetRaceStrPref(race)` | global | obtiene prefijo de raza utilizado por scripts nativos |
| `AsUnit()` | `Obj` | convierte referencia a `Unit` |
| `AsBuilding()` | `Obj` | convierte referencia a `Building` |
| `IsHeirOf(class)` | `Obj` | comprueba herencia de clase |
| `AddToGroup(name)` | `Obj` | añade objeto a grupo |
| `RemoveFromGroup(name)` | `Obj` | elimina objeto de grupo |
| `RemoveFromAllGroups()` | `Obj` | elimina objeto de todos sus grupos |
| `SetPlayer(player)` | `Obj`/`Unit`/`Building` | cambia propietario |
| `SetHealth(value)` | `Obj`/`Unit` | modifica salud |
| `Damage(value)` | `Obj`/`Unit` | aplica daño |
| `SetLevel(level)` | `Unit` | fija nivel |
| `SetFood(value)` | `Unit` | fija comida |
| `SetFeeding(bool)` | `Unit` | activa/desactiva alimentación |
| `SetNoAIFlag(bool)` | `Unit` | excluye/incluye de gestión estratégica de IA |
| `SetCommand(cmd,arg)` | `Unit` | asigna orden |
| `GetCommanded()` | `Unit` | detecta estado de orden/intervención usado en scripts |
| `InHolder()` | `Unit` | indica si está dentro de un holder |
| `DistTo(obj)` | `Obj`/`Building` | distancia entre objetos |
| `Units()` | `Settlement` | lista de unidades contenidas |
| `UnitsCount()` | `Settlement` | número de unidades contenidas |
| `ForceAddUnit(unit)` | `Settlement` | fuerza incorporación de una unidad |
| `SetLoyalty(value)` | `Settlement` | modifica lealtad |
| `AllowCapture(bool)` | `Settlement` | habilita/deshabilita captura |
| `AddMaxSentries(n)` | `Settlement` | modifica capacidad de sentinelas del sistema de murallas |
| `AddSentries(n)` | `Settlement` | añade sentinelas en sistema compatible |
| `GetObjList()` | `Query`/`Group` | convierte resultado en `ObjList` |
| `Clear()` | `ObjList` | vacía lista |
| `ClearDead()` | `ObjList` | elimina referencias muertas |
| `Add(obj)` | `ObjList` | añade objeto |
| `AddList(list)` | `ObjList` | añade otra lista |
| `Contains(obj)` | `ObjList` | comprueba pertenencia |

## Comandos de `SetCommand` documentados

| Comando | Uso observado |
|---|---|
| `"advance"` | avanzar hacia un punto combatiendo |
| `"move"` | desplazamiento |
| `"attack"` | ataque a objetivo |
| `"enter_tent"` | entrar en holder/edificio |

La referencia debe ampliarse únicamente con nombres encontrados en archivos reales o verificados en el editor.


---

# 16. Referencia de clases y unidades

## Outposts

| ID | Referencia |
|---|---|
| `TOutpost` | Outpost germano |
| `GOutpost` | Outpost galo |
| `BOutpost` | Outpost britano |
| `IOutpost` | Outpost íbero |
| `COutpost` | Outpost cartaginés |
| `ROutpost` | Outpost romano |
| `EOutpost` | Outpost egipcio |
| `GGuardPost` | Guard Post |

## Categorías genéricas

| ID | Referencia |
|---|---|
| `Unit` | unidad genérica |
| `Military` | unidad militar |
| `BaseMage` | clase base de unidades mágicas/héroes relacionados |
| `Sentry` | sentinela |
| `Building` | edificio |
| `Catapult` | categoría usada para catapultas/asedio |

## Roma

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

## Germania

| ID | Unidad |
|---|---|
| `TMaceman` | Maceman |
| `THuntress` | Huntress |
| `TArcher` | Archer |
| `TTeutonRider` | Teuton Rider |
| `TValkyrie` | Valkyrie |
| `THero1` | héroe germano |

## Galia

| ID | Unidad |
|---|---|
| `GWomanWarrior` | Woman Warrior |
| `GAxeman` | Axeman |
| `GArcher` | Archer |
| `GHorseman` | Horseman |
| `GTridentWarrior` | Trident Warrior / Fand |
| `GHero1` | héroe galo |

## Britania

| ID | Unidad |
|---|---|
| `BBronzeSpearman` | Bronze Spearman |
| `BHighlander` | Highlander |
| `BBowman` | Bowman |
| `BJavelineer` | Javelineer |
| `BHero1` | héroe britano |

No se encontró una clase de caballería britana en la investigación del roster utilizada para los ejércitos de recompensa.

## Iberia

| ID | Unidad |
|---|---|
| `IDefender` | Defender |
| `IEliteGuard` | Elite Guard |
| `ISlinger` | Slinger |
| `IMilitiaman` | Militiaman |
| `ICavalry` | Cavalry |
| `IHero1` | héroe íbero |

## Cartago

| ID | Unidad |
|---|---|
| `CLibyanFootman` | Libyan Footman |
| `CJavelinThrower` | Numidian Javelin Thrower |
| `CBerberAssassin` | Berber Assassin |
| `CNoble` | Noble |
| `CNumidianRider` | Numidian Rider |
| `CMacemen` | guerrero con maza usado por el Outpost |
| `CHero1` | héroe cartaginés |

## Egipto

| ID | Unidad |
|---|---|
| `EGuardian` | Guardian |
| `EArcher` | Archer |
| `EAxetrower` | Axe Thrower |
| `EAnubisWarrior` | Anubis Warrior |
| `EHorusWarrior` | Horus Warrior |
| `EChariot` | Chariot |
| `EHero1` | héroe egipcio |

`EChariot` funciona como unidad móvil equivalente a caballería, aunque su clase base investigada no sea `Horse`.

## Sentinelas de Guard Post

El script nativo construye la clase mediante un prefijo de raza:

```text
<PrefijoRaza>GuardPostSentry
```

Ejemplo:

```text
GGuardPostSentry
```


---

# 17. Metodología de investigación

La documentación no se construyó únicamente a partir de prueba y error en el editor.

Se combinaron varias fuentes.

## 1. Inspección de `Packs\data.pak`

Se buscaron definiciones de clases y fragmentos de scripts.

Elementos de interés:

```xml
<class id="...">
<properties ...>
<behavior script="...">
<method ...>
```

Esto permite conocer:

- herencia;
- `cpp_class`;
- `entity`;
- propiedades;
- scripts de comportamiento;
- nombres técnicos de unidades;
- relaciones entre edificios y sistemas internos.

## 2. Inspección de mapas `.BFHP`

Se buscaron cadenas literales dentro de escenarios reales.

Ejemplos:

```text
Place(
SetCommand(
ClassPlayerObjs(
AllowCapture(
AddMaxSentries(
EnvReadInt(
EnvWriteInt(
```

El objetivo es comprobar si una función aparece dentro de una Sequence real.

## 3. Comparación de mapas

Se revisaron:

- escenarios;
- aventuras;
- conquistas;
- mapas comunitarios disponibles;
- el escenario en desarrollo.

La repetición de un patrón en distintos BFHP permite aumentar la confianza en su uso.

## 4. Pruebas en editor

Las funciones más importantes se verificaron compilando y probando pequeñas Sequences.

Ejemplos ya empleados en el proyecto:

```cpp
Place(...)
SetFeeding(false)
SetPlayer(...)
SetNoAIFlag(true)
ForceAddUnit(...)
SetCommand(...)
```

## 5. Investigación de scripts nativos

El análisis de `GGuardPost_Sentries.vs` permitió reconstruir el funcionamiento interno del Guard Post:

- 12 sentinelas;
- posiciones fijas;
- regeneración;
- nivel progresivo;
- sustitución al cambiar de propietario.

## 6. Diferenciar evidencia

Una función puede aparecer:

1. en un inventario de nombres;
2. en un script nativo;
3. en una Sequence real;
4. en una prueba directa.

Estas evidencias no son equivalentes.

Para construir código de producción se priorizan:

```text
prueba directa
    ↓
Sequence real
    ↓
script nativo
    ↓
definición/inventario
```

## 7. Búsqueda de nombres técnicos de unidades

Para identificar strings válidos de `Place()` se cruzaron:

- `class id`;
- `display_name`;
- `entity`;
- apariciones `class="..."` en BFHP;
- tablas de IA;
- llamadas literales a `Place()` cuando estaban disponibles.

Este método permitió evitar depender de nombres visibles o traducciones.


---


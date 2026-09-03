# Secuencia 5 — `OutpostAuxDefense_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).** Este documento describe la implementación canónica incluida en `V2.0ImperivmIII.txt`.

`OutpostAuxDefense_Main` añade una segunda capa de defensa a los Outposts culturales gestionados por `Fortresses_Main`.

Su función no es crear una guarnición nueva, sino utilizar temporalmente las **tropas normales que el propietario haya almacenado voluntariamente dentro del Outpost**. Cuando aparecen enemigos dentro del radio defensivo, la Sequence identifica esas tropas, excluye la guarnición estructural creada por `Fortresses_Main`, saca únicamente las unidades militares válidas y las emplea como defensa auxiliar.

La versión v2.0 introduce además una regla importante de control manual: mientras una tropa siga vinculada al sistema auxiliar, `GetCommanded()` permite detectar que ha recibido una orden externa/manual. En ese momento la unidad se elimina inmediatamente del Group temporal y vuelve a ser una tropa normal completamente libre.

Cuando termina el ataque, las auxiliares que sigan vinculadas se repliegan hacia el Outpost. Tras confirmar varios ciclos consecutivos sin amenazas, reciben `enter_tent` cuando vuelven a estar dentro de `fort.range` y son eliminadas del Group auxiliar.

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Relación con `Fortresses_Main`

Esta Sequence **depende directamente de `Fortresses_Main`**.

No es un sistema independiente.

La dependencia aparece en dos elementos:

```cpp
initialized =
    EnvReadInt(
        fort,
        "FG_Init"
    );
```

y:

```cpp
garrisonGroup =
    "__FRT_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

`FG_Init` y los Groups `__FRT_X_Y` pertenecen a la arquitectura de `Fortresses_Main`.

Por tanto:

```text
Fortresses_Main
↓
crea y gestiona la guarnición estructural del Outpost
↓
OutpostAuxDefense_Main
↓
utiliza temporalmente tropas normales almacenadas como defensa auxiliar
```

---

# 2. Preparación necesaria en el editor

Hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── OutpostAuxDefense_Main
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

Además debe existir y estar activa:

```text
Fortresses_Main
```

porque esta Sequence utiliza su estado interno.

---

# 3. Groups que hay que crear manualmente

**No hay que crear ningún Group manual para esta Sequence.**

Los dos tipos de Group que utiliza son dinámicos.

## Guarnición oficial

```text
__FRT_X_Y
```

Es el Group utilizado por `Fortresses_Main`.

Ejemplo:

```text
__FRT_13500_9200
```

## Tropas auxiliares temporales

```text
__FRT_AUX_X_Y
```

Ejemplo:

```text
__FRT_AUX_13500_9200
```

La Sequence añade y elimina unidades mediante:

```cpp
u.AddToGroup(auxGroup);
```

y:

```cpp
aux.RemoveFromGroup(auxGroup);
```

No deben crearse previamente en el editor.

---

# 4. No hay que crear Areas, Holders ni marcadores

La Sequence no utiliza Areas manuales.

Tampoco necesita Holders adicionales ni puntos de aparición.

Toda la lógica espacial parte del propio Outpost:

```cpp
fort.pos
```

y de:

```cpp
fort.range
```

---

# 5. Qué edificios controla

La Sequence descubre únicamente los Outposts culturales:

```text
TOutpost
GOutpost
BOutpost
IOutpost
COutpost
ROutpost
EOutpost
```

mediante `ClassPlayerObjs(...)` para Players 1 a 16.

No controla:

- `GGuardPost`;
- Townhall/Foros;
- `TTent`;
- aldeas;
- torres;
- murallas;
- puertas.

`GGuardPost` pertenece a la Sequence específica `GGuardPost` documentada en la Secuencia 3.

---

# 6. Descubrimiento automático de los Outposts

Al comenzar la partida se construye:

```cpp
ObjList forts;
```

y se recorren los Players 1 a 16:

```cpp
for (p = 1; p <= 16; p += 1)
```

La lista se construye una sola vez al arrancar.

En v2.0 el bucle permanente añade además:

```cpp
forts.ClearDead();
```

antes de recorrerla, para evitar conservar referencias a fortines que hayan sido eliminados por el motor.

---

# 7. Consecuencia del descubrimiento inicial

Todos los Outposts que deban participar deben existir desde el comienzo de la partida.

Un Outpost creado dinámicamente después del arranque no será añadido automáticamente a `forts`.

---

# 8. Estado inicial de cada Outpost

Para cada fortaleza se escriben:

```cpp
EnvWriteInt(
    fort,
    "OA_LastOwner",
    fort.player
);
```

y:

```cpp
EnvWriteInt(
    fort,
    "OA_QuietClock",
    0
);
```

| Variable | Función |
|---|---|
| `OA_LastOwner` | Último propietario reconocido por esta Sequence |
| `OA_QuietClock` | Tiempo acumulado sin enemigos |

Cada Outpost conserva su propio estado.

---

# 9. Parámetros globales de v2.0

La configuración canónica actual es:

```cpp
CONTROL_INTERVAL = 1500;
RETURN_DELAY = 5000;
```

## `CONTROL_INTERVAL`

```text
1.500 ms
```

La Sequence revisa los Outposts aproximadamente una vez cada **1,5 segundos**.

El propio comentario del código explica que esta frecuencia sustituye a una revisión anterior de 750 ms para reducir aproximadamente a la mitad el coste permanente del sistema.

## `RETURN_DELAY`

```text
5.000 ms
```

Es el umbral lógico de paz necesario antes de entrar en la fase final de regreso.

## `RELEASE_DISTANCE`

La versión v2.0 **ya no declara ni utiliza** `RELEASE_DISTANCE`.

La lógica de distancia utiliza exclusivamente:

```cpp
fort.range
```

Esto corrige una discrepancia de documentación de versiones anteriores, donde `RELEASE_DISTANCE = 600` aparecía declarado pero no siempre participaba en el comportamiento real.

---

# 10. Precisión real del temporizador de paz

El contador se incrementa así:

```cpp
quietClock += CONTROL_INTERVAL;
```

Con:

```text
CONTROL_INTERVAL = 1500 ms
RETURN_DELAY = 5000 ms
```

los valores sucesivos son aproximadamente:

```text
1500
3000
4500
6000
```

Por tanto el umbral de 5.000 ms se supera en el cuarto ciclo.

En la práctica, si no existe ninguna otra demora, la fase final se activa tras aproximadamente **6 segundos de paz acumulada por polling**, no exactamente a los 5.000 ms nominales.

El nombre `RETURN_DELAY = 5000` sigue describiendo el umbral lógico, pero la resolución temporal depende de `CONTROL_INTERVAL`.

---

# 11. Inicio del bucle permanente

La Sequence entra en:

```cpp
while (1)
{
    Sleep(CONTROL_INTERVAL);
    forts.ClearDead();
    ...
}
```

Cada ciclo:

1. elimina referencias muertas de `forts`;
2. recorre los Outposts restantes;
3. lee propietario y estado;
4. procesa defensa auxiliar sólo cuando corresponde.

---

# 12. Comprobación de `FG_Init`

La dependencia principal con `Fortresses_Main` es:

```cpp
initialized =
    EnvReadInt(
        fort,
        "FG_Init"
    );
```

Si:

```cpp
initialized != 1
```

la Sequence no moviliza tropas normales.

Antes de continuar limpia cualquier auxiliar temporal que todavía pudiera quedar vinculada y reinicia:

```text
OA_QuietClock = 0
```

---

# 13. Comportamiento mientras el Outpost sigue neutral

En los Outposts neutrales normales:

```text
FG_Init = 0
```

Por tanto `OutpostAuxDefense_Main` no interviene.

Esto preserva la fase neutral y la lógica de `Fortresses_Main`.

---

# 14. Construcción del nombre de la guarnición oficial

La Sequence calcula:

```cpp
garrisonGroup =
    "__FRT_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

Este patrón coincide exactamente con `Fortresses_Main`.

---

# 15. Construcción del Group auxiliar

También calcula:

```cpp
auxGroup =
    "__FRT_AUX_"
    +
    fort.pos.x
    +
    "_"
    +
    fort.pos.y;
```

Conceptualmente:

```text
Outpost
├── __FRT_X_Y
│   └── guarnición estructural oficial
│
└── __FRT_AUX_X_Y
    └── tropas normales movilizadas temporalmente
```

---

# 16. Optimización de v2.0: la guarnición oficial no se reconstruye en todos los ciclos

Versiones anteriores recuperaban `garrison` de forma más frecuente.

En v2.0 la lista:

```cpp
garrison =
    Group(
        garrisonGroup
    )
    .GetObjList();
```

se recupera **sólo cuando realmente hay enemigos** y es necesario decidir qué unidades almacenadas pueden salir.

El comentario del código lo indica expresamente:

```text
La guarnicion oficial solo hace falta cuando realmente hay
combate y vamos a decidir que unidades pueden salir.
```

Esto reduce reconstrucciones de listas durante periodos prolongados de paz.

---

# 17. Detección de cambio de propietario

Se compara:

```cpp
lastOwner =
    EnvReadInt(
        fort,
        "OA_LastOwner"
    );
```

con:

```cpp
owner = fort.player;
```

Si:

```cpp
lastOwner != owner
```

se recupera el Group auxiliar, se limpian muertos y todas las auxiliares restantes se eliminan del Group.

---

# 18. Qué ocurre con auxiliares del propietario anterior

La operación es:

```cpp
auxiliary[j].RemoveFromGroup(auxGroup);
```

No se ejecuta:

```cpp
SetPlayer(newOwner)
```

No se matan.

No se transfieren.

No reciben nuevas órdenes de esta Sequence.

Siguen siendo tropas normales de su propietario original.

---

# 19. Reinicio tras cambio de propietario

Después del cambio se actualiza:

```text
OA_LastOwner = nuevo propietario
OA_QuietClock = 0
```

y se ejecuta:

```cpp
continue;
```

No se intenta movilizar auxiliares del nuevo propietario en ese mismo ciclo.

---

# 20. Sólo funciona para Players 1..8

El código exige:

```cpp
if (
    owner < 1
    ||
    owner > 8
)
```

En ese caso:

1. elimina del Group auxiliar cualquier unidad registrada;
2. reinicia `OA_QuietClock`;
3. no interviene.

El sistema está diseñado para los ocho jugadores principales.

---

# 21. Detección de enemigos

El sistema utiliza:

```cpp
fort.range
```

Primero busca unidades dentro del radio:

```cpp
ObjsInRange(
    fort,
    "Unit",
    fort.range
);
```

Después filtra:

```text
Military enemigo
BaseMage enemigo
```

y excluye:

```text
Sentry enemigo
```

---

# 22. Las catapultas también cuentan como amenaza

Se realiza una segunda consulta sobre Buildings:

```cpp
ObjsInRange(
    fort,
    "Building",
    fort.range
)
```

filtrada por:

```cpp
EnemyObjs(owner, "Catapult")
```

Por tanto una amenaza válida puede ser:

```text
Military enemigo
BaseMage enemigo
Catapult enemiga
```

---

# 23. Inicio de un ataque

Si:

```cpp
enemies.count > 0
```

se ejecuta inmediatamente:

```cpp
EnvWriteInt(
    fort,
    "OA_QuietClock",
    0
);
```

El contador de paz queda reiniciado.

---

# 24. Control de auxiliares ya desplegadas

Durante un ataque se recupera:

```cpp
auxiliary =
    Group(
        auxGroup
    )
    .GetObjList();

auxiliary.ClearDead();
```

Después se analiza cada unidad vinculada de forma individual.

---

# 25. Si una auxiliar ya no pertenece al propietario

Se comprueba:

```cpp
if (aux.player != owner)
```

y se ejecuta:

```cpp
aux.RemoveFromGroup(auxGroup);
```

La Sequence deja de controlarla inmediatamente.

---

# 26. `GetCommanded()` y toma de mando manual

Esta es una de las diferencias principales respecto a la documentación antigua.

La versión v2.0 sí utiliza:

```cpp
aux.GetCommanded()
```

El código interpreta ese resultado como que la unidad ha recibido una orden externa/manual.

Cuando devuelve verdadero:

```cpp
aux.RemoveFromGroup(
    auxGroup
);
```

Desde ese instante `OutpostAuxDefense_Main` deja de administrar esa unidad.

El flujo es:

```text
auxiliar vinculada
↓
GetCommanded() detecta toma de mando
↓
RemoveFromGroup(__FRT_AUX_X_Y)
↓
la Sequence deja de darle órdenes
↓
vuelve a ser tropa normal completamente libre
```

---

# 27. Una tropa desvinculada no vuelve a engancharse por proximidad

El código no busca tropas libres alrededor del Outpost para volver a incorporarlas.

Sólo selecciona nuevas auxiliares desde:

```cpp
fort.settlement.Units()
```

y además exige:

```cpp
settlementUnits[j].AsUnit().InHolder()
```

Por tanto una tropa que fue desvinculada por `GetCommanded()` puede acercarse, alejarse o combatir cerca del fortín sin volver automáticamente al sistema.

Para poder ser seleccionada otra vez debe **entrar físicamente de nuevo en el Outpost**.

---

# 28. Límite de persecución de auxiliares vinculadas

Si una auxiliar sigue bajo control de la Sequence y:

```cpp
fort.DistTo(aux) > fort.range
```

se pretende hacerla regresar al fortín.

La versión v2.0 evita repetir la misma clase de orden si ya está moviéndose:

```cpp
if(aux.command != "move")
{
    aux.SetCommand(
        "move",
        fort.pos
    );
}
```

No existe ya ningún `fort.range + RELEASE_DISTANCE`.

El límite efectivo es exactamente:

```text
fort.range
```

---

# 29. Orden ofensiva durante un ataque

Si la auxiliar permanece dentro de `fort.range`, v2.0 **no reimpone `advance` continuamente**.

Sólo lo hace cuando:

```cpp
aux.command == "idle"
```

Entonces:

```cpp
aux.SetCommand(
    "advance",
    enemies[0].pos
);
```

Esto reduce el número de órdenes repetidas respecto a versiones anteriores.

---

# 30. Qué enemigo recibe como referencia

La orden utiliza:

```cpp
enemies[0].pos
```

No existe reparto individual de blancos.

La Sequence utiliza el primer enemigo de la lista como punto inicial de avance.

---

# 31. Lectura de tropas almacenadas

Durante el ataque se consulta:

```cpp
settlementUnits =
    fort
    .settlement
    .Units();

settlementUnits.ClearDead();
```

Sólo en este momento se recupera también la guarnición estructural `__FRT_X_Y` para usarla como lista de exclusión.

---

# 32. Condiciones para convertirse en auxiliar

Una unidad almacenada sólo puede salir si cumple simultáneamente:

```cpp
settlementUnits[j].AsUnit().InHolder()
```

```cpp
settlementUnits[j].player == owner
```

```cpp
settlementUnits[j].IsHeirOf("Military")
||
settlementUnits[j].IsHeirOf("BaseMage")
```

```cpp
!garrison.Contains(settlementUnits[j])
```

```cpp
!auxiliary.Contains(settlementUnits[j])
```

---

# 33. Debe estar realmente dentro del Outpost

La versión v2.0 utiliza explícitamente:

```cpp
settlementUnits[j].AsUnit().InHolder()
```

No basta con aparecer asociado al Settlement.

La unidad debe estar físicamente dentro del holder en el momento de ser seleccionada.

---

# 34. Exclusión de la guarnición oficial

La condición:

```cpp
!garrison.Contains(
    settlementUnits[j]
)
```

impide que la guarnición creada por `Fortresses_Main` sea capturada también por la lógica auxiliar.

Por tanto:

```text
Fortresses_Main
→ guarnición estructural

OutpostAuxDefense_Main
→ tropas normales almacenadas
```

---

# 35. Exclusión de auxiliares ya activas

También se comprueba:

```cpp
!auxiliary.Contains(
    settlementUnits[j]
)
```

para evitar duplicar la misma unidad dentro de `__FRT_AUX_X_Y`.

---

# 36. Orden inicial para salir y defender

Cuando una unidad válida es seleccionada:

```cpp
u.AddToGroup(
    auxGroup
);
```

seguido de:

```cpp
u.SetCommand(
    "advance",
    enemies[0].pos
);
```

Esta es la orden inicial que provoca su salida desde el Outpost.

A partir de ahí permanece vinculada mientras:

- siga perteneciendo al propietario;
- `GetCommanded()` no detecte una toma de mando externa/manual.

---

# 37. No existe un comando especial de salida

La Sequence no usa:

```text
unitsout
exit_tent
ExitHolder
```

La salida se provoca mediante una orden normal:

```cpp
SetCommand("advance", ...)
```

---

# 38. No existe un máximo de auxiliares

La Sequence no establece un límite numérico.

Si dentro del Outpost existen muchas tropas válidas, todas pueden intentar salir durante un ataque.

El límite real dependerá de:

- capacidad del Settlement;
- unidades almacenadas;
- filtros de clase;
- comportamiento del motor.

---

# 39. Las auxiliares mantienen alimentación normal

La Sequence no ejecuta:

```cpp
SetFeeding(false)
```

sobre las tropas auxiliares.

Siguen siendo unidades normales del jugador.

---

# 40. Las auxiliares mantienen control normal de IA fuera del vínculo temporal

Tampoco ejecuta:

```cpp
SetNoAIFlag(true)
```

Por tanto no se convierten en guarniciones estructurales.

Mientras pertenezcan a `auxGroup`, la Sequence puede dirigirlas según su lógica defensiva.

Al ser desvinculadas recuperan su comportamiento normal.

---

# 41. Fin del ataque: comienzo del repliegue

Cuando:

```text
enemies.count == 0
```

se incrementa `OA_QuietClock` y se recupera el Group auxiliar.

Para cada unidad todavía vinculada:

1. si ya no pertenece al propietario → se desvincula;
2. si `GetCommanded()` detecta una orden externa/manual → se desvincula;
3. si sigue vinculada y no tiene ya `move` → recibe:

```cpp
aux.SetCommand(
    "move",
    fort.pos
);
```

Por tanto la persecución se corta en cuanto la Sequence detecta que ya no existen enemigos.

---

# 42. El repliegue se revisa durante toda la espera

Mientras `quietClock < RETURN_DELAY`, cada ciclo vuelve a analizar las auxiliares.

Una tropa que reciba una orden manual durante este periodo se libera inmediatamente mediante `GetCommanded()`.

Las demás continúan regresando hacia `fort.pos`.

---

# 43. Qué ocurre si reaparece un enemigo

En cuanto vuelve a cumplirse:

```cpp
enemies.count > 0
```

se ejecuta:

```text
OA_QuietClock = 0
```

y las auxiliares que todavía sigan vinculadas vuelven a entrar en la lógica de defensa.

---

# 44. Fase final de regreso

Cuando el contador supera el umbral `RETURN_DELAY`, sólo se procesan las unidades que **todavía siguen vinculadas**.

El orden de decisión es:

```text
¿cambió de propietario?
→ desvincular

¿GetCommanded()?
→ desvincular

¿está fuera de fort.range?
→ move hacia fort.pos

¿está dentro de fort.range?
→ enter_tent
→ RemoveFromGroup
```

---

# 45. Si la auxiliar sigue lejos

La condición es:

```cpp
fort.DistTo(aux) > fort.range
```

En ese caso:

```cpp
aux.SetCommand(
    "move",
    fort.pos
);
```

La unidad permanece dentro de `auxGroup`.

La Sequence seguirá revisándola en ciclos posteriores.

---

# 46. Si la auxiliar ya está dentro del radio

Cuando:

```cpp
fort.DistTo(aux) <= fort.range
```

se ejecuta:

```cpp
aux.SetCommand(
    "enter_tent",
    fort
);
```

y acto seguido:

```cpp
aux.RemoveFromGroup(
    auxGroup
);
```

---

# 47. La liberación ocurre al ordenar `enter_tent`

La Sequence no espera a confirmar posteriormente:

```cpp
aux.InHolder()
```

La secuencia real es:

```text
auxiliar dentro de fort.range
↓
SetCommand("enter_tent", fort)
↓
RemoveFromGroup(__FRT_AUX_X_Y)
↓
la Sequence deja de controlarla
```

Si completa la entrada, volverá a estar disponible para una defensa futura.

Si el motor o el jugador alteran posteriormente su orden, ya no estará bajo control de esta Sequence.

---

# 48. Toma de mando durante la fase final

Incluso después de superar `RETURN_DELAY`, se vuelve a comprobar:

```cpp
aux.GetCommanded()
```

Si devuelve verdadero, la unidad se elimina del Group auxiliar y no recibe `enter_tent` por parte de esta Sequence.

Esto permite recuperar control manual también durante el regreso definitivo.

---

# 49. Reinicio de `OA_QuietClock`

Al terminar la fase final de procesamiento se ejecuta:

```cpp
EnvWriteInt(
    fort,
    "OA_QuietClock",
    0
);
```

Si siguen existiendo auxiliares lejos del puesto, el proceso de paz comienza de nuevo en ciclos posteriores hasta que sean liberadas, entren o reciban una orden externa/manual.

---

# 50. Cambio de propietario mientras hay auxiliares fuera

Si el Outpost cambia de dueño:

```cpp
lastOwner != owner
```

la Sequence elimina todas las referencias del Group auxiliar.

Las tropas antiguas:

- no se convierten;
- no se matan;
- no reciben orden de regresar;
- no reciben orden de entrar;
- dejan de estar controladas.

---

# 51. Ataque combinado con `Fortresses_Main`

Si un Outpost tiene:

```text
guarnición estructural
+
tropas normales almacenadas
```

y aparece un enemigo:

```text
Fortresses_Main
→ controla la guarnición estructural

OutpostAuxDefense_Main
→ moviliza las tropas normales válidas
```

Los dos sistemas pueden defender simultáneamente el mismo Outpost sin seleccionar deliberadamente las mismas unidades.

---

# 52. Paz después del combate

Cuando desaparece la amenaza:

```text
Fortresses_Main
→ devuelve su guarnición estructural mediante enter_tent

OutpostAuxDefense_Main
→ repliega auxiliares vinculadas
→ permite desvinculación manual con GetCommanded()
→ tras el periodo de paz intenta enter_tent
→ las libera del Group temporal
```

---

# 53. No existe regeneración de auxiliares

Si una tropa normal muere durante la defensa:

```text
no reaparece
```

`OutpostAuxDefense_Main` no utiliza `Place()`.

Las auxiliares son exactamente las tropas normales que el propietario había almacenado.

---

# 54. No existe un mínimo de auxiliares

Una sola unidad válida puede ser movilizada.

No existe una condición de mínimo 5, 10 o cualquier otro valor.

---

# 55. No existe selección por civilización

El filtro es genérico:

```text
Military
BaseMage
```

La Sequence no selecciona clases concretas según civilización.

---

# 56. Atención con héroes

El código no contiene una exclusión literal de `Hero`.

Por tanto, si una clase de héroe satisface la jerarquía utilizada por:

```cpp
IsHeirOf("Military")
```

o:

```cpp
IsHeirOf("BaseMage")
```

podría entrar en el sistema auxiliar.

No debe asumirse que los héroes estén protegidos automáticamente.

---

# 57. `GetCommanded()` sí forma parte de la versión canónica

La documentación anterior afirmaba que esta Sequence no utilizaba `GetCommanded()`.

Eso ya no es correcto.

La versión canónica v2.0 lo utiliza en tres momentos:

```text
1. durante el ataque;
2. durante el repliegue sin enemigos;
3. durante la fase final de regreso.
```

Su finalidad es la misma en los tres casos:

```text
detectar toma de mando externa/manual
↓
desvincular de __FRT_AUX_X_Y
↓
devolver control normal
```

---

# 58. Qué ocurre si el jugador saca manualmente una tropa durante la paz

Si no hay enemigos y la tropa no pertenece ya a `auxGroup`:

- la Sequence no la añade automáticamente;
- no le impone órdenes;
- no la obliga a regresar.

El sistema sólo incorpora nuevas auxiliares desde dentro del Settlement cuando existe una amenaza.

---

# 59. Qué ocurre si el jugador mete nuevas tropas durante un ataque

Durante cada ciclo con enemigos se vuelve a consultar:

```cpp
fort.settlement.Units()
```

Por tanto una unidad introducida físicamente en el Outpost durante el combate puede ser detectada y movilizada en un ciclo posterior.

Con:

```text
CONTROL_INTERVAL = 1500 ms
```

la latencia típica máxima del polling es aproximadamente 1,5 segundos, sin contar otras operaciones de la Sequence.

---

# 60. Qué ocurre si una unidad desvinculada vuelve a entrar

Una tropa que fue liberada por `GetCommanded()` no vuelve a quedar vinculada simplemente por acercarse.

Si posteriormente entra físicamente en el Outpost y vuelve a cumplir:

```cpp
InHolder() == true
```

podrá ser seleccionada en un ataque futuro.

---

# 61. Qué ocurre si una auxiliar muere

En la siguiente reconstrucción de `auxiliary`:

```cpp
auxiliary.ClearDead();
```

la referencia desaparece.

No existe reposición.

---

# 62. No modifica la captura del Outpost

Esta Sequence no llama a:

```cpp
AllowCapture(...)
```

No modifica:

```text
loyalty
player
SetPlayer
```

La captura continúa siendo responsabilidad de `Fortresses_Main` y del comportamiento correspondiente del Outpost.

---

# 63. No modifica la regeneración estructural

No toca:

```text
FG_Regen
FG_Turn
FG_ExpectedOwner
```

La única variable de `Fortresses_Main` que lee directamente es:

```text
FG_Init
```

Además consulta el Group estructural:

```text
__FRT_X_Y
```

para excluir esas unidades del sistema auxiliar.

---

# 64. Condiciones necesarias para funcionar correctamente

El mapa debe cumplir:

1. `Fortresses_Main` debe existir y ejecutarse.
2. Los Outposts deben existir al arrancar.
3. Deben ser clases culturales compatibles.
4. Los Players principales deben estar entre 1 y 8.
5. Las tropas normales deben poder almacenarse en `fort.settlement`.
6. `OutpostAuxDefense_Main` debe tener `Autorun allowed`.
7. No debe existir otra Sequence que utilice `__FRT_AUX_` con una semántica distinta.

---

# 65. Orden recomendado de configuración

```text
Map
└── Sequences
    ├── Fortresses_Main
    │   └── Autorun allowed = Sí
    │
    └── OutpostAuxDefense_Main
        └── Autorun allowed = Sí
```

No es necesario imponer manualmente un orden de arranque entre ambas.

`OutpostAuxDefense_Main` espera a que:

```text
FG_Init = 1
```

antes de intervenir.

---

# 66. Groups necesarios en el editor

Ninguno.

La Sequence utiliza dinámicamente:

```text
__FRT_X_Y
__FRT_AUX_X_Y
```

---

# 67. Areas necesarias

Ninguna.

Toda la detección se basa en:

```cpp
ObjsInRange(
    fort,
    ...,
    fort.range
)
```

---

# 68. Holders necesarios

Ninguno adicional.

El propio Outpost y su `Settlement` son suficientes.

---

# 69. Flujo completo durante un ataque

```text
Outpost conquistado
↓
FG_Init = 1
↓
jugador guarda tropas normales dentro
↓
paz: la Sequence no las toca
↓
aparece enemigo dentro de fort.range
↓
OA_QuietClock = 0
↓
leer fort.settlement.Units()
↓
recuperar __FRT_X_Y sólo para excluir guarnición oficial
↓
filtrar:
    InHolder()
    propietario actual
    Military/BaseMage
    no guarnición oficial
    no auxiliar ya activa
↓
AddToGroup(__FRT_AUX_X_Y)
↓
SetCommand("advance", enemigo)
↓
durante el combate:
    si cambia de propietario → desvincular
    si GetCommanded() → desvincular
    si sale de fort.range → move al Outpost
    si está dentro y queda idle → advance
↓
desaparece el último enemigo
↓
repliegue hacia fort.pos
↓
si GetCommanded() → desvincular
↓
quietClock avanza en bloques de 1500 ms
↓
al superar RETURN_DELAY:
    fuera de fort.range → seguir move
    dentro de fort.range → enter_tent + RemoveFromGroup
↓
unidad vuelve al comportamiento normal
```

---

# 70. Flujo durante una toma de mando manual

```text
auxiliar vinculada
↓
usuario / orden externa toma el mando
↓
GetCommanded() = true
↓
RemoveFromGroup(__FRT_AUX_X_Y)
↓
la Sequence deja de darle órdenes
↓
puede retirarse, atacar o marcharse libremente
↓
NO se vuelve a vincular por proximidad
↓
para futuras defensas debe volver a entrar físicamente en el Outpost
```

---

# 71. Flujo durante un cambio de propietario

```text
Outpost de Player A
↓
auxiliares de Player A desplegadas
↓
el edificio pasa a Player B
↓
OA_LastOwner != owner
↓
limpiar __FRT_AUX_X_Y
↓
las antiguas tropas no cambian de jugador
↓
la Sequence deja de controlarlas
↓
OA_LastOwner = Player B
OA_QuietClock = 0
```

---

# 72. Diferencia respecto a `Fortresses_Main`

## `Fortresses_Main`

Gestiona tropas estructurales:

```text
creadas por script
SetFeeding(false)
SetNoAIFlag(true)
regeneración
captura territorial
guarnición permanente
```

## `OutpostAuxDefense_Main`

Gestiona temporalmente tropas normales:

```text
no las crea
no altera alimentación
no altera AI flag
no regenera
no cambia propietario
no controla captura
permite desvinculación manual con GetCommanded()
```

---

# 73. Diferencia respecto a `GGuardPost`

`GGuardPost` administra una escolta externa permanente asociada a los puestos de guardia.

`OutpostAuxDefense_Main` no se aplica a `GGuardPost`.

Aquí las unidades:

- proceden del interior del Outpost;
- son tropas normales del jugador;
- sólo quedan bajo control temporal;
- pueden abandonar ese control mediante `GetCommanded()`.

---

# 74. Cambios principales de v2.0 respecto a la documentación anterior

La versión canónica actual cambia varios puntos importantes:

```text
CONTROL_INTERVAL
500/750 ms anteriores
→ 1500 ms

RELEASE_DISTANCE
antes documentado como 600
→ eliminado de la Sequence v2.0

GetCommanded()
antes documentado como ausente
→ utilizado durante ataque, repliegue y regreso final

control defensivo
advance repetido continuamente
→ sólo se emite cuando aux.command == "idle"

move de regreso
→ no se repite si aux.command ya es "move"

lista __FRT_X_Y
antes reconstruida con más frecuencia
→ en v2.0 sólo se recupera durante combate cuando se necesita excluir la guarnición oficial

forts
→ ahora ejecuta ClearDead() en cada ciclo
```

---

# 75. Preparación exacta en el editor

```text
Map
└── Sequences
    ├── Fortresses_Main
    │   ├── código canónico v2.0
    │   └── Autorun allowed = Sí
    │
    └── OutpostAuxDefense_Main
        ├── código canónico v2.0
        ├── Compile
        └── Autorun allowed = Sí
```

### Elementos adicionales

- **Groups manuales:** ninguno.
- **Areas:** ninguna.
- **Holders adicionales:** ninguno.
- **Marcadores:** ninguno.
- **Puntos de defensa:** ninguno.

---

# 76. Resumen funcional

`OutpostAuxDefense_Main` v2.0 implementa este ciclo:

```text
descubrir todos los Outposts culturales
        ↓
limpiar referencias muertas de forts en cada ciclo
        ↓
esperar a FG_Init = 1
        ↓
en paz:
    no tocar tropas normales almacenadas
        ↓
si aparece enemigo:
    detectar Military/BaseMage almacenados
    del propietario actual
        ↓
excluir __FRT_X_Y
        ↓
exigir InHolder()
        ↓
añadir a __FRT_AUX_X_Y
        ↓
dar orden inicial "advance"
        ↓
mientras sigan vinculadas:
    GetCommanded() → liberar inmediatamente
    fuera de fort.range → regresar
    idle dentro del radio → advance
        ↓
cuando desaparece la amenaza:
    replegar hacia el Outpost
    permitir toma de mando manual
        ↓
tras superar RETURN_DELAY:
    si sigue lejos → continuar regreso
    si entra en fort.range → enter_tent + liberar
        ↓
volver al control normal
```

Es una Sequence auxiliar de defensa que aprovecha tropas normales almacenadas sin convertirlas en una guarnición permanente, y en v2.0 incorpora explícitamente la posibilidad de que una orden externa/manual las desvincule del sistema mediante `GetCommanded()`.

# Secuencia 5 — `OutpostAuxDefense_Main`

`OutpostAuxDefense_Main` añade una segunda capa de defensa a los Outposts culturales gestionados por `Fortresses_Main`.

Su función no es crear una guarnición nueva, sino utilizar temporalmente las **tropas normales que el propietario haya almacenado voluntariamente dentro del Outpost**. Cuando aparecen enemigos dentro del radio defensivo, la Sequence identifica esas tropas, excluye la guarnición estructural creada por `Fortresses_Main`, saca únicamente las unidades militares válidas y las emplea como defensa auxiliar.

Cuando termina el ataque, las tropas auxiliares dejan de perseguir al enemigo, regresan hacia el Outpost y, tras cinco segundos continuados sin amenazas, reciben una orden para volver a entrar. Después dejan de estar controladas por esta Sequence y vuelven a comportarse como tropas normales del jugador.

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

`FG_Init` y los Groups `__FRT_X_Y` son creados y utilizados por `Fortresses_Main`.

Por tanto:

```text
Fortresses_Main
↓
crea/gestiona la guarnición oficial del Outpost
↓
OutpostAuxDefense_Main
↓
utiliza las tropas normales almacenadas como defensa auxiliar
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

La Sequence añade y elimina unidades de estos Groups mediante:

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

No existe ninguna llamada como:

```cpp
ClassPlayerAreaObjs(...)
```

Tampoco necesita Holders adicionales ni puntos de aparición.

Toda la lógica espacial parte del propio Outpost:

```cpp
fort.pos
```

y de:

```cpp
fort.range
```

Por tanto la preparación adicional es mínima.

---

# 5. Qué edificios controla

La Sequence busca únicamente los Outposts culturales:

```cpp
TOutpost
GOutpost
BOutpost
IOutpost
COutpost
ROutpost
EOutpost
```

mediante:

```cpp
ClassPlayerObjs(...)
```

No controla:

- `GGuardPost`
- Townhall/Foros
- `TTent`
- aldeas
- torres
- murallas
- puertas

`GGuardPost` tiene su propia arquitectura y pertenece a `GuardPosts_Main`.

---

# 6. Descubrimiento automático de los Outposts

Al comenzar la partida se crea:

```cpp
ObjList forts;
```

y se recorren los Players 1 a 16:

```cpp
for (p = 1; p <= 16; p += 1)
```

añadiendo todos los Outposts culturales existentes.

Ejemplo:

```cpp
forts.AddList(
    ClassPlayerObjs(
        "TOutpost",
        p
    )
    .GetObjList()
);
```

La lista se construye una sola vez al arrancar.

---

# 7. Consecuencia del descubrimiento inicial

Todos los Outposts que deban participar deben existir desde el comienzo de la partida.

Un Outpost creado dinámicamente después no será añadido automáticamente a `forts`.

Esto coincide con la arquitectura de `Fortresses_Main`.

---

# 8. Estado inicial de cada Outpost

Para cada fortaleza se guardan dos valores:

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

Estas variables significan:

| Variable | Función |
|---|---|
| `OA_LastOwner` | Último propietario reconocido por esta Sequence |
| `OA_QuietClock` | Tiempo acumulado sin enemigos |

Cada Outpost conserva su propio estado.

---

# 9. Parámetros globales

La configuración es:

```cpp
CONTROL_INTERVAL = 500;
RETURN_DELAY = 5000;
RELEASE_DISTANCE = 600;
```

## `CONTROL_INTERVAL`

```text
500 ms
```

La Sequence revisa todos los Outposts dos veces por segundo.

## `RETURN_DELAY`

```text
5000 ms
```

Después de desaparecer los enemigos deben pasar cinco segundos continuados de paz antes de ordenar la entrada definitiva al Outpost.

## `RELEASE_DISTANCE`

```text
600
```

Esta variable se declara y recibe valor, pero **no se utiliza en ninguna condición del código actual**.

Por tanto:

> `RELEASE_DISTANCE = 600` no tiene ningún efecto funcional en esta versión.

La lógica real utiliza:

```cpp
fort.range
```

para determinar si una unidad está suficientemente cerca del Outpost.

---

# 10. Inicio del bucle permanente

La Sequence entra en:

```cpp
while (1)
{
    Sleep(CONTROL_INTERVAL);
    ...
}
```

Cada 500 ms recorre todos los Outposts registrados.

Para cada uno obtiene:

```cpp
fort = forts[i].AsBuilding();
owner = fort.player;
```

---

# 11. Comprobación de `FG_Init`

La primera dependencia real con `Fortresses_Main` es:

```cpp
initialized =
    EnvReadInt(
        fort,
        "FG_Init"
    );
```

Después se exige:

```cpp
if (initialized != 1)
```

Si `FG_Init` todavía no vale 1, esta Sequence no interviene.

Esto significa que las tropas auxiliares sólo se activan una vez que `Fortresses_Main` ha tomado el control de ese Outpost después de su primera conquista.

---

# 12. Comportamiento mientras el Outpost sigue neutral

En los Outposts neutrales normales:

```text
FG_Init = 0
```

Por tanto `OutpostAuxDefense_Main` no toca las tropas.

Esto preserva el comportamiento original de la fortaleza neutral.

---

# 13. Construcción del nombre de la guarnición oficial

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

Es exactamente el mismo patrón utilizado por `Fortresses_Main`.

Después recupera:

```cpp
garrison =
    Group(
        garrisonGroup
    )
    .GetObjList();
```

Esta lista representa la **guarnición estructural oficial** del Outpost.

---

# 14. Construcción del Group auxiliar

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

Este Group representa exclusivamente las tropas normales que en ese momento están siendo utilizadas como defensa auxiliar.

Ejemplo conceptual:

```text
Outpost
├── __FRT_14000_8000
│   └── guarnición oficial de Fortresses_Main
│
└── __FRT_AUX_14000_8000
    └── tropas normales movilizadas temporalmente
```

---

# 15. Reconstrucción de los Groups

En cada ciclo se ejecuta:

```cpp
garrison.ClearDead();
```

y:

```cpp
auxiliary.ClearDead();
```

Esto elimina referencias a unidades muertas.

Es especialmente importante en `auxiliary`, porque una tropa normal puede morir durante la defensa y debe desaparecer del seguimiento.

---

# 16. Detección de cambio de propietario

Se lee:

```cpp
lastOwner =
    EnvReadInt(
        fort,
        "OA_LastOwner"
    );
```

y se compara:

```cpp
if (lastOwner != owner)
```

Si el edificio ha cambiado de dueño, la Sequence considera que las tropas auxiliares del ciclo anterior ya no deben seguir bajo su control.

---

# 17. Qué ocurre con las auxiliares del propietario anterior

En un cambio de propietario:

```cpp
for (j = 0; j < auxiliary.count; j += 1)
{
    auxiliary[j].RemoveFromGroup(auxGroup);
}
```

No se ejecuta:

```cpp
SetPlayer(newOwner)
```

No se matan.

No se transfieren.

No reciben nuevas órdenes.

Simplemente dejan de formar parte del sistema auxiliar.

---

# 18. Las tropas auxiliares antiguas no cambian de bando

Esta es una regla de diseño importante.

Supongamos:

```text
Outpost pertenece a Player 3
↓
5 soldados normales de Player 3 salen como auxiliares
↓
Player 6 conquista el Outpost
```

La Sequence no convierte esas tropas a Player 6.

Siguen perteneciendo a Player 3.

Únicamente se ejecuta:

```text
RemoveFromGroup(auxGroup)
```

y vuelven a comportarse como unidades normales.

---

# 19. Reinicio del estado tras cambio de propietario

Después del cambio se actualiza:

```text
OA_LastOwner = nuevo propietario
OA_QuietClock = 0
```

y se hace:

```cpp
continue;
```

La Sequence no intenta movilizar tropas auxiliares en ese mismo ciclo.

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

1. elimina del Group auxiliar cualquier unidad todavía registrada;
2. reinicia `OA_QuietClock`;
3. no interviene.

Por tanto el sistema auxiliar está pensado exclusivamente para los ocho jugadores principales.

---

# 21. Qué tropas se consideran auxiliares potenciales

La Sequence lee las unidades almacenadas mediante:

```cpp
settlementUnits =
    fort
    .settlement
    .Units();
```

Después filtra individualmente.

Una unidad sólo puede salir como auxiliar si cumple simultáneamente:

```cpp
settlementUnits[j].AsUnit().InHolder()
```

```cpp
settlementUnits[j].player == owner
```

y además es:

```cpp
Military
```

o:

```cpp
BaseMage
```

---

# 22. Debe estar realmente dentro del Outpost

La condición:

```cpp
settlementUnits[j]
    .AsUnit()
    .InHolder()
```

evita seleccionar unidades que puedan estar asociadas al Settlement pero no físicamente dentro del edificio.

Esto sigue el patrón seguro recuperado de Sequences oficiales.

---

# 23. Debe pertenecer al propietario actual

La unidad debe cumplir:

```cpp
settlementUnits[j].player == owner
```

Por tanto no se despliega una unidad almacenada que pertenezca a otro Player.

---

# 24. Clases válidas

Las tropas auxiliares válidas son:

```text
Military
o
BaseMage
```

El filtro es:

```cpp
(
    settlementUnits[j].IsHeirOf("Military")
    ||
    settlementUnits[j].IsHeirOf("BaseMage")
)
```

Esto permite sacar tropas de combate normales y magos.

---

# 25. Exclusión de la guarnición oficial

La condición más importante es:

```cpp
!garrison.Contains(
    settlementUnits[j]
)
```

Esto evita que las tropas generadas por `Fortresses_Main` sean tratadas también como auxiliares.

Sin esta exclusión ambos sistemas podrían intentar controlar simultáneamente las mismas unidades.

---

# 26. Exclusión de auxiliares ya desplegadas

También se comprueba:

```cpp
!auxiliary.Contains(
    settlementUnits[j]
)
```

para evitar añadir dos veces la misma unidad al Group auxiliar.

---

# 27. Paz normal: la Sequence no toca las tropas almacenadas

Mientras no haya enemigos y las tropas normales estén simplemente almacenadas dentro del Outpost, no se hace una búsqueda para sacarlas.

Por tanto el jugador puede:

```text
meter tropas
sacar tropas
reorganizarlas
dejarlas dentro
```

sin que la Sequence interfiera en condiciones normales.

Este es uno de los objetivos principales del diseño.

---

# 28. Detección de enemigos

El sistema utiliza el radio:

```cpp
fort.range
```

Primero busca unidades:

```cpp
ObjsInRange(
    fort,
    "Unit",
    fort.range
);
```

y filtra:

```cpp
EnemyObjs(
    owner,
    "Military"
)
```

más:

```cpp
EnemyObjs(
    owner,
    "BaseMage"
)
```

---

# 29. Exclusión de sentinelas

Después se resta:

```cpp
EnemyObjs(
    owner,
    "Sentry"
)
```

Por tanto los sentinelas enemigos no disparan por sí solos la movilización auxiliar.

---

# 30. Las catapultas también cuentan como amenaza

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
EnemyObjs(
    owner,
    "Catapult"
)
```

Después se une a `qEnemies`.

La amenaza puede ser:

```text
Military enemigo
BaseMage enemigo
Catapult enemiga
```

---

# 31. Inicio de un ataque

Si:

```cpp
enemies.count > 0
```

la Sequence considera que el Outpost está bajo ataque.

Lo primero que hace es:

```cpp
OA_QuietClock = 0
```

porque ya no existe un periodo de paz.

---

# 32. Control de auxiliares ya desplegadas

Antes de sacar nuevas tropas, se recupera nuevamente:

```cpp
auxiliary =
    Group(
        auxGroup
    )
    .GetObjList();
```

y se ejecuta:

```cpp
auxiliary.ClearDead();
```

Después se controla cada unidad ya desplegada.

---

# 33. Si una auxiliar ya no pertenece al propietario

Se comprueba:

```cpp
if (aux.player != owner)
```

y entonces:

```cpp
aux.RemoveFromGroup(auxGroup);
```

La Sequence deja de controlarla inmediatamente.

No intenta cambiar su propietario.

---

# 34. Límite de persecución

Si una auxiliar se aleja demasiado:

```cpp
fort.DistTo(aux)
>
fort.range
```

recibe:

```cpp
aux.SetCommand(
    "move",
    fort.pos
);
```

Por tanto una tropa auxiliar no puede perseguir al enemigo indefinidamente.

El propio radio del Outpost funciona como límite defensivo.

---

# 35. Orden de combate

Mientras la auxiliar siga dentro de `fort.range`:

```cpp
aux.SetCommand(
    "advance",
    enemies[0].pos
);
```

Todas las auxiliares reciben una orden hacia el primer enemigo de la lista.

No existe reparto individual de objetivos.

---

# 36. Las órdenes defensivas se reimponen cada 500 ms

Durante un ataque la Sequence revisa el Group auxiliar en cada ciclo.

Por tanto una orden manual dada a una de esas tropas durante la defensa puede ser sustituida como máximo unos 500 ms después.

Mientras una unidad permanezca dentro de `auxGroup`, está temporalmente bajo control defensivo del sistema.

---

# 37. Salida selectiva de tropas almacenadas

Después de controlar las auxiliares que ya están fuera, la Sequence consulta:

```cpp
fort.settlement.Units()
```

y recorre todas las unidades almacenadas.

Cuando encuentra una unidad válida:

```cpp
u =
    settlementUnits[j]
    .AsUnit();
```

la añade a:

```cpp
auxGroup
```

y después ejecuta:

```cpp
u.SetCommand(
    "advance",
    enemies[0].pos
);
```

---

# 38. No se utiliza un comando especial de “sacar tropas”

La salida desde el Outpost se provoca mediante una orden normal de unidad:

```cpp
SetCommand(
    "advance",
    ...
)
```

No se utiliza:

```text
unitsout
```

ni un comando inventado como:

```text
exit_tent
```

Esto coincide con el patrón recuperado en Sequences oficiales.

---

# 39. Se pueden sacar muchas tropas normales

No existe un máximo de auxiliares en esta Sequence.

Si dentro del Outpost hay:

```text
3 soldados normales
```

pueden salir los 3.

Si hay:

```text
20 soldados normales
```

el bucle intentará movilizar los 20 siempre que:

- aparezcan en `settlement.Units()`;
- estén realmente `InHolder()`;
- sean `Military` o `BaseMage`;
- sean del propietario;
- no pertenezcan a la guarnición oficial.

El límite real dependerá de la capacidad y comportamiento del Outpost.

---

# 40. No se modifica `SetFeeding`

Las tropas auxiliares son tropas normales del jugador.

La Sequence no ejecuta:

```cpp
SetFeeding(false)
```

Por tanto mantienen su comportamiento de alimentación normal.

---

# 41. No se modifica `SetNoAIFlag`

Tampoco se ejecuta:

```cpp
SetNoAIFlag(true)
```

Las unidades siguen siendo tropas normales.

El único control especial se produce temporalmente mediante las órdenes que esta Sequence impone mientras estén en `auxGroup`.

---

# 42. Fin inmediato de la persecución

Cuando:

```text
enemies.count == 0
```

la Sequence comienza a incrementar:

```text
OA_QuietClock
```

pero al mismo tiempo ordena inmediatamente a las auxiliares:

```cpp
aux.SetCommand(
    "move",
    fort.pos
);
```

Por tanto no continúan persiguiendo durante los cinco segundos de espera.

La secuencia real es:

```text
desaparece el último enemigo
↓
cortar persecución inmediatamente
↓
mover hacia el Outpost
↓
esperar confirmación de paz durante 5 segundos
```

---

# 43. Temporizador de paz

Se lee:

```cpp
quietClock =
    EnvReadInt(
        fort,
        "OA_QuietClock"
    );
```

y se incrementa:

```cpp
quietClock +=
    CONTROL_INTERVAL;
```

Como:

```text
CONTROL_INTERVAL = 500 ms
```

son necesarios aproximadamente:

```text
10 ciclos
```

para llegar a:

```text
5000 ms
```

---

# 44. Si reaparece un enemigo durante esos cinco segundos

En cuanto:

```text
enemies.count > 0
```

se ejecuta:

```text
OA_QuietClock = 0
```

El proceso de regreso definitivo se cancela y las tropas vuelven al modo defensivo.

Ejemplo:

```text
enemigo eliminado
↓
3 segundos de paz
↓
aparece otro enemigo
↓
OA_QuietClock vuelve a 0
↓
auxiliares salen otra vez
```

---

# 45. Confirmación del fin del ataque

Cuando:

```cpp
quietClock >= RETURN_DELAY
```

la Sequence considera confirmado que el ataque ha terminado.

Entonces comienza la fase de regreso definitivo.

---

# 46. Auxiliares que todavía están fuera del radio

Si:

```cpp
fort.DistTo(aux)
>
fort.range
```

la unidad recibe:

```cpp
aux.SetCommand(
    "move",
    fort.pos
);
```

y permanece dentro de `auxGroup`.

Por tanto sigue bajo control de la Sequence hasta regresar al radio defensivo.

---

# 47. Auxiliares que ya han vuelto al radio del Outpost

Cuando una auxiliar cumple:

```cpp
fort.DistTo(aux)
<=
fort.range
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

La unidad deja de estar controlada por esta Sequence.

---

# 48. Observación importante: se libera al ordenar `enter_tent`, no al confirmar que ya ha entrado

Los comentarios iniciales indican:

```text
Solo se liberan del grupo temporal cuando vuelven a la zona defensiva.
```

Esto es correcto.

Sin embargo, conviene precisar la implementación.

El código **no espera a que**:

```cpp
aux.InHolder()
```

vuelva a ser verdadero.

La secuencia real es:

```text
la unidad está dentro de fort.range
↓
SetCommand("enter_tent", fort)
↓
RemoveFromGroup(auxGroup)
```

Por tanto queda liberada **inmediatamente después de recibir la orden de entrada**, no después de confirmar físicamente que ya está dentro del Outpost.

---

# 49. Consecuencia de la liberación inmediata

Al ser eliminada del Group justo después de:

```cpp
enter_tent
```

la Sequence deja de reimponer esa orden.

Eso permite que el jugador pueda cancelar la entrada y dar otra orden inmediatamente.

Este comportamiento coincide con el comentario del código:

```text
Así el jugador puede cancelar incluso esa orden si quiere.
```

Por tanto la intención final es devolver el control al jugador cuanto antes.

---

# 50. El comentario de cabecera y el comportamiento real

La cabecera dice:

```text
Tras 5 segundos de paz intenta meterlas de nuevo en el Outpost.
```

Esto es exactamente lo que hace el código.

No garantiza que entren.

La Sequence:

1. espera cinco segundos;
2. si están dentro del radio, emite `enter_tent`;
3. elimina la unidad del Group temporal;
4. deja de controlarla.

A partir de ahí el motor y el jugador deciden qué ocurre con esa unidad.

---

# 51. `RELEASE_DISTANCE` no participa en esta lógica

Aunque existe:

```cpp
RELEASE_DISTANCE = 600;
```

la liberación no utiliza:

```cpp
fort.DistTo(aux) <= RELEASE_DISTANCE
```

Utiliza:

```cpp
fort.DistTo(aux) <= fort.range
```

Por tanto el valor 600 es actualmente código muerto.

Si se pretendía utilizar un radio específico de liberación diferente a `fort.range`, habría que modificar la condición.

---

# 52. Cambio de propietario mientras hay auxiliares fuera

Si el Outpost cambia de propietario:

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

Esto evita apropiarse artificialmente de unidades normales que pertenecían al antiguo dueño.

---

# 53. Qué ocurre con la guarnición oficial durante la defensa auxiliar

La Sequence recupera:

```cpp
garrison =
    Group(
        garrisonGroup
    )
    .GetObjList();
```

pero no le da órdenes.

Sólo la utiliza como lista de exclusión:

```cpp
!garrison.Contains(
    settlementUnits[j]
)
```

Por tanto:

```text
Fortresses_Main
→ continúa controlando la guarnición oficial

OutpostAuxDefense_Main
→ controla únicamente las tropas normales auxiliares
```

Los dos sistemas pueden actuar simultáneamente durante un ataque sin seleccionar deliberadamente las mismas unidades.

---

# 54. Ataque combinado de la fortaleza

Si un Outpost conquistado tiene:

```text
10 guardianes oficiales
+
8 soldados normales almacenados
```

y aparece un enemigo:

```text
Fortresses_Main
→ saca y controla sus 10 guardianes oficiales

OutpostAuxDefense_Main
→ detecta las 8 tropas normales
→ las añade a __FRT_AUX_X_Y
→ las saca con advance
```

Resultado:

```text
18 defensores potenciales
```

pero gestionados por dos sistemas diferentes.

---

# 55. Paz después del combate

Cuando termina el ataque:

```text
Fortresses_Main
→ ordena enter_tent a su guarnición oficial

OutpostAuxDefense_Main
→ repliega auxiliares
→ espera cinco segundos
→ intenta enter_tent
→ las libera
```

La guarnición oficial continúa siendo estructural.

Las auxiliares vuelven a ser tropas normales.

---

# 56. No existe regeneración de auxiliares

Si una tropa normal muere durante la defensa:

```text
no reaparece
```

La Sequence no genera nuevas unidades.

No existe:

```cpp
Place(...)
```

en este sistema.

Las tropas auxiliares son exactamente las que el jugador había almacenado.

---

# 57. No existe un número mínimo de auxiliares

La Sequence no exige:

```text
mínimo 5
mínimo 10
```

Si sólo existe una unidad válida dentro del Settlement, esa unidad puede salir.

---

# 58. No existe selección por tipo concreto de civilización

No importa que la unidad sea:

```text
Hastatus
Maceman
Archer
Cavalry
Hero
...
```

La condición se basa en herencia:

```text
Military
o
BaseMage
```

Siempre que pertenezca al propietario y no esté en la guarnición oficial.

---

# 59. Atención con héroes

El código no excluye expresamente `Hero`.

Si una clase de héroe pertenece a una rama compatible con el filtro utilizado por:

```cpp
IsHeirOf("Military")
```

o:

```cpp
IsHeirOf("BaseMage")
```

podría ser seleccionada como auxiliar.

El documento fuente no aporta una exclusión específica para héroes.

Por tanto no debe afirmarse que los héroes estén protegidos de esta movilización.

---

# 60. No existe `GetCommanded()` en esta versión

La investigación previa recuperó patrones oficiales donde se utiliza:

```cpp
GetCommanded()
```

para detectar si un jugador ha tomado control manual de una unidad y dejar de administrarla.

Sin embargo, **esta Sequence concreta no utiliza `GetCommanded()`**.

Durante un ataque, mientras una unidad pertenezca a `auxGroup`, las órdenes defensivas se reimponen cada 500 ms.

Por tanto el jugador no puede recuperar control estable sobre una auxiliar hasta que sea eliminada del Group temporal.

---

# 61. Diferencia entre paz previa y paz posterior a un ataque

Antes de cualquier ataque:

```text
tropas almacenadas
→ control libre del jugador
→ Sequence no interviene
```

Después de que hayan sido movilizadas:

```text
desaparece amenaza
→ 5 segundos de repliegue controlado
→ enter_tent si están cerca
→ RemoveFromGroup
→ vuelven al control libre
```

---

# 62. Qué ocurre si el jugador saca manualmente una tropa del Outpost durante la paz

Si no hay enemigos:

- la Sequence no la añade a `auxGroup`;
- no le impone órdenes;
- no la obliga a regresar.

Por tanto puede utilizarla libremente.

El sistema sólo secuestra temporalmente unidades que estaban dentro del Settlement en el momento de detectarse una amenaza.

---

# 63. Qué ocurre si el jugador mete nuevas tropas mientras ya hay un ataque

Durante cada ciclo con enemigos se vuelve a ejecutar:

```cpp
settlementUnits =
    fort
    .settlement
    .Units();
```

Por tanto una nueva unidad introducida en el Outpost durante el combate puede ser detectada en un ciclo posterior y movilizada automáticamente si cumple los filtros.

Con:

```text
CONTROL_INTERVAL = 500 ms
```

esa incorporación puede ocurrir muy rápidamente.

---

# 64. Qué ocurre si una unidad vuelve a entrar durante el mismo ataque

Si sigue existiendo:

```text
enemies.count > 0
```

y la unidad vuelve a aparecer dentro de:

```cpp
settlement.Units()
```

pero sigue perteneciendo a `auxGroup`, la condición:

```cpp
!auxiliary.Contains(
    settlementUnits[j]
)
```

impide añadirla otra vez.

Además el bloque anterior sigue imponiendo órdenes de combate a las auxiliares registradas.

---

# 65. Qué ocurre si una auxiliar muere

En el siguiente ciclo:

```cpp
auxiliary.ClearDead();
```

elimina su referencia.

No existe ningún efecto adicional.

No se repone.

---

# 66. No modifica la captura del Outpost

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

# 67. No modifica la regeneración oficial

Tampoco toca:

```text
FG_Regen
FG_Turn
```

ni otros estados de `Fortresses_Main`.

La única variable de `Fortresses_Main` que lee es:

```text
FG_Init
```

y el único recurso compartido adicional es el Group `__FRT_X_Y`.

---

# 68. Condiciones necesarias para que funcione correctamente

El mapa debe cumplir:

1. `Fortresses_Main` debe existir y ejecutarse.
2. Los Outposts deben estar presentes desde el inicio.
3. Los Outposts deben ser clases culturales compatibles.
4. Los Players principales deben estar entre 1 y 8.
5. Las unidades normales que quieran participar deben poder almacenarse en `fort.settlement`.
6. La Sequence debe tener `Autorun allowed`.
7. No debe existir otra Sequence que utilice el mismo prefijo `__FRT_AUX_` con una semántica distinta.

---

# 69. Orden recomendado de configuración

En el editor deben existir como mínimo:

```text
Map
└── Sequences
    ├── Fortresses_Main
    │   └── Autorun allowed = Sí
    │
    └── OutpostAuxDefense_Main
        └── Autorun allowed = Sí
```

No es necesario garantizar un orden concreto de ejecución entre ambas mediante configuración manual, porque `OutpostAuxDefense_Main` espera a que:

```text
FG_Init = 1
```

antes de actuar sobre cada fortaleza.

---

# 70. Groups necesarios en el editor

Ninguno.

La Sequence utiliza:

```text
__FRT_X_Y
```

creado/gestionado dinámicamente por `Fortresses_Main`, y:

```text
__FRT_AUX_X_Y
```

creado de forma dinámica al añadir auxiliares.

No deben prepararse manualmente.

---

# 71. Areas necesarias

Ninguna.

Toda la detección utiliza:

```cpp
ObjsInRange(
    fort,
    ...,
    fort.range
)
```

---

# 72. Holders necesarios

Ninguno adicional.

El propio Outpost y su `Settlement` son suficientes.

---

# 73. Flujo completo durante un ataque

```text
Outpost conquistado
↓
FG_Init = 1
↓
jugador guarda tropas normales dentro
↓
paz
↓
OutpostAuxDefense_Main no las toca
↓
aparece enemigo dentro de fort.range
↓
OA_QuietClock = 0
↓
leer fort.settlement.Units()
↓
filtrar:
    InHolder
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
    reimponer órdenes cada 500 ms
    limitar persecución a fort.range
↓
desaparece el último enemigo
↓
cortar persecución inmediatamente
↓
move hacia fort.pos
↓
esperar 5 segundos continuados
↓
si sigue sin enemigos:
    si todavía está fuera de fort.range
        → move hacia fort.pos
    si ya está dentro de fort.range
        → enter_tent
        → RemoveFromGroup
↓
unidad vuelve a control normal
```

---

# 74. Flujo durante un cambio de propietario

```text
Outpost de Player A
↓
auxiliares de Player A desplegadas
↓
el edificio pasa a Player B
↓
OA_LastOwner != owner
↓
todas las auxiliares salen de __FRT_AUX_X_Y
↓
no cambian de jugador
↓
no reciben más órdenes de esta Sequence
↓
OA_LastOwner = Player B
↓
OA_QuietClock = 0
```

---

# 75. Diferencia respecto a `Fortresses_Main`

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
sólo las moviliza durante ataques
```

Ambas Sequences son complementarias.

---

# 76. Diferencia respecto a `GuardPosts_Main`

`GuardPosts_Main` crea una escolta externa permanente para `GGuardPost`.

`OutpostAuxDefense_Main` no se aplica a `GGuardPost`.

Aquí las unidades:

- proceden del interior del Outpost;
- son tropas normales del jugador;
- sólo quedan bajo control temporal.

---

# 77. Observaciones técnicas que conviene dejar documentadas

Existen dos detalles del código actual que no deben perderse.

## 77.1 `RELEASE_DISTANCE` no se utiliza

Se declara:

```cpp
RELEASE_DISTANCE = 600;
```

pero ninguna condición lo consulta.

La distancia efectiva es siempre:

```cpp
fort.range
```

## 77.2 La unidad se libera antes de confirmar `InHolder()`

Después de cinco segundos de paz:

```cpp
aux.SetCommand(
    "enter_tent",
    fort
);

aux.RemoveFromGroup(
    auxGroup
);
```

No existe una espera posterior del tipo:

```cpp
if (aux.InHolder())
```

Por tanto el sistema **intenta** devolver la unidad al Outpost y libera inmediatamente su control.

Esto parece deliberado para devolver el control manual al jugador lo antes posible.

---

# 78. Preparación exacta en el editor

La configuración necesaria es:

```text
Map
└── Sequences
    ├── Fortresses_Main
    │   ├── código correspondiente
    │   └── Autorun allowed = Sí
    │
    └── OutpostAuxDefense_Main
        ├── pegar este código
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

# 79. Resumen funcional

`OutpostAuxDefense_Main` implementa exactamente esta función:

```text
descubrir todos los Outposts culturales
        ↓
esperar a que Fortresses_Main los inicialice
        ↓
en paz:
    no tocar tropas normales almacenadas
        ↓
si aparece enemigo:
    detectar Military/BaseMage almacenados
    del propietario actual
        ↓
excluir guarnición oficial
        ↓
añadirlos a Group auxiliar temporal
        ↓
sacarlos con "advance"
        ↓
reimponer defensa cada 500 ms
        ↓
limitar persecución a fort.range
        ↓
cuando desaparece la amenaza:
    replegar inmediatamente hacia el Outpost
        ↓
esperar 5 segundos de paz
        ↓
ordenar "enter_tent" al estar dentro del radio
        ↓
eliminar del Group temporal
        ↓
devolver el control normal al jugador
```

Es una Sequence auxiliar de defensa que aprovecha las tropas normales almacenadas por el jugador sin convertirlas en una guarnición permanente ni modificar sus propiedades básicas.

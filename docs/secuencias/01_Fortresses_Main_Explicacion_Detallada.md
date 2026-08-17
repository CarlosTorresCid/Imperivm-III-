# Secuencia 1 — `Fortresses_Main`

`Fortresses_Main` es la secuencia principal del sistema universal de fortalezas. Su función es convertir todos los Outposts culturales del mapa en posiciones defensivas persistentes, con guarniciones ligadas a la cultura de la fortaleza, defensa automática, regeneración, control personalizado de la captura y soporte para reconquistas ilimitadas.

---

## 1. Qué hay que crear en el editor

Para esta secuencia la configuración manual es muy reducida.

### Hay que crear

- Una única Sequence llamada, por ejemplo, `Fortresses_Main`.
- Pegar en ella todo el código.
- Marcar **`Autorun allowed`**.
- Compilarla y guardar el escenario.

### No hay que crear

- Groups para cada fortaleza.
- Holders específicos.
- Areas.
- Marcadores de posición.
- Una Sequence diferente para cada fortaleza.
- Grupos de guarnición manuales.

La propia Sequence encuentra automáticamente los Outposts y crea sus grupos de seguimiento en tiempo de ejecución.

La estructura en el editor sería:

```text
Scenario
└── Map
    └── Sequences
        └── Fortresses_Main
            ├── Source: [código completo]
            └── Autorun allowed: activado
```

No es necesario preparar nada dentro de `Groups`.

---

## 2. Qué edificios controla

Al comenzar la partida, la Sequence busca todos los Outposts de estas siete clases:

| Cultura | Clase del edificio | Guarnición gestionada |
|---|---|---|
| Germania | `TOutpost` | 10 `TValkyrie` |
| Galia | `GOutpost` | 4 `GTridentWarrior` |
| Britania | `BOutpost` | 10 `BHighlander` |
| Iberia | `IOutpost` | 12 `ISlinger` + 10 `IDefender` |
| Cartago | `COutpost` | 24 `CMacemen` |
| Roma | `ROutpost` | 20 `RLiberatus` |
| Egipto | `EOutpost` | 10 `EHorusWarrior` + 10 `EAnubisWarrior` |

No gestiona:

- `GGuardPost`.
- Townhalls/Foros.
- `TTent`.
- Torres.
- Murallas.
- Puertas.
- Otros edificios.

`GGuardPost`, en particular, debe mantenerse en su sistema separado porque posee una arquitectura distinta de centinelas y `max_units=0`.

---

## 3. Descubrimiento automático de las fortalezas

La primera operación importante es construir la lista:

```cpp
ObjList forts;
```

Al comienzo de la partida se recorren los jugadores del 1 al 16:

```cpp
for (p = 1; p <= 16; p += 1)
```

y para cada jugador se buscan todas las clases culturales:

```cpp
forts.AddList(ClassPlayerObjs("TOutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("GOutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("BOutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("IOutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("COutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("ROutpost", p).GetObjList());
forts.AddList(ClassPlayerObjs("EOutpost", p).GetObjList());
```

Esto significa que la Sequence no necesita saber previamente:

- cuántas fortalezas existen;
- dónde están;
- qué jugador las posee;
- cómo se llaman en el editor.

Las encuentra directamente a partir de su clase.

### Consecuencia importante

Este descubrimiento se ejecuta **una sola vez**, antes del bucle permanente.

Eso está pensado para un mapa en el que todos los Outposts ya existen al comenzar la partida.

Un Outpost creado dinámicamente después de comenzar la partida no se incorporaría automáticamente a `forts`.

Para el mapa actual esto no supone ningún problema si todas las fortalezas están colocadas previamente en el editor.

---

## 4. Qué ocurre cuando una fortaleza cambia de propietario

Aunque la búsqueda inicial se haga según el propietario inicial, la lista `forts` conserva la referencia al edificio.

Por ejemplo:

```text
TOutpost neutral → Player 15
        ↓
lo conquista Player 3
        ↓
sigue siendo el mismo objeto
        ↓
continúa dentro de forts
```

Por eso no hace falta volver a ejecutar:

```cpp
ClassPlayerObjs(...)
```

cada vez que una fortaleza cambia de dueño.

En cada ciclo simplemente se vuelve a consultar:

```cpp
owner = fort.player;
```

Así la Sequence trabaja siempre con el propietario actual.

---

## 5. Parámetros globales

La secuencia tiene tres parámetros fundamentales:

```cpp
REGEN_INTERVAL = 20000;
DEFENDER_LEVEL = 20;
CONTROL_INTERVAL = 500;
```

| Parámetro | Valor | Función |
|---|---:|---|
| `REGEN_INTERVAL` | 20.000 ms | Una baja puede regenerarse cada 20 segundos |
| `DEFENDER_LEVEL` | 20 | Nivel de toda unidad creada por el sistema |
| `CONTROL_INTERVAL` | 500 ms | Frecuencia del controlador principal |

El núcleo del sistema se ejecuta, por tanto, dos veces por segundo.

Esto explica por qué las tropas de guarnición quedan prácticamente bloqueadas para uso ofensivo: la Sequence vuelve a imponerles órdenes cada medio segundo.

---

## 6. Tratamiento especial de la fortaleza egipcia al comenzar la partida

Egipto es una excepción importante.

Los demás Outposts neutrales conservan inicialmente la defensa nativa del juego. El `EOutpost`, en cambio, recibe una defensa diseñada específicamente para este mapa:

```text
10 Guerreros de Horus
+
10 Guerreros de Anubis
```

Por eso, antes incluso de comenzar el bucle principal, se recorren todos los Outposts:

```cpp
if (fort.IsHeirOf("EOutpost"))
```

Si el EOutpost es neutral:

```cpp
if (owner > 8)
```

se fija primero:

```cpp
fort.settlement.SetLoyalty(100);
```

y después se crean las veinte unidades.

---

## 7. Cómo se crean las 20 unidades egipcias

Para cada Guerrero de Horus:

```cpp
u = Place("EHorusWarrior", fort.pos, owner);
u.SetLevel(DEFENDER_LEVEL);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
fort.settlement.ForceAddUnit(u);
u.AddToGroup(groupName);
```

El mismo patrón se repite con `EAnubisWarrior`.

### `Place()`

```cpp
u = Place("EHorusWarrior", fort.pos, owner);
```

Crea físicamente la unidad.

### `SetLevel(20)`

```cpp
u.SetLevel(DEFENDER_LEVEL);
```

Todas las guarniciones gestionadas por esta Sequence son nivel 20.

### `SetFood(20)`

Proporciona comida inicial a la unidad.

### `SetFeeding(false)`

```cpp
u.SetFeeding(false);
```

La unidad deja de depender del sistema normal de alimentación.

La guarnición no consume comida del jugador y no puede morir de hambre.

### `SetNoAIFlag(true)`

```cpp
u.SetNoAIFlag(true);
```

Evita que la IA estratégica del jugador utilice esas tropas como parte de sus ejércitos normales.

Esto es especialmente importante cuando una fortaleza pertenece a un jugador controlado por la CPU.

### `ForceAddUnit()`

```cpp
fort.settlement.ForceAddUnit(u);
```

Introduce la unidad dentro del Settlement del Outpost.

### `AddToGroup()`

```cpp
u.AddToGroup(groupName);
```

Registra la unidad como miembro de la guarnición especial de esa fortaleza.

---

## 8. Los Groups de guarnición se crean automáticamente

No hay que crear manualmente grupos como:

```text
FortalezaGermana1_Garrison
FortalezaGermana2_Garrison
FortalezaIbera1_Garrison
```

La Sequence genera el nombre a partir de las coordenadas del propio edificio:

```cpp
groupName = "__FRT_" + fort.pos.x + "_" + fort.pos.y;
```

Por ejemplo, una fortaleza situada aproximadamente en:

```text
x = 12750
y = 8300
```

utilizaría internamente algo equivalente a:

```text
__FRT_12750_8300
```

Las unidades se añaden mediante:

```cpp
u.AddToGroup(groupName);
```

y posteriormente se recuperan con:

```cpp
garrison = Group(groupName).GetObjList();
```

### Importante

**No hay que crear esos Groups en el editor.**

Son grupos de ejecución administrados por la propia Sequence.

La ventaja es que el mismo código puede controlar muchas fortalezas sin necesitar un grupo manual por cada una.

---

## 9. Estado persistente asociado a cada fortaleza

Además de los Groups, el sistema guarda pequeñas variables directamente en cada edificio mediante:

```cpp
EnvReadInt(...)
EnvWriteInt(...)
```

Cada fortaleza mantiene su propio estado independiente.

Las claves utilizadas son:

| Variable | Función |
|---|---|
| `FG_NeutralInit` | Indica si se creó la guarnición neutral egipcia |
| `FG_ExpectedOwner` | Propietario legítimo del EOutpost |
| `FG_Init` | Indica que el sistema ya ha tomado el control de la fortaleza |
| `FG_FirstDelay` | Temporizador de la primera conquista |
| `FG_Regen` | Temporizador de regeneración |
| `FG_Turn` | Alternancia entre dos tipos de unidades |
| `FG_CarthageCleanup` | Ventana de eliminación de aldeanos cartagineses |

Esto permite utilizar una sola Sequence para todas las fortalezas.

---

## 10. Los Outposts neutrales normales se dejan completamente intactos

Después de identificar la cultura de cada fortaleza, la Sequence comprueba:

```cpp
if (
    owner > 8
    && initialized == 0
    && isEgypt == 0
)
{
    continue;
}
```

Mientras una fortaleza no egipcia:

- continúe neutral;
- y nunca haya sido conquistada;

la Sequence no interviene.

Por tanto siguen funcionando las defensas originales del juego.

```text
TOutpost → defensa neutral nativa
GOutpost → defensa neutral nativa
BOutpost → defensa neutral nativa
IOutpost → defensa neutral nativa
COutpost → defensa neutral nativa
ROutpost → defensa neutral nativa
```

El sistema personalizado comienza después de su primera conquista.

Egipto es la excepción porque su guarnición neutral se sustituye deliberadamente.

---

## 11. Primera conquista de una fortaleza normal

Cuando el comportamiento original del juego conquista un Outpost neutral, su propietario cambia a uno de los jugadores reales:

```cpp
owner >= 1
&& owner <= 8
```

Si además:

```cpp
initialized == 0
```

la Sequence interpreta que es la primera entrada de esa fortaleza en el sistema personalizado.

La transición es:

```text
sistema nativo
        ↓
primera conquista
        ↓
Fortresses_Main toma el control
        ↓
sistema personalizado permanente
```

---

## 12. Espera de un segundo después de la conquista

La Sequence no crea inmediatamente la nueva guarnición.

Utiliza:

```cpp
firstDelay = EnvReadInt(fort, "FG_FirstDelay");
firstDelay += CONTROL_INTERVAL;
```

Como el controlador se ejecuta cada 500 ms:

```text
primer ciclo → 500 ms
segundo ciclo → 1000 ms
```

Hasta llegar a:

```cpp
if (firstDelay < 1000)
{
    continue;
}
```

De este modo se da aproximadamente un segundo al comportamiento original del Outpost para terminar su proceso de captura.

No se utiliza un `Sleep(1000)` dentro de cada fortaleza, ya que eso bloquearía temporalmente toda la Sequence.

Cada edificio mantiene su propio temporizador mediante `EnvReadInt/EnvWriteInt`.

---

## 13. Tratamiento particular del `COutpost`

Cartago necesita una corrección específica.

La primera vez que se conquista un `COutpost`, el comportamiento nativo puede introducir `CVillager`.

El diseño de esta Sequence quiere conservar los guerreros con maza, pero eliminar ese bonus automático de aldeanos.

Por eso lee:

```cpp
settlementUnits = fort.settlement.Units();
```

y busca exclusivamente:

```cpp
IsHeirOf("CVillager")
```

Esas unidades son eliminadas:

```cpp
settlementUnits[j].SetHealth(0);
```

### Qué no elimina

No toca los `CMacemen`.

Tampoco desactiva el comportamiento normal del COutpost que permite introducir campesinos posteriormente.

```text
campesinos generados automáticamente en primera captura
→ eliminados

campesinos que el jugador introduce voluntariamente más adelante
→ no afectados
```

---

## 14. Ventana de seguridad cartaginesa de cinco segundos

Existe un segundo mecanismo porque el comportamiento nativo podría crear alguno de esos aldeanos unas décimas después.

Al terminar la primera inicialización:

```cpp
EnvWriteInt(
    fort,
    "FG_CarthageCleanup",
    5000
);
```

Durante los siguientes cinco segundos, cada 500 ms se vuelve a revisar el Settlement.

Si aparece un `CVillager`, se elimina.

Transcurrido ese tiempo:

```text
FG_CarthageCleanup = 0
```

y esa limpieza queda desactivada.

---

## 15. Creación de la guarnición del primer conquistador

Una vez transcurrido el segundo de espera, la Sequence genera la guarnición completa de la cultura del edificio.

La composición depende de la cultura de la fortaleza, no de la civilización del jugador que la conquista.

Ejemplo:

```text
Jugador romano conquista TOutpost germano
```

No aparecen romanos.

Aparecen:

```text
10 TValkyrie
```

pero pertenecen al jugador romano.

Así se conserva permanentemente la identidad cultural de cada fortaleza.

---

## 16. La cultura se determina por la clase del edificio

En cada ciclo se ejecuta una cadena de comprobaciones:

```cpp
if (fort.IsHeirOf("TOutpost"))
...
else if (fort.IsHeirOf("GOutpost"))
...
```

A partir de ahí se establecen:

```cpp
cls1
cls2
max1
max2
```

Ejemplo para Germania:

```cpp
cls1 = "TValkyrie";
max1 = 10;
```

Ejemplo para Iberia:

```cpp
cls1 = "ISlinger";
cls2 = "IDefender";

max1 = 12;
max2 = 10;
```

Esto permite utilizar el mismo sistema de regeneración para fortalezas con uno o dos tipos de defensor.

---

## 17. Reconstrucción de la guarnición en cada ciclo

Una vez una fortaleza está gestionada por la Sequence, se recupera su grupo:

```cpp
garrison = Group(groupName).GetObjList();
garrison.ClearDead();
```

`ClearDead()` elimina las referencias a unidades muertas.

Después se separan las unidades por clase:

```cpp
pool1.Clear();
pool2.Clear();
```

y:

```cpp
if (garrison[j].IsHeirOf(cls1))
{
    pool1.Add(garrison[j]);
}
```

o, si existe un segundo tipo:

```cpp
pool2.Add(garrison[j]);
```

Finalmente:

```cpp
count1 = pool1.count;
count2 = pool2.count;
```

Con esto la Sequence sabe exactamente cuántos defensores quedan de cada clase.

---

## 18. El `EOutpost` necesita otro sistema adicional de protección

La fortaleza egipcia presenta un problema diferente: su mecanismo original puede cambiar de propietario por proximidad aunque todavía queden defensores.

Para evitarlo se mantiene una variable:

```cpp
FG_ExpectedOwner
```

que representa al propietario considerado legítimo por `Fortresses_Main`.

Por ejemplo:

```text
EOutpost pertenece a Player 3

FG_ExpectedOwner = 3
```

Si el motor cambia prematuramente el edificio a Player 5 mientras todavía quedan Horus o Anubis:

```cpp
if (fort.player != expectedOwner)
```

la Sequence lo corrige inmediatamente:

```cpp
fort.SetPlayer(expectedOwner);
fort.settlement.SetLoyalty(100);
```

y además restaura el propietario de todos los defensores:

```cpp
defender.SetPlayer(expectedOwner);
```

---

## 19. Por qué existe `queryOwner`

Normalmente:

```cpp
queryOwner = owner;
```

Pero en Egipto:

```cpp
queryOwner = expectedOwner;
```

Puede existir durante unos instantes una discrepancia entre:

```text
fort.player
```

y:

```text
propietario legítimo según Fortresses_Main
```

Las consultas de enemigos y aliados deben realizarse respecto al segundo.

De lo contrario, si el motor cambia prematuramente el propietario, los atacantes podrían dejar de figurar como enemigos en la consulta.

---

## 20. Cómo detecta atacantes

Primero obtiene todas las unidades dentro del radio del Outpost:

```cpp
qRange = ObjsInRange(fort, "Unit", fort.range);
```

Después busca:

```cpp
EnemyObjs(queryOwner, "Military")
```

y:

```cpp
EnemyObjs(queryOwner, "BaseMage")
```

Es decir, cuentan:

- tropas militares enemigas;
- magos enemigos.

Posteriormente elimina:

```cpp
EnemyObjs(queryOwner, "Sentry")
```

por lo que los centinelas no se consideran una fuerza atacante normal.

Finalmente también se buscan:

```cpp
EnemyObjs(queryOwner, "Catapult")
```

entre los Buildings del radio.

Para este sistema un atacante válido puede ser:

```text
Military
BaseMage
Catapult
```

pero no un `Sentry`.

---

## 21. Cómo detecta a los defensores externos

Destruir la guarnición especial no basta para capturar la fortaleza.

La Sequence comprueba también si el propietario mantiene tropas normales cerca.

Busca:

```cpp
ClassPlayerObjs("Military", queryOwner)
```

y:

```cpp
ClassPlayerObjs("BaseMage", queryOwner)
```

y las intersecta con:

```cpp
ObjsInRange(fort, "Unit", fort.range)
```

El resultado se almacena en:

```cpp
friends
```

Ejemplo:

```text
Fortaleza de Player 3
Guarnición especial: 0
Soldados normales de Player 3 cerca: 15
Atacantes de Player 5 cerca: 30
```

La fortaleza no se conquista todavía.

La posición se considera disputada.

---

## 22. Las tres condiciones de captura

La captura personalizada sólo se ejecuta cuando se cumplen simultáneamente:

```cpp
garrison.count == 0
&& enemies.count > 0
&& friends.count == 0
```

Traducido:

1. Ha muerto toda la guarnición especial.
2. Existen atacantes en el radio.
3. No queda ninguna fuerza militar del propietario defendiendo la posición.

```text
¿Queda guarnición?
        │
      Sí ─────→ no captura
        │
       No
        ↓
¿Hay atacantes?
        │
      No ─────→ no captura
        │
       Sí
        ↓
¿Quedan defensores del propietario?
        │
      Sí ─────→ posición disputada
        │
       No
        ↓
      CAPTURA
```

---

## 23. Cómo decide quién conquista la fortaleza

Cuando la posición finalmente puede ser conquistada:

```cpp
newOwner = enemies[rand(enemies.count)].player;
```

Se escoge aleatoriamente uno de los objetos atacantes presentes.

Después se comprueba:

```cpp
if (
    newOwner < 1
    || newOwner > 8
)
{
    continue;
}
```

Por tanto únicamente los jugadores 1-8 pueden convertirse en propietarios.

### Combates de tres bandos

Si Player 2 y Player 5 están atacando simultáneamente, el vencedor no se determina por:

- quién causó el último golpe;
- quién tiene más tropas como regla explícita;
- quién llegó primero.

Se toma aleatoriamente una entidad de `enemies`.

Esto produce una ponderación indirecta por cantidad de objetos presentes: un jugador con más unidades tendrá más entradas en la lista y, por tanto, más posibilidades de ser seleccionado.

---

## 24. Qué ocurre inmediatamente después de una conquista

La Sequence ejecuta:

```cpp
fort.SetPlayer(newOwner);
fort.settlement.SetLoyalty(100);
```

Después reinicia el estado interno:

```text
FG_Init = 1
FG_FirstDelay = 0
FG_Regen = 0
FG_Turn = 1
```

Y crea inmediatamente la guarnición completa.

El nuevo propietario recibe directamente el máximo definido para esa cultura.

Por ejemplo, una fortaleza íbera pasa a:

```text
12 Slingers
+
10 Defenders
```

Después de ese momento las bajas posteriores sí se regeneran gradualmente.

---

## 25. Defensa automática cuando hay enemigos

Si:

```cpp
enemies.count > 0
```

se cancela el temporizador de regeneración:

```cpp
EnvWriteInt(fort, "FG_Regen", 0);
```

No se regenera ninguna unidad durante un combate.

Después se recorre toda la guarnición.

Si un defensor se ha alejado más que:

```cpp
fort.range
```

se le ordena volver:

```cpp
defender.SetCommand("move", fort.pos);
```

Si continúa dentro del radio defensivo:

```cpp
defender.SetCommand("advance", enemies[0].pos);
```

Así la guarnición sale automáticamente a combatir.

---

## 26. Por qué el jugador no puede utilizar estas tropas como ejército

La orden anterior se ejecuta dentro del controlador que despierta cada 500 ms.

Si el jugador intenta seleccionar una unidad de la guarnición y enviarla a otro lugar, en el siguiente ciclo `Fortresses_Main` vuelve a imponer la orden defensiva correspondiente.

Además:

```cpp
SetNoAIFlag(true)
```

impide que la IA estratégica se apropie de ellas.

Estas unidades están concebidas como una extensión funcional de la fortaleza, no como un ejército gratuito.

---

## 27. Qué ocurre cuando termina el combate

Si:

```cpp
enemies.count == 0
```

todas las unidades reciben:

```cpp
defender.SetCommand("enter_tent", fort);
```

El comportamiento es:

```text
enemigos detectados
→ salir a defender

enemigos eliminados
→ volver al Outpost
```

La orden se vuelve a imponer cada 500 ms hasta que la situación cambie.

---

## 28. Regeneración de bajas

La regeneración sólo ocurre si no hay enemigos.

Se comprueba:

```cpp
count1 < max1
||
count2 < max2
```

Si falta alguna unidad, comienza a incrementarse:

```cpp
FG_Regen
```

a razón de 500 ms por ciclo.

Al alcanzar:

```text
20000 ms
```

se genera exactamente una unidad.

Después:

```text
FG_Regen = 0
```

y debe transcurrir otro intervalo completo para la siguiente.

```text
1 baja   → 20 s
2 bajas  → 40 s
3 bajas  → 60 s
...
```

siempre que durante ese periodo no aparezcan enemigos.

---

## 29. Qué sucede si reaparece un enemigo durante la regeneración

En cuanto:

```cpp
enemies.count > 0
```

se ejecuta:

```cpp
EnvWriteInt(fort, "FG_Regen", 0);
```

El progreso acumulado se pierde.

Ejemplo:

```text
han pasado 18 segundos de regeneración
        ↓
aparece un enemigo
        ↓
FG_Regen vuelve a 0
        ↓
termina el ataque
        ↓
son necesarios otros 20 segundos completos
```

Esto evita que durante una batalla aparezca repentinamente un defensor porque el temporizador ya estaba casi terminado.

---

## 30. Alternancia en fortalezas con dos tipos de unidad

Iberia y Egipto tienen dos pools.

Por ejemplo:

```text
Iberia:
12 ISlinger
10 IDefender
```

Cuando faltan unidades de ambos tipos se utiliza:

```cpp
FG_Turn
```

para alternar:

```text
Slinger
Defender
Slinger
Defender
...
```

Así se mantienen ambos pools de forma progresiva.

Si únicamente falta un tipo, el sistema regenera directamente ese tipo.

---

## 31. El Egipto neutral no regenera

Hay una excepción deliberada:

```cpp
if (
    isEgypt == 1
    && owner > 8
    && initialized == 0
)
{
    EnvWriteInt(fort, "FG_Regen", 0);
    continue;
}
```

La guarnición egipcia neutral inicial es finita.

Ejemplo:

```text
inicio:
10 Horus + 10 Anubis

mueren 4 Horus durante un ataque fallido

queda:
6 Horus + 10 Anubis
```

No reaparecerán mientras el fortín siga neutral.

Una vez conquistado y pasado al sistema persistente, sí comienza la regeneración normal.

---

## 32. Ciclo completo de una fortaleza no egipcia

### Estado 1 — Neutral

```text
Outpost neutral
↓
Fortresses_Main no interviene
↓
funciona la defensa original del juego
```

### Estado 2 — Primera conquista

```text
motor original cambia propietario
↓
Fortresses_Main lo detecta
↓
espera aproximadamente 1 segundo
↓
crea guarnición completa cultural
↓
FG_Init = 1
```

### Estado 3 — Propiedad estable

```text
sin enemigos
↓
guarnición dentro
↓
regenera lentamente las bajas
```

### Estado 4 — Ataque

```text
enemigos en fort.range
↓
regeneración = 0
↓
guarnición sale
↓
combate
```

### Estado 5A — Defensa exitosa

```text
enemigos = 0
↓
fortaleza continúa con mismo propietario
↓
guarnición vuelve dentro
↓
comienza regeneración de bajas
```

### Estado 5B — Guarnición destruida pero hay ejército aliado

```text
guarnición = 0
enemigos > 0
friends > 0
↓
posición disputada
↓
NO cambia propietario
↓
NO regenera
```

### Estado 5C — Conquista

```text
guarnición = 0
enemigos > 0
friends = 0
↓
selección de nuevo propietario
↓
SetPlayer(newOwner)
↓
guarnición completa inmediata
↓
comienza nuevo ciclo
```

El ciclo puede repetirse indefinidamente.

---

## 33. Diferencia entre la primera conquista y las siguientes

### Primera conquista

En los Outposts no egipcios todavía se utiliza el comportamiento original del juego:

```text
Neutral
↓
captura nativa
↓
Fortresses_Main detecta el resultado
```

### Segunda y siguientes

La Sequence mantiene:

```cpp
fort.settlement.SetLoyalty(100);
```

y ejecuta su propia lógica de captura.

```text
primera captura
= transición desde sistema nativo

reconquistas
= gestionadas por Fortresses_Main
```

---

## 34. `SetLoyalty(100)` y por qué aparece constantemente

Después de inicializar una fortaleza, prácticamente cada ciclo ejecuta:

```cpp
fort.settlement.SetLoyalty(100);
```

La intención es impedir que la captura convencional por loyalty interfiera con las reglas personalizadas.

La condición real de captura pasa a ser:

```text
guarnición especial = 0
+
enemigos > 0
+
defensores propios = 0
```

Por eso la loyalty deja de gobernar la conquista de estas fortalezas una vez integradas en el sistema.

---

## 35. Qué ocurre si una fortaleza queda vacía después de un ataque fallido

Puede darse este caso:

```text
guarnición = 0
enemigos = 0
```

La fortaleza no cambia de propietario.

Como tampoco hay enemigos, vuelve a activarse la regeneración.

Después de 20 segundos:

```text
aparece 1 defensor
```

20 segundos después:

```text
aparece otro
```

y así sucesivamente hasta recuperar la guarnición completa.

Destruir la defensa no basta por sí solo: para conquistar hay que mantener presencia atacante cuando desaparece la última defensa.

---

## 36. Configuración manual necesaria, resumida

Para utilizar esta Sequence correctamente en el mapa:

1. Crear una única Sequence.
2. Nombrarla `Fortresses_Main`.
3. Pegar el código completo.
4. Marcar `Autorun allowed`.
5. Compilar.
6. Guardar el escenario.
7. Asegurarse de que los Outposts que debe controlar el sistema ya están colocados al iniciar la partida.
8. No crear Groups de guarnición.
9. No crear Areas.
10. No crear Holders.
11. No preparar puntos de aparición.
12. No crear una Sequence por fortaleza.

La Sequence realiza el seguimiento mediante identificación de clase, coordenadas, Groups dinámicos y variables persistentes del propio edificio.

---

## 37. Condiciones que conviene respetar en el mapa

### Los neutrales deben utilizar un Player entre 9 y 16

El descubrimiento recorre:

```cpp
p = 1 ... 16
```

y el código interpreta:

```cpp
owner > 8
```

como propietario neutral/no jugable.

Si un Outpost se colocase con `player = 0`, este código no lo descubriría.

Si los neutrales utilizan 15/16, no hay problema.

### Los Outposts deben existir al arrancar

Como `forts` se construye una sola vez, un nuevo Outpost creado dinámicamente a mitad de partida no quedaría incorporado automáticamente.

### Debe haber una sola instancia de `Fortresses_Main`

No conviene ejecutar dos copias simultáneas de esta Sequence.

Ambas intentarían administrar las mismas fortalezas y podrían duplicar órdenes o interferir en los temporizadores.

La configuración correcta es:

```text
1 Sequence
+
1 Autorun
```

---

## 38. Caso especial: Outposts que ya pertenezcan a jugadores al inicio

La detección de primera conquista es:

```cpp
owner >= 1
&& owner <= 8
&& initialized == 0
&& isEgypt == 0
```

La Sequence no distingue entre:

```text
un fortín neutral que acaba de ser conquistado
```

y:

```text
un fortín que ya pertenecía a Player 1 al comenzar la partida
```

En ambos casos observa:

```text
owner = 1..8
FG_Init = 0
```

y los trata igual.

Por tanto, si existe un `TOutpost`, `COutpost`, etc. ya propiedad de un jugador desde el segundo 0, aproximadamente un segundo después del inicio recibirá automáticamente su guarnición completa personalizada.

En un `COutpost` inicial perteneciente a un jugador también se activaría la limpieza inicial de `CVillager`.

Si todos los Outposts empiezan neutrales, no hay que modificar nada.

---

## 39. Particularidad equivalente del `EOutpost` inicial

La preinicialización egipcia completa:

```text
10 Horus + 10 Anubis
```

se ejecuta sólo cuando:

```cpp
owner > 8
```

Por tanto el código está diseñado pensando en que el `EOutpost` especial comience neutral.

Si un `EOutpost` comenzase ya en manos de Player 1-8, no pasaría por esa preinicialización de veinte unidades y su comportamiento inicial sería diferente.

Si las fortalezas empiezan neutrales, no hay ningún problema.

---

## 40. Qué representa esta Sequence dentro del mod

`Fortresses_Main` no es simplemente un generador de soldados.

Después de la primera conquista sustituye buena parte de la lógica de las fortalezas por un controlador territorial propio:

```text
descubrimiento automático
        ↓
identidad cultural
        ↓
seguimiento individual por Group
        ↓
estado individual mediante EnvReadInt/EnvWriteInt
        ↓
detección de enemigos
        ↓
detección de defensores
        ↓
defensa automática
        ↓
captura personalizada
        ↓
cambio de propietario
        ↓
reposición completa tras conquista
        ↓
regeneración gradual
        ↓
reconquista ilimitada
```

La característica principal de su arquitectura es que todo se realiza con una sola Sequence para todos los Outposts del mapa.

---

## 41. Preparación exacta en el editor

La preparación necesaria para esta primera Sequence es:

```text
Map
└── Sequences
    └── Fortresses_Main
        ├── pegar código
        ├── Compile
        └── Autorun allowed = Sí
```

### Elementos adicionales necesarios

- **Groups adicionales:** ninguno.
- **Areas adicionales:** ninguna.
- **Holders adicionales:** ninguno.
- **Marcadores:** ninguno.

La única condición importante es que las fortalezas que se quieran controlar sean realmente objetos `TOutpost`, `GOutpost`, `BOutpost`, `IOutpost`, `COutpost`, `ROutpost` o `EOutpost`, y que estén presentes desde el inicio del escenario.

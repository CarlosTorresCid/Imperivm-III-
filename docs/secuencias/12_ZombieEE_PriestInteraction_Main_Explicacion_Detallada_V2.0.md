# Secuencia 12 — `ZombieEE_PriestInteraction_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_PriestInteraction_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_PriestInteraction_Main` es el gestor central de interacción presencial con el sacerdote egipcio del Easter Egg.

La Sequence no decide cuándo se completa cada fase narrativa. Esa información le llega mediante:

```text
EE_PRIEST_PENDING
```

Su función es:

```text
esperar a que exista un diálogo pendiente
↓
mostrar al jugador el objetivo:
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
recordarlo cada 15 segundos
↓
comprobar que César y el sacerdote existen
↓
esperar a que César esté a ≤180
↓
borrar EE_PRIEST_PENDING antes de lanzar el diálogo
↓
ejecutar la Sequence correspondiente
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

y es iniciada desde:

```text
ZombieIntro_Main
```

mediante:

```cpp
RunSequence(
    "ZombieEE_PriestInteraction_Main"
);
```

---

# 1. Función dentro del Easter Egg

`ZombieEE_PriestInteraction_Main` convierte un estado abstracto:

```text
EE_PRIEST_PENDING = N
```

en una interacción física:

```text
el jugador debe llevar a César
hasta el sacerdote egipcio
```

Sólo cuando ambos están suficientemente cerca se ejecuta el diálogo correspondiente.

---

# 2. Por qué existe esta Sequence

Sin esta capa, una fase del Easter Egg podría ejecutar directamente:

```cpp
RunSequence(
    "ZombieEE_DialogueXX"
);
```

justo después de completar una condición.

Eso provocaría conversaciones automáticas aunque César estuviera:

```text
en otra ciudad
en combate
en el extremo opuesto del mapa
```

La arquitectura actual obliga al jugador a volver presencialmente al sacerdote.

---

# 3. Autorun

La configuración correcta es:

```text
ZombieEE_PriestInteraction_Main
→ AUTORUN = NO
```

La intro la lanza una única vez.

Después permanece ejecutándose durante todo el flujo del Easter Egg.

---

# 4. Inicio desde `ZombieIntro_Main`

Al terminar la introducción se ejecuta:

```cpp
RunSequence(
    "ZombieEE_PriestInteraction_Main"
);
```

antes de:

```cpp
RunSequence(
    "ZombieEE_FirstHordeTrigger"
);

RunSequence(
    "ZombieWaves_Main"
);
```

Por tanto el gestor de interacción ya está esperando antes de que pueda aparecer el primer `EE_PRIEST_PENDING`.

---

# 5. Variables principales

La Sequence declara:

```cpp
ObjList q;
ObjList stateList;

Building state;
Unit u_capitan;
Unit u_sacerdote;

int pending;
int lastPending;
int reminderAt;
int priestReady;
```

---

# 6. `q`

Es una lista reutilizada para recuperar:

```text
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 7. `stateList`

Se utiliza exclusivamente para:

```text
CapitalForum_P1
```

y obtener el objeto global de estado.

---

# 8. `state`

Representa el `Building` contenido en:

```text
CapitalForum_P1
```

Sobre él se lee y escribe:

```text
EE_PRIEST_PENDING
```

---

# 9. `u_capitan`

Es la unidad César obtenida desde:

```text
ZombieEE_Caesar
```

---

# 10. `u_sacerdote`

Es el sacerdote egipcio obtenido desde:

```text
ZombieEE_Priest01
```

Sólo se adquiere cuando existe realmente un diálogo pendiente.

---

# 11. `pending`

Contiene el valor actual de:

```text
EE_PRIEST_PENDING
```

Los valores válidos del flujo actual son:

```text
1
2
3
4
5
```

---

# 12. `lastPending`

Se utiliza para detectar que ha aparecido un nuevo objetivo de diálogo.

Se inicializa:

```cpp
lastPending = 0;
```

---

# 13. `reminderAt`

Guarda el siguiente instante en el que debe repetirse:

```text
VE A HABLAR CON EL SACERDOTE EGIPCIO
```

Se inicializa:

```cpp
reminderAt = 0;
```

---

# 14. `priestReady`

Indica si existe exactamente una unidad válida dentro de:

```text
ZombieEE_Priest01
```

durante un estado pendiente.

---

# 15. Bucle permanente

La Sequence entra en:

```cpp
while(1)
{
    Sleep(500);
    ...
}
```

Por tanto revisa el estado aproximadamente:

```text
2 veces por segundo
```

---

# 16. Por qué refresca todas las referencias

La cabecera de la versión v2.0 indica expresamente:

```text
Refresca Cesar, sacerdote y edificio de estado
en cada ciclo.
No conserva handles de Unit/Building
a traves de esperas prolongadas.
```

Esto es una medida de estabilidad.

---

# 17. Refresco de `CapitalForum_P1`

Cada 500 ms:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después:

```cpp
if(stateList.count != 1)
    return;
```

---

# 18. Consecuencia si falla `CapitalForum_P1`

Si deja de resolver exactamente a un objeto:

```text
la Sequence termina
```

No existe reintento posterior.

---

# 19. Renovación de `state`

Cuando el Group es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

La referencia se obtiene de nuevo en cada ciclo.

---

# 20. Refresco de César

Después:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

y:

```cpp
if(q.count != 1)
    return;
```

---

# 21. Consecuencia si César deja de existir

Si:

```text
ZombieEE_Caesar.count != 1
```

la Sequence finaliza.

El Easter Egg presupone la existencia de un único César válido.

---

# 22. Renovación de `u_capitan`

Cuando el Group es correcto:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 23. Lectura de `EE_PRIEST_PENDING`

Cada ciclo:

```cpp
pending =
    EnvReadInt(
        state,
        "EE_PRIEST_PENDING"
    );
```

---

# 24. Estado sin diálogo pendiente

Si:

```text
pending == 0
```

la Sequence no necesita al sacerdote.

No ejecuta:

```text
Group("ZombieEE_Priest01")
```

para continuar el flujo.

---

# 25. Por qué sólo busca al sacerdote si `pending > 0`

El código contiene:

```cpp
if(pending > 0)
```

antes de recuperar:

```text
ZombieEE_Priest01
```

Esto evita exigir que el sacerdote exista durante fases en las que puede estar oculto.

---

# 26. Relación con `ZombieEE_Dialogue04`

La cabecera interna recuerda:

```text
Dialogue04 puede ocultar al sacerdote
y el asalto final lo restaura.
```

Por tanto el gestor debe tolerar:

```text
sacerdote temporalmente inexistente
```

---

# 27. Inicialización de `priestReady`

Antes de comprobar el sacerdote:

```cpp
priestReady = 0;
```

---

# 28. Recuperación del sacerdote

Si:

```text
pending > 0
```

se ejecuta:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 29. Condición exacta de disponibilidad

Sólo si:

```cpp
q.count == 1
```

se hace:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();

priestReady = 1;
```

---

# 30. Qué ocurre si el Group está vacío

Si:

```text
ZombieEE_Priest01.count == 0
```

entonces:

```text
priestReady = 0
```

y no se muestra recordatorio ni se intenta ejecutar ningún diálogo.

El ciclo vuelve a intentarlo 500 ms después.

---

# 31. Qué ocurre si hay más de un sacerdote

Si:

```text
q.count > 1
```

también queda:

```text
priestReady = 0
```

No se selecciona una unidad arbitrariamente.

---

# 32. Ventaja de este comportamiento

Durante la transición:

```text
sacerdote oculto
↓
asalto final
↓
sacerdote restaurado
```

el gestor puede permanecer activo sin fallar.

---

# 33. Primer aviso al aparecer un nuevo `pending`

La condición es:

```cpp
if(
    pending > 0
    &&
    priestReady == 1
    &&
    pending != lastPending
)
```

---

# 34. Texto del objetivo

Se muestra:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "VE A HABLAR CON EL SACERDOTE EGIPCIO"
);
```

---

# 35. Identificador de anuncio

El canal utilizado es:

```text
ZombieEEObjective
```

La misma ID permite:

```text
actualizar
ocultar
reutilizar
```

el objetivo durante todo el Easter Egg.

---

# 36. Registro de `lastPending`

Después del primer aviso:

```cpp
lastPending = pending;
```

Esto impide considerar el mismo estado como un objetivo nuevo en el ciclo siguiente.

---

# 37. Primer recordatorio programado

Después:

```cpp
reminderAt =
    GetTime()
    +
    15000;
```

Por tanto el siguiente aviso puede aparecer:

```text
15 segundos después
```

---

# 38. Recordatorios periódicos

La condición es:

```cpp
if(
    pending > 0
    &&
    priestReady == 1
    &&
    GetTime() >= reminderAt
)
```

---

# 39. Frecuencia de recordatorio

Cada vez que se muestra:

```text
VE A HABLAR CON EL SACERDOTE EGIPCIO
```

se vuelve a programar:

```cpp
reminderAt =
    GetTime()
    +
    15000;
```

Por tanto se repite aproximadamente:

```text
cada 15 segundos
```

---

# 40. Qué ocurre si el sacerdote desaparece mientras hay un pending

Si:

```text
pending > 0
```

pero:

```text
priestReady == 0
```

el recordatorio no se muestra.

Esto evita pedir al jugador que hable con un personaje que todavía no existe.

---

# 41. Qué ocurre cuando reaparece

En cuanto el Group vuelve a contener exactamente una unidad:

```text
priestReady = 1
```

el sistema puede reanudar los avisos.

---

# 42. Interacción por proximidad

La condición de entrada al diálogo es:

```cpp
if(
    pending > 0
    &&
    priestReady == 1
    &&
    u_capitan.DistTo(
        u_sacerdote
    )
    <= 180
)
```

---

# 43. Radio exacto de interacción

El valor actual es:

```text
180
```

Por tanto César debe acercarse físicamente a aproximadamente:

```text
180 unidades o menos
```

del sacerdote.

---

# 44. No basta con seleccionar al sacerdote

La Sequence no detecta:

```text
click
orden de interactuar
selección de unidad
```

La condición real es exclusivamente:

```text
DistTo <= 180
```

---

# 45. Ocultar el objetivo al iniciar el diálogo

Cuando César entra en rango:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

El mensaje deja de ocupar la interfaz.

---

# 46. Bloqueo preventivo antes de lanzar el diálogo

Antes de `RunSequence()` se ejecuta:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    0
);
```

---

# 47. Motivo del borrado previo

El comentario interno indica:

```text
Bloquear la activacion antes de lanzar el dialogo
impide que dos ciclos consecutivos
ejecuten la misma Sequence.
```

---

# 48. Riesgo que evita

Sin esta escritura:

```text
ciclo A detecta DistTo <=180
↓
RunSequence(Dialogue)
↓
500 ms después
↓
pending sigue siendo N
↓
ciclo B vuelve a ejecutar el mismo diálogo
```

La versión v2.0 elimina ese riesgo.

---

# 49. Reinicio de `lastPending`

También se ejecuta:

```cpp
lastPending = 0;
```

Así el próximo valor nuevo podrá generar correctamente su primer aviso.

---

# 50. Mapeo de `pending`

La relación canónica es:

```text
1 → ZombieEE_Dialogue01
2 → ZombieEE_Dialogue02
3 → ZombieEE_Dialogue03
4 → ZombieEE_Dialogue04
5 → ZombieEE_DialogueFinal
```

---

# 51. `pending == 1`

Ejecuta:

```cpp
RunSequence(
    "ZombieEE_Dialogue01"
);
```

---

# 52. `pending == 2`

Ejecuta:

```cpp
RunSequence(
    "ZombieEE_Dialogue02"
);
```

---

# 53. `pending == 3`

Ejecuta:

```cpp
RunSequence(
    "ZombieEE_Dialogue03"
);
```

---

# 54. `pending == 4`

Ejecuta:

```cpp
RunSequence(
    "ZombieEE_Dialogue04"
);
```

---

# 55. `pending == 5`

Ejecuta:

```cpp
RunSequence(
    "ZombieEE_DialogueFinal"
);
```

---

# 56. Los diálogos no se ejecutan mediante `else if`

El código utiliza cinco condiciones independientes:

```cpp
if(pending == 1)
...
if(pending == 2)
...
```

Como `pending` sólo puede tener un valor concreto, sólo una rama se ejecuta.

---

# 57. Pausa tras lanzar una Conversation Sequence

Después de cualquier diálogo:

```cpp
Sleep(2000);
```

---

# 58. Función del `Sleep(2000)`

La espera introduce dos segundos antes de volver al bucle general.

Esto reduce el riesgo de que la transición entre:

```text
RunSequence
nuevo flag
nuevo estado del sacerdote
```

se procese demasiado rápido en el gestor de proximidad.

---

# 59. `RunSequence()` es asíncrono desde la arquitectura del flujo

`ZombieEE_PriestInteraction_Main` no contiene el contenido de los diálogos.

Se limita a lanzar otra Sequence y después continuar existiendo para futuros estados.

---

# 60. El gestor no termina tras Dialogue01

Después de ejecutar:

```text
ZombieEE_Dialogue01
```

la Sequence sigue viva.

Puede posteriormente procesar:

```text
pending 2
pending 3
pending 4
pending 5
```

---

# 61. Un único gestor para todo el Easter Egg

No existe una Sequence diferente de proximidad para cada visita al sacerdote.

Toda la arquitectura utiliza:

```text
ZombieEE_PriestInteraction_Main
```

durante las cinco visitas.

---

# 62. Productores de `EE_PRIEST_PENDING`

Distintas fases del Easter Egg escriben valores diferentes.

Conceptualmente:

```text
FirstHordeTrigger
→ pending 1

AnubisAttack / fase posterior
→ pending 2

Portales completados
→ pending 3

Amuleto / fase posterior
→ pending 4

FinalAssault
→ pending 5
```

El gestor no necesita saber cómo se alcanzó cada estado.

---

# 63. Separación entre lógica narrativa e interacción

La arquitectura es:

```text
Sequence de fase
↓
decide que toca hablar
↓
EE_PRIEST_PENDING = N
↓
PriestInteraction
↓
espera proximidad física
↓
RunSequence(DialogueN)
```

---

# 64. Ventaja de esta separación

Permite que cada sistema:

```text
sacrificio
ataque de Anubis
portales
amuleto
asalto final
```

termine su trabajo sin tener que implementar:

```text
recordatorios
DistTo
César
sacerdote
UI
```

---

# 65. No controla las conversaciones internamente

La Sequence no declara:

```cpp
Conversation conv;
```

No ejecuta:

```text
conv.Init
conv.SetActor
conv.Run
```

Todo eso pertenece a las `ZombieEE_DialogueXX`.

---

# 66. No bloquea al jugador

No utiliza:

```cpp
BlockUserInput();
```

La llegada hasta el sacerdote ocurre durante gameplay normal.

---

# 67. No mueve a César

No ejecuta:

```text
SetCommand
move
advance
```

sobre César.

El jugador debe llevarlo manualmente.

---

# 68. No mueve al sacerdote

El sacerdote permanece gestionado por:

```text
ZombieEE_PriestKeeper
```

`PriestInteraction` sólo mide distancia.

---

# 69. No restaura la vida del sacerdote

Eso pertenece a:

```text
ZombieEE_PriestKeeper
```

---

# 70. No controla el estado `EE_PRIEST_HIDDEN`

No lee directamente:

```text
EE_PRIEST_HIDDEN
```

La disponibilidad real se deduce de:

```text
ZombieEE_Priest01.count == 1
```

cuando existe `pending`.

---

# 71. Ventaja de no depender del flag hidden

Incluso si existe una pequeña ventana temporal entre:

```text
reaparición física
```

y:

```text
actualización de otro flag
```

el gestor sólo actúa cuando encuentra realmente una unidad válida.

---

# 72. No termina al ocultarse el sacerdote

Si `Dialogue04` lo hace desaparecer:

```text
q.count = 0
```

pero la Sequence permanece viva.

Esto es esencial para poder procesar más tarde:

```text
pending = 5
```

cuando el asalto final lo restaure.

---

# 73. Refresco seguro después de `Sleep`

La versión v2.0 evita conservar:

```text
u_capitan
u_sacerdote
state
```

durante periodos largos sin volver a comprobar los Groups.

Cada ciclo vuelve a adquirirlos.

---

# 74. Motivo de estabilidad

Durante un Easter Egg largo pueden ocurrir:

```text
capturas de ciudades
desaparición/reaparición del sacerdote
muertes
Erase()
Save/Load
esperas de muchos minutos
```

Refrescar referencias reduce problemas con handles obsoletos.

---

# 75. Coste de ejecución

Cada 500 ms la Sequence realiza como mínimo:

```text
lookup CapitalForum_P1
lookup ZombieEE_Caesar
2 ClearDead
1 EnvReadInt
```

Sólo busca al sacerdote si:

```text
pending > 0
```

---

# 76. Optimización cuando no hay diálogo pendiente

Durante la mayor parte del Easter Egg:

```text
pending == 0
```

Por tanto no se ejecuta:

```text
Group("ZombieEE_Priest01")
DistTo sacerdote
ShowAnnouncement
```

---

# 77. Frecuencia de proximidad

Cuando existe un diálogo pendiente:

```text
DistTo(César, sacerdote)
```

se revisa aproximadamente:

```text
cada 500 ms
```

---

# 78. Tiempo máximo aproximado de detección

Si César entra en el radio justo después de un ciclo:

```text
el diálogo debería detectarse
en aproximadamente ≤500 ms
```

salvo carga adicional del motor.

---

# 79. Recordatorio independiente de la proximidad

Aunque César esté acercándose:

```text
cada 15 segundos
```

se vuelve a mostrar el objetivo hasta que entra en rango.

---

# 80. Qué ocurre si César ya está junto al sacerdote cuando aparece `pending`

En el mismo ciclo pueden cumplirse:

```text
pending != lastPending
```

y:

```text
DistTo <= 180
```

El sistema puede:

```text
mostrar objetivo
↓
ocultarlo inmediatamente
↓
borrar pending
↓
lanzar diálogo
```

No es necesario que César se aleje y vuelva a entrar.

---

# 81. Qué ocurre si el sacerdote reaparece junto a César

Si ya existe:

```text
pending > 0
```

y el sacerdote reaparece a:

```text
DistTo <= 180
```

en cuanto `priestReady` pase a 1 puede lanzarse el diálogo.

---

# 82. Qué ocurre si `pending` cambia de 1 a 2 sin volver a cero

La arquitectura normal no debería hacerlo porque `PriestInteraction` borra el valor antes de ejecutar el diálogo.

Aun así:

```text
pending != lastPending
```

detectaría el nuevo valor y mostraría un nuevo objetivo.

---

# 83. Qué ocurre con un valor `pending` desconocido

Si por error:

```text
EE_PRIEST_PENDING = 6
```

se seguirían cumpliendo:

```text
pending > 0
```

por lo que aparecería el objetivo y podría detectarse proximidad.

Después:

```text
EE_PRIEST_PENDING = 0
```

pero ninguna de las ramas:

```text
1..5
```

ejecutaría un diálogo.

Por tanto el estado se perdería.

---

# 84. Valores válidos

La versión v2.0 sólo debe escribir:

```text
1
2
3
4
5
```

---

# 85. Mapeo completo de visitas

| `EE_PRIEST_PENDING` | Sequence |
|---:|---|
| 1 | `ZombieEE_Dialogue01` |
| 2 | `ZombieEE_Dialogue02` |
| 3 | `ZombieEE_Dialogue03` |
| 4 | `ZombieEE_Dialogue04` |
| 5 | `ZombieEE_DialogueFinal` |

---

# 86. Group obligatorio de César

Debe existir:

```text
ZombieEE_Caesar
```

con:

```text
exactamente 1 Unit
```

---

# 87. Group del sacerdote

Debe existir:

```text
ZombieEE_Priest01
```

cuando haya una visita pendiente.

Durante fases ocultas puede estar temporalmente vacío.

---

# 88. Group global de estado

Debe existir:

```text
CapitalForum_P1
```

con:

```text
exactamente 1 Building
```

---

# 89. Groups que no necesita

No consulta directamente:

```text
HordeSpawn_01..08
EE_FirstHorde_Spawn01
EE_AnubisWave01
EE_FinalAssault
HW_H1..8
```

---

# 90. Areas necesarias

Ninguna.

---

# 91. Holders necesarios

Ninguno.

---

# 92. Conversations necesarias indirectamente

Las Sequences lanzadas deben poder ejecutar sus Conversations correspondientes.

`ZombieEE_PriestInteraction_Main` sólo necesita que existan las cinco Sequences:

```text
ZombieEE_Dialogue01
ZombieEE_Dialogue02
ZombieEE_Dialogue03
ZombieEE_Dialogue04
ZombieEE_DialogueFinal
```

---

# 93. Dependencias directas de Sequence

Depende de:

```text
ZombieIntro_Main
```

para ser iniciada.

Depende de:

```text
ZombieEE_PriestKeeper
```

funcionalmente para mantener al sacerdote disponible y estable, aunque no la invoque directamente.

---

# 94. Secuencias que consume

Puede lanzar:

```text
ZombieEE_Dialogue01
ZombieEE_Dialogue02
ZombieEE_Dialogue03
ZombieEE_Dialogue04
ZombieEE_DialogueFinal
```

---

# 95. Flags implicados

| Flag | Operación | Función |
|---|---|---|
| `EE_PRIEST_PENDING` | Lee | Indica qué diálogo está pendiente |
| `EE_PRIEST_PENDING` | Escribe `0` | Bloquea activación duplicada antes de lanzar diálogo |

---

# 96. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieEEObjective` | `VE A HABLAR CON EL SACERDOTE EGIPCIO` |

---

# 97. Frecuencias

| Acción | Frecuencia |
|---|---:|
| Bucle principal | 500 ms |
| Comprobación de proximidad | ~500 ms |
| Recordatorio de objetivo | 15 s |
| Pausa tras lanzar diálogo | 2 s |

---

# 98. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── ZombieEE_Caesar
│   │   └── exactamente 1 Unit
│   │
│   └── ZombieEE_Priest01
│       └── sacerdote egipcio cuando está visible
│
└── Sequences
    ├── ZombieIntro_Main
    │   └── AUTORUN = SI
    │
    ├── ZombieEE_PriestKeeper
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue01
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue02
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue03
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue04
    │   └── AUTORUN = NO
    │
    └── ZombieEE_DialogueFinal
        └── AUTORUN = NO
```

---

# 99. Flujo de `pending = 1`

```text
ZombieEE_FirstHordeTrigger
↓
EE_PRIEST_PENDING = 1
↓
PriestInteraction detecta nuevo pending
↓
mostrar:
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
recordar cada 15 s
↓
César <=180
↓
HideAnnouncement
↓
EE_PRIEST_PENDING = 0
↓
lastPending = 0
↓
RunSequence("ZombieEE_Dialogue01")
↓
Sleep(2000)
↓
seguir esperando próximos estados
```

---

# 100. Flujo con sacerdote oculto

```text
Dialogue04 oculta sacerdote
↓
ZombieEE_Priest01 temporalmente vacío
↓
PriestInteraction sigue vivo
↓
pending puede permanecer 0
↓
asalto final termina
↓
sacerdote reaparece
↓
otra fase publica pending = 5
↓
PriestInteraction encuentra:
ZombieEE_Priest01.count == 1
↓
priestReady = 1
↓
mostrar objetivo
↓
César <=180
↓
ZombieEE_DialogueFinal
```

---

# 101. Flujo general completo

```text
while(1)
↓
Sleep(500)
↓
refrescar CapitalForum_P1
↓
refrescar César
↓
leer EE_PRIEST_PENDING
↓
si pending > 0:
    buscar sacerdote
↓
¿nuevo pending y sacerdote listo?
    ↓
    mostrar objetivo
    programar recordatorio +15 s
↓
¿han pasado 15 s?
    ↓
    repetir objetivo
↓
¿César <=180 y sacerdote listo?
    ↓
    ocultar objetivo
    ↓
    EE_PRIEST_PENDING = 0
    ↓
    lastPending = 0
    ↓
    pending 1 → Dialogue01
    pending 2 → Dialogue02
    pending 3 → Dialogue03
    pending 4 → Dialogue04
    pending 5 → DialogueFinal
    ↓
    Sleep(2000)
↓
repetir
```

---

# 102. Resumen funcional

`ZombieEE_PriestInteraction_Main` v2.0 es el intermediario permanente entre las fases del Easter Egg y sus cinco conversaciones.

Su regla esencial es:

```text
una fase del Easter Egg termina
↓
escribe EE_PRIEST_PENDING = N
↓
el jugador recibe:
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
César debe acercarse a ≤180
↓
el pending se borra antes del lanzamiento
↓
se ejecuta DialogueN
↓
el gestor permanece vivo
↓
espera la siguiente visita
```

La versión v2.0 refuerza la estabilidad al refrescar `CapitalForum_P1`, César y el sacerdote en cada ciclo, y tolera que el sacerdote desaparezca temporalmente durante las fases narrativas que lo requieren.

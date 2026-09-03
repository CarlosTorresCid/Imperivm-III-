# Secuencia 10 — `ZombieEE_FirstHordeTrigger`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_FirstHordeTrigger` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_FirstHordeTrigger` es la Sequence que activa el primer paso jugable del Easter Egg después de que haya ocurrido una condición muy concreta:

```text
la primera mini-horda de la Ronda 1
generada específicamente en HordeSpawn_01
ha terminado de aparecer
+
todos los zombies de esa mini-horda han muerto
```

La Sequence no inicia directamente una Conversation.

Su responsabilidad termina cuando escribe:

```text
EE_PRIEST_PENDING = 1
```

A partir de ese momento `ZombieEE_PriestInteraction_Main` queda autorizado a iniciar el primer diálogo cuando César se acerque físicamente al sacerdote egipcio.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

y es iniciada por:

```cpp
ZombieIntro_Main
```

mediante:

```cpp
RunSequence(
    "ZombieEE_FirstHordeTrigger"
);
```

---

# 1. Función dentro del Easter Egg

El flujo es:

```text
ZombieIntro_Main termina
        ↓
RunSequence("ZombieEE_FirstHordeTrigger")
        ↓
esperar EE_FIRST_HORDE_READY
        ↓
esperar EE_FirstHorde_Spawn01.count == 0
        ↓
EE_PRIEST_PENDING = 1
        ↓
ZombieEE_PriestInteraction_Main
        ↓
César debe acercarse al sacerdote
        ↓
ZombieEE_Dialogue01
```

---

# 2. Por qué no es Autorun

La Sequence no debe empezar al cargar el mapa.

Debe arrancar únicamente después de que haya terminado toda la introducción.

Por eso:

```text
ZombieEE_FirstHordeTrigger
→ AUTORUN = NO
```

`ZombieIntro_Main` la lanza justo antes de iniciar `ZombieWaves_Main`.

---

# 3. Orden de arranque

Al final de la introducción se ejecuta:

```cpp
RunSequence(
    "ZombieEE_PriestInteraction_Main"
);

RunSequence(
    "ZombieEE_FirstHordeTrigger"
);

RunSequence(
    "ZombieWaves_Main"
);
```

Por tanto cuando empieza el reloj de las oleadas:

```text
PriestInteraction ya está esperando
FirstHordeTrigger ya está esperando
```

---

# 4. Variables principales

La Sequence declara:

```cpp
ObjList q;
ObjList zombies;

Building state;

int ready;
int completed;
```

---

# 5. `q`

Se utiliza para recuperar:

```text
CapitalForum_P1
```

y obtener desde él el objeto global de estado.

---

# 6. `zombies`

Se utiliza para consultar:

```text
EE_FirstHorde_Spawn01
```

y detectar cuándo ya no queda ningún zombie vivo de esa mini-horda concreta.

---

# 7. `state`

Es el `Building` contenido en:

```text
CapitalForum_P1
```

Sobre él se leen:

```text
EE_DIALOGUE01_COMPLETED
EE_FIRST_HORDE_READY
```

y se escribe:

```text
EE_PRIEST_PENDING
```

---

# 8. `ready`

Representa si la mini-horda relevante ya ha terminado de generarse.

Se obtiene desde:

```text
EE_FIRST_HORDE_READY
```

---

# 9. `completed`

Representa si:

```text
ZombieEE_Dialogue01
```

ya fue completado anteriormente.

Se obtiene desde:

```text
EE_DIALOGUE01_COMPLETED
```

y funciona como protección frente a una activación tardía o duplicada.

---

# 10. Group obligatorio de estado

La Sequence necesita:

```text
CapitalForum_P1
```

Durante la primera fase:

```cpp
q =
    Group("CapitalForum_P1")
    .GetObjList();

q.ClearDead();
```

Después exige:

```cpp
if(q.count != 1)
```

---

# 11. Error de `CapitalForum_P1`

Si el Group no resuelve exactamente a un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - CapitalForum_P1"
);

return;
```

La Sequence termina inmediatamente.

---

# 12. `CapitalForum_P1` como memoria global

El objeto se obtiene con:

```cpp
state =
    q[0]
    .AsBuilding();
```

No se utiliza como posición de spawn ni como destino de movimiento.

Su función aquí es exclusivamente:

```text
almacenar el estado del Easter Egg
```

---

# 13. Primer objetivo: esperar a que la mini-horda exista completamente

La Sequence comienza con:

```cpp
ready = 0;
```

Después:

```cpp
while(ready == 0)
```

mantiene un bucle de espera.

---

# 14. Por qué no empieza directamente mirando el Group de zombies

Si la Sequence consultara inmediatamente:

```text
EE_FirstHorde_Spawn01
```

al principio de la partida, ese Group estaría vacío porque la horda todavía no habría sido creada.

Podría interpretarse erróneamente:

```text
count == 0
→ la horda ya murió
```

cuando en realidad sería:

```text
count == 0
→ todavía no ha aparecido
```

Por eso existe:

```text
EE_FIRST_HORDE_READY
```

---

# 15. `EE_FIRST_HORDE_READY`

Este flag es escrito por:

```text
ZombieWaves_Main
```

cuando termina de crear específicamente la mini-horda de:

```text
Ronda 1
+
HordeSpawn_01
```

La escritura es conceptualmente:

```cpp
EnvWriteInt(
    state,
    "EE_FIRST_HORDE_READY",
    1
);
```

---

# 16. Qué unidades forman esa mini-horda

Durante R1, `ZombieWaves_Main` utiliza los ocho `HordeSpawn_XX` una vez cada uno en orden aleatorio.

Cuando:

```text
w == 1
S == 1
```

las unidades creadas para `HordeSpawn_01` se añaden también a:

```text
EE_FirstHorde_Spawn01
```

---

# 17. Group especial del Easter Egg

El Group relevante es:

```text
EE_FirstHorde_Spawn01
```

No debe confundirse con:

```text
HW_H1
```

ni con:

```text
HW_R1
```

---

# 18. Diferencia entre los tres Groups

Una unidad creada en R1 desde HordeSpawn_01 puede pertenecer simultáneamente a:

```text
HW_H1
HW_R1
EE_FirstHorde_Spawn01
```

Cada Group tiene una función diferente.

---

# 19. `HW_H1`

Representa:

```text
frente táctico asociado a HordeSpawn_01
```

Puede recibir nuevos refuerzos en rondas posteriores.

---

# 20. `HW_R1`

Representa:

```text
todas las unidades de toda la Ronda 1
```

incluyendo las ocho mini-hordas.

Se utiliza para la recompensa normal de R1.

---

# 21. `EE_FirstHorde_Spawn01`

Representa exclusivamente:

```text
la mini-horda de R1 nacida en HordeSpawn_01
```

Es el Group utilizado por este trigger.

---

# 22. Por qué se utiliza un Group separado

El Easter Egg no quiere esperar a que muera:

```text
toda la Ronda 1
```

Quiere dispararse cuando se elimina únicamente la mini-horda específica asociada a `HordeSpawn_01`.

Por tanto:

```text
HW_R1
```

sería demasiado amplio.

---

# 23. Orden aleatorio de R1

`ZombieWaves_Main` elige el orden de los ocho spawns aleatoriamente.

Por tanto:

```text
HordeSpawn_01
```

puede aparecer como:

```text
primera
segunda
tercera
...
octava mini-horda
```

de R1.

---

# 24. Consecuencia para el Easter Egg

El Easter Egg no se activa necesariamente al matar a la primera mini-horda cronológica.

Se activa al matar:

```text
la mini-horda específica de HordeSpawn_01
```

independientemente de qué posición haya ocupado dentro del orden aleatorio de R1.

---

# 25. Comprobación de diálogo ya completado

Dentro del primer bucle se lee:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_DIALOGUE01_COMPLETED"
    );
```

Si:

```cpp
completed == 1
```

se ejecuta:

```cpp
return;
```

---

# 26. Por qué existe esta protección

Evita que una ejecución tardía o duplicada de `ZombieEE_FirstHordeTrigger` vuelva a preparar:

```text
EE_PRIEST_PENDING = 1
```

después de que la primera conversación ya se haya completado.

---

# 27. Lectura de `ready`

Después:

```cpp
ready =
    EnvReadInt(
        state,
        "EE_FIRST_HORDE_READY"
    );
```

Si sigue en cero:

```cpp
Sleep(1000);
```

---

# 28. Frecuencia de espera de la primera fase

Mientras no exista la mini-horda completa:

```text
1 comprobación aproximadamente cada segundo
```

No existe un barrido de alta frecuencia.

---

# 29. No hay timeout de espera

La primera fase puede esperar indefinidamente.

Eso es deliberado porque R1 puede tardar:

```text
30 minutos de espera inicial
+
el tiempo necesario hasta que HordeSpawn_01 aparezca dentro del orden aleatorio
```

---

# 30. Relación con el delay inicial de Waves

`ZombieWaves_Main` comienza:

```text
30 minutos
```

después de terminar la intro.

Por tanto `ZombieEE_FirstHordeTrigger` puede permanecer dormida durante todo ese periodo sin problema.

---

# 31. Salida del primer bucle

Cuando:

```text
EE_FIRST_HORDE_READY == 1
```

termina:

```cpp
while(ready == 0)
```

y comienza la fase de seguimiento de muertes.

---

# 32. Segunda fase: esperar a que mueran esos zombies concretos

La Sequence ejecuta:

```cpp
while(1)
{
    zombies =
        Group(
            "EE_FirstHorde_Spawn01"
        )
        .GetObjList();

    zombies.ClearDead();

    if(zombies.count == 0)
        break;

    Sleep(1000);
}
```

---

# 33. `ClearDead()`

Antes de contar las unidades:

```cpp
zombies.ClearDead();
```

elimina referencias a unidades que ya han muerto.

Por tanto:

```text
zombies.count
```

representa las unidades todavía vivas del Group.

---

# 34. Condición exacta de activación

La condición es:

```cpp
zombies.count == 0
```

No se utiliza:

```text
porcentaje de muertos
último golpe
distancia
tiempo
ronda completa
```

Todos los miembros del Group deben haber desaparecido.

---

# 35. La mini-horda puede abandonar su zona

La Sequence no exige que los zombies mueran cerca de:

```text
HordeSpawn_01
```

Una vez añadidos al Group pueden:

```text
marchar
combatir
asediar
cambiar de objetivo
```

y morir en cualquier punto del mapa.

El trigger sólo observa el Group.

---

# 36. Tactical continúa controlando esas unidades

Mientras están vivas, también pertenecen a:

```text
HW_H1
```

por lo que:

```text
ZombieTactical_Main
```

puede moverlas y usarlas normalmente.

`ZombieEE_FirstHordeTrigger` no les da ninguna orden.

---

# 37. No modifica propiedades de los zombies

La Sequence no utiliza:

```text
SetPlayer
SetCommand
SetHealth
SetLevel
Erase
```

sobre los zombies.

Sólo los observa.

---

# 38. Frecuencia de seguimiento de las muertes

Mientras queden unidades:

```cpp
Sleep(1000);
```

Por tanto la desaparición completa puede tardar hasta aproximadamente un segundo en ser detectada.

---

# 39. Qué ocurre cuando el Group queda vacío

Cuando:

```text
EE_FirstHorde_Spawn01.count == 0
```

se ejecuta:

```cpp
break;
```

y la Sequence pasa a refrescar el estado global.

---

# 40. Por qué vuelve a leer `CapitalForum_P1`

Después de una espera potencialmente muy larga, la Sequence no reutiliza directamente la antigua referencia.

Hace:

```cpp
q =
    Group("CapitalForum_P1")
    .GetObjList();

q.ClearDead();
```

---

# 41. Segunda validación del estado global

Si:

```cpp
q.count != 1
```

simplemente:

```cpp
return;
```

En esta segunda validación no se muestra el anuncio de error.

---

# 42. Renovación de `state`

Si el Group es válido:

```cpp
state =
    q[0]
    .AsBuilding();
```

Se obtiene una referencia actualizada después de todo el periodo de espera.

---

# 43. Segunda comprobación de `EE_DIALOGUE01_COMPLETED`

Se vuelve a leer:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_DIALOGUE01_COMPLETED"
    );
```

Si vale 1:

```cpp
return;
```

---

# 44. Motivo de la segunda comprobación

Durante el tiempo transcurrido entre:

```text
EE_FIRST_HORDE_READY
```

y:

```text
muerte de todos los zombies
```

otra ejecución o una partida cargada podría haber dejado ya completado el primer diálogo.

La protección evita reabrir un paso ya resuelto.

---

# 45. Activación real del primer paso

Si el diálogo todavía no se ha completado:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    1
);
```

---

# 46. Significado de `EE_PRIEST_PENDING = 1`

El valor:

```text
1
```

significa:

```text
primer diálogo del Easter Egg pendiente
```

No ejecuta el diálogo inmediatamente.

---

# 47. Qué Sequence consume `EE_PRIEST_PENDING`

El consumidor es:

```text
ZombieEE_PriestInteraction_Main
```

que ya fue iniciado por `ZombieIntro_Main`.

---

# 48. Interacción presencial

`ZombieEE_PriestInteraction_Main` exige que:

```text
César
```

se acerque físicamente al sacerdote egipcio.

Por tanto la experiencia jugable es:

```text
matar mini-horda de Spawn 01
↓
el paso queda disponible
↓
el jugador debe ir a hablar con el sacerdote
```

---

# 49. No hay Conversation automática

`ZombieEE_FirstHordeTrigger` no utiliza:

```cpp
Conversation
```

ni:

```cpp
RunSequence(
    "ZombieEE_Dialogue01"
);
```

directamente.

La separación evita que la conversación aparezca en cualquier punto del mapa justo después de morir el último zombie.

---

# 50. No muestra el objetivo directamente

La versión canónica de esta Sequence no muestra:

```text
VE A HABLAR CON EL SACERDOTE
```

Ese trabajo pertenece al gestor de interacción presencial.

---

# 51. No activa sacrificio

No escribe:

```text
EE_SACRIFICE_ENABLED
```

Ese flag pertenece al resultado de:

```text
ZombieEE_Dialogue01
```

---

# 52. No activa portales

No escribe:

```text
EE_PORTALS_ENABLED
```

Los portales corresponden a una fase posterior del Easter Egg.

---

# 53. No modifica Waves

La Sequence no detiene ni pausa:

```text
ZombieWaves_Main
```

Las rondas normales continúan mientras el jugador avanza por el Easter Egg.

---

# 54. No modifica Rewards

Tampoco toca:

```text
ZR_MASK
ZR_REWARDED
ZR_ENDLESS_*
```

La recompensa normal de R1 funciona de forma independiente.

---

# 55. Independencia entre recompensa y Easter Egg

R1 tiene dos seguimientos simultáneos.

## Recompensa Zombies

```text
HW_R1
↓
debe morir toda la Ronda 1
↓
ZombieRewards_Main
```

## Easter Egg

```text
EE_FirstHorde_Spawn01
↓
sólo debe morir la mini-horda de Spawn 01
↓
ZombieEE_FirstHordeTrigger
```

Son condiciones distintas.

---

# 56. El Easter Egg puede activarse antes de terminar toda R1

Si la mini-horda de Spawn 01 es eliminada mientras siguen vivos zombies de otros spawns:

```text
EE_PRIEST_PENDING = 1
```

puede activarse igualmente.

No es necesario esperar:

```text
HW_R1.count == 0
```

---

# 57. El grupo especial sólo se utiliza en R1

`ZombieWaves_Main` añade unidades a:

```text
EE_FirstHorde_Spawn01
```

únicamente cuando:

```text
w == 1
S == 1
```

R2 y posteriores no vuelven a rellenar este Group.

---

# 58. Consecuencia de no reutilizarlo

Una vez los zombies de la mini-horda original han muerto:

```text
EE_FirstHorde_Spawn01
```

permanece vacío.

Por ello el flag:

```text
EE_FIRST_HORDE_READY
```

es esencial para diferenciar:

```text
vacío antes de aparecer
```

de:

```text
vacío después de morir
```

---

# 59. Arquitectura productor/consumidor

La coordinación completa es:

```text
ZombieWaves_Main
        ↓
crea R1 / Spawn 01
        ↓
AddToGroup("EE_FirstHorde_Spawn01")
        ↓
termina su creación
        ↓
EE_FIRST_HORDE_READY = 1
        ↓
ZombieEE_FirstHordeTrigger
        ↓
espera count == 0
        ↓
EE_PRIEST_PENDING = 1
        ↓
ZombieEE_PriestInteraction_Main
        ↓
ZombieEE_Dialogue01
```

---

# 60. Groups necesarios

## Obligatorio

```text
CapitalForum_P1
```

Debe contener exactamente un `Building`.

## Dinámico utilizado

```text
EE_FirstHorde_Spawn01
```

No necesita estar poblado manualmente.

`ZombieWaves_Main` añade sus unidades mediante `AddToGroup()`.

---

# 61. Groups que no necesita

No necesita:

```text
ZombieEE_Caesar
ZombieEE_Priest01
HordeSpawn_01
HW_R1
HW_H1
```

de forma directa.

Aunque algunos participan en la arquitectura general, esta Sequence sólo consulta:

```text
CapitalForum_P1
EE_FirstHorde_Spawn01
```

---

# 62. Areas necesarias

Ninguna.

---

# 63. Holders necesarios

Ninguno.

---

# 64. Marcadores necesarios

Ninguno adicional.

No consulta la posición física de `HordeSpawn_01`.

---

# 65. Conversations necesarias

Ninguna directamente.

---

# 66. Dependencias de Sequences

Depende funcionalmente de:

```text
ZombieWaves_Main
```

porque Waves debe escribir:

```text
EE_FIRST_HORDE_READY
```

y llenar:

```text
EE_FirstHorde_Spawn01
```

También depende del sistema completo de:

```text
ZombieEE_PriestInteraction_Main
```

para continuar la historia después de escribir `EE_PRIEST_PENDING = 1`.

---

# 67. Dependencia de `ZombieIntro_Main`

`ZombieIntro_Main` es quien ejecuta:

```cpp
RunSequence(
    "ZombieEE_FirstHordeTrigger"
);
```

Sin esa llamada, la Sequence no se ejecuta porque:

```text
AUTORUN = NO
```

---

# 68. Estado previo que debe existir

Antes de que pueda producirse el evento deben darse:

```text
CapitalForum_P1 válido
ZombieWaves_Main activo
Ronda 1 iniciada
Spawn 01 seleccionado dentro de R1
mini-horda creada completamente
```

---

# 69. Estado posterior

Después de completarse:

```text
EE_PRIEST_PENDING = 1
```

y la Sequence:

```cpp
return;
```

No permanece en un bucle permanente.

---

# 70. Ejecución de una sola vez

El diseño es de:

```text
una ejecución
una condición
un trigger
return
```

No necesita permanecer activo después del primer paso del Easter Egg.

---

# 71. Protección frente a una segunda ejecución

Si se ejecutara otra vez accidentalmente y:

```text
EE_DIALOGUE01_COMPLETED == 1
```

terminaría antes de realizar cambios.

---

# 72. Qué ocurre si se ejecuta dos veces antes de completar el diálogo

Dos instancias simultáneas podrían llegar a observar:

```text
EE_DIALOGUE01_COMPLETED == 0
```

y ambas acabar escribiendo:

```text
EE_PRIEST_PENDING = 1
```

La escritura sería idéntica, por lo que no crea dos estados distintos.

Aun así la arquitectura normal sólo la ejecuta una vez desde `ZombieIntro_Main`.

---

# 73. Error más peligroso: eliminar `EE_FIRST_HORDE_READY`

Si se eliminara esa primera espera:

```text
Group vacío al inicio
→ trigger inmediato
→ Easter Egg disponible antes de R1
```

Por tanto esa variable no es redundante.

---

# 74. Error más peligroso: usar `HW_R1`

Si se sustituyera:

```text
EE_FirstHorde_Spawn01
```

por:

```text
HW_R1
```

el jugador tendría que destruir las ocho mini-hordas completas de R1 antes de habilitar el primer diálogo.

Eso cambiaría la mecánica.

---

# 75. Error más peligroso: usar `HW_H1`

Tampoco debe usarse:

```text
HW_H1
```

porque ese frente puede recibir zombies de rondas posteriores.

El Group podría no volver a cero en el momento esperado.

---

# 76. Motivo del Group dedicado

`EE_FirstHorde_Spawn01` es una instantánea lógica de:

```text
un conjunto único e irrepetible de zombies
```

Por ello es el Group correcto para un trigger narrativo de una sola vez.

---

# 77. No depende del orden visual de spawns

Aunque Spawn 01 aparezca octavo en R1, la Sequence seguirá funcionando porque espera:

```text
EE_FIRST_HORDE_READY
```

sin asumir un tiempo concreto.

---

# 78. No depende del número de zombies

La Sequence no contiene:

```text
cantidad esperada
```

Sólo espera que el Group pase de:

```text
creado
```

a:

```text
vacío
```

Por tanto cambios futuros en la composición de R1 no obligan a modificar este trigger.

---

# 79. No depende del nivel de los zombies

Tampoco comprueba:

```text
SetLevel
```

ni clases concretas.

Puede seguir funcionando aunque la composición de R1 cambie.

---

# 80. No depende del propietario del zombie

No comprueba:

```text
Player 12
```

directamente.

La pertenencia correcta viene garantizada por `ZombieWaves_Main`.

---

# 81. No depende del objetivo de la horda

No consulta:

```text
HW_TX1
HW_TY1
HW_OWNER1
```

La mini-horda puede dirigirse a cualquier ciudad.

---

# 82. No depende de quién la mata

No importa si los zombies son destruidos por:

```text
Player 1
Player 2
otro jugador
otra IA
defensas de ciudad
```

El trigger sólo detecta:

```text
Group vacío
```

---

# 83. Comportamiento en una partida muy rápida

Si la mini-horda completa de Spawn 01 muere casi inmediatamente después de generarse:

```text
Waves termina spawn
↓
EE_FIRST_HORDE_READY = 1
↓
Trigger sale del primer bucle
↓
consulta Group
↓
count == 0
↓
EE_PRIEST_PENDING = 1
```

El sistema sigue siendo válido.

---

# 84. Comportamiento si tarda mucho en morir

Si sobrevive durante varios minutos:

```text
zombies.count > 0
↓
Sleep(1000)
↓
seguir esperando
```

No hay timeout.

---

# 85. Comportamiento si la horda conquista ciudades

No importa.

Mientras algún miembro del Group siga vivo:

```text
no se activa el diálogo
```

---

# 86. Comportamiento si las oleadas normales se detienen después

Una vez:

```text
EE_FIRST_HORDE_READY = 1
```

el trigger ya no depende de que `ZombieWaves_Main` siga generando nuevas rondas.

Sólo espera la muerte de los zombies ya registrados.

---

# 87. Interacción con el cierre de portales

El cierre de los cuatro portales ocurre mucho más tarde narrativamente.

No afecta a esta Sequence porque para entonces:

```text
EE_DIALOGUE01_COMPLETED
```

ya debería valer 1 y el trigger habrá terminado.

---

# 88. Mensajes visibles

Esta Sequence sólo puede mostrar:

```text
ERROR EE - CapitalForum_P1
```

en la primera validación.

No muestra:

```text
objetivos
recordatorios
contadores
mensajes de muerte de horda
```

---

# 89. Sin mensajes de debug

No utiliza:

```text
pr(...)
```

ni mensajes de depuración visibles en pantalla.

---

# 90. Frecuencia total

Las dos esperas principales funcionan a:

```text
Sleep(1000)
```

Por tanto el coste permanente durante su vida es muy bajo.

---

# 91. Preparación exacta

```text
Map
├── Groups
│   └── CapitalForum_P1
│       └── exactamente 1 Building
│
└── Sequences
    ├── ZombieIntro_Main
    │   └── AUTORUN = SI
    │
    ├── ZombieWaves_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_FirstHordeTrigger
    │   └── AUTORUN = NO
    │
    └── ZombieEE_PriestInteraction_Main
        └── AUTORUN = NO
```

`EE_FirstHorde_Spawn01` se rellena dinámicamente desde Waves.

---

# 92. Flags implicados

| Flag | Lee/escribe | Función |
|---|---|---|
| `EE_FIRST_HORDE_READY` | Lee | Confirma que R1/Spawn01 terminó de generarse |
| `EE_DIALOGUE01_COMPLETED` | Lee | Evita reactivar un paso ya completado |
| `EE_PRIEST_PENDING` | Escribe | Habilita el primer diálogo presencial |

---

# 93. Groups implicados

| Group | Función |
|---|---|
| `CapitalForum_P1` | Estado global |
| `EE_FirstHorde_Spawn01` | Zombies concretos que deben morir |

---

# 94. Flujo interno exacto

```text
ready = 0
↓
while ready == 0
    ↓
    recuperar CapitalForum_P1
    ↓
    ¿count != 1?
        Sí → ERROR + return
    ↓
    leer EE_DIALOGUE01_COMPLETED
    ↓
    ¿completed == 1?
        Sí → return
    ↓
    leer EE_FIRST_HORDE_READY
    ↓
    ¿ready == 0?
        Sí → Sleep(1000)
↓
ready == 1
↓
while(1)
    ↓
    leer EE_FirstHorde_Spawn01
    ↓
    ClearDead
    ↓
    ¿count == 0?
        Sí → break
        No → Sleep(1000)
↓
recuperar otra vez CapitalForum_P1
↓
¿count != 1?
    Sí → return
↓
leer EE_DIALOGUE01_COMPLETED
↓
¿completed == 1?
    Sí → return
↓
EE_PRIEST_PENDING = 1
↓
return
```

---

# 95. Flujo completo desde la intro

```text
ZombieIntro_Main
        ↓
RunSequence(
    "ZombieEE_FirstHordeTrigger"
)
        ↓
Trigger queda esperando
        ↓
ZombieWaves_Main arranca
        ↓
30 minutos
        ↓
R1 comienza
        ↓
los 8 spawns salen en orden aleatorio
        ↓
llega HordeSpawn_01
        ↓
sus zombies:
HW_H1
HW_R1
EE_FirstHorde_Spawn01
        ↓
termina creación
        ↓
EE_FIRST_HORDE_READY = 1
        ↓
Trigger empieza a vigilar muertes
        ↓
último zombie del Group muere
        ↓
EE_PRIEST_PENDING = 1
        ↓
ZombieEE_PriestInteraction_Main
queda autorizado
        ↓
jugador lleva a César
hasta el sacerdote
        ↓
ZombieEE_Dialogue01
```

---

# 96. Resumen funcional

`ZombieEE_FirstHordeTrigger` implementa un trigger narrativo de una sola vez:

```text
esperar a que exista realmente
la mini-horda R1 / HordeSpawn_01
        ↓
esperar a que todos sus zombies mueran
        ↓
comprobar que Dialogue01
no esté ya completado
        ↓
EE_PRIEST_PENDING = 1
        ↓
terminar
```

La separación entre:

```text
EE_FIRST_HORDE_READY
```

y:

```text
EE_FirstHorde_Spawn01.count == 0
```

es esencial para evitar que un Group todavía vacío antes de su creación active el Easter Egg prematuramente.

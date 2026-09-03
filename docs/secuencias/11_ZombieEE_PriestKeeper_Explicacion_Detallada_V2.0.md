# Secuencia 11 — `ZombieEE_PriestKeeper`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_PriestKeeper` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_PriestKeeper` es la Sequence encargada de mantener al sacerdote egipcio del Easter Egg protegido, fuera del control normal de la IA y cerca de su posición original mientras el Easter Egg siga activo.

También está preparada para un momento especial del flujo:

```text
EE_PRIEST_HIDDEN = 1
```

Durante esa fase el sacerdote puede dejar de existir temporalmente. La Sequence no intenta recrearlo por su cuenta. Cuando el sistema vuelve a colocar una nueva unidad dentro de:

```text
ZombieEE_Priest01
```

y:

```text
EE_PRIEST_HIDDEN = 0
```

`ZombieEE_PriestKeeper` vuelve a adquirir automáticamente esa nueva unidad y retoma su protección.

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
    "ZombieEE_PriestKeeper"
);
```

---

# 1. Función principal

El objetivo general es:

```text
sacerdote visible
↓
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
↓
si se aleja más de 50
→ move a su posición original
↓
repetir cada 100 ms
↓
hasta EE_COMPLETED = 1
```

---

# 2. Por qué no es Autorun

La Sequence no necesita empezar antes de la introducción.

El orden canónico es:

```text
ZombieIntro_Main
↓
localiza a César
↓
RunSequence("ZombieEE_PriestKeeper")
↓
continúa la cinemática
```

Por tanto:

```text
ZombieEE_PriestKeeper
→ AUTORUN = NO
```

---

# 3. Inicio temprano durante la introducción

`ZombieIntro_Main` lanza `ZombieEE_PriestKeeper` antes de crear:

```text
mensajero cartaginés
sacerdote romano
30 soldados romanos
```

Así el sacerdote egipcio persistente queda protegido desde el comienzo de la partida jugable.

---

# 4. Diferencia entre sacerdote egipcio y sacerdote romano

Esta Sequence controla únicamente:

```text
ZombieEE_Priest01
```

que corresponde al sacerdote egipcio del Easter Egg.

No controla al:

```text
RPriest
```

temporal creado por `ZombieIntro_Main`.

---

# 5. Group obligatorio de estado

La Sequence necesita:

```text
CapitalForum_P1
```

La consulta inicial es:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después:

```cpp
if(stateList.count != 1)
```

---

# 6. Error de `CapitalForum_P1`

Si el Group no contiene exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - CapitalForum_P1"
);

return;
```

La Sequence termina.

---

# 7. Función de `CapitalForum_P1`

El único objeto se convierte a:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

Se utiliza únicamente como memoria global para leer:

```text
EE_PRIEST_HIDDEN
EE_COMPLETED
```

---

# 8. Group obligatorio del sacerdote

La Sequence necesita:

```text
ZombieEE_Priest01
```

Al arrancar:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 9. Error de `ZombieEE_Priest01`

Si inicialmente:

```text
q.count != 1
```

se muestra:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - ZombieEE_Priest01"
);

return;
```

Por tanto al comenzar la Sequence debe existir exactamente una unidad válida en ese Group.

---

# 10. Tipo esperado de objeto

El único objeto se convierte a:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

Por tanto `ZombieEE_Priest01` debe contener una `Unit`.

---

# 11. Captura de la posición original

Nada más localizar al sacerdote:

```cpp
priestPos =
    u_sacerdote.pos;
```

Esta posición queda guardada durante toda la ejecución.

---

# 12. Función de `priestPos`

`priestPos` representa:

```text
posición canónica de reposo del sacerdote
```

Si la unidad se desplaza accidentalmente o por una orden externa:

```text
DistTo(priestPos) > 50
```

la Sequence intenta devolverla.

---

# 13. Variable `completed`

Se inicializa:

```cpp
completed = 0;
```

y controla el bucle principal:

```cpp
while(completed == 0)
```

---

# 14. Condición de finalización

Al final de cada ciclo se lee:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_COMPLETED"
    );
```

Cuando:

```text
EE_COMPLETED = 1
```

el bucle termina.

---

# 15. Significado de `EE_COMPLETED`

Ese flag representa:

```text
Easter Egg completamente finalizado
```

Mientras siga en cero, el sacerdote continúa protegido cuando debe estar visible.

---

# 16. Variable `hidden`

En cada ciclo:

```cpp
hidden =
    EnvReadInt(
        state,
        "EE_PRIEST_HIDDEN"
    );
```

---

# 17. Significado de `EE_PRIEST_HIDDEN`

```text
0
→ el sacerdote debe existir y estar protegido

1
→ el sacerdote está temporalmente oculto / eliminado
```

---

# 18. Fase visible

La lógica de protección sólo se ejecuta cuando:

```cpp
if(hidden == 0)
```

---

# 19. Fase oculta

Si:

```text
EE_PRIEST_HIDDEN = 1
```

la Sequence no:

```text
busca obligatoriamente una unidad
muestra error
recrea sacerdote
mueve sacerdote
cura sacerdote
```

Simplemente espera al siguiente ciclo.

---

# 20. Por qué no debe tratar la ausencia como error durante la fase oculta

Durante una fase posterior del Easter Egg el sacerdote puede desaparecer deliberadamente.

Por eso la lógica inicial:

```text
q.count debe ser 1
```

sólo es obligatoria al arrancar.

Dentro del bucle:

```cpp
if(q.count == 1)
```

protege únicamente si existe una unidad válida.

---

# 21. Re-adquisición automática

Cada vez que:

```text
hidden == 0
```

se vuelve a consultar:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 22. Consecuencia de volver a consultar el Group

La Sequence no conserva para siempre el handle inicial.

Si el sacerdote original desaparece y después otra Sequence crea uno nuevo dentro del mismo Group:

```text
ZombieEE_Priest01
```

el siguiente ciclo puede adquirir la nueva unidad.

---

# 23. Condición para adquirir una nueva unidad

La protección sólo se aplica cuando:

```cpp
q.count == 1
```

Si temporalmente el Group está vacío:

```text
no hace nada
```

y vuelve a intentarlo unos 100 ms después.

---

# 24. Qué ocurre si aparecen dos sacerdotes

Si:

```text
q.count == 2
```

el bloque de protección no entra porque exige:

```cpp
if(q.count == 1)
```

No selecciona uno al azar.

---

# 25. Consecuencia de tener dos objetos

La Sequence no muestra error permanente dentro del bucle.

Simplemente deja de aplicar protección hasta que el Group vuelva a resolver exactamente a una unidad.

---

# 26. Actualización del handle

Cuando:

```text
q.count == 1
```

se ejecuta:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

La variable queda apuntando a la unidad actual.

---

# 27. Protección frente a la IA

Cada ciclo visible ejecuta:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 28. Función de `SetNoAIFlag(true)`

Impide que la IA estratégica normal trate al sacerdote como una unidad disponible para:

```text
ejércitos
movimientos estratégicos
órdenes automáticas generales
```

---

# 29. Alimentación desactivada

También ejecuta:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 30. Consecuencia de `SetFeeding(false)`

El sacerdote no depende del sistema normal de comida.

No debería:

```text
consumir comida
sufrir hambre
morir por falta de alimentación
```

durante el Easter Egg.

---

# 31. Protección de salud

Cada ciclo visible ejecuta:

```cpp
u_sacerdote.SetHealth(
    1000
);
```

---

# 32. Consecuencia de `SetHealth(1000)`

La salud se restaura continuamente a:

```text
1000
```

mientras:

```text
EE_PRIEST_HIDDEN = 0
EE_COMPLETED = 0
```

---

# 33. Frecuencia de restauración de salud

El bucle termina con:

```cpp
Sleep(100);
```

Por tanto la salud se reimpone aproximadamente:

```text
10 veces por segundo
```

---

# 34. Protección práctica frente a daño

Si el sacerdote recibe daño pero sigue vivo hasta el siguiente ciclo:

```text
SetHealth(1000)
```

lo restaura.

Por tanto funciona como una protección muy fuerte frente a daño convencional.

---

# 35. No existe `SetInvulnerable`

La Sequence no utiliza una API específica de invulnerabilidad.

La protección se implementa mediante:

```text
restauración continua de vida
+
exclusión de IA
+
reposicionamiento
```

---

# 36. Caso extremo de muerte instantánea

Si una fuente externa destruyera completamente la unidad entre dos ciclos, la Sequence no puede restaurar la vida de una unidad que ya no existe.

En ese caso:

```text
q.count = 0
```

hasta que otra Sequence vuelva a crear un sacerdote.

---

# 37. Control de posición

Después de proteger propiedades:

```cpp
if(
    u_sacerdote.DistTo(
        priestPos
    )
    >
    50
)
```

se considera que se ha alejado demasiado.

---

# 38. Tolerancia de posición

La tolerancia es:

```text
50 unidades
```

No se obliga al sacerdote a coincidir exactamente con la coordenada original.

---

# 39. Orden de retorno

Si supera esa distancia:

```cpp
u_sacerdote.SetCommand(
    "move",
    priestPos
);
```

---

# 40. No utiliza `stand_position`

La Sequence no mantiene permanentemente:

```text
stand_position
```

Simplemente manda:

```text
move a priestPos
```

si se aleja.

---

# 41. Consecuencia de utilizar `move`

Cuando ya está dentro del radio de 50:

```text
no se emite nueva orden de posición
```

Esto reduce órdenes innecesarias.

---

# 42. El sacerdote puede oscilar ligeramente

Como sólo se corrige cuando:

```text
DistTo > 50
```

puede existir una pequeña variación alrededor de la posición original sin que la Sequence intervenga.

---

# 43. Reposición tras una orden manual

Si el jugador o una Sequence externa mueve al sacerdote fuera del radio:

```text
máximo ~100 ms después
```

`ZombieEE_PriestKeeper` puede detectar la desviación y ordenar el regreso.

---

# 44. Reposición tras una acción de IA externa

Aunque otra lógica intente moverlo, la combinación:

```text
SetNoAIFlag(true)
+
control cada 100 ms
```

hace que el sacerdote tienda a permanecer en su zona original.

---

# 45. No se utiliza `SetPlayer`

La Sequence no cambia nunca el propietario del sacerdote.

No ejecuta:

```cpp
u_sacerdote.SetPlayer(...)
```

---

# 46. No se utiliza `Erase`

La Sequence no elimina al sacerdote.

La desaparición temporal pertenece a otras Sequences del Easter Egg.

---

# 47. No se utiliza `Damage`

Tampoco inflige daño.

Su función es exclusivamente de protección.

---

# 48. No inicia Conversations

No ejecuta:

```text
ZombieEE_Dialogue01
ZombieEE_Dialogue02
ZombieEE_Dialogue03
ZombieEE_Dialogue04
ZombieEE_DialogueFinal
```

---

# 49. No controla proximidad con César

No consulta:

```text
ZombieEE_Caesar
```

ni:

```text
DistTo(César)
```

La interacción presencial pertenece a:

```text
ZombieEE_PriestInteraction_Main
```

---

# 50. No escribe `EE_PRIEST_PENDING`

No decide qué diálogo toca.

Sólo lee:

```text
EE_PRIEST_HIDDEN
EE_COMPLETED
```

---

# 51. No controla el sacrificio

No lee ni escribe:

```text
EE_SACRIFICE_ENABLED
EE_SOULS_DELIVERED
EE_SACRIFICE_COMPLETED
```

---

# 52. No controla los portales

No utiliza:

```text
EE_PORTALS_ENABLED
EE_PORTALS_COMPLETED
EE_ZOMBIE_SPAWNS_DISABLED
```

---

# 53. No controla el amuleto

No utiliza flags específicos de:

```text
ZombieEE_Amulet_Main
```

---

# 54. No controla el asalto final

No crea ni dirige tropas del asalto final.

Sólo responde al estado:

```text
EE_PRIEST_HIDDEN
```

que otras Sequences modifican durante esas fases.

---

# 55. Qué Sequence la inicia

La llamada canónica está en:

```text
ZombieIntro_Main
```

después de localizar correctamente a César.

---

# 56. Momento exacto de inicio

El orden es:

```text
PlayMovie()
↓
obtener ZombieEE_Caesar
↓
César SetNoAIFlag(true)
↓
RunSequence("ZombieEE_PriestKeeper")
↓
crear actores temporales de la intro
```

---

# 57. Ventaja de iniciarla antes del diálogo introductorio

El sacerdote egipcio ya queda protegido durante:

```text
toda la cinemática inicial
```

aunque todavía no tenga una función interactiva para el jugador.

---

# 58. Posición original y reaparición

`priestPos` se captura únicamente una vez:

```text
al inicio de la Sequence
```

Cuando reaparece un sacerdote nuevo, la Sequence sigue utilizando esa misma coordenada original.

---

# 59. Consecuencia para el sacerdote reaparecido

La unidad nueva puede aparecer inicialmente en otra posición.

Si:

```text
DistTo(priestPos) > 50
```

la Sequence la manda de vuelta al lugar original.

---

# 60. El Group debe conservar el mismo nombre tras la reaparición

La re-adquisición depende de:

```text
ZombieEE_Priest01
```

Por tanto cualquier Sequence que reconstruya al sacerdote debe añadir la nueva unidad a ese mismo Group.

---

# 61. No hace falta actualizar `priestPos`

El diseño asume que el sacerdote debe volver al lugar canónico inicial.

Por eso no se sustituye:

```text
priestPos
```

con la posición de la unidad nueva.

---

# 62. Fase escondida conceptual

El flujo esperado es:

```text
sacerdote visible
↓
EE_PRIEST_HIDDEN = 0
↓
PriestKeeper lo protege
↓
otra Sequence inicia fase donde debe desaparecer
↓
EE_PRIEST_HIDDEN = 1
↓
sacerdote eliminado/oculto
↓
PriestKeeper deja de exigir su presencia
↓
otra Sequence lo recrea
↓
lo añade a ZombieEE_Priest01
↓
EE_PRIEST_HIDDEN = 0
↓
PriestKeeper lo vuelve a adquirir
↓
protección restaurada
```

---

# 63. Por qué `hidden` debe cambiar antes o junto a la desaparición

Si una Sequence eliminara al sacerdote manteniendo:

```text
EE_PRIEST_HIDDEN = 0
```

`PriestKeeper` simplemente encontraría:

```text
q.count = 0
```

y esperaría.

No provocaría un crash, pero el estado dejaría de representar correctamente la fase narrativa.

---

# 64. No existe error si falta temporalmente durante `hidden = 0`

Dentro del bucle sólo se exige:

```cpp
if(q.count == 1)
```

Por tanto una ausencia temporal no termina la Sequence.

Esto permite tolerar pequeñas ventanas entre:

```text
Erase
Place
AddToGroup
```

si otras Sequences gestionan la reaparición.

---

# 65. Estado global no se refresca mediante Group dentro del bucle

La referencia:

```text
state
```

se obtiene una sola vez al principio.

Después se reutiliza para:

```text
EE_PRIEST_HIDDEN
EE_COMPLETED
```

---

# 66. Consecuencia de perder `CapitalForum_P1` durante la partida

Esta Sequence no vuelve a ejecutar:

```text
Group("CapitalForum_P1")
```

dentro del bucle.

Por tanto presupone que el `Building state` seguirá siendo válido durante toda la duración del Easter Egg.

---

# 67. Requisito de estabilidad de `CapitalForum_P1`

Conviene que el objeto utilizado como memoria global:

```text
no sea destruido
no sea sustituido físicamente
```

mientras el Easter Egg esté activo.

Un cambio de propietario no implica necesariamente perder la referencia, pero destruir el objeto sí sería problemático.

---

# 68. Coste de ejecución

La Sequence corre cada:

```text
100 ms
```

pero su trabajo por ciclo es pequeño:

```text
2 EnvReadInt
1 Group lookup cuando visible
ClearDead
3 setters
1 comprobación de distancia
```

---

# 69. Por qué se usa 100 ms y no 1 segundo

El sacerdote es un personaje narrativo que debe:

```text
no morir
no alejarse
no ser absorbido por la IA
```

Una frecuencia de 100 ms da una corrección mucho más rápida que los controladores estratégicos generales de 1–2 segundos.

---

# 70. Frecuencia frente a daño

Con:

```text
Sleep(100)
```

la salud puede restaurarse hasta unas diez veces por segundo.

---

# 71. Frecuencia frente a desplazamiento

Una orden externa puede existir sólo una fracción de segundo antes de que el sacerdote reciba:

```text
move → priestPos
```

si ya ha salido de la tolerancia de 50.

---

# 72. Protección frente a hambre

Aunque el sacerdote permanezca muchas horas en una partida endless:

```cpp
SetFeeding(false)
```

evita que el sistema normal de alimentación sea una amenaza.

---

# 73. Protección frente a la IA estratégica

Aunque el jugador propietario sea controlado por IA:

```cpp
SetNoAIFlag(true)
```

se reimpone continuamente.

---

# 74. No existe regeneración de una unidad perdida

`ZombieEE_PriestKeeper` no contiene:

```cpp
Place("EPriest", ...)
```

Por tanto si el sacerdote desaparece accidentalmente y ninguna otra Sequence lo repone:

```text
no reaparecerá gracias a PriestKeeper
```

---

# 75. Responsabilidad de la reaparición

La Sequence sólo garantiza:

```text
si vuelve a existir una unidad válida en ZombieEE_Priest01
→ volverá a protegerla
```

La creación física pertenece a otra fase del Easter Egg.

---

# 76. No necesita Conversation

No requiere ningún objeto de:

```text
Conversations
```

---

# 77. No necesita Areas

No utiliza:

```text
Area
ClassPlayerAreaObjs
```

---

# 78. No necesita Holders

No utiliza Holders adicionales.

---

# 79. No necesita marcadores de posición

La propia posición original del sacerdote actúa como marcador:

```cpp
priestPos =
    u_sacerdote.pos;
```

---

# 80. Groups necesarios

## Obligatorios

```text
CapitalForum_P1
ZombieEE_Priest01
```

---

# 81. Qué debe contener `CapitalForum_P1`

```text
exactamente 1 Building
```

que funcione como objeto de estado global.

---

# 82. Qué debe contener `ZombieEE_Priest01`

Al iniciar la Sequence:

```text
exactamente 1 Unit
```

correspondiente al sacerdote egipcio.

---

# 83. Groups que no necesita

No consulta directamente:

```text
ZombieEE_Caesar
ZombieEE_SacrificePyramids
HordeSpawn_01
EE_FirstHorde_Spawn01
CapitalForum_P2..P8
```

---

# 84. Flags implicados

| Flag | Operación | Función |
|---|---|---|
| `EE_PRIEST_HIDDEN` | Lee | Decide si el sacerdote debe estar activo/protegido |
| `EE_COMPLETED` | Lee | Finaliza definitivamente PriestKeeper |

---

# 85. No escribe flags

Esta Sequence no modifica el flujo narrativo.

No contiene ningún:

```cpp
EnvWriteInt(...)
```

para flags del Easter Egg.

---

# 86. Flujo inicial

```text
ZombieIntro_Main
↓
RunSequence("ZombieEE_PriestKeeper")
↓
resolver CapitalForum_P1
↓
resolver ZombieEE_Priest01
↓
guardar priestPos
↓
completed = 0
↓
entrar en bucle
```

---

# 87. Flujo de un ciclo visible

```text
leer EE_PRIEST_HIDDEN
↓
hidden == 0
↓
recuperar ZombieEE_Priest01
↓
ClearDead
↓
¿count == 1?
        ↓ Sí
    adquirir Unit
        ↓
    SetNoAIFlag(true)
        ↓
    SetFeeding(false)
        ↓
    SetHealth(1000)
        ↓
    ¿DistTo(priestPos) > 50?
        ↓ Sí
    move → priestPos
↓
leer EE_COMPLETED
↓
Sleep(100)
```

---

# 88. Flujo de un ciclo oculto

```text
leer EE_PRIEST_HIDDEN
↓
hidden == 1
↓
no consultar sacerdote
↓
no restaurar salud
↓
no mover
↓
leer EE_COMPLETED
↓
Sleep(100)
```

---

# 89. Flujo de reaparición

```text
EE_PRIEST_HIDDEN = 1
↓
sacerdote desaparece
↓
PriestKeeper espera
↓
otra Sequence crea nuevo sacerdote
↓
AddToGroup("ZombieEE_Priest01")
↓
EE_PRIEST_HIDDEN = 0
↓
siguiente ciclo
↓
q.count == 1
↓
adquirir nueva Unit
↓
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
↓
si está lejos:
move → priestPos original
```

---

# 90. Finalización

Cuando:

```text
EE_COMPLETED = 1
```

al final de un ciclo:

```cpp
completed = 1;
```

El `while` termina.

---

# 91. Salida definitiva

Después del bucle:

```cpp
return;
```

La Sequence deja de proteger al sacerdote.

---

# 92. Consecuencia tras terminar el Easter Egg

Una vez:

```text
EE_COMPLETED = 1
```

el sacerdote deja de depender de `ZombieEE_PriestKeeper`.

Su estado posterior queda en manos del resto del diseño del mapa.

---

# 93. No se restablecen propiedades al terminar

La Sequence no ejecuta:

```text
SetNoAIFlag(false)
SetFeeding(true)
```

antes de salir.

Por tanto la última configuración aplicada puede permanecer en la unidad.

---

# 94. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   └── ZombieEE_Priest01
│       └── exactamente 1 sacerdote egipcio al inicio
│
└── Sequences
    ├── ZombieIntro_Main
    │   └── AUTORUN = SI
    │
    └── ZombieEE_PriestKeeper
        ├── código v2.0
        ├── Compile
        └── AUTORUN = NO
```

---

# 95. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_Priest01` contiene exactamente un sacerdote al comenzar.
3. `ZombieIntro_Main` ejecuta `RunSequence("ZombieEE_PriestKeeper")`.
4. El sacerdote original está colocado en la posición definitiva deseada.
5. Las Sequences que lo oculten escriben correctamente `EE_PRIEST_HIDDEN`.
6. Si se recrea, la nueva unidad vuelve a añadirse a `ZombieEE_Priest01`.
7. El cierre del Easter Egg termina escribiendo `EE_COMPLETED = 1`.

---

# 96. Errores de configuración

## `CapitalForum_P1` incorrecto

Resultado:

```text
ERROR EE - CapitalForum_P1
↓
return
```

## `ZombieEE_Priest01` incorrecto al inicio

Resultado:

```text
ERROR EE - ZombieEE_Priest01
↓
return
```

## `ZombieEE_Priest01` vacío temporalmente durante el bucle

Resultado:

```text
no error
no protección ese ciclo
Sleep(100)
reintentar
```

---

# 97. Diferencia entre error inicial y ausencia posterior

Al inicio:

```text
debe existir exactamente 1 sacerdote
```

Durante el Easter Egg:

```text
puede existir temporalmente 0
```

porque la desaparición forma parte de la narrativa.

---

# 98. Protección aplicada

La protección real es:

```text
SetNoAIFlag(true)
+
SetFeeding(false)
+
SetHealth(1000)
+
corrección de posición cada 100 ms
```

---

# 99. Lo que no hace

`ZombieEE_PriestKeeper` no:

```text
crea el sacerdote
borra el sacerdote
inicia diálogos
detecta a César
activa objetivos
cuenta sacrificios
crea enemigos
controla portales
controla el amuleto
controla Waves
controla Rewards
```

---

# 100. Resumen funcional

```text
RunSequence desde ZombieIntro_Main
        ↓
resolver CapitalForum_P1
        ↓
resolver sacerdote inicial
        ↓
guardar posición original
        ↓
mientras EE_COMPLETED == 0
        ↓
leer EE_PRIEST_HIDDEN
        ↓
si visible:
    recuperar sacerdote actual
    ↓
    SetNoAIFlag(true)
    SetFeeding(false)
    SetHealth(1000)
    ↓
    si se aleja >50
        move → posición original
        ↓
si oculto:
    no intervenir
        ↓
Sleep(100)
        ↓
repetir
        ↓
EE_COMPLETED = 1
        ↓
return
```

`ZombieEE_PriestKeeper` es la capa de protección y persistencia funcional del sacerdote egipcio. No controla la narrativa del Easter Egg, pero garantiza que el personaje permanezca estable mientras está visible y que pueda ser re-adquirido automáticamente después de una desaparición temporal.

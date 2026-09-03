# Secuencia 13 — `ZombieEE_Dialogue01`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Dialogue01` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Dialogue01` es la primera conversación presencial del Easter Egg.

Se ejecuta cuando:

```text
la mini-horda concreta de R1 nacida en HordeSpawn_01
ha sido aniquilada
↓
ZombieEE_FirstHordeTrigger
escribe EE_PRIEST_PENDING = 1
↓
ZombieEE_PriestInteraction_Main
detecta a César a ≤180 del sacerdote
↓
borra EE_PRIEST_PENDING
↓
RunSequence("ZombieEE_Dialogue01")
```

La Sequence:

1. valida el estado global;
2. impide repetir el diálogo;
3. recupera a César;
4. recupera al sacerdote egipcio;
5. bloquea temporalmente ambos actores frente a IA y alimentación;
6. bloquea el input;
7. centra brevemente la cámara en el sacerdote;
8. ejecuta `ZombieEE_Conv01`;
9. devuelve el control al jugador;
10. restaura a César;
11. marca el diálogo como completado;
12. inicializa la fase de las cincuenta almas;
13. activa `ZombieEE_Sacrifice_Main`;
14. muestra durante 8 segundos el objetivo de llevar 50 aldeanos a las pirámides.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel narrativo

`ZombieEE_Dialogue01` transforma el primer trigger oculto del Easter Egg en una misión jugable explícita.

La transición es:

```text
primera horda especial destruida
↓
visita presencial al sacerdote
↓
conversación
↓
fase de sacrificio habilitada
↓
objetivo:
CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_Dialogue01
→ AUTORUN = NO
```

No debe empezar al cargar el mapa.

Su único lanzamiento normal procede de:

```text
ZombieEE_PriestInteraction_Main
```

---

# 3. Condición previa

Antes de ejecutarse normalmente debe haber ocurrido:

```text
EE_PRIEST_PENDING = 1
```

pero `ZombieEE_Dialogue01` no necesita leer ese flag.

`ZombieEE_PriestInteraction_Main` lo pone a cero antes de lanzar esta Sequence.

---

# 4. Variables principales

La Sequence declara:

```cpp
ObjList q;
ObjList stateList;

Building state;

Unit u_capitan;
Unit u_sacerdote;

Conversation conv;
```

---

# 5. `stateList`

Se utiliza para recuperar:

```text
CapitalForum_P1
```

---

# 6. `state`

Es el `Building` global donde se leen y escriben los flags del Easter Egg.

---

# 7. `q`

Es una lista reutilizada para localizar:

```text
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 8. `u_capitan`

Representa a César.

---

# 9. `u_sacerdote`

Representa al sacerdote egipcio persistente del Easter Egg.

---

# 10. `conv`

Es la instancia de:

```cpp
Conversation
```

utilizada para reproducir:

```text
ZombieEE_Conv01
```

---

# 11. Group obligatorio de estado

La Sequence empieza con:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después exige:

```cpp
if(stateList.count != 1)
```

---

# 12. Error de `CapitalForum_P1`

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - CapitalForum_P1"
);

return;
```

---

# 13. Obtención del objeto global

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 14. Protección frente a repetición

Antes de buscar actores:

```cpp
if(
    EnvReadInt(
        state,
        "EE_DIALOGUE01_COMPLETED"
    )
    ==
    1
)
    return;
```

---

# 15. Significado de `EE_DIALOGUE01_COMPLETED`

```text
0
→ Dialogue01 todavía puede ejecutarse

1
→ Dialogue01 ya terminó
```

---

# 16. Ventaja de comprobarlo al principio

Aunque otra Sequence lanzara accidentalmente:

```cpp
RunSequence(
    "ZombieEE_Dialogue01"
);
```

una segunda vez, la conversación no volvería a reproducirse si el flag ya está marcado.

---

# 17. Group obligatorio de César

La Sequence consulta:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

---

# 18. Validación de César

Debe cumplirse:

```text
ZombieEE_Caesar.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - ZombieEE_Caesar"
);

return;
```

---

# 19. Conversión a `Unit`

Cuando el Group es correcto:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 20. Group obligatorio del sacerdote

Después:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 21. Validación del sacerdote

Debe cumplirse:

```text
ZombieEE_Priest01.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE - ZombieEE_Priest01"
);

return;
```

---

# 22. Conversión del sacerdote

Cuando el Group es válido:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

---

# 23. Preparación de César

Antes del diálogo:

```cpp
u_capitan.SetNoAIFlag(
    true
);
```

---

# 24. Preparación del sacerdote

También:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 25. Alimentación temporal de César

Se ejecuta:

```cpp
u_capitan.SetFeeding(
    false
);
```

---

# 26. Alimentación del sacerdote

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 27. Motivo de `SetNoAIFlag(true)`

Durante la escena se evita que la IA estratégica interfiera con:

```text
César
sacerdote
```

mientras la Conversation está activa.

---

# 28. Motivo de `SetFeeding(false)`

La escena es breve, pero se elimina cualquier dependencia temporal de alimentación mientras los actores están bloqueados en modo conversación.

---

# 29. Bloqueo del jugador

Antes de mover la cámara:

```cpp
BlockUserInput();
```

El jugador pierde control temporalmente.

---

# 30. Cámara inicial

Se ejecuta:

```cpp
StartViewFollow(
    u_sacerdote
);
```

---

# 31. Duración del seguimiento inicial

Después:

```cpp
Sleep(1000);
```

La cámara permanece aproximadamente:

```text
1 segundo
```

siguiendo al sacerdote.

---

# 32. Fin del seguimiento

Después:

```cpp
StopViewFollow();
```

---

# 33. Pausa antes de la Conversation

Se ejecuta:

```cpp
Sleep(250);
```

Esto introduce una transición breve antes del diálogo.

---

# 34. Conversation utilizada

La Sequence inicializa:

```cpp
conv.Init(
    "ZombieEE_Conv01"
);
```

Por tanto debe existir exactamente:

```text
ZombieEE_Conv01
```

en el editor de Conversations.

---

# 35. Actor `Capitan`

La Conversation debe contener un actor llamado:

```text
Capitan
```

Se asigna mediante:

```cpp
conv.SetActor(
    "Capitan",
    u_capitan
);
```

---

# 36. Actor `Sacerdote`

La Conversation debe contener un actor llamado:

```text
Sacerdote
```

Se asigna mediante:

```cpp
conv.SetActor(
    "Sacerdote",
    u_sacerdote
);
```

---

# 37. Número de actores

`ZombieEE_Conv01` utiliza exactamente:

```text
2 actores
```

desde esta Sequence:

```text
Capitan
Sacerdote
```

---

# 38. Ejecución de la Conversation

La conversación se reproduce con:

```cpp
conv.Run();
```

La Sequence espera a que termine antes de continuar.

---

# 39. No utiliza mensajero

El mensajero cartaginés pertenece a:

```text
ZombieIntro_Main
```

No participa en `ZombieEE_Conv01`.

---

# 40. No utiliza sacerdote romano

El `RPriest` temporal de la intro ya fue eliminado.

Aquí sólo existe el sacerdote egipcio:

```text
ZombieEE_Priest01
```

---

# 41. Pausa tras el diálogo

Después de `conv.Run()`:

```cpp
Sleep(500);
```

---

# 42. Devolver control al jugador

Después:

```cpp
UnblockUserInput();
```

La fase cinematográfica termina.

---

# 43. Restauración de César

Se ejecuta:

```cpp
u_capitan.SetFeeding(
    true
);

u_capitan.SetNoAIFlag(
    false
);
```

---

# 44. César vuelve al sistema normal

Tras estas llamadas César vuelve a:

```text
alimentación normal
IA normal
control normal
```

---

# 45. El sacerdote no se restaura aquí

La Sequence no ejecuta:

```text
u_sacerdote.SetFeeding(true)
u_sacerdote.SetNoAIFlag(false)
```

---

# 46. Motivo

El sacerdote sigue siendo un personaje persistente del Easter Egg y está gestionado por:

```text
ZombieEE_PriestKeeper
```

que continúa imponiendo:

```text
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
```

---

# 47. Primer flag escrito al terminar

Se marca:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE01_COMPLETED",
    1
);
```

---

# 48. Consecuencia

Desde ese instante:

```text
ZombieEE_Dialogue01
```

no debe volver a ejecutarse.

---

# 49. Reinicio del contador de almas

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_SOULS_DELIVERED",
    0
);
```

---

# 50. Significado de `EE_SOULS_DELIVERED`

Representa:

```text
número de aldeanos sacrificados
```

durante la siguiente fase.

Dialogue01 lo reinicia expresamente a cero antes de arrancarla.

---

# 51. Reinicio de `EE_SACRIFICE_COMPLETED`

También:

```cpp
EnvWriteInt(
    state,
    "EE_SACRIFICE_COMPLETED",
    0
);
```

---

# 52. Significado

```text
0
→ sacrificio todavía no completado

1
→ las 50 almas ya fueron entregadas
```

---

# 53. Activación del sacrificio

La Sequence escribe:

```cpp
EnvWriteInt(
    state,
    "EE_SACRIFICE_ENABLED",
    1
);
```

---

# 54. Significado de `EE_SACRIFICE_ENABLED`

```text
1
```

autoriza a:

```text
ZombieEE_Sacrifice_Main
```

a comenzar a aceptar aldeanos en las pirámides.

---

# 55. Orden exacto de flags

La Sequence escribe:

```text
EE_DIALOGUE01_COMPLETED = 1
EE_SOULS_DELIVERED = 0
EE_SACRIFICE_COMPLETED = 0
EE_SACRIFICE_ENABLED = 1
```

antes de lanzar la siguiente Sequence.

---

# 56. Lanzamiento de la fase siguiente

Después:

```cpp
RunSequence(
    "ZombieEE_Sacrifice_Main"
);
```

---

# 57. `ZombieEE_Sacrifice_Main`

Debe existir con:

```text
AUTORUN = NO
```

porque es iniciada directamente por Dialogue01.

---

# 58. Aviso de objetivo

Después del `RunSequence()`:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES"
);
```

---

# 59. Canal de anuncio

La ID utilizada es:

```text
ZombieHelp
```

---

# 60. Duración del objetivo visible

La Sequence espera:

```cpp
Sleep(8000);
```

Por tanto el mensaje permanece aproximadamente:

```text
8 segundos
```

---

# 61. Ocultar el mensaje

Después:

```cpp
HideAnnouncement(
    "ZombieHelp"
);
```

---

# 62. La misión sigue activa después de ocultar el texto

Ocultar el anuncio no desactiva:

```text
EE_SACRIFICE_ENABLED
```

La mecánica de las 50 almas continúa funcionando.

---

# 63. Final de la Sequence

Después:

```cpp
return;
```

`ZombieEE_Dialogue01` termina definitivamente.

---

# 64. No permanece vigilando el sacrificio

No contiene ningún:

```text
while
```

para esperar:

```text
EE_SOULS_DELIVERED == 50
```

Ese trabajo pertenece por completo a:

```text
ZombieEE_Sacrifice_Main
```

---

# 65. No crea enemigos

Dialogue01 no crea:

```text
Anubis
Horus
zombies
```

---

# 66. No activa todavía los portales

No escribe:

```text
EE_PORTALS_ENABLED
```

Los portales pertenecen a una fase posterior.

---

# 67. No inicia el ataque de Anubis

La Sequence no ejecuta:

```cpp
RunSequence(
    "ZombieEE_AnubisAttack_Main"
);
```

Ese ataque se produce después de completar las 50 almas.

---

# 68. No modifica Waves

No pausa:

```text
ZombieWaves_Main
```

---

# 69. No modifica Rewards

No toca:

```text
ZR_MASK
ZR_REWARDED
ZR_ENDLESS_*
```

---

# 70. No modifica `EE_PRIEST_PENDING`

Ese valor ya fue puesto a cero por:

```text
ZombieEE_PriestInteraction_Main
```

antes de lanzar este diálogo.

---

# 71. No escribe `EE_PRIEST_HIDDEN`

El sacerdote permanece visible después de Dialogue01.

---

# 72. No escribe `EE_COMPLETED`

El Easter Egg todavía está en sus primeras fases.

---

# 73. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 74. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 75. `ZombieEE_Caesar`

Debe contener:

```text
exactamente 1 Unit
```

---

# 76. `ZombieEE_Priest01`

Debe contener:

```text
exactamente 1 Unit
```

cuando Dialogue01 se ejecuta.

---

# 77. Groups que no necesita

No consulta directamente:

```text
EE_FirstHorde_Spawn01
HordeSpawn_01
HW_H1
HW_R1
CapitalForum_P2..P8
```

---

# 78. Areas necesarias

Ninguna.

---

# 79. Holders necesarios

Ninguno.

---

# 80. Conversation necesaria

Debe existir:

```text
ZombieEE_Conv01
```

con actores:

```text
Capitan
Sacerdote
```

---

# 81. Sequence siguiente

Debe existir:

```text
ZombieEE_Sacrifice_Main
```

---

# 82. Dependencia anterior

La Sequence es lanzada normalmente por:

```text
ZombieEE_PriestInteraction_Main
```

---

# 83. Dependencia funcional con PriestKeeper

Aunque no lo llama directamente, presupone que:

```text
ZombieEE_PriestKeeper
```

sigue ejecutándose y manteniendo al sacerdote estable.

---

# 84. Flags que lee

| Flag | Función |
|---|---|
| `EE_DIALOGUE01_COMPLETED` | Evita repetir la conversación |

---

# 85. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_DIALOGUE01_COMPLETED` | 1 | Marca Dialogue01 como completado |
| `EE_SOULS_DELIVERED` | 0 | Reinicia contador de almas |
| `EE_SACRIFICE_COMPLETED` | 0 | Reinicia estado del sacrificio |
| `EE_SACRIFICE_ENABLED` | 1 | Activa fase de las 50 almas |

---

# 86. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR EE - CapitalForum_P1` |
| `ZombieHelp` | `ERROR EE - ZombieEE_Caesar` |
| `ZombieHelp` | `ERROR EE - ZombieEE_Priest01` |
| `ZombieHelp` | `CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES` |

---

# 87. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Cámara sobre sacerdote | 1.000 ms |
| Pausa después de StopViewFollow | 250 ms |
| Pausa tras Conversation | 500 ms |
| Objetivo de 50 aldeanos visible | 8.000 ms |

---

# 88. Flujo exacto de cámara

```text
BlockUserInput
↓
StartViewFollow(sacerdote)
↓
1 segundo
↓
StopViewFollow
↓
250 ms
↓
ZombieEE_Conv01
```

---

# 89. Flujo exacto de actores

```text
César:
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
SetFeeding(true)
SetNoAIFlag(false)

Sacerdote:
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
no se restaura aquí
↓
PriestKeeper sigue controlándolo
```

---

# 90. Flujo exacto de transición de fase

```text
conv.Run()
↓
Sleep(500)
↓
UnblockUserInput()
↓
restaurar César
↓
EE_DIALOGUE01_COMPLETED = 1
↓
EE_SOULS_DELIVERED = 0
↓
EE_SACRIFICE_COMPLETED = 0
↓
EE_SACRIFICE_ENABLED = 1
↓
RunSequence("ZombieEE_Sacrifice_Main")
↓
CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES
↓
8 segundos
↓
HideAnnouncement
↓
return
```

---

# 91. Qué ocurre si se lanza y falta César

Resultado:

```text
ERROR EE - ZombieEE_Caesar
↓
return
```

No se activa la fase del sacrificio.

---

# 92. Qué ocurre si falta el sacerdote

Resultado:

```text
ERROR EE - ZombieEE_Priest01
↓
return
```

No se marca Dialogue01 como completado.

---

# 93. Qué ocurre si `CapitalForum_P1` falla

Resultado:

```text
ERROR EE - CapitalForum_P1
↓
return
```

No se puede leer ni escribir el estado del Easter Egg.

---

# 94. Qué ocurre si Dialogue01 ya estaba completado

Resultado:

```text
EE_DIALOGUE01_COMPLETED == 1
↓
return
```

No hay mensaje ni repetición.

---

# 95. Qué ocurre si `ZombieEE_Sacrifice_Main` no existe

El diseño presupone que el nombre de la Sequence es exacto:

```text
ZombieEE_Sacrifice_Main
```

Cualquier cambio de nombre rompería la transición automática al sacrificio.

---

# 96. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── ZombieEE_Caesar
│   │   └── César
│   │
│   └── ZombieEE_Priest01
│       └── sacerdote egipcio
│
├── Conversations
│   └── ZombieEE_Conv01
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue01
    │   └── AUTORUN = NO
    │
    └── ZombieEE_Sacrifice_Main
        └── AUTORUN = NO
```

---

# 97. Lugar dentro del Easter Egg

```text
ZombieEE_FirstHordeTrigger
↓
EE_PRIEST_PENDING = 1
↓
ZombieEE_PriestInteraction_Main
↓
César <=180 del sacerdote
↓
ZombieEE_Dialogue01
↓
EE_SACRIFICE_ENABLED = 1
↓
ZombieEE_Sacrifice_Main
↓
50 almas
↓
fase siguiente
```

---

# 98. Separación de responsabilidades

## `ZombieEE_FirstHordeTrigger`

Decide:

```text
ya puede empezar el primer diálogo
```

## `ZombieEE_PriestInteraction_Main`

Decide:

```text
César ya llegó físicamente al sacerdote
```

## `ZombieEE_Dialogue01`

Decide:

```text
reproducir conversación
y activar el sacrificio
```

## `ZombieEE_Sacrifice_Main`

Decide:

```text
cuándo se han entregado las 50 almas
```

---

# 99. Resumen funcional

```text
RunSequence desde PriestInteraction
        ↓
validar CapitalForum_P1
        ↓
¿EE_DIALOGUE01_COMPLETED == 1?
        Sí → return
        ↓
obtener César
        ↓
obtener sacerdote
        ↓
SetNoAIFlag(true)
SetFeeding(false)
        ↓
BlockUserInput
        ↓
cámara 1 s sobre sacerdote
        ↓
ZombieEE_Conv01
        ↓
UnblockUserInput
        ↓
restaurar César
        ↓
EE_DIALOGUE01_COMPLETED = 1
EE_SOULS_DELIVERED = 0
EE_SACRIFICE_COMPLETED = 0
EE_SACRIFICE_ENABLED = 1
        ↓
RunSequence("ZombieEE_Sacrifice_Main")
        ↓
mostrar 8 s:
CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES
        ↓
return
```

`ZombieEE_Dialogue01` es la transición entre el descubrimiento inicial del Easter Egg y su primera mecánica activa: el sacrificio de cincuenta aldeanos en las pirámides.

# Secuencia 18 — `ZombieEE_Dialogue03`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Dialogue03` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Dialogue03` es la tercera conversación presencial del Easter Egg.

Se ejecuta después de completar la fase de los portales y volver físicamente con César hasta el sacerdote egipcio.

La Sequence:

1. valida el estado global;
2. impide repetir la conversación;
3. exige que la fase de portales ya esté completada;
4. obtiene a César;
5. obtiene al sacerdote egipcio;
6. bloquea temporalmente ambos frente a la IA y la alimentación;
7. bloquea el input;
8. centra brevemente la cámara en el sacerdote;
9. reproduce `ZombieEE_Conv03`;
10. devuelve el control al jugador;
11. restaura a César;
12. marca Dialogue03 como completado;
13. marca como terminada la fase de portales;
14. inicializa todos los flags de la búsqueda de Gem of Power;
15. inicia `ZombieEE_Amulet_Main`;
16. muestra durante 6 segundos el objetivo:

```text
ATACA EL CAMPAMENTO DEL SUR Y RECUPERA GEM OF POWER
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo narrativo es:

```text
cerrar 4 portales cualesquiera
↓
ZombieEE_Portals_Main
↓
EE_PORTALS_COMPLETED = 1
EE_PRIEST_PENDING = 3
↓
ZombieEE_PriestInteraction_Main
↓
César <=180 del sacerdote
↓
EE_PRIEST_PENDING = 0
↓
RunSequence("ZombieEE_Dialogue03")
↓
ZombieEE_Conv03
↓
activar búsqueda de Gem of Power
↓
RunSequence("ZombieEE_Amulet_Main")
```

---

# 2. Nota sobre el comentario histórico del Source

La cabecera interna del Source dice:

```text
despues de cerrar los ocho portales
```

Sin embargo la lógica canónica v2.0 de `ZombieEE_Portals_Main` completa la fase al cerrar:

```text
4 de los 8 portales
```

Por tanto, funcionalmente Dialogue03 se ejecuta después de:

```text
EE_PORTALS_COMPLETED = 1
```

y ese flag se alcanza al sellar cuatro portales cualesquiera.

---

# 3. Autorun

La configuración correcta es:

```text
ZombieEE_Dialogue03
→ AUTORUN = NO
```

No debe ejecutarse al cargar el mapa.

Su lanzamiento normal procede de:

```text
ZombieEE_PriestInteraction_Main
```

---

# 4. Condición narrativa previa

Antes del lanzamiento normal:

```text
EE_PORTALS_COMPLETED = 1
```

y previamente:

```text
EE_PRIEST_PENDING = 3
```

`ZombieEE_PriestInteraction_Main` pone `pending` a cero antes de ejecutar esta Sequence.

---

# 5. Variables principales

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

# 6. `stateList`

Se utiliza para obtener:

```text
CapitalForum_P1
```

---

# 7. `state`

Es el `Building` global utilizado como memoria persistente del Easter Egg.

---

# 8. `q`

Es una lista reutilizada para obtener:

```text
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 9. `u_capitan`

Representa a César.

---

# 10. `u_sacerdote`

Representa al sacerdote egipcio persistente.

---

# 11. `conv`

Es la instancia de:

```cpp
Conversation
```

que reproduce:

```text
ZombieEE_Conv03
```

---

# 12. Group obligatorio de estado

La Sequence comienza con:

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

# 13. Error de `CapitalForum_P1`

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE3 - CapitalForum_P1"
);

return;
```

---

# 14. Obtención del estado global

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 15. Protección frente a repetición

La primera validación de fase es:

```cpp
if(
    EnvReadInt(
        state,
        "EE_DIALOGUE03_COMPLETED"
    )
    ==
    1
)
    return;
```

---

# 16. Significado de `EE_DIALOGUE03_COMPLETED`

```text
0
→ Dialogue03 todavía puede ejecutarse

1
→ Dialogue03 ya terminó
```

---

# 17. Qué ocurre si se intenta repetir

Si el flag ya vale 1:

```text
no Conversation
no reinicio de amuleto
no RunSequence
return
```

---

# 18. Validación de portales completados

Después:

```cpp
if(
    EnvReadInt(
        state,
        "EE_PORTALS_COMPLETED"
    )
    !=
    1
)
    return;
```

---

# 19. Consecuencia

Aunque alguien ejecutara manualmente:

```cpp
RunSequence(
    "ZombieEE_Dialogue03"
);
```

antes de cerrar los portales necesarios:

```text
la Sequence termina sin hacer nada
```

---

# 20. Condición real de acceso a Dialogue03

Deben cumplirse simultáneamente:

```text
EE_DIALOGUE03_COMPLETED != 1
EE_PORTALS_COMPLETED == 1
```

---

# 21. Group obligatorio de César

La Sequence consulta:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

---

# 22. Validación de César

Debe cumplirse:

```text
ZombieEE_Caesar.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE3 - ZombieEE_Caesar"
);

return;
```

---

# 23. Conversión de César

Cuando es válido:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 24. Group obligatorio del sacerdote

Después:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 25. Validación del sacerdote

Debe cumplirse:

```text
ZombieEE_Priest01.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE3 - ZombieEE_Priest01"
);

return;
```

---

# 26. Conversión del sacerdote

Cuando es válido:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

---

# 27. Preparación de César

Antes de la conversación:

```cpp
u_capitan.SetNoAIFlag(
    true
);
```

---

# 28. Preparación del sacerdote

También:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 29. Alimentación temporal de César

Se ejecuta:

```cpp
u_capitan.SetFeeding(
    false
);
```

---

# 30. Alimentación del sacerdote

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 31. Motivo de estas llamadas

Durante la conversación se evita que:

```text
IA estratégica
sistema de alimentación
```

interfieran con César o el sacerdote.

---

# 32. Bloqueo del input

Antes de la cámara:

```cpp
BlockUserInput();
```

---

# 33. Cámara inicial

Se ejecuta:

```cpp
StartViewFollow(
    u_sacerdote
);
```

---

# 34. Duración del seguimiento

Después:

```cpp
Sleep(
    1000
);
```

La cámara permanece aproximadamente:

```text
1 segundo
```

sobre el sacerdote.

---

# 35. Fin del seguimiento

Después:

```cpp
StopViewFollow();
```

---

# 36. Pausa de transición

Se ejecuta:

```cpp
Sleep(
    250
);
```

---

# 37. Conversation utilizada

La Sequence inicializa:

```cpp
conv.Init(
    "ZombieEE_Conv03"
);
```

Por tanto debe existir exactamente:

```text
ZombieEE_Conv03
```

en el editor.

---

# 38. Actor `Capitan`

Debe existir dentro de la Conversation:

```text
Capitan
```

y se asigna mediante:

```cpp
conv.SetActor(
    "Capitan",
    u_capitan
);
```

---

# 39. Actor `Sacerdote`

Debe existir:

```text
Sacerdote
```

y se asigna mediante:

```cpp
conv.SetActor(
    "Sacerdote",
    u_sacerdote
);
```

---

# 40. Número de actores

La Conversation utiliza:

```text
2 actores
```

desde esta Sequence:

```text
Capitan
Sacerdote
```

---

# 41. Ejecución del diálogo

Se reproduce con:

```cpp
conv.Run();
```

---

# 42. Pausa posterior

Después:

```cpp
Sleep(
    500
);
```

---

# 43. Devolver control al jugador

Se ejecuta:

```cpp
UnblockUserInput();
```

---

# 44. Restauración de César

La versión canónica ejecuta directamente:

```cpp
u_capitan.SetFeeding(
    true
);

u_capitan.SetNoAIFlag(
    false
);
```

---

# 45. Diferencia respecto a Dialogue02

`ZombieEE_Dialogue02` refresca el Group de César antes de restaurarlo.

`ZombieEE_Dialogue03` reutiliza directamente:

```text
u_capitan
```

después de `conv.Run()`.

---

# 46. Consecuencia técnica

El código presupone que César sigue siendo una unidad válida al terminar la Conversation.

No contiene una nueva comprobación:

```text
Group("ZombieEE_Caesar")
```

entre:

```text
conv.Run()
```

y:

```text
SetFeeding(true)
SetNoAIFlag(false)
```

---

# 47. El sacerdote no se restaura

No se ejecuta:

```text
SetFeeding(true)
SetNoAIFlag(false)
```

sobre el sacerdote.

---

# 48. Motivo

El sacerdote sigue protegido por:

```text
ZombieEE_PriestKeeper
```

que mantiene:

```text
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
```

---

# 49. Marcar Dialogue03 como completado

Después se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE03_COMPLETED",
    1
);
```

---

# 50. Marcar fase de portales terminada

También:

```cpp
EnvWriteInt(
    state,
    "EE_PORTAL_PHASE_FINISHED",
    1
);
```

---

# 51. Significado de `EE_PORTAL_PHASE_FINISHED`

Dialogue02 había reiniciado:

```text
EE_PORTAL_PHASE_FINISHED = 0
```

Dialogue03 es quien finalmente lo pone a:

```text
1
```

---

# 52. Diferencia respecto a `EE_PORTALS_COMPLETED`

`EE_PORTALS_COMPLETED = 1` significa:

```text
ya se cerraron los portales necesarios
```

`EE_PORTAL_PHASE_FINISHED = 1` significa:

```text
César ya volvió al sacerdote
y Dialogue03 ya procesó el final narrativo de esa fase
```

---

# 53. Habilitar búsqueda del amuleto

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_HUNT_ENABLED",
    1
);
```

---

# 54. Significado

```text
1
→ la fase de Gem of Power queda habilitada
```

---

# 55. Reiniciar spawn del ejército cartaginés

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_ARMY_SPAWNED",
    0
);
```

---

# 56. Significado

```text
0
→ el ejército/campamento asociado a Gem of Power
todavía no ha sido marcado como generado
```

---

# 57. Reiniciar derrota del portador

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_CARRIER_DEFEATED",
    0
);
```

---

# 58. Significado

```text
0
→ el portador del amuleto todavía no ha sido derrotado
```

---

# 59. Reiniciar entrega del amuleto

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_DELIVERED",
    0
);
```

---

# 60. Significado

```text
0
→ Gem of Power todavía no ha sido entregada
```

---

# 61. Reiniciar fase completada

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_PHASE_COMPLETED",
    0
);
```

---

# 62. Significado

```text
0
→ la fase completa del amuleto todavía no ha terminado
```

---

# 63. Reiniciar ejército derrotado

También:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_ARMY_DEFEATED",
    0
);
```

---

# 64. Significado

```text
0
→ el ejército que protege el amuleto
todavía no está marcado como derrotado
```

---

# 65. Reiniciar Dialogue04

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE04_COMPLETED",
    0
);
```

---

# 66. Motivo

Dialogue04 es la conversación posterior a la fase de Gem of Power.

Dialogue03 deja explícitamente su estado preparado.

---

# 67. Lista completa de flags escritos

```text
EE_DIALOGUE03_COMPLETED = 1
EE_PORTAL_PHASE_FINISHED = 1

EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_ARMY_SPAWNED = 0
EE_AMULET_CARRIER_DEFEATED = 0
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0
EE_AMULET_ARMY_DEFEATED = 0

EE_DIALOGUE04_COMPLETED = 0
```

---

# 68. No reinicia `EE_PRIEST_PENDING`

Dialogue03 no escribe:

```text
EE_PRIEST_PENDING
```

porque `ZombieEE_PriestInteraction_Main` ya lo puso a cero antes de lanzar esta conversación.

---

# 69. Lanzamiento de la fase del amuleto

Después de inicializar los flags:

```cpp
RunSequence(
    "ZombieEE_Amulet_Main"
);
```

---

# 70. Autorun esperado de `ZombieEE_Amulet_Main`

Debe estar configurada con:

```text
AUTORUN = NO
```

porque Dialogue03 es quien la inicia.

---

# 71. Comentario interno del Source

La sección se titula:

```text
GENERAR EL CAMPAMENTO CARTAGINES
```

antes de:

```cpp
RunSequence(
    "ZombieEE_Amulet_Main"
);
```

---

# 72. Objetivo mostrado al jugador

Después del `RunSequence()`:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "ATACA EL CAMPAMENTO DEL SUR Y RECUPERA GEM OF POWER"
);
```

---

# 73. ID del anuncio

Se utiliza:

```text
ZombieEEObjective
```

---

# 74. Duración del anuncio

Después:

```cpp
Sleep(
    6000
);
```

El mensaje permanece aproximadamente:

```text
6 segundos
```

---

# 75. No se oculta explícitamente después

La Sequence no contiene:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

al final.

---

# 76. Consecuencia

El anuncio queda gestionado por el sistema de anuncios del juego o por futuras llamadas que reutilicen:

```text
ZombieEEObjective
```

---

# 77. Fin de la Sequence

Después del `Sleep(6000)`:

```cpp
return;
```

---

# 78. Dialogue03 no gestiona físicamente el campamento

No contiene:

```text
Place de soldados cartagineses
Place de héroe/portador
detección de muertes
movimiento del amuleto
entrega en pirámides
```

Todo eso pertenece a:

```text
ZombieEE_Amulet_Main
```

---

# 79. No espera a que el ejército sea derrotado

No contiene:

```text
while EE_AMULET_ARMY_DEFEATED == 0
```

---

# 80. No espera a que el portador muera

No contiene ninguna espera sobre:

```text
EE_AMULET_CARRIER_DEFEATED
```

---

# 81. No espera la entrega de Gem of Power

No contiene ninguna espera sobre:

```text
EE_AMULET_DELIVERED
```

---

# 82. Separación de responsabilidades

Dialogue03 sólo realiza:

```text
Conversation
+
inicialización de flags
+
RunSequence
+
mensaje de objetivo
```

---

# 83. No reactiva Waves

Las nuevas oleadas normales ya fueron desactivadas al completar los cuatro portales.

Dialogue03 no escribe:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 0
```

---

# 84. Estado de Waves tras Dialogue03

La intención canónica es mantener:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 1
```

---

# 85. Zombies ya existentes

Dialogue03 no elimina zombies residuales.

Pueden seguir existiendo unidades de:

```text
HW_H1..8
```

mientras comienza la fase de Gem of Power.

---

# 86. Tactical sigue independiente

`ZombieTactical_Main` puede seguir controlando esos zombies supervivientes.

---

# 87. No modifica Rewards

No toca:

```text
ZR_MASK
ZR_REWARDED
ZR_ENDLESS_*
```

---

# 88. No modifica los ocho flags `EE_PORTAL_CLOSEDN`

La selección de qué cuatro portales fueron cerrados permanece registrada.

---

# 89. No modifica recompensas de portales

Tampoco toca:

```text
EE_PORTAL_REWARD_GRANTED1..8
```

---

# 90. No oculta al sacerdote

Dialogue03 no escribe:

```text
EE_PRIEST_HIDDEN = 1
```

El sacerdote sigue visible después de la conversación.

---

# 91. Ocultación posterior

La desaparición del sacerdote pertenece a una fase posterior del Easter Egg.

---

# 92. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 93. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 94. `ZombieEE_Caesar`

Debe contener:

```text
exactamente 1 Unit
```

---

# 95. `ZombieEE_Priest01`

Debe contener:

```text
exactamente 1 Unit
```

cuando Dialogue03 se ejecuta.

---

# 96. Groups que no necesita directamente

No consulta:

```text
HordeSpawn_01..08
EE_PortalGuardiansActive
EE_PortalRewards
HW_H1..8
Groups del campamento cartaginés
```

---

# 97. Areas necesarias

Ninguna.

---

# 98. Holders necesarios

Ninguno.

---

# 99. Conversation necesaria

Debe existir:

```text
ZombieEE_Conv03
```

con los actores:

```text
Capitan
Sacerdote
```

---

# 100. Sequence anterior

La fase anterior es:

```text
ZombieEE_Portals_Main
```

---

# 101. Intermediario presencial

Después de los cuatro cierres:

```text
ZombieEE_PriestInteraction_Main
```

espera que César vuelva al sacerdote.

---

# 102. Sequence siguiente

Dialogue03 inicia:

```text
ZombieEE_Amulet_Main
```

---

# 103. Flags que lee

| Flag | Función |
|---|---|
| `EE_DIALOGUE03_COMPLETED` | Evita repetir Dialogue03 |
| `EE_PORTALS_COMPLETED` | Exige que los portales necesarios ya estén sellados |

---

# 104. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_DIALOGUE03_COMPLETED` | 1 | Marca Dialogue03 completado |
| `EE_PORTAL_PHASE_FINISHED` | 1 | Cierra narrativamente la fase de portales |
| `EE_AMULET_HUNT_ENABLED` | 1 | Habilita búsqueda de Gem of Power |
| `EE_AMULET_ARMY_SPAWNED` | 0 | Reinicia estado de aparición del ejército |
| `EE_AMULET_CARRIER_DEFEATED` | 0 | Reinicia estado del portador |
| `EE_AMULET_DELIVERED` | 0 | Reinicia entrega de Gem of Power |
| `EE_AMULET_PHASE_COMPLETED` | 0 | Reinicia completado global de la fase |
| `EE_AMULET_ARMY_DEFEATED` | 0 | Reinicia derrota del ejército |
| `EE_DIALOGUE04_COMPLETED` | 0 | Prepara el siguiente diálogo |

---

# 105. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR EE3 - CapitalForum_P1` |
| `ZombieHelp` | `ERROR EE3 - ZombieEE_Caesar` |
| `ZombieHelp` | `ERROR EE3 - ZombieEE_Priest01` |
| `ZombieEEObjective` | `ATACA EL CAMPAMENTO DEL SUR Y RECUPERA GEM OF POWER` |

---

# 106. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Cámara sobre sacerdote | 1.000 ms |
| Pausa tras StopViewFollow | 250 ms |
| Pausa tras Conversation | 500 ms |
| Objetivo del amuleto | 6.000 ms |

---

# 107. Flujo exacto de cámara

```text
BlockUserInput
↓
StartViewFollow(sacerdote)
↓
Sleep(1000)
↓
StopViewFollow
↓
Sleep(250)
↓
ZombieEE_Conv03
```

---

# 108. Flujo exacto de César

```text
obtener César
↓
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
Sleep(500)
↓
UnblockUserInput
↓
SetFeeding(true)
SetNoAIFlag(false)
```

---

# 109. Flujo exacto del sacerdote

```text
obtener sacerdote
↓
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
no restaurarlo
↓
PriestKeeper continúa gestionándolo
```

---

# 110. Flujo exacto de transición

```text
conv.Run()
↓
Sleep(500)
↓
UnblockUserInput
↓
restaurar César
↓
EE_DIALOGUE03_COMPLETED = 1
EE_PORTAL_PHASE_FINISHED = 1
↓
EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_ARMY_SPAWNED = 0
EE_AMULET_CARRIER_DEFEATED = 0
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0
EE_AMULET_ARMY_DEFEATED = 0
EE_DIALOGUE04_COMPLETED = 0
↓
RunSequence("ZombieEE_Amulet_Main")
↓
mostrar:
ATACA EL CAMPAMENTO DEL SUR
Y RECUPERA GEM OF POWER
↓
Sleep(6000)
↓
return
```

---

# 111. Preparación exacta en el editor

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
│   └── ZombieEE_Conv03
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieEE_Portals_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue03
    │   └── AUTORUN = NO
    │
    └── ZombieEE_Amulet_Main
        └── AUTORUN = NO
```

---

# 112. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_Caesar` contiene exactamente a César.
3. `ZombieEE_Priest01` contiene exactamente al sacerdote egipcio.
4. `ZombieEE_Conv03` existe.
5. Sus actores se llaman exactamente `Capitan` y `Sacerdote`.
6. `ZombieEE_Portals_Main` termina escribiendo `EE_PORTALS_COMPLETED = 1`.
7. `ZombieEE_Portals_Main` termina escribiendo `EE_PRIEST_PENDING = 3`.
8. `ZombieEE_PriestInteraction_Main` sigue activo.
9. `ZombieEE_Amulet_Main` existe.
10. `ZombieEE_Amulet_Main` tiene Autorun desactivado.

---

# 113. Estado esperado antes de Dialogue03

Un estado normal es:

```text
EE_DIALOGUE02_COMPLETED = 1
EE_PORTALS_STARTED = 1
EE_PORTALS_COMPLETED = 1
EE_PORTALS_ENABLED = 0
EE_PORTALS_CLOSED = 4
EE_ZOMBIE_SPAWNS_DISABLED = 1
EE_DIALOGUE03_COMPLETED = 0
EE_PRIEST_PENDING = 0
```

`pending` ya está en cero porque PriestInteraction lo borra antes de ejecutar Dialogue03.

---

# 114. Estado esperado después de Dialogue03

```text
EE_DIALOGUE03_COMPLETED = 1
EE_PORTAL_PHASE_FINISHED = 1

EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_ARMY_SPAWNED = 0
EE_AMULET_CARRIER_DEFEATED = 0
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0
EE_AMULET_ARMY_DEFEATED = 0

EE_DIALOGUE04_COMPLETED = 0
```

---

# 115. Separación de responsabilidades

## `ZombieEE_Portals_Main`

Decide:

```text
ya se cerraron 4 portales
```

## `ZombieEE_PriestInteraction_Main`

Decide:

```text
César ya volvió físicamente al sacerdote
```

## `ZombieEE_Dialogue03`

Decide:

```text
reproducir la tercera conversación
y activar la fase de Gem of Power
```

## `ZombieEE_Amulet_Main`

Decide:

```text
cómo se genera el campamento
cómo se derrota al portador
cómo se recupera y entrega Gem of Power
```

---

# 116. Resumen funcional

`ZombieEE_Dialogue03` implementa la transición entre la fase de los portales y la búsqueda de Gem of Power:

```text
EE_PORTALS_COMPLETED = 1
↓
César vuelve al sacerdote
↓
ZombieEE_Conv03
↓
EE_DIALOGUE03_COMPLETED = 1
↓
EE_PORTAL_PHASE_FINISHED = 1
↓
reiniciar todos los estados del amuleto
↓
EE_AMULET_HUNT_ENABLED = 1
↓
RunSequence("ZombieEE_Amulet_Main")
↓
mostrar:
ATACA EL CAMPAMENTO DEL SUR
Y RECUPERA GEM OF POWER
↓
return
```

La Sequence no implementa la mecánica del amuleto: únicamente cierra narrativamente la fase de portales e inicializa de forma limpia el estado necesario para que `ZombieEE_Amulet_Main` tome el control.

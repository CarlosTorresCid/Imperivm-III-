# Secuencia 16 — `ZombieEE_Dialogue02`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Dialogue02` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Dialogue02` es la segunda conversación presencial del Easter Egg.

Se ejecuta después de derrotar a los cincuenta Guerreros de Anubis y volver físicamente con César hasta el sacerdote egipcio.

La Sequence:

1. valida el estado global;
2. evita repetir la conversación;
3. obtiene a César;
4. obtiene al sacerdote egipcio;
5. bloquea temporalmente ambos frente a la IA y la alimentación;
6. bloquea el input;
7. centra brevemente la cámara en el sacerdote;
8. reproduce `ZombieEE_Conv02`;
9. devuelve el control al jugador;
10. restaura a César;
11. marca Dialogue02 como completado;
12. reinicializa completamente el estado de los ocho portales;
13. mantiene las oleadas Zombies normales activas;
14. inicia `ZombieEE_Portals_Main`;
15. muestra el objetivo:

```text
CIERRA 4 PORTALES CUALESQUIERA CON SACERDOTES ROMANOS
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo narrativo es:

```text
50 Guerreros de Anubis derrotados
↓
ZombieEE_AnubisAttack_Main
↓
EE_PRIEST_PENDING = 2
↓
ZombieEE_PriestInteraction_Main
↓
César <=180 del sacerdote
↓
EE_PRIEST_PENDING = 0
↓
RunSequence("ZombieEE_Dialogue02")
↓
ZombieEE_Conv02
↓
activar fase de portales
↓
RunSequence("ZombieEE_Portals_Main")
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_Dialogue02
→ AUTORUN = NO
```

No debe ejecutarse al cargar el escenario.

La llamada normal llega desde:

```text
ZombieEE_PriestInteraction_Main
```

---

# 3. Condición narrativa previa

El estado normal antes de entrar es:

```text
EE_ANUBIS_ATTACK_COMPLETED = 1
```

y:

```text
EE_PRIEST_PENDING = 2
```

aunque `ZombieEE_Dialogue02` no lee directamente esos flags.

La responsabilidad de decidir que toca Dialogue02 pertenece a:

```text
ZombieEE_AnubisAttack_Main
+
ZombieEE_PriestInteraction_Main
```

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

Se utiliza para obtener:

```text
CapitalForum_P1
```

---

# 6. `state`

Representa el `Building` global donde se guardan los flags del Easter Egg.

---

# 7. `q`

Es una lista reutilizada para obtener:

```text
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 8. `u_capitan`

Representa a César.

---

# 9. `u_sacerdote`

Representa al sacerdote egipcio persistente.

---

# 10. `conv`

Es la Conversation:

```text
ZombieEE_Conv02
```

---

# 11. Group obligatorio de estado

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

# 12. Error de `CapitalForum_P1`

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE2 - CapitalForum_P1"
);

return;
```

---

# 13. Obtención del estado

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 14. Protección frente a repetición

Antes de obtener actores:

```cpp
if(
    EnvReadInt(
        state,
        "EE_DIALOGUE02_COMPLETED"
    )
    ==
    1
)
    return;
```

---

# 15. Significado de `EE_DIALOGUE02_COMPLETED`

```text
0
→ Dialogue02 todavía no ha terminado

1
→ Dialogue02 ya está completado
```

---

# 16. Qué ocurre si se intenta ejecutar dos veces

Si el flag ya vale 1:

```text
no Conversation
no reinicio de portales
no RunSequence
no mensajes
return
```

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
    "ERROR EE2 - ZombieEE_Caesar"
);

return;
```

---

# 19. Conversión de César

Cuando es válido:

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
    "ERROR EE2 - ZombieEE_Priest01"
);

return;
```

---

# 22. Conversión del sacerdote

Cuando es válido:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

---

# 23. Protección temporal de César

Antes de la conversación:

```cpp
u_capitan.SetNoAIFlag(
    true
);
```

---

# 24. Protección temporal del sacerdote

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

# 27. Motivo de estas cuatro llamadas

Durante la conversación se evita que:

```text
IA estratégica
sistema de alimentación
```

interfieran con los dos actores principales.

---

# 28. Bloqueo del input

Antes de mover la cámara:

```cpp
BlockUserInput();
```

El jugador pierde control durante la escena.

---

# 29. Cámara inicial

Se ejecuta:

```cpp
StartViewFollow(
    u_sacerdote
);
```

---

# 30. Duración del seguimiento

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

siguiendo al sacerdote.

---

# 31. Final del seguimiento

Después:

```cpp
StopViewFollow();
```

---

# 32. Pausa de transición

Se ejecuta:

```cpp
Sleep(
    250
);
```

---

# 33. Conversation utilizada

La Conversation se inicializa con:

```cpp
conv.Init(
    "ZombieEE_Conv02"
);
```

---

# 34. Actor `Capitan`

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

# 35. Actor `Sacerdote`

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

# 36. Número de actores

`ZombieEE_Conv02` utiliza:

```text
2 actores
```

desde esta Sequence.

---

# 37. Ejecución de la conversación

Se reproduce mediante:

```cpp
conv.Run();
```

---

# 38. Pausa posterior

Después:

```cpp
Sleep(
    500
);
```

---

# 39. Devolver control al jugador

Se ejecuta:

```cpp
UnblockUserInput();
```

---

# 40. Refresco de César tras la conversación

La versión canónica no reutiliza directamente el handle anterior para restaurarlo.

Vuelve a consultar:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

---

# 41. Restauración sólo si sigue existiendo

La condición es:

```cpp
if(q.count == 1)
```

---

# 42. Renovación de César

Si el Group sigue siendo válido:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 43. Restaurar alimentación

Después:

```cpp
u_capitan.SetFeeding(
    true
);
```

---

# 44. Restaurar IA

También:

```cpp
u_capitan.SetNoAIFlag(
    false
);
```

---

# 45. El sacerdote no se restaura aquí

No se ejecuta:

```text
SetFeeding(true)
SetNoAIFlag(false)
```

sobre el sacerdote.

---

# 46. Motivo

El sacerdote sigue gestionado por:

```text
ZombieEE_PriestKeeper
```

que debe mantener:

```text
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
```

---

# 47. Refresco del estado global tras la conversación

Después vuelve a consultar:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 48. Segunda validación de `CapitalForum_P1`

Si:

```text
stateList.count != 1
```

la Sequence termina:

```cpp
return;
```

---

# 49. Renovación de `state`

Cuando el Group es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 50. Marcar Dialogue02 como completado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE02_COMPLETED",
    1
);
```

---

# 51. Inicio de reinicialización de portales

Después se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_STARTED",
    0
);
```

---

# 52. Significado de `EE_PORTALS_STARTED`

```text
0
→ el gestor de portales todavía no ha terminado su inicialización

1
→ la fase ya fue arrancada internamente
```

Dialogue02 lo deja preparado en cero antes de ejecutar el gestor.

---

# 53. Habilitar portales

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_ENABLED",
    1
);
```

---

# 54. Significado

```text
EE_PORTALS_ENABLED = 1
```

habilita la siguiente fase del Easter Egg.

---

# 55. Reiniciar estado de completado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_COMPLETED",
    0
);
```

---

# 56. Reiniciar contador de portales cerrados

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_CLOSED",
    0
);
```

---

# 57. Significado de `EE_PORTALS_CLOSED`

Representa el número total de portales sellados durante la fase actual.

El objetivo final es:

```text
4
```

---

# 58. Reiniciar Dialogue03

También:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE03_COMPLETED",
    0
);
```

Dialogue03 es la conversación que se producirá después de completar la fase de portales.

---

# 59. Reiniciar final de fase

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTAL_PHASE_FINISHED",
    0
);
```

---

# 60. Reiniciar `EE_PRIEST_PENDING`

También:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    0
);
```

---

# 61. Motivo de dejar `pending = 0`

Durante la fase de portales no debe aparecer inmediatamente otra visita al sacerdote.

La siguiente activación llegará cuando `ZombieEE_Portals_Main` complete los cuatro portales.

---

# 62. Las rondas Zombies siguen activas

El comentario canónico indica expresamente:

```text
Las rondas siguen activas hasta cerrar el cuarto portal.
```

---

# 63. Mantener spawns Zombies habilitados

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_ZOMBIE_SPAWNS_DISABLED",
    0
);
```

---

# 64. Significado

```text
0
→ ZombieWaves_Main puede seguir creando nuevas rondas
```

---

# 65. Reiniciar confirmación de parada de Waves

También:

```cpp
EnvWriteInt(
    state,
    "ZWAVES_STOPPED_BY_PORTALS",
    0
);
```

---

# 66. Consecuencia

Durante la fase:

```text
portales 0/4
portales 1/4
portales 2/4
portales 3/4
```

las oleadas Zombies normales continúan.

---

# 67. Cuándo se detendrán

La detención sólo debe ocurrir cuando:

```text
se cierre el cuarto portal
```

y la Sequence de portales escriba:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 1
```

---

# 68. Estado individual de los ocho portales

Dialogue02 pone a cero:

```text
EE_PORTAL_CLOSED1
EE_PORTAL_CLOSED2
EE_PORTAL_CLOSED3
EE_PORTAL_CLOSED4
EE_PORTAL_CLOSED5
EE_PORTAL_CLOSED6
EE_PORTAL_CLOSED7
EE_PORTAL_CLOSED8
```

---

# 69. Motivo

Los ocho portales deben empezar la fase como:

```text
no cerrados
```

---

# 70. Cualquier cuatro portales sirven

La mecánica no exige cerrar:

```text
1,2,3,4
```

El objetivo es:

```text
4 de los 8
```

cualesquiera.

---

# 71. Estado individual de recompensa

También se reinician:

```text
EE_PORTAL_REWARD_GRANTED1
EE_PORTAL_REWARD_GRANTED2
EE_PORTAL_REWARD_GRANTED3
EE_PORTAL_REWARD_GRANTED4
EE_PORTAL_REWARD_GRANTED5
EE_PORTAL_REWARD_GRANTED6
EE_PORTAL_REWARD_GRANTED7
EE_PORTAL_REWARD_GRANTED8
```

---

# 72. Motivo de estos flags

El comentario canónico indica:

```text
Evita entregar dos veces
la recompensa de un mismo portal.
```

---

# 73. Estado inicial de recompensas

Los ocho quedan:

```text
0
```

---

# 74. Un portal sellado puede recompensar una vez

Cuando el gestor entregue la recompensa correspondiente, el flag individual deberá cambiar a:

```text
1
```

---

# 75. Lista completa de flags reiniciados

Dialogue02 escribe:

```text
EE_DIALOGUE02_COMPLETED = 1

EE_PORTALS_STARTED = 0
EE_PORTALS_ENABLED = 1
EE_PORTALS_COMPLETED = 0
EE_PORTALS_CLOSED = 0
EE_DIALOGUE03_COMPLETED = 0
EE_PORTAL_PHASE_FINISHED = 0
EE_PRIEST_PENDING = 0

EE_ZOMBIE_SPAWNS_DISABLED = 0
ZWAVES_STOPPED_BY_PORTALS = 0

EE_PORTAL_CLOSED1 = 0
EE_PORTAL_CLOSED2 = 0
EE_PORTAL_CLOSED3 = 0
EE_PORTAL_CLOSED4 = 0
EE_PORTAL_CLOSED5 = 0
EE_PORTAL_CLOSED6 = 0
EE_PORTAL_CLOSED7 = 0
EE_PORTAL_CLOSED8 = 0

EE_PORTAL_REWARD_GRANTED1 = 0
EE_PORTAL_REWARD_GRANTED2 = 0
EE_PORTAL_REWARD_GRANTED3 = 0
EE_PORTAL_REWARD_GRANTED4 = 0
EE_PORTAL_REWARD_GRANTED5 = 0
EE_PORTAL_REWARD_GRANTED6 = 0
EE_PORTAL_REWARD_GRANTED7 = 0
EE_PORTAL_REWARD_GRANTED8 = 0
```

---

# 76. Orden de inicialización

La fase queda completamente reiniciada antes de lanzar:

```cpp
RunSequence(
    "ZombieEE_Portals_Main"
);
```

---

# 77. Arrancar el gestor de portales

La llamada es:

```cpp
RunSequence(
    "ZombieEE_Portals_Main"
);
```

---

# 78. Autorun esperado de `ZombieEE_Portals_Main`

Debe estar configurada con:

```text
AUTORUN = NO
```

porque Dialogue02 es quien la inicia.

---

# 79. Aviso de nueva misión

Después del `RunSequence()` se muestra:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "CIERRA 4 PORTALES CUALESQUIERA CON SACERDOTES ROMANOS"
);
```

---

# 80. Mecánica que comunica el mensaje

El texto deja claro:

```text
objetivo = 4 portales
de 8 disponibles
```

y que el cierre se realiza usando:

```text
sacerdotes romanos
```

---

# 81. Duración del aviso

Después:

```cpp
Sleep(
    8000
);
```

El mensaje permanece aproximadamente:

```text
8 segundos
```

---

# 82. Ocultar el aviso

Finalmente:

```cpp
HideAnnouncement(
    "ZombieHelp"
);
```

---

# 83. La fase sigue activa

Ocultar el mensaje no modifica:

```text
EE_PORTALS_ENABLED
```

ni detiene:

```text
ZombieEE_Portals_Main
```

---

# 84. Final de Dialogue02

Después:

```cpp
return;
```

La Sequence termina.

---

# 85. Dialogue02 no controla físicamente los portales

No contiene:

```text
Groups Portal
sacerdotes cerca
spawns de Horus
spawns de Anubis
recompensas
contador de cierre
```

Eso pertenece a:

```text
ZombieEE_Portals_Main
```

---

# 86. Dialogue02 sólo inicializa

Su responsabilidad es:

```text
Conversation
+
reset de estado
+
RunSequence
+
mensaje
```

---

# 87. No espera a que se cierre ningún portal

No contiene:

```text
while EE_PORTALS_CLOSED < 4
```

---

# 88. No desactiva Waves

Dialogue02 deja explícitamente:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 0
```

---

# 89. No activa Dialogue03

No escribe:

```text
EE_PRIEST_PENDING = 3
```

---

# 90. Quién habilita Dialogue03

La fase de portales será la que, al completarse, prepare:

```text
EE_PRIEST_PENDING = 3
```

para la siguiente visita presencial.

---

# 91. No modifica el sacrificio

No toca:

```text
EE_SOULS_DELIVERED
EE_SACRIFICE_ENABLED
EE_SACRIFICE_COMPLETED
```

---

# 92. No modifica el ataque de Anubis

No toca:

```text
EE_ANUBIS_ATTACK_STARTED
EE_ANUBIS_ATTACK_COMPLETED
```

---

# 93. No modifica amuleto

No activa ninguna flag de:

```text
ZombieEE_Amulet_Main
```

---

# 94. No modifica asalto final

No activa:

```text
EE_FINAL_ASSAULT_ENABLED
EE_FINAL_ASSAULT_STARTED
```

---

# 95. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 96. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 97. `ZombieEE_Caesar`

Debe contener:

```text
exactamente 1 Unit
```

---

# 98. `ZombieEE_Priest01`

Debe contener:

```text
exactamente 1 Unit
```

cuando Dialogue02 se ejecuta.

---

# 99. Groups que no necesita directamente

No consulta:

```text
EE_AnubisWave01
HordeSpawn_01
HW_H1..8
HW_R1..16
Groups de portales
```

---

# 100. Areas necesarias

Ninguna.

---

# 101. Holders necesarios

Ninguno.

---

# 102. Conversation necesaria

Debe existir:

```text
ZombieEE_Conv02
```

con actores:

```text
Capitan
Sacerdote
```

---

# 103. Sequence anterior

El flujo normal llega desde:

```text
ZombieEE_AnubisAttack_Main
```

que deja:

```text
EE_PRIEST_PENDING = 2
```

---

# 104. Intermediario presencial

Después:

```text
ZombieEE_PriestInteraction_Main
```

espera que César llegue al sacerdote.

---

# 105. Sequence siguiente

Dialogue02 ejecuta:

```text
ZombieEE_Portals_Main
```

---

# 106. Flags que lee

| Flag | Función |
|---|---|
| `EE_DIALOGUE02_COMPLETED` | Evita repetir la conversación |

---

# 107. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_DIALOGUE02_COMPLETED` | 1 | Marca Dialogue02 completado |
| `EE_PORTALS_STARTED` | 0 | Deja el gestor listo para iniciar |
| `EE_PORTALS_ENABLED` | 1 | Habilita la fase |
| `EE_PORTALS_COMPLETED` | 0 | Reinicia completado global |
| `EE_PORTALS_CLOSED` | 0 | Reinicia contador |
| `EE_DIALOGUE03_COMPLETED` | 0 | Prepara siguiente diálogo |
| `EE_PORTAL_PHASE_FINISHED` | 0 | Reinicia cierre de fase |
| `EE_PRIEST_PENDING` | 0 | No hay visita pendiente todavía |
| `EE_ZOMBIE_SPAWNS_DISABLED` | 0 | Waves sigue activa |
| `ZWAVES_STOPPED_BY_PORTALS` | 0 | Waves aún no confirmó parada |

---

# 108. Flags individuales de portal

Se reinician:

```text
EE_PORTAL_CLOSED1..8
```

todos a:

```text
0
```

---

# 109. Flags individuales de recompensa

Se reinician:

```text
EE_PORTAL_REWARD_GRANTED1..8
```

todos a:

```text
0
```

---

# 110. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR EE2 - CapitalForum_P1` |
| `ZombieHelp` | `ERROR EE2 - ZombieEE_Caesar` |
| `ZombieHelp` | `ERROR EE2 - ZombieEE_Priest01` |
| `ZombieHelp` | `CIERRA 4 PORTALES CUALESQUIERA CON SACERDOTES ROMANOS` |

---

# 111. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Cámara sobre sacerdote | 1.000 ms |
| Pausa tras StopViewFollow | 250 ms |
| Pausa tras Conversation | 500 ms |
| Objetivo de portales visible | 8.000 ms |

---

# 112. Flujo exacto de cámara

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
ZombieEE_Conv02
```

---

# 113. Flujo exacto de César

```text
obtener César
↓
SetNoAIFlag(true)
↓
SetFeeding(false)
↓
Conversation
↓
UnblockUserInput
↓
refrescar Group
↓
si existe:
    SetFeeding(true)
    SetNoAIFlag(false)
```

---

# 114. Flujo exacto del sacerdote

```text
obtener sacerdote
↓
SetNoAIFlag(true)
↓
SetFeeding(false)
↓
Conversation
↓
no restaurarlo aquí
↓
ZombieEE_PriestKeeper
continúa protegiéndolo
```

---

# 115. Flujo exacto de transición

```text
conv.Run()
↓
Sleep(500)
↓
UnblockUserInput
↓
restaurar César
↓
refrescar CapitalForum_P1
↓
EE_DIALOGUE02_COMPLETED = 1
↓
reiniciar todos los flags de portales
↓
mantener Waves activa
↓
RunSequence("ZombieEE_Portals_Main")
↓
mostrar 8 s:
CIERRA 4 PORTALES CUALESQUIERA
CON SACERDOTES ROMANOS
↓
HideAnnouncement
↓
return
```

---

# 116. Preparación exacta en el editor

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
│   └── ZombieEE_Conv02
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue02
    │   └── AUTORUN = NO
    │
    └── ZombieEE_Portals_Main
        └── AUTORUN = NO
```

---

# 117. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_Caesar` contiene exactamente a César.
3. `ZombieEE_Priest01` contiene exactamente al sacerdote egipcio.
4. `ZombieEE_Conv02` existe.
5. Sus actores se llaman exactamente `Capitan` y `Sacerdote`.
6. `ZombieEE_Portals_Main` existe con el nombre exacto.
7. `ZombieEE_Portals_Main` no tiene Autorun.
8. `ZombieEE_PriestInteraction_Main` sigue vivo después de Dialogue01.
9. `ZombieEE_AnubisAttack_Main` acaba escribiendo `EE_PRIEST_PENDING = 2`.
10. `ZombieWaves_Main` sigue atendiendo `EE_ZOMBIE_SPAWNS_DISABLED`.

---

# 118. Estado antes de Dialogue02

Un estado normal es:

```text
EE_DIALOGUE01_COMPLETED = 1
EE_SACRIFICE_COMPLETED = 1
EE_ANUBIS_ATTACK_STARTED = 1
EE_ANUBIS_ATTACK_COMPLETED = 1
EE_PRIEST_PENDING = 0
```

El `pending` ya está en cero porque PriestInteraction lo borra antes de ejecutar Dialogue02.

---

# 119. Estado inmediatamente después de Dialogue02

La fase queda preparada como:

```text
EE_DIALOGUE02_COMPLETED = 1

EE_PORTALS_STARTED = 0
EE_PORTALS_ENABLED = 1
EE_PORTALS_COMPLETED = 0
EE_PORTALS_CLOSED = 0

EE_PORTAL_CLOSED1..8 = 0
EE_PORTAL_REWARD_GRANTED1..8 = 0

EE_DIALOGUE03_COMPLETED = 0
EE_PORTAL_PHASE_FINISHED = 0
EE_PRIEST_PENDING = 0

EE_ZOMBIE_SPAWNS_DISABLED = 0
ZWAVES_STOPPED_BY_PORTALS = 0
```

---

# 120. Resumen funcional

`ZombieEE_Dialogue02` implementa la transición entre el desafío de los 50 Guerreros de Anubis y la fase de los ocho portales:

```text
volver con César al sacerdote
↓
ZombieEE_Conv02
↓
marcar Dialogue02 completado
↓
activar sistema de portales
↓
reiniciar:
8 estados de cerrado
8 estados de recompensa
contador global
flags de fase
↓
mantener Waves activa
↓
RunSequence("ZombieEE_Portals_Main")
↓
mostrar:
CIERRA 4 PORTALES CUALESQUIERA
CON SACERDOTES ROMANOS
↓
terminar
```

La Sequence no gestiona el cierre de los portales por sí misma: su función es inicializar de forma limpia todo el estado y transferir el control a `ZombieEE_Portals_Main`.

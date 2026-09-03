# Secuencia 20 — `ZombieEE_Dialogue04`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Dialogue04` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Dialogue04` es la cuarta conversación presencial del Easter Egg.

Se ejecuta después de completar la fase de Gem of Power y volver físicamente con César hasta el sacerdote egipcio.

La Sequence:

1. valida el estado global;
2. impide repetir la conversación;
3. exige que `EE_AMULET_DELIVERED = 1`;
4. obtiene a César;
5. obtiene al sacerdote egipcio;
6. guarda la posición y el propietario actual del sacerdote;
7. reproduce `ZombieEE_Conv04`;
8. devuelve el control al jugador;
9. restaura a César;
10. marca al sacerdote como oculto;
11. lo elimina de `ZombieEE_Priest01`;
12. lo borra físicamente del mapa;
13. marca Dialogue04 y la fase de Gem of Power como completados;
14. reinicia desde cero el estado del asalto final;
15. muestra que el sacerdote parte hacia Egipto;
16. lanza la nueva Sequence:

```text
ZombieEE_FinalAssault_Run
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo narrativo es:

```text
Gem of Power entregada
↓
EE_AMULET_DELIVERED = 1
↓
EE_PRIEST_PENDING = 4
↓
ZombieEE_PriestInteraction_Main
↓
César <=180 del sacerdote
↓
EE_PRIEST_PENDING = 0
↓
RunSequence("ZombieEE_Dialogue04")
↓
ZombieEE_Conv04
↓
el sacerdote desaparece
↓
EE_FINAL_ASSAULT_ENABLED = 1
↓
RunSequence("ZombieEE_FinalAssault_Run")
```

---

# 2. Comentario canónico del Source

La cabecera de la Sequence establece:

```text
El sacerdote promete resolver el problema en Egipto y desaparece.
Despues lanza:

ZombieEE_FinalAssault_Run
```

También aclara:

```text
Usamos una Sequence NUEVA para el asalto final
para evitar cualquier problema de registro
asociado al antiguo ZombieEE_FinalAssault_Main.
```

---

# 3. Autorun

La configuración correcta es:

```text
ZombieEE_Dialogue04
→ AUTORUN = NO
```

No debe ejecutarse al cargar el escenario.

Su lanzamiento normal procede de:

```text
ZombieEE_PriestInteraction_Main
```

---

# 4. Condición narrativa previa

El estado necesario es:

```text
EE_AMULET_DELIVERED = 1
```

Esto significa que la fase anterior ha llegado al punto requerido para habilitar Dialogue04.

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

int priestX;
int priestY;
int priestOwner;
```

---

# 6. `stateList`

Se utiliza para obtener:

```text
CapitalForum_P1
```

---

# 7. `state`

Es el Building global utilizado como almacenamiento persistente del Easter Egg.

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

```text
ZombieEE_Conv04
```

---

# 12. `priestX`

Guarda:

```text
u_sacerdote.pos.x
```

antes de borrar al sacerdote.

---

# 13. `priestY`

Guarda:

```text
u_sacerdote.pos.y
```

antes de borrarlo.

---

# 14. `priestOwner`

Guarda:

```text
u_sacerdote.player
```

antes de borrarlo.

---

# 15. Por qué se guarda la posición del sacerdote

El comentario canónico indica:

```text
Se utilizara al terminar el asalto final para recrearlo.
```

Dialogue04 destruye físicamente al sacerdote, por lo que su posición debe persistirse antes del `Erase()`.

---

# 16. Group obligatorio de estado

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

# 17. Error de `CapitalForum_P1`

Si el Group no contiene exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE5 - CapitalForum_P1"
);
```

También se registra:

```cpp
pr(
    "EE DIALOGUE04 ERROR - CapitalForum_P1 count="
    + stateList.count
);
```

Después:

```cpp
return;
```

---

# 18. Obtención del estado global

Cuando es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 19. Protección frente a repetición

La primera validación narrativa es:

```cpp
if(
    EnvReadInt(
        state,
        "EE_DIALOGUE04_COMPLETED"
    )
    ==
    1
)
{
    return;
}
```

---

# 20. Significado de `EE_DIALOGUE04_COMPLETED`

```text
0
→ Dialogue04 todavía puede ejecutarse

1
→ Dialogue04 ya terminó
```

---

# 21. Qué ocurre si se intenta repetir

Si ya está completado:

```text
no Conversation
no Erase del sacerdote
no reinicio del asalto final
no RunSequence
return
```

---

# 22. Validación de la fase del amuleto

Después se exige:

```cpp
if(
    EnvReadInt(
        state,
        "EE_AMULET_DELIVERED"
    )
    !=
    1
)
```

---

# 23. Error si Gem of Power todavía no está entregada

Se muestra:

```text
EE DIALOGUE04 ERROR - FASE DEL CAUDILLO NO COMPLETADA
```

mediante:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    ...
);
```

Después:

```cpp
return;
```

---

# 24. Condición real de entrada

Dialogue04 sólo continúa si:

```text
EE_DIALOGUE04_COMPLETED != 1
EE_AMULET_DELIVERED == 1
```

---

# 25. Group obligatorio de César

La Sequence consulta:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

---

# 26. Validación de César

Debe cumplirse:

```text
ZombieEE_Caesar.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE5 - ZombieEE_Caesar"
);

return;
```

---

# 27. Conversión de César

Cuando es válido:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 28. Group obligatorio del sacerdote

Después:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 29. Validación del sacerdote

Debe cumplirse:

```text
ZombieEE_Priest01.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR EE5 - ZombieEE_Priest01"
);

return;
```

---

# 30. Conversión del sacerdote

Cuando es válido:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

---

# 31. Guardar posición X

Se ejecuta:

```cpp
priestX =
    u_sacerdote.pos.x;
```

---

# 32. Guardar posición Y

Se ejecuta:

```cpp
priestY =
    u_sacerdote.pos.y;
```

---

# 33. Guardar propietario

Se ejecuta:

```cpp
priestOwner =
    u_sacerdote.player;
```

---

# 34. Persistir X

Después:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_HOME_X",
    priestX
);
```

---

# 35. Persistir Y

También:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_HOME_Y",
    priestY
);
```

---

# 36. Persistir propietario

También:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_OWNER",
    priestOwner
);
```

---

# 37. Estado guardado para la reaparición

Los tres valores persistentes son:

```text
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
```

---

# 38. Registro de depuración

La Sequence escribe:

```text
EE DIALOGUE04 - priest home=X,Y owner=P
```

mediante:

```cpp
pr(...)
```

---

# 39. Preparar a César

Antes de la Conversation:

```cpp
u_capitan.SetNoAIFlag(
    true
);
```

---

# 40. Preparar al sacerdote

También:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 41. Alimentación de César

Se ejecuta:

```cpp
u_capitan.SetFeeding(
    false
);
```

---

# 42. Alimentación del sacerdote

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 43. Motivo

Durante la escena se evita que:

```text
IA estratégica
alimentación
```

interfieran con los dos actores.

---

# 44. Bloqueo del input

Antes de mover la cámara:

```cpp
BlockUserInput();
```

---

# 45. Seguimiento de cámara

Se ejecuta:

```cpp
StartViewFollow(
    u_sacerdote
);
```

---

# 46. Duración inicial

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

# 47. Detener seguimiento

Después:

```cpp
StopViewFollow();
```

---

# 48. Pausa de transición

Se ejecuta:

```cpp
Sleep(
    250
);
```

---

# 49. Conversation utilizada

Se inicializa:

```cpp
conv.Init(
    "ZombieEE_Conv04"
);
```

---

# 50. Actor `Capitan`

La Conversation debe contener:

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

# 51. Actor `Sacerdote`

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

# 52. Ejecución de la Conversation

Se reproduce con:

```cpp
conv.Run();
```

---

# 53. Pausa posterior

Después:

```cpp
Sleep(
    500
);
```

---

# 54. Devolver control al jugador

Se ejecuta:

```cpp
UnblockUserInput();
```

---

# 55. Restaurar alimentación de César

Después:

```cpp
u_capitan.SetFeeding(
    true
);
```

---

# 56. Restaurar IA de César

También:

```cpp
u_capitan.SetNoAIFlag(
    false
);
```

---

# 57. El sacerdote no se restaura

No se ejecuta:

```text
SetFeeding(true)
SetNoAIFlag(false)
```

sobre el sacerdote.

La razón es que inmediatamente después va a desaparecer.

---

# 58. Orden correcto para ocultar al sacerdote

El Source especifica:

```text
Primero ponemos EE_PRIEST_HIDDEN=1
para impedir que ZombieEE_PriestKeeper
intente recuperarlo mientras no existe.
```

---

# 59. Marcar sacerdote como oculto

La primera operación es:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_HIDDEN",
    1
);
```

---

# 60. Interacción con `ZombieEE_PriestKeeper`

Mientras:

```text
EE_PRIEST_HIDDEN = 1
```

PriestKeeper deja de exigir que exista una unidad válida dentro de:

```text
ZombieEE_Priest01
```

---

# 61. Eliminar al sacerdote del Group

Después:

```cpp
u_sacerdote.RemoveFromGroup(
    "ZombieEE_Priest01"
);
```

---

# 62. Por qué se elimina del Group antes del `Erase()`

La unidad deja de ser visible para las Sequences que consultan:

```text
ZombieEE_Priest01
```

antes de ser destruida físicamente.

---

# 63. Borrar físicamente al sacerdote

Después:

```cpp
u_sacerdote.Erase();
```

---

# 64. Resultado

El sacerdote desaparece completamente del mapa.

---

# 65. Registro de depuración de desaparición

Se escribe:

```text
EE DIALOGUE04 - PRIEST ERASED
```

---

# 66. Estado de `ZombieEE_Priest01`

Después del `RemoveFromGroup()` y `Erase()`:

```text
ZombieEE_Priest01
```

queda sin el sacerdote original.

---

# 67. Por qué PriestInteraction no falla

`ZombieEE_PriestInteraction_Main` sólo necesita al sacerdote cuando existe:

```text
EE_PRIEST_PENDING > 0
```

Durante el asalto final puede permanecer activo sin un sacerdote visible.

---

# 68. Marcar Dialogue04 como completado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE04_COMPLETED",
    1
);
```

---

# 69. Marcar Gem phase como completada

También:

```cpp
EnvWriteInt(
    state,
    "EE_GEM_PHASE_COMPLETED",
    1
);
```

---

# 70. Diferencia entre `EE_AMULET_DELIVERED` y `EE_GEM_PHASE_COMPLETED`

```text
EE_AMULET_DELIVERED = 1
→ condición necesaria para permitir Dialogue04

EE_GEM_PHASE_COMPLETED = 1
→ la conversación posterior a la entrega ya terminó
y la narrativa entra oficialmente en el asalto final
```

---

# 71. Preparar el asalto final desde cero

El comentario canónico establece:

```text
Aunque una prueba anterior hubiera dejado valores guardados,
esta conversacion prepara expresamente
una ejecucion limpia.
```

---

# 72. Habilitar el asalto final

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_ENABLED",
    1
);
```

---

# 73. Reiniciar `STARTED`

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_STARTED",
    0
);
```

---

# 74. Reiniciar `COMPLETED`

También:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_COMPLETED",
    0
);
```

---

# 75. Reiniciar lote desplegado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_BATCH_DEPLOYED",
    0
);
```

---

# 76. Estado completo del asalto tras Dialogue04

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
```

---

# 77. Motivo del reinicio explícito

Aunque alguna prueba previa o estado persistente hubiera dejado:

```text
STARTED = 1
COMPLETED = 1
```

Dialogue04 fuerza una preparación limpia.

---

# 78. Aviso narrativo

Se muestra:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "EL SACERDOTE PARTE HACIA EGIPTO"
);
```

---

# 79. Registro de debug

También:

```text
EE DIALOGUE04 - FINAL ASSAULT ENABLED
```

mediante:

```cpp
pr(...)
```

---

# 80. Duración del aviso

Después:

```cpp
Sleep(
    3000
);
```

El mensaje permanece aproximadamente:

```text
3 segundos
```

---

# 81. Ocultar el anuncio narrativo

Después:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

---

# 82. Mensaje debug visible antes de lanzar el asalto

La versión canónica actual contiene:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "EE FINAL DEBUG - LANZANDO ZombieEE_FinalAssault_Run"
);
```

---

# 83. Importante sobre ese mensaje

Este mensaje:

```text
sí está presente en el Source v2.0
```

y por tanto forma parte de la implementación actual documentada.

No debe confundirse con los `pr(...)`, que son registros de depuración separados.

---

# 84. Registro `pr` antes del lanzamiento

También se escribe:

```text
EE DIALOGUE04 - RUN ZombieEE_FinalAssault_Run
```

---

# 85. Pausa antes de lanzar el asalto

Se ejecuta:

```cpp
Sleep(
    1000
);
```

---

# 86. Lanzar la nueva Sequence

Finalmente:

```cpp
RunSequence(
    "ZombieEE_FinalAssault_Run"
);
```

---

# 87. Sequence elegida

La implementación canónica lanza:

```text
ZombieEE_FinalAssault_Run
```

---

# 88. No lanza `ZombieEE_FinalAssault_Main`

Aunque existe una Sequence histórica con ese nombre, Dialogue04 no ejecuta:

```text
ZombieEE_FinalAssault_Main
```

---

# 89. Motivo documentado

La cabecera indica que se usa una nueva Sequence para evitar:

```text
problemas de registro asociados al antiguo
ZombieEE_FinalAssault_Main
```

---

# 90. Final de Dialogue04

Después del `RunSequence()`:

```cpp
return;
```

Dialogue04 termina.

---

# 91. No espera al asalto final

No contiene:

```text
while EE_FINAL_ASSAULT_COMPLETED == 0
```

---

# 92. Separación de responsabilidades

Dialogue04 sólo:

```text
reproduce conversación
oculta sacerdote
prepara flags
lanza FinalAssault_Run
```

---

# 93. `ZombieEE_FinalAssault_Run` toma el control

A partir de:

```cpp
RunSequence(
    "ZombieEE_FinalAssault_Run"
);
```

la lógica militar del asalto final pertenece a esa nueva Sequence.

---

# 94. No crea tropas del asalto final

Dialogue04 no contiene ningún:

```text
Place()
```

de enemigos del asalto final.

---

# 95. No controla tandas

No contiene lógica de:

```text
batch
oleadas internas
niveles
tipos de tropas
```

---

# 96. No espera muertes

No controla ningún Group de enemigos finales.

---

# 97. No recrea al sacerdote

La reaparición del sacerdote ocurre posteriormente.

Dialogue04 sólo guarda:

```text
X
Y
propietario
```

y lo borra.

---

# 98. Datos necesarios para reaparición

La Sequence deja persistidos:

```text
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
```

---

# 99. La posición usada es la actual

No usa una posición fija codificada.

Guarda:

```text
la posición real del sacerdote
en el momento de Dialogue04
```

---

# 100. Consecuencia

Si el sacerdote se hubiera desplazado legítimamente antes de Dialogue04, la posición guardada sería esa nueva posición.

---

# 101. Interacción con PriestKeeper antes de guardar

En condiciones normales PriestKeeper intenta mantenerlo cerca de su posición original, por lo que los valores guardados deberían corresponder al emplazamiento canónico.

---

# 102. El propietario también se guarda dinámicamente

No se presupone:

```text
Player 1
```

o un Player fijo.

Se usa:

```cpp
u_sacerdote.player
```

---

# 103. Ventaja

La reaparición posterior puede conservar el mismo propietario real que tenía el sacerdote antes de desaparecer.

---

# 104. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 105. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 106. `ZombieEE_Caesar`

Debe contener:

```text
exactamente 1 Unit
```

---

# 107. `ZombieEE_Priest01`

Debe contener:

```text
exactamente 1 Unit
```

al comenzar Dialogue04.

---

# 108. Estado posterior de `ZombieEE_Priest01`

Después del diálogo:

```text
el sacerdote es eliminado del Group
y borrado del mapa
```

---

# 109. Groups que no necesita directamente

No consulta:

```text
HordeSpawn_01
EE_FinalAssault
HW_H1..8
EE_PortalGuardiansActive
```

---

# 110. Areas necesarias

Ninguna.

---

# 111. Holders necesarios

Ninguno.

---

# 112. Conversation necesaria

Debe existir:

```text
ZombieEE_Conv04
```

con:

```text
Capitan
Sacerdote
```

---

# 113. Sequence anterior

El flujo normal llega desde:

```text
ZombieEE_Amulet_Main
```

que termina habilitando la visita:

```text
EE_PRIEST_PENDING = 4
```

---

# 114. Intermediario presencial

`ZombieEE_PriestInteraction_Main` espera que César vuelva al sacerdote y después ejecuta Dialogue04.

---

# 115. Sequence siguiente

Dialogue04 lanza directamente:

```text
ZombieEE_FinalAssault_Run
```

---

# 116. Flags que lee

| Flag | Función |
|---|---|
| `EE_DIALOGUE04_COMPLETED` | Evita repetir Dialogue04 |
| `EE_AMULET_DELIVERED` | Exige que Gem of Power ya haya sido entregada |

---

# 117. Flags de posición del sacerdote

| Flag | Valor |
|---|---|
| `EE_PRIEST_HOME_X` | X actual del sacerdote |
| `EE_PRIEST_HOME_Y` | Y actual del sacerdote |
| `EE_PRIEST_OWNER` | Player actual del sacerdote |

---

# 118. Flags narrativos que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_PRIEST_HIDDEN` | 1 | Indica que el sacerdote debe permanecer ausente |
| `EE_DIALOGUE04_COMPLETED` | 1 | Marca Dialogue04 completado |
| `EE_GEM_PHASE_COMPLETED` | 1 | Cierra narrativamente la fase de Gem of Power |

---

# 119. Flags del asalto final

| Flag | Valor | Función |
|---|---:|---|
| `EE_FINAL_ASSAULT_ENABLED` | 1 | Habilita el asalto final |
| `EE_FINAL_ASSAULT_STARTED` | 0 | Fuerza inicio limpio |
| `EE_FINAL_ASSAULT_COMPLETED` | 0 | Reinicia completado |
| `EE_FINAL_BATCH_DEPLOYED` | 0 | Reinicia seguimiento de despliegue |

---

# 120. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR EE5 - CapitalForum_P1` |
| `ZombieHelp` | `EE DIALOGUE04 ERROR - FASE DEL CAUDILLO NO COMPLETADA` |
| `ZombieHelp` | `ERROR EE5 - ZombieEE_Caesar` |
| `ZombieHelp` | `ERROR EE5 - ZombieEE_Priest01` |
| `ZombieEEObjective` | `EL SACERDOTE PARTE HACIA EGIPTO` |
| `ZombieHelp` | `EE FINAL DEBUG - LANZANDO ZombieEE_FinalAssault_Run` |

---

# 121. Registros `pr(...)`

La versión canónica contiene:

```text
EE DIALOGUE04 ERROR - CapitalForum_P1 count=X
EE DIALOGUE04 - priest home=X,Y owner=P
EE DIALOGUE04 - PRIEST ERASED
EE DIALOGUE04 - FINAL ASSAULT ENABLED
EE DIALOGUE04 - RUN ZombieEE_FinalAssault_Run
```

---

# 122. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Cámara sobre sacerdote | 1.000 ms |
| Pausa tras StopViewFollow | 250 ms |
| Pausa tras Conversation | 500 ms |
| Aviso `EL SACERDOTE PARTE HACIA EGIPTO` | 3.000 ms |
| Pausa previa a `FinalAssault_Run` | 1.000 ms |

---

# 123. Flujo exacto de cámara

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
ZombieEE_Conv04
```

---

# 124. Flujo exacto de César

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

# 125. Flujo exacto del sacerdote

```text
obtener sacerdote
↓
guardar:
X
Y
Player
↓
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
EE_PRIEST_HIDDEN = 1
↓
RemoveFromGroup("ZombieEE_Priest01")
↓
Erase()
↓
sacerdote desaparecido
```

---

# 126. Flujo exacto de transición al asalto final

```text
EE_DIALOGUE04_COMPLETED = 1
↓
EE_GEM_PHASE_COMPLETED = 1
↓
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
↓
mostrar:
EL SACERDOTE PARTE HACIA EGIPTO
↓
Sleep(3000)
↓
HideAnnouncement
↓
mostrar debug:
EE FINAL DEBUG - LANZANDO ZombieEE_FinalAssault_Run
↓
Sleep(1000)
↓
RunSequence("ZombieEE_FinalAssault_Run")
↓
return
```

---

# 127. Orden crítico de ocultación

El orden canónico es:

```text
1. guardar X/Y/owner
2. conversación
3. EE_PRIEST_HIDDEN = 1
4. RemoveFromGroup
5. Erase
```

No debe invertirse la relación:

```text
Erase
antes de EE_PRIEST_HIDDEN
```

porque PriestKeeper podría interpretar incorrectamente la desaparición.

---

# 128. Interacción con `ZombieEE_PriestInteraction_Main`

Mientras el sacerdote está oculto:

```text
ZombieEE_Priest01.count = 0
```

PriestInteraction puede permanecer en ejecución sin intentar lanzar diálogos mientras no exista un nuevo `pending` válido con sacerdote disponible.

---

# 129. Interacción con `ZombieEE_PriestKeeper`

PriestKeeper lee:

```text
EE_PRIEST_HIDDEN
```

y mientras vale 1:

```text
no intenta proteger ni reposicionar un sacerdote inexistente
```

---

# 130. Reaparición futura

Cuando el asalto final termine, otra Sequence podrá:

```text
leer EE_PRIEST_HOME_X
leer EE_PRIEST_HOME_Y
leer EE_PRIEST_OWNER
↓
crear sacerdote
↓
AddToGroup("ZombieEE_Priest01")
↓
EE_PRIEST_HIDDEN = 0
```

---

# 131. No se restablece `EE_PRIEST_HIDDEN` aquí

Dialogue04 deja el valor en:

```text
1
```

---

# 132. No escribe `EE_PRIEST_PENDING = 5`

El diálogo final no se activa desde Dialogue04.

La activación posterior pertenece al flujo del asalto final.

---

# 133. No escribe `EE_COMPLETED`

El Easter Egg todavía no ha terminado.

---

# 134. No entrega recompensa final

Dialogue04 no crea:

```text
ejército recompensa
héroes finales
```

---

# 135. No detiene Tactical

No modifica:

```text
ZombieTactical_Main
```

---

# 136. No modifica Waves

Las nuevas Waves normales ya deberían estar detenidas desde la fase de portales.

Dialogue04 no toca:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

---

# 137. No reactiva Waves

No existe ninguna escritura:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 0
```

---

# 138. Preparación exacta en el editor

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
│   └── ZombieEE_Conv04
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue04
    │   └── AUTORUN = NO
    │
    └── ZombieEE_FinalAssault_Run
        └── AUTORUN = NO
```

---

# 139. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_Caesar` contiene exactamente a César.
3. `ZombieEE_Priest01` contiene exactamente al sacerdote antes de Dialogue04.
4. `ZombieEE_Conv04` existe.
5. Sus actores se llaman exactamente `Capitan` y `Sacerdote`.
6. `EE_AMULET_DELIVERED` llega a 1 al completar la fase anterior.
7. `ZombieEE_PriestInteraction_Main` convierte `pending = 4` en Dialogue04.
8. `ZombieEE_PriestKeeper` respeta `EE_PRIEST_HIDDEN`.
9. `ZombieEE_FinalAssault_Run` existe con ese nombre exacto.
10. `ZombieEE_FinalAssault_Run` tiene Autorun desactivado.

---

# 140. Estado esperado antes de Dialogue04

Un estado normal es:

```text
EE_DIALOGUE03_COMPLETED = 1
EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_DELIVERED = 1
EE_DIALOGUE04_COMPLETED = 0
EE_PRIEST_HIDDEN = 0
EE_PRIEST_PENDING = 0
```

`pending` ya está en cero porque PriestInteraction lo borra antes de ejecutar Dialogue04.

---

# 141. Estado esperado después de Dialogue04

```text
EE_DIALOGUE04_COMPLETED = 1
EE_GEM_PHASE_COMPLETED = 1

EE_PRIEST_HIDDEN = 1

EE_PRIEST_HOME_X = posición X guardada
EE_PRIEST_HOME_Y = posición Y guardada
EE_PRIEST_OWNER = propietario guardado

EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
```

Además:

```text
ZombieEE_Priest01
```

queda sin el sacerdote original.

---

# 142. Separación de responsabilidades

## `ZombieEE_Amulet_Main`

Decide:

```text
Gem of Power ya fue entregada
```

## `ZombieEE_PriestInteraction_Main`

Decide:

```text
César ya volvió al sacerdote
```

## `ZombieEE_Dialogue04`

Decide:

```text
reproducir la cuarta conversación
ocultar al sacerdote
preparar el asalto final
```

## `ZombieEE_FinalAssault_Run`

Decide:

```text
cómo se desarrolla el asalto final
cuándo termina
cuándo reaparece el sacerdote
y cuándo se habilita el diálogo final
```

---

# 143. Resumen funcional

`ZombieEE_Dialogue04` v2.0 implementa la transición entre Gem of Power y el asalto final:

```text
EE_AMULET_DELIVERED = 1
↓
César vuelve al sacerdote
↓
ZombieEE_Conv04
↓
guardar:
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
↓
EE_PRIEST_HIDDEN = 1
↓
RemoveFromGroup("ZombieEE_Priest01")
↓
Erase(sacerdote)
↓
EE_DIALOGUE04_COMPLETED = 1
↓
EE_GEM_PHASE_COMPLETED = 1
↓
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
↓
EL SACERDOTE PARTE HACIA EGIPTO
↓
RunSequence("ZombieEE_FinalAssault_Run")
↓
return
```

La característica crítica de esta Sequence es que el sacerdote desaparece físicamente del mapa, pero antes se guardan su posición y propietario para que el sistema del asalto final pueda reconstruirlo posteriormente. Además, la implementación actual lanza expresamente `ZombieEE_FinalAssault_Run`, no el antiguo `ZombieEE_FinalAssault_Main`.

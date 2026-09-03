# Secuencia 23 — `ZombieEE_DialogueFinal`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_DialogueFinal` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_DialogueFinal` es la última Sequence narrativa del Easter Egg.

Se ejecuta cuando:

```text
el asalto final ha terminado
↓
EE_FINAL_ASSAULT_COMPLETED = 1
↓
el sacerdote egipcio ha reaparecido
↓
EE_PRIEST_PENDING = 5
↓
ZombieEE_PriestInteraction_Main
↓
César vuelve físicamente al sacerdote
↓
RunSequence("ZombieEE_DialogueFinal")
```

La Sequence:

1. valida el estado global;
2. impide repetir el final;
3. exige que el asalto final esté completado;
4. obtiene a César;
5. obtiene al sacerdote recreado;
6. reproduce `ZombieEE_ConvFinal`;
7. deja al sacerdote como prisionero;
8. entrega cuatro campeones finales a Roma;
9. equipa a los cuatro campeones con cuatro objetos cada uno;
10. marca la recompensa como entregada;
11. marca el diálogo final como completado;
12. marca todo el Easter Egg como completado;
13. muestra durante 10 segundos el mensaje final.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo final completo es:

```text
ZombieEE_FinalAssault_Run
↓
EE_FinalAssault.count == 0
↓
recrear sacerdote
↓
EE_PRIEST_HIDDEN = 0
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_ASSAULT_ENABLED = 0
EE_PRIEST_PENDING = 5
↓
ZombieEE_PriestInteraction_Main
↓
César <=180 del sacerdote
↓
EE_PRIEST_PENDING = 0
↓
RunSequence("ZombieEE_DialogueFinal")
↓
ZombieEE_ConvFinal
↓
sacerdote prisionero
↓
4 campeones nivel 60
↓
EE_DIALOGUE_FINAL_COMPLETED = 1
EE_COMPLETED = 1
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_DialogueFinal
→ AUTORUN = NO
```

No debe ejecutarse al cargar el escenario.

Su lanzamiento normal procede de:

```text
ZombieEE_PriestInteraction_Main
```

cuando:

```text
EE_PRIEST_PENDING = 5
```

y César entra en el radio de interacción con el sacerdote.

---

# 3. Comentario narrativo canónico

La cabecera de la Sequence establece:

```text
Revela la conspiracion de Egipto y Cartago,
ordena encarcelar al sacerdote
y concede al jugador romano los cuatro campeones finales.
```

Por tanto esta Sequence cierra tanto:

```text
la historia del Easter Egg
```

como:

```text
la progresión mecánica de sus recompensas
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
Unit u;

Conversation conv;

int rewardX;
int rewardY;
```

---

# 5. `stateList`

Se utiliza para obtener:

```text
CapitalForum_P1
```

---

# 6. `state`

Es el `Building` global donde se leen y escriben los flags finales del Easter Egg.

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

Representa al sacerdote egipcio ya recreado después del asalto final.

---

# 10. `u`

Se reutiliza para crear cada uno de los cuatro campeones finales.

---

# 11. `conv`

Es la instancia de:

```text
ZombieEE_ConvFinal
```

---

# 12. `rewardX` y `rewardY`

Guardan la posición del sacerdote después de la conversación y sirven como centro de la formación de los cuatro campeones.

---

# 13. Group obligatorio de estado

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

# 14. Error de `CapitalForum_P1`

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR FINAL - CapitalForum_P1"
);

return;
```

---

# 15. Obtención del estado global

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 16. Protección frente a repetición

La primera validación narrativa es:

```cpp
if(
    EnvReadInt(
        state,
        "EE_DIALOGUE_FINAL_COMPLETED"
    )
    ==
    1
)
    return;
```

---

# 17. Significado de `EE_DIALOGUE_FINAL_COMPLETED`

```text
0
→ el diálogo final todavía puede ejecutarse

1
→ el diálogo final ya terminó
```

---

# 18. Consecuencia de una segunda ejecución

Si el flag ya vale 1:

```text
no Conversation
no nuevos campeones
no nuevo encarcelamiento
no nuevo mensaje final
return
```

---

# 19. Validación del asalto final

Después:

```cpp
if(
    EnvReadInt(
        state,
        "EE_FINAL_ASSAULT_COMPLETED"
    )
    !=
    1
)
    return;
```

---

# 20. Condición real de entrada

Para continuar deben cumplirse:

```text
EE_DIALOGUE_FINAL_COMPLETED != 1
EE_FINAL_ASSAULT_COMPLETED == 1
```

---

# 21. Qué ocurre si se lanza demasiado pronto

Si el asalto final todavía no ha terminado:

```text
no mensaje de error
no conversación
no recompensa
return
```

---

# 22. Group obligatorio de César

La Sequence consulta:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

---

# 23. Validación de César

Debe cumplirse:

```text
ZombieEE_Caesar.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR FINAL - ZombieEE_Caesar"
);

return;
```

---

# 24. Conversión de César

Cuando es válido:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 25. Group obligatorio del sacerdote recreado

Después:

```cpp
q =
    Group("ZombieEE_Priest01")
    .GetObjList();

q.ClearDead();
```

---

# 26. Validación del sacerdote

Debe cumplirse:

```text
ZombieEE_Priest01.count == 1
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR FINAL - ZombieEE_Priest01"
);

return;
```

---

# 27. Conversión del sacerdote

Cuando es válido:

```cpp
u_sacerdote =
    q[0]
    .AsUnit();
```

---

# 28. Procedencia del sacerdote

En el flujo actual fue recreado por:

```text
ZombieEE_FinalAssault_Run
```

tras la muerte del último atacante del asalto final.

---

# 29. Preparación de César

Antes de la Conversation:

```cpp
u_capitan.SetNoAIFlag(
    true
);
```

---

# 30. Preparación del sacerdote

También:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 31. Alimentación de César

Se ejecuta:

```cpp
u_capitan.SetFeeding(
    false
);
```

---

# 32. Alimentación del sacerdote

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 33. Motivo

Durante la escena final se evita que:

```text
IA estratégica
alimentación
```

interfieran con los dos actores.

---

# 34. Bloqueo del input

Antes de mover la cámara:

```cpp
BlockUserInput();
```

---

# 35. Cámara inicial

Se ejecuta:

```cpp
StartViewFollow(
    u_sacerdote
);
```

---

# 36. Duración del seguimiento

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

# 37. Fin del seguimiento

Después:

```cpp
StopViewFollow();
```

---

# 38. Pausa de transición

Se ejecuta:

```cpp
Sleep(
    250
);
```

---

# 39. Conversation utilizada

La Sequence inicializa:

```cpp
conv.Init(
    "ZombieEE_ConvFinal"
);
```

---

# 40. Actor `Capitan`

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

# 41. Actor `Sacerdote`

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

# 42. Número de actores

`ZombieEE_ConvFinal` utiliza:

```text
2 actores
```

asignados por esta Sequence.

---

# 43. Ejecución del diálogo

Se reproduce con:

```cpp
conv.Run();
```

---

# 44. Pausa posterior

Después:

```cpp
Sleep(
    500
);
```

---

# 45. Devolver control al jugador

Se ejecuta:

```cpp
UnblockUserInput();
```

---

# 46. Restaurar alimentación de César

Después:

```cpp
u_capitan.SetFeeding(
    true
);
```

---

# 47. Restaurar IA de César

También:

```cpp
u_capitan.SetNoAIFlag(
    false
);
```

---

# 48. El sacerdote no se restaura al estado normal

No se ejecuta:

```text
SetFeeding(true)
SetNoAIFlag(false)
```

sobre el sacerdote.

---

# 49. Razón narrativa

La siguiente sección del código es:

```text
EL SACERDOTE QUEDA COMO PRISIONERO
```

Por tanto debe seguir:

```text
fuera de la IA normal
sin alimentación
```

---

# 50. Configuración final del sacerdote

Se ejecuta explícitamente:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);

u_sacerdote.SetFeeding(
    false
);
```

---

# 51. Group de prisionero

Después:

```cpp
u_sacerdote.AddToGroup(
    "ZombieEE_Prisoner"
);
```

---

# 52. Resultado

El sacerdote permanece físicamente en el mapa, pero queda identificado como:

```text
prisionero del final del Easter Egg
```

---

# 53. No se borra al sacerdote

A diferencia de Dialogue04, aquí no existe:

```cpp
Erase();
```

---

# 54. No se elimina de `ZombieEE_Priest01`

Tampoco existe:

```cpp
RemoveFromGroup(
    "ZombieEE_Priest01"
);
```

---

# 55. Consecuencia

El sacerdote puede pertenecer simultáneamente a:

```text
ZombieEE_Priest01
ZombieEE_Prisoner
```

---

# 56. Interacción con PriestKeeper

Mientras siga en:

```text
ZombieEE_Priest01
```

y `EE_COMPLETED` todavía no se haya procesado al final de esta Sequence, `ZombieEE_PriestKeeper` puede seguir manteniendo sus propiedades.

Después:

```text
EE_COMPLETED = 1
```

PriestKeeper terminará su bucle.

---

# 57. Recompensa final

La sección canónica se titula:

```text
RECOMPENSA: CUATRO CAMPEONES DE ROMA
```

---

# 58. Identificadores confirmados

El Source especifica:

```text
BVikingLord
GTridentWarrior
TValkyrie
RPraetorian
```

---

# 59. Protección contra recompensa duplicada

Antes de crear nada:

```cpp
if(
    EnvReadInt(
        state,
        "EE_REWARDS_SPAWNED"
    )
    !=
    1
)
```

---

# 60. Significado de `EE_REWARDS_SPAWNED`

```text
0
→ los campeones todavía no fueron generados

1
→ la recompensa ya fue entregada
```

---

# 61. Centro de aparición

Si la recompensa todavía no fue creada:

```cpp
rewardX =
    u_sacerdote.pos.x;

rewardY =
    u_sacerdote.pos.y;
```

---

# 62. Posición relativa

Los cuatro campeones aparecen alrededor de la posición actual del sacerdote.

La formación es:

```text
(-120,-90)    (+120,-90)

       sacerdote

(-120,+90)    (+120,+90)
```

---

# 63. Campeón 1 — Jefe normando

Se crea:

```cpp
Place(
    "BVikingLord",
    Point(
        rewardX - 120,
        rewardY - 90
    ),
    1
)
```

---

# 64. Clase

```text
BVikingLord
```

---

# 65. Descripción del Source

El comentario lo identifica como:

```text
JEFE NORMANDO
```

---

# 66. Propietario

Se crea para:

```text
Player 1
```

---

# 67. Nivel

Recibe:

```cpp
u.SetLevel(
    60
);
```

---

# 68. Alimentación

Se ejecuta:

```cpp
u.SetFeeding(
    false
);
```

---

# 69. Primer objeto

Recibe:

```text
Fur gloves of health
```

---

# 70. Segundo objeto

Recibe:

```text
Concentration stone
```

---

# 71. Tercer objeto

Recibe:

```text
King's belt
```

---

# 72. Cuarto objeto

Recibe:

```text
Elephant tusk
```

---

# 73. Group de recompensa

Finalmente:

```cpp
u.AddToGroup(
    "ZombieEE_FinalRewards"
);
```

---

# 74. Campeón 2 — Guerrero de Fand

Se crea:

```cpp
Place(
    "GTridentWarrior",
    Point(
        rewardX + 120,
        rewardY - 90
    ),
    1
)
```

---

# 75. Clase

```text
GTridentWarrior
```

---

# 76. Descripción del Source

```text
GUERRERO DE FAND
```

---

# 77. Nivel

```text
60
```

---

# 78. Alimentación

```text
false
```

---

# 79. Objetos

Recibe exactamente:

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

---

# 80. Group

```text
ZombieEE_FinalRewards
```

---

# 81. Campeón 3 — Valquiria

Se crea:

```cpp
Place(
    "TValkyrie",
    Point(
        rewardX - 120,
        rewardY + 90
    ),
    1
)
```

---

# 82. Clase

```text
TValkyrie
```

---

# 83. Nivel

```text
60
```

---

# 84. Alimentación

```text
false
```

---

# 85. Objetos

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

---

# 86. Group

```text
ZombieEE_FinalRewards
```

---

# 87. Campeón 4 — Pretoriano

Se crea:

```cpp
Place(
    "RPraetorian",
    Point(
        rewardX + 120,
        rewardY + 90
    ),
    1
)
```

---

# 88. Clase

```text
RPraetorian
```

---

# 89. Nivel

```text
60
```

---

# 90. Alimentación

```text
false
```

---

# 91. Objetos

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

---

# 92. Group

```text
ZombieEE_FinalRewards
```

---

# 93. Configuración común de los cuatro campeones

Todos comparten:

```text
Player 1
Nivel 60
SetFeeding(false)
4 objetos
Group ZombieEE_FinalRewards
```

---

# 94. Objetos comunes

Cada campeón recibe exactamente:

```text
1 × Fur gloves of health
1 × Concentration stone
1 × King's belt
1 × Elephant tusk
```

---

# 95. Total de objetos entregados

Con cuatro campeones:

```text
4 Fur gloves of health
4 Concentration stone
4 King's belt
4 Elephant tusk
```

Total:

```text
16 objetos
```

---

# 96. No se utiliza `SetNoAIFlag(false)` en los campeones

La Sequence no ejecuta ningún `SetNoAIFlag()` sobre las cuatro recompensas.

---

# 97. Estado de IA de los campeones

Quedan con el comportamiento por defecto derivado de su creación para Player 1.

---

# 98. No se insertan dentro del Foro

A diferencia de las recompensas de portales, aquí no existe:

```cpp
ForceAddUnit(...)
```

---

# 99. Aparición exterior

Los cuatro campeones aparecen físicamente alrededor del sacerdote mediante `Place()`.

---

# 100. No se usa formación dinámica

Las cuatro posiciones son fijas respecto a:

```text
rewardX
rewardY
```

---

# 101. Marcar recompensa entregada

Después del cuarto campeón:

```cpp
EnvWriteInt(
    state,
    "EE_REWARDS_SPAWNED",
    1
);
```

---

# 102. Orden del marcado

A diferencia de otras recompensas del proyecto, aquí el flag se escribe:

```text
después de crear los cuatro campeones
```

---

# 103. Consecuencia

Si la Sequence se interrumpiera a mitad de creación antes de escribir:

```text
EE_REWARDS_SPAWNED = 1
```

una nueva ejecución podría volver a entrar en el bloque de recompensa.

---

# 104. Sin `Sleep()` entre campeones

La creación de los cuatro es consecutiva.

No existe:

```cpp
Sleep(20);
```

entre ellos.

---

# 105. No hay validación individual de `Place()`

La Sequence presupone que cada:

```cpp
Place(...).AsUnit()
```

produce una unidad válida.

---

# 106. Fin del Easter Egg

Después del bloque de recompensas:

```cpp
EnvWriteInt(
    state,
    "EE_DIALOGUE_FINAL_COMPLETED",
    1
);
```

---

# 107. Marcar todo el Easter Egg completado

También:

```cpp
EnvWriteInt(
    state,
    "EE_COMPLETED",
    1
);
```

---

# 108. Significado de `EE_COMPLETED`

Es el flag global definitivo del Easter Egg:

```text
0
→ Easter Egg todavía activo

1
→ Easter Egg completamente terminado
```

---

# 109. Interacción con `ZombieEE_PriestKeeper`

`ZombieEE_PriestKeeper` ejecuta su bucle mientras:

```text
EE_COMPLETED == 0
```

Al escribir:

```text
EE_COMPLETED = 1
```

DialogueFinal provoca que PriestKeeper termine su ejecución.

---

# 110. El sacerdote queda prisionero después del final

Aunque PriestKeeper deja de operar, el sacerdote ya quedó configurado con:

```text
SetNoAIFlag(true)
SetFeeding(false)
Group ZombieEE_Prisoner
```

---

# 111. Anuncio final

Se muestra:

```text
EASTER EGG COMPLETADO - CUATRO CAMPEONES SE UNEN A ROMA
```

---

# 112. ID del anuncio

Utiliza:

```text
ZombieEEObjective
```

---

# 113. Duración del anuncio final

Después:

```cpp
Sleep(
    10000
);
```

El mensaje permanece aproximadamente:

```text
10 segundos
```

---

# 114. Ocultar anuncio

Después:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

---

# 115. Final definitivo

Después:

```cpp
return;
```

La Sequence termina.

---

# 116. No se inicia ninguna otra Sequence

`ZombieEE_DialogueFinal` no ejecuta ningún:

```cpp
RunSequence(...)
```

---

# 117. Es el final de la cadena narrativa

No existe una fase posterior del Easter Egg dentro de esta arquitectura.

---

# 118. No se reinician Waves

La Sequence no modifica:

```text
EE_ZOMBIE_SPAWNS_DISABLED
ZWAVES_STOPPED_BY_PORTALS
```

---

# 119. Estado de Waves al llegar aquí

Las nuevas hordas normales ya quedaron detenidas durante la fase de los portales.

DialogueFinal no las reactiva.

---

# 120. No se eliminan zombies residuales aquí

La Sequence no consulta:

```text
HW_H1..8
```

ni borra tropas normales.

---

# 121. El asalto final ya debe estar completamente muerto

Esto sí está garantizado por:

```text
EE_FINAL_ASSAULT_COMPLETED = 1
```

---

# 122. No se modifica el asalto final

DialogueFinal no escribe:

```text
EE_FINAL_ASSAULT_ENABLED
EE_FINAL_ASSAULT_STARTED
EE_FINAL_BATCH_DEPLOYED
```

---

# 123. No se vuelve a ocultar al sacerdote

No se escribe:

```text
EE_PRIEST_HIDDEN = 1
```

---

# 124. El sacerdote permanece visible

La narrativa final lo deja:

```text
presente
prisionero
fuera de la IA normal
```

---

# 125. No se borra `EE_PRIEST_PENDING`

La Sequence no escribe este flag porque:

```text
ZombieEE_PriestInteraction_Main
```

ya lo puso a cero antes de lanzar DialogueFinal.

---

# 126. No existe recompensa militar de 200 soldados aquí

La implementación canónica actual de `ZombieEE_DialogueFinal` entrega exactamente:

```text
4 campeones
```

No contiene un spawn adicional de 200 tropas de recompensa.

---

# 127. Recompensa final exacta del Source v2.0

```text
1 BVikingLord nivel 60
1 GTridentWarrior nivel 60
1 TValkyrie nivel 60
1 RPraetorian nivel 60
```

Cada uno con:

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

---

# 128. Group de recompensa final

Los cuatro pertenecen a:

```text
ZombieEE_FinalRewards
```

---

# 129. Group del sacerdote prisionero

El sacerdote se añade a:

```text
ZombieEE_Prisoner
```

---

# 130. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
ZombieEE_Caesar
ZombieEE_Priest01
```

---

# 131. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 132. `ZombieEE_Caesar`

Debe contener:

```text
exactamente 1 Unit
```

---

# 133. `ZombieEE_Priest01`

Debe contener:

```text
exactamente 1 Unit
```

cuando se ejecute DialogueFinal.

---

# 134. Groups dinámicos utilizados

```text
ZombieEE_Prisoner
ZombieEE_FinalRewards
```

---

# 135. No necesitan contenido manual inicial

Ambos Groups se rellenan durante la ejecución mediante:

```text
AddToGroup(...)
```

---

# 136. Groups que no utiliza directamente

No consulta:

```text
EE_FinalAssault
HordeSpawn_01
EE_PortalGuardiansActive
EE_AnubisWave01
HW_H1..8
HW_R1..16
```

---

# 137. Areas necesarias

Ninguna.

---

# 138. Holders necesarios

Ninguno.

---

# 139. Conversation necesaria

Debe existir:

```text
ZombieEE_ConvFinal
```

con actores:

```text
Capitan
Sacerdote
```

---

# 140. Sequence anterior

La fase anterior efectiva es:

```text
ZombieEE_FinalAssault_Run
```

---

# 141. Intermediario presencial

Después del asalto:

```text
ZombieEE_PriestInteraction_Main
```

espera que César vuelva al sacerdote.

---

# 142. Sequence posterior

Ninguna.

`ZombieEE_DialogueFinal` cierra el Easter Egg.

---

# 143. Flags que lee

| Flag | Función |
|---|---|
| `EE_DIALOGUE_FINAL_COMPLETED` | Evita repetir el final |
| `EE_FINAL_ASSAULT_COMPLETED` | Exige que el asalto final haya terminado |
| `EE_REWARDS_SPAWNED` | Evita duplicar los cuatro campeones |

---

# 144. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_REWARDS_SPAWNED` | 1 | Marca la recompensa final como creada |
| `EE_DIALOGUE_FINAL_COMPLETED` | 1 | Marca el último diálogo como completado |
| `EE_COMPLETED` | 1 | Marca todo el Easter Egg como terminado |

---

# 145. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR FINAL - CapitalForum_P1` |
| `ZombieHelp` | `ERROR FINAL - ZombieEE_Caesar` |
| `ZombieHelp` | `ERROR FINAL - ZombieEE_Priest01` |
| `ZombieEEObjective` | `EASTER EGG COMPLETADO - CUATRO CAMPEONES SE UNEN A ROMA` |

---

# 146. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Cámara sobre sacerdote | 1.000 ms |
| Pausa tras StopViewFollow | 250 ms |
| Pausa tras Conversation | 500 ms |
| Mensaje final | 10.000 ms |

---

# 147. Flujo exacto de cámara

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
ZombieEE_ConvFinal
```

---

# 148. Flujo exacto de César

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

# 149. Flujo exacto del sacerdote

```text
obtener sacerdote recreado
↓
SetNoAIFlag(true)
SetFeeding(false)
↓
Conversation
↓
SetNoAIFlag(true)
SetFeeding(false)
↓
AddToGroup("ZombieEE_Prisoner")
↓
permanece en el mapa como prisionero
```

---

# 150. Flujo exacto de recompensas

```text
¿EE_REWARDS_SPAWNED != 1?
↓ Sí
rewardX/Y = posición del sacerdote
↓
Place BVikingLord
(-120,-90)
↓
nivel 60
4 objetos
↓
Place GTridentWarrior
(+120,-90)
↓
nivel 60
4 objetos
↓
Place TValkyrie
(-120,+90)
↓
nivel 60
4 objetos
↓
Place RPraetorian
(+120,+90)
↓
nivel 60
4 objetos
↓
EE_REWARDS_SPAWNED = 1
```

---

# 151. Formación final alrededor del sacerdote

```text
BVikingLord             GTridentWarrior
(-120,-90)                (+120,-90)

               Sacerdote
                (0,0)

TValkyrie                 RPraetorian
(-120,+90)                (+120,+90)
```

---

# 152. Configuración exacta de campeones

| Campeón | Clase | Player | Nivel | Posición relativa |
|---|---|---:|---:|---|
| Jefe normando | `BVikingLord` | 1 | 60 | `(-120,-90)` |
| Guerrero de Fand | `GTridentWarrior` | 1 | 60 | `(+120,-90)` |
| Valquiria | `TValkyrie` | 1 | 60 | `(-120,+90)` |
| Pretoriano | `RPraetorian` | 1 | 60 | `(+120,+90)` |

---

# 153. Equipamiento exacto

Cada campeón recibe:

```text
Fur gloves of health
Concentration stone
King's belt
Elephant tusk
```

---

# 154. Alimentación de campeones

Todos reciben:

```text
SetFeeding(false)
```

---

# 155. No se fija nivel de César ni sacerdote

DialogueFinal no modifica el nivel de los actores de la conversación.

---

# 156. No se añaden items al sacerdote

Todos los objetos de recompensa se entregan exclusivamente a los cuatro campeones.

---

# 157. No se añaden items a César

César tampoco recibe objetos directamente en esta Sequence.

---

# 158. No se usa `ForceAddUnit`

Los campeones quedan desplegados exteriormente alrededor del sacerdote.

---

# 159. No se usa `SetNoAIFlag(true)` para recompensas

Los cuatro campeones no reciben esa llamada.

---

# 160. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── ZombieEE_Caesar
│   │   └── César
│   │
│   ├── ZombieEE_Priest01
│   │   └── sacerdote egipcio recreado
│   │
│   ├── ZombieEE_Prisoner
│   │   └── vacío inicialmente
│   │
│   └── ZombieEE_FinalRewards
│       └── vacío inicialmente
│
├── Conversations
│   └── ZombieEE_ConvFinal
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieEE_FinalAssault_Run
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    └── ZombieEE_DialogueFinal
        └── AUTORUN = NO
```

---

# 161. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_Caesar` contiene exactamente a César.
3. `ZombieEE_Priest01` contiene exactamente al sacerdote recreado.
4. `ZombieEE_ConvFinal` existe.
5. Sus actores se llaman exactamente `Capitan` y `Sacerdote`.
6. `ZombieEE_FinalAssault_Run` termina escribiendo `EE_FINAL_ASSAULT_COMPLETED = 1`.
7. `ZombieEE_FinalAssault_Run` termina escribiendo `EE_PRIEST_PENDING = 5`.
8. `ZombieEE_PriestInteraction_Main` sigue activo.
9. `ZombieEE_Prisoner` puede recibir al sacerdote.
10. `ZombieEE_FinalRewards` puede recibir los cuatro campeones.
11. Las clases `BVikingLord`, `GTridentWarrior`, `TValkyrie` y `RPraetorian` son válidas.
12. Los cuatro nombres de items son válidos exactamente como aparecen en Source.

---

# 162. Estado esperado antes de DialogueFinal

Un estado normal es:

```text
EE_FINAL_ASSAULT_ENABLED = 0
EE_FINAL_ASSAULT_STARTED = 1
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_BATCH_DEPLOYED = 8

EE_PRIEST_HIDDEN = 0
EE_PRIEST_PENDING = 0

EE_DIALOGUE_FINAL_COMPLETED = 0
```

`pending` ya está en cero porque PriestInteraction lo borra antes de ejecutar DialogueFinal.

---

# 163. Estado esperado después

```text
EE_REWARDS_SPAWNED = 1
EE_DIALOGUE_FINAL_COMPLETED = 1
EE_COMPLETED = 1
```

Además:

```text
ZombieEE_Prisoner
→ contiene al sacerdote

ZombieEE_FinalRewards
→ contiene 4 campeones
```

---

# 164. Resultado jugable final

Roma recibe:

```text
1 Jefe normando
1 Guerrero de Fand
1 Valquiria
1 Pretoriano
```

Todos:

```text
nivel 60
```

y equipados con cuatro objetos.

---

# 165. Resultado narrativo final

El sacerdote:

```text
no desaparece
no muere
no vuelve a Egipto
```

sino que queda registrado como:

```text
ZombieEE_Prisoner
```

según la orden narrativa de encarcelamiento.

---

# 166. Fin de `ZombieEE_PriestKeeper`

Después de:

```text
EE_COMPLETED = 1
```

PriestKeeper abandona su bucle principal.

---

# 167. Fin de la cadena `EE_PRIEST_PENDING`

No existe un:

```text
EE_PRIEST_PENDING = 6
```

La secuencia de visitas termina en:

```text
5 → ZombieEE_DialogueFinal
```

---

# 168. Secuencia completa de diálogos

```text
pending 1
→ ZombieEE_Dialogue01

pending 2
→ ZombieEE_Dialogue02

pending 3
→ ZombieEE_Dialogue03

pending 4
→ ZombieEE_Dialogue04

pending 5
→ ZombieEE_DialogueFinal
```

---

# 169. Cadena completa del Easter Egg

```text
Primera mini-horda R1/Spawn01 destruida
↓
Dialogue01
↓
50 aldeanos sacrificados
↓
50 Guerreros de Anubis
↓
Dialogue02
↓
4 de 8 portales sellados
↓
Dialogue03
↓
Gem of Power
↓
Dialogue04
↓
sacerdote desaparece
↓
FinalAssault_Run
↓
200 atacantes derrotados
↓
sacerdote reaparece
↓
DialogueFinal
↓
4 campeones
↓
EE_COMPLETED = 1
```

---

# 170. Resumen funcional

`ZombieEE_DialogueFinal` cierra definitivamente el Easter Egg:

```text
EE_FINAL_ASSAULT_COMPLETED = 1
↓
César vuelve al sacerdote
↓
ZombieEE_ConvFinal
↓
restaurar César
↓
sacerdote:
SetNoAIFlag(true)
SetFeeding(false)
AddToGroup("ZombieEE_Prisoner")
↓
si EE_REWARDS_SPAWNED != 1:
    crear alrededor del sacerdote:
    BVikingLord
    GTridentWarrior
    TValkyrie
    RPraetorian
    ↓
    todos Player 1
    todos nivel 60
    todos con 4 objetos
    ↓
    AddToGroup("ZombieEE_FinalRewards")
    ↓
    EE_REWARDS_SPAWNED = 1
↓
EE_DIALOGUE_FINAL_COMPLETED = 1
↓
EE_COMPLETED = 1
↓
mostrar 10 s:
EASTER EGG COMPLETADO - CUATRO CAMPEONES SE UNEN A ROMA
↓
return
```

La Sequence 23 es el cierre definitivo de la arquitectura del Easter Egg v2.0: no lanza más fases, convierte al sacerdote en prisionero, entrega exactamente cuatro campeones de nivel 60 y marca `EE_COMPLETED = 1` como estado global de finalización.

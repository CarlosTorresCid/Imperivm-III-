# Secuencia 21 — `ZombieEE_FinalAssault_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_FinalAssault_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_FinalAssault_Main` es la implementación histórica completa del asalto final del Easter Egg.

La propia fuente v2.0 conserva esta Sequence, pero `ZombieEE_Dialogue04` ya no la utiliza como punto de entrada principal. La transición actual lanza:

```text
ZombieEE_FinalAssault_Run
```

y no:

```text
ZombieEE_FinalAssault_Main
```

Aun así, `ZombieEE_FinalAssault_Main` contiene una implementación funcional completa del asalto final:

```text
8 tandas
×
25 unidades
=
200 atacantes
```

Los atacantes:

```text
Player 12
SetFeeding(false)
SetNoAIFlag(true)
Group EE_FinalAssault
```

y avanzan directamente hacia:

```text
CapitalForum_P1
```

mediante:

```text
advance
```

sin integrarse en `HW_H1`, sin utilizar `ZombieTactical_Main` y sin recibir órdenes de captura.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel histórico dentro del Easter Egg

La intención de esta Sequence es:

```text
Dialogue04
↓
EE_FINAL_ASSAULT_ENABLED = 1
↓
FinalAssault_Main
↓
8 tandas × 25
↓
200 atacantes
↓
todos muertos
↓
recrear sacerdote
↓
EE_PRIEST_PENDING = 5
↓
DialogueFinal
```

Sin embargo, en la arquitectura v2.0 actual `Dialogue04` lanza expresamente:

```text
ZombieEE_FinalAssault_Run
```

para evitar problemas históricos de registro asociados a esta Sequence.

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_FinalAssault_Main
→ AUTORUN = NO
```

No debe ejecutarse al cargar el escenario.

---

# 3. Comentario canónico de comportamiento

La cabecera establece:

```text
8 tandas x 25 = 200 atacantes.
```

También especifica:

```text
- NO usan HW_H1.
- NO utilizan el sistema de asedio zombie.
- NO reciben orden "capture".
- Avanzan hacia Roma mediante "advance".
- Luchan contra enemigos encontrados durante el trayecto.
- Al terminar un combate siguen avanzando hacia el Foro.
```

---

# 4. Independencia respecto a Tactical

La Sequence no añade unidades a:

```text
HW_H1
HW_H2
...
HW_H8
```

---

# 5. Independencia respecto a Waves

Tampoco utiliza:

```text
HW_R1..15
HW_R16
```

---

# 6. Independencia respecto a Rewards

Por tanto estas 200 unidades no forman parte de:

```text
ZombieRewards_Main
```

---

# 7. Group exclusivo

Todas las unidades del asalto final se añaden únicamente a:

```text
EE_FinalAssault
```

---

# 8. Variables principales

La Sequence declara:

```cpp
ObjList stateList;
ObjList spawnList;
ObjList finalArmy;
ObjList priestList;

Building state;

Unit u;
Unit u_sacerdote;

point spawnPos;
point priestPos;
point targetPos;
```

Además usa:

```text
c1..c5
n1..n5
batch
level
t
n
i
idx
spawnX
spawnY
remaining
lastRemaining
priestX
priestY
priestOwner
```

---

# 9. Group de estado

La Sequence comienza con:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 10. Validación de `CapitalForum_P1`

Debe existir exactamente:

```text
1 Building
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR FINAL - CapitalForum_P1"
);

return;
```

---

# 11. `CapitalForum_P1` como objetivo

Después:

```cpp
state =
    stateList[0]
    .AsBuilding();

targetPos =
    state.pos;
```

Por tanto el Foro cumple simultáneamente:

```text
memoria del Easter Egg
+
objetivo militar del asalto
```

---

# 12. Flags de entrada

Se leen:

```text
EE_FINAL_ASSAULT_ENABLED
EE_FINAL_ASSAULT_STARTED
EE_FINAL_ASSAULT_COMPLETED
```

---

# 13. Validación `enabled`

Si:

```text
EE_FINAL_ASSAULT_ENABLED != 1
```

la Sequence termina.

---

# 14. Validación `completed`

Si:

```text
EE_FINAL_ASSAULT_COMPLETED == 1
```

termina.

---

# 15. Validación `started`

Si:

```text
EE_FINAL_ASSAULT_STARTED == 1
```

también termina.

---

# 16. Protección frente a doble ejecución

El estado válido de entrada es:

```text
ENABLED = 1
STARTED = 0
COMPLETED = 0
```

---

# 17. Group de spawn

La Sequence utiliza:

```text
HordeSpawn_01
```

---

# 18. Validación de `HordeSpawn_01`

Debe contener:

```text
exactamente 1 objeto
```

Si no:

```text
ERROR FINAL - HordeSpawn_01
```

y:

```cpp
return;
```

---

# 19. Posición del spawn

Se guarda:

```cpp
spawnPos =
    spawnList[0]
    .pos;
```

---

# 20. Comprobación de asalto residual

Antes de iniciar:

```cpp
finalArmy =
    Group("EE_FinalAssault")
    .GetObjList();

finalArmy.ClearDead();
```

---

# 21. Error si quedan unidades

Si:

```text
EE_FinalAssault.count > 0
```

se muestra:

```text
ERROR FINAL - YA EXISTE UN ASALTO
```

y termina.

---

# 22. Marcar inicio

Sólo después de validar todo:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_STARTED",
    1
);
```

---

# 23. Primer anuncio

Se muestra:

```text
ALERTA - LA HORDA FINAL AVANZA CONTRA ROMA
```

mediante:

```text
ZombieEEObjective
```

---

# 24. Duración del aviso inicial

Después:

```cpp
Sleep(
    3000
);
```

---

# 25. Número total de tandas

El bucle principal es:

```cpp
for(
    batch = 1;
    batch <= 8;
    batch += 1
)
```

---

# 26. Unidades por tanda

Cada tanda contiene:

```text
5 clases
×
5 unidades
=
25 unidades
```

---

# 27. Total general

```text
8
×
25
=
200 atacantes
```

---

# 28. Tanda 1

Nivel:

```text
20
```

Composición:

```text
5 TMaceman
5 RHastatus
5 GAxeman
5 CLibyanFootman
5 BBronzeSpearman
```

Total:

```text
25
```

---

# 29. Tanda 2

Nivel:

```text
26
```

Composición:

```text
5 RPraetorian
5 IEliteGuard
5 BHighlander
5 CNumidianRider
5 EGuardian
```

---

# 30. Tanda 3

Nivel:

```text
32
```

Composición:

```text
5 EAnubisWarrior
5 EHorusWarrior
5 TValkyrie
5 GTridentWarrior
5 RLiberatus
```

---

# 31. Tanda 4

Nivel:

```text
38
```

Composición:

```text
5 RPraetorian
5 BHighlander
5 IEliteGuard
5 EAnubisWarrior
5 EHorusWarrior
```

---

# 32. Tanda 5

Nivel:

```text
44
```

Composición:

```text
5 TValkyrie
5 GTridentWarrior
5 RLiberatus
5 CWarElephant
5 EAnubisWarrior
```

---

# 33. Tanda 6

Nivel:

```text
50
```

Composición:

```text
5 RPraetorian
5 TValkyrie
5 GTridentWarrior
5 EHorusWarrior
5 EAnubisWarrior
```

---

# 34. Tanda 7

Nivel:

```text
55
```

Composición:

```text
5 GTridentWarrior
5 RLiberatus
5 BHighlander
5 IEliteGuard
5 CWarElephant
```

---

# 35. Tanda 8

Nivel:

```text
60
```

Composición:

```text
5 CWarElephant
5 EAnubisWarrior
5 EHorusWarrior
5 TValkyrie
5 RPraetorian
```

---

# 36. Progresión de nivel

La progresión es:

| Tanda | Nivel |
|---:|---:|
| 1 | 20 |
| 2 | 26 |
| 3 | 32 |
| 4 | 38 |
| 5 | 44 |
| 6 | 50 |
| 7 | 55 |
| 8 | 60 |

---

# 37. Diferencia de nivel entre tandas

La progresión principal es aproximadamente:

```text
+6 niveles
```

hasta T6.

Después:

```text
T6 → T7 = +5
T7 → T8 = +5
```

---

# 38. Estructura interna de clases

Cada tanda reinicia:

```cpp
c1 = "";
c2 = "";
c3 = "";
c4 = "";
c5 = "";

n1 = 0;
n2 = 0;
n3 = 0;
n4 = 0;
n5 = 0;
```

---

# 39. Creación por tipo

Después:

```cpp
for(
    t = 1;
    t <= 5;
    t += 1
)
```

selecciona:

```text
c1/n1
c2/n2
c3/n3
c4/n4
c5/n5
```

---

# 40. Creación individual

Por cada tipo:

```cpp
for(
    i = 0;
    i < n;
    i += 1
)
```

---

# 41. Formación de cada tanda

La X se calcula:

```cpp
spawnX =
    spawnPos.x
    +
    (idx % 5) * 55
    -
    110;
```

---

# 42. Número de columnas

```text
5 columnas
```

---

# 43. Separación horizontal

```text
55
```

---

# 44. Rango horizontal

Con columnas 0..4:

```text
-110
-55
0
+55
+110
```

respecto al centro.

---

# 45. Coordenada Y

Se calcula:

```cpp
spawnY =
    spawnPos.y
    +
    (idx / 5) * 55
    -
    110;
```

---

# 46. Número de filas

Con 25 unidades:

```text
5 filas
```

---

# 47. Separación vertical

```text
55
```

---

# 48. Rango vertical

```text
-110
-55
0
+55
+110
```

---

# 49. Formación total

Cada tanda aparece como:

```text
5 × 5
```

centrada alrededor de:

```text
HordeSpawn_01
```

---

# 50. Player de los atacantes

Todas las unidades se crean con:

```text
Player 12
```

---

# 51. Nivel de la tanda

Cada unidad recibe:

```cpp
u.SetLevel(
    level
);
```

---

# 52. Alimentación

Cada atacante recibe:

```cpp
u.SetFeeding(
    false
);
```

---

# 53. Exclusión de IA estratégica

También:

```cpp
u.SetNoAIFlag(
    true
);
```

---

# 54. Group exclusivo

Cada atacante:

```cpp
u.AddToGroup(
    "EE_FinalAssault"
);
```

---

# 55. No entra en `HW_H1`

El comentario interno remarca expresamente:

```text
NO HW_H1
```

---

# 56. Orden inicial

Cada unidad recibe:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 57. Objetivo inicial

```text
CapitalForum_P1.pos
```

---

# 58. No utiliza `move`

La orden militar inicial es:

```text
advance
```

---

# 59. No utiliza `capture`

La cabecera especifica:

```text
NO reciben orden "capture"
```

---

# 60. No utiliza `Siege()`

No existe lógica explícita:

```text
Gate
Catapult
Siege
```

---

# 61. Filosofía de comportamiento

El diseño busca:

```text
avanzar hacia Roma
+
combatir durante el trayecto
+
seguir avanzando después del combate
```

---

# 62. Creación escalonada

Después de cada unidad:

```cpp
Sleep(
    20
);
```

---

# 63. Tiempo programado de creación por tanda

```text
25 × 20 ms
=
500 ms
```

más coste del motor.

---

# 64. Tiempo programado de creación de 200

```text
200 × 20 ms
=
4.000 ms
```

acumulados, sin contar los intervalos entre tandas.

---

# 65. Refresco del estado después de cada tanda

Después de crear 25 unidades:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 66. Validación entre tandas

Si:

```text
stateList.count != 1
```

la Sequence termina.

---

# 67. Renovación de `state`

Después:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 68. Flag de tanda desplegada

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_BATCH_DEPLOYED",
    batch
);
```

---

# 69. Significado

El valor indica:

```text
última tanda completamente desplegada
```

---

# 70. Valores posibles

Durante el asalto:

```text
1
2
3
4
5
6
7
8
```

---

# 71. Anuncio de tanda

Después se muestra:

```text
ASALTO FINAL - TANDA N/8 - NIVEL L
```

---

# 72. Ejemplo

Para Tanda 6:

```text
ASALTO FINAL - TANDA 6/8 - NIVEL 50
```

---

# 73. Intervalo entre tandas

Si:

```text
batch < 8
```

se ejecuta:

```cpp
Sleep(
    20000
);
```

---

# 74. Intervalo exacto

```text
20 segundos
```

entre el final del despliegue de una tanda y el comienzo de la siguiente.

---

# 75. Número de pausas

Existen:

```text
7 pausas
```

de 20 segundos.

---

# 76. Tiempo total de pausas

```text
7 × 20 s
=
140 segundos
=
2 min 20 s
```

---

# 77. No espera a que muera una tanda antes de crear la siguiente

El despliegue sigue por tiempo:

```text
cada 20 segundos
```

independientemente de cuántos enemigos sigan vivos.

---

# 78. Solapamiento de tandas

Pueden coexistir unidades de:

```text
varias tandas simultáneamente
```

---

# 79. Después de la Tanda 8

No hay:

```text
Sleep(20000)
```

adicional.

La Sequence pasa directamente a:

```text
esperar a que mueran todos
```

---

# 80. Seguimiento final

Se inicializa:

```cpp
lastRemaining =
    -1;
```

---

# 81. Bucle de supervivientes

La Sequence entra en:

```cpp
while(1)
```

---

# 82. Refresco de ejército

Cada ciclo:

```cpp
finalArmy =
    Group("EE_FinalAssault")
    .GetObjList();

finalArmy.ClearDead();
```

---

# 83. Conteo

Después:

```cpp
remaining =
    finalArmy.count;
```

---

# 84. Condición final de victoria

Si:

```text
remaining == 0
```

se ejecuta:

```cpp
break;
```

---

# 85. No hay timeout

El asalto puede durar indefinidamente mientras quede al menos un atacante vivo.

---

# 86. Reactivación de unidades ociosas

Por cada superviviente:

```cpp
if(
    u.command
    ==
    "idle"
)
```

---

# 87. Orden de reactivación

Sólo en ese caso:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 88. No se pisan combates

La fuente explica:

```text
NO se pisan unidades que estén atacando.
```

---

# 89. Una unidad en `attack`

No recibe una nueva orden.

---

# 90. Una unidad en `engage`

Tampoco recibe `advance` mientras siga ocupada.

---

# 91. Cuando termina un combate

Si el motor deja la unidad en:

```text
idle
```

la Sequence vuelve a enviarla hacia el Foro.

---

# 92. Objetivo fijo durante todo el asalto

`targetPos` se calcula al comienzo y se mantiene como:

```text
posición inicial de CapitalForum_P1
```

---

# 93. No recalcula la posición en cada ciclo

Aunque `state` se refresca entre tandas, `targetPos` no se vuelve a asignar en esos bloques.

---

# 94. Contador visible

Si:

```cpp
remaining != lastRemaining
```

se muestra:

```text
ASALTO FINAL - ENEMIGOS RESTANTES: X
```

---

# 95. Primer contador

Como:

```text
lastRemaining = -1
```

el primer ciclo siempre actualiza la interfaz.

---

# 96. Actualización sólo cuando cambia

Si no muere nadie:

```text
no se vuelve a escribir el anuncio
```

---

# 97. Frecuencia de control

Mientras queden enemigos:

```cpp
Sleep(
    1000
);
```

---

# 98. Frecuencia aproximada

```text
1 comprobación por segundo
```

---

# 99. Fin del combate

Al quedar:

```text
0 enemigos
```

se muestra:

```text
LA HORDA FINAL HA SIDO ANIQUILADA
```

---

# 100. Duración del anuncio

Después:

```cpp
Sleep(
    2500
);
```

---

# 101. Refresco del estado tras el combate

Después vuelve a consultar:

```text
CapitalForum_P1
```

---

# 102. Validación

Si deja de existir exactamente uno:

```cpp
return;
```

---

# 103. Reaparición del sacerdote

La Sequence lee:

```text
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
```

---

# 104. `priestX`

Se obtiene mediante:

```cpp
EnvReadInt(
    state,
    "EE_PRIEST_HOME_X"
);
```

---

# 105. `priestY`

Se obtiene mediante:

```cpp
EnvReadInt(
    state,
    "EE_PRIEST_HOME_Y"
);
```

---

# 106. `priestOwner`

Se obtiene mediante:

```cpp
EnvReadInt(
    state,
    "EE_PRIEST_OWNER"
);
```

---

# 107. Fallback de propietario

Si:

```text
priestOwner <= 0
```

se fuerza:

```text
Player 1
```

---

# 108. Fallback de posición

Si:

```text
priestX <= 0
o
priestY <= 0
```

la posición de reaparición será:

```text
targetPos
```

es decir:

```text
CapitalForum_P1.pos
```

---

# 109. Posición normal

Si los valores son válidos:

```cpp
priestPos =
    Point(
        priestX,
        priestY
    );
```

---

# 110. Comprobar sacerdote ya existente

La Sequence consulta:

```cpp
priestList =
    Group("ZombieEE_Priest01")
    .GetObjList();

priestList.ClearDead();
```

---

# 111. Si ya existe un sacerdote

Si:

```text
priestList.count > 0
```

utiliza:

```cpp
u_sacerdote =
    priestList[0]
    .AsUnit();
```

---

# 112. No crea un duplicado

La lógica evita ejecutar `Place()` si ya existe una unidad dentro del Group.

---

# 113. Si no existe

Se crea:

```cpp
Place(
    "EPriest",
    priestPos,
    priestOwner
)
```

---

# 114. Clase del sacerdote recreado

```text
EPriest
```

---

# 115. Propietario

Se usa:

```text
EE_PRIEST_OWNER
```

o:

```text
Player 1
```

como fallback.

---

# 116. Añadir al Group

La nueva unidad recibe:

```cpp
u_sacerdote.AddToGroup(
    "ZombieEE_Priest01"
);
```

---

# 117. Protección de la unidad recreada

Después:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 118. Alimentación

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 119. Salud

Se fuerza:

```cpp
u_sacerdote.SetHealth(
    1000
);
```

---

# 120. Interacción con PriestKeeper

Después de volver a poner:

```text
EE_PRIEST_HIDDEN = 0
```

`ZombieEE_PriestKeeper` puede volver a adquirir al sacerdote desde:

```text
ZombieEE_Priest01
```

---

# 121. Marcar sacerdote visible

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_HIDDEN",
    0
);
```

---

# 122. Marcar asalto completado

También:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_COMPLETED",
    1
);
```

---

# 123. Deshabilitar asalto

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_ENABLED",
    0
);
```

---

# 124. Preparar diálogo final

Finalmente:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    5
);
```

---

# 125. Significado de `pending = 5`

`ZombieEE_PriestInteraction_Main` interpreta:

```text
5
→ ZombieEE_DialogueFinal
```

---

# 126. Primer anuncio tras reaparición

Se muestra:

```text
LA ULTIMA HORDA HA CAIDO - EL SACERDOTE HA REGRESADO
```

---

# 127. Duración

Después:

```cpp
Sleep(
    5000
);
```

---

# 128. Segundo anuncio

Después se muestra:

```text
VE A HABLAR CON EL SACERDOTE EGIPCIO
```

---

# 129. No ejecuta DialogueFinal directamente

La Sequence termina después del anuncio.

El jugador debe acercarse de nuevo al sacerdote.

---

# 130. Sequence consumidora de `pending = 5`

```text
ZombieEE_PriestInteraction_Main
```

---

# 131. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
HordeSpawn_01
```

---

# 132. Group dinámico del ejército

```text
EE_FinalAssault
```

---

# 133. Group dinámico del sacerdote

```text
ZombieEE_Priest01
```

---

# 134. Groups que no utiliza

No usa:

```text
HW_H1..8
HW_R1..16
EE_PortalGuardiansActive
EE_AnubisWave01
```

---

# 135. Areas necesarias

Ninguna.

---

# 136. Holders necesarios

Ninguno.

---

# 137. Conversations necesarias

Ninguna directamente.

---

# 138. Flags que lee

| Flag | Función |
|---|---|
| `EE_FINAL_ASSAULT_ENABLED` | Autoriza el asalto |
| `EE_FINAL_ASSAULT_STARTED` | Evita doble inicio |
| `EE_FINAL_ASSAULT_COMPLETED` | Evita repetir fase |
| `EE_PRIEST_HOME_X` | Coordenada X para reaparición |
| `EE_PRIEST_HOME_Y` | Coordenada Y para reaparición |
| `EE_PRIEST_OWNER` | Propietario para recrear sacerdote |

---

# 139. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_FINAL_ASSAULT_STARTED` | 1 | Marca inicio |
| `EE_FINAL_BATCH_DEPLOYED` | 1..8 | Última tanda desplegada |
| `EE_PRIEST_HIDDEN` | 0 | Hace visible de nuevo al sacerdote |
| `EE_FINAL_ASSAULT_COMPLETED` | 1 | Marca fase terminada |
| `EE_FINAL_ASSAULT_ENABLED` | 0 | Desactiva nueva ejecución |
| `EE_PRIEST_PENDING` | 5 | Habilita diálogo final |

---

# 140. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR FINAL - CapitalForum_P1` |
| `ZombieHelp` | `ERROR FINAL - HordeSpawn_01` |
| `ZombieHelp` | `ERROR FINAL - YA EXISTE UN ASALTO` |
| `ZombieEEObjective` | `ALERTA - LA HORDA FINAL AVANZA CONTRA ROMA` |
| `ZombieEEObjective` | `ASALTO FINAL - TANDA N/8 - NIVEL L` |
| `ZombieEEObjective` | `ASALTO FINAL - ENEMIGOS RESTANTES: X` |
| `ZombieEEObjective` | `LA HORDA FINAL HA SIDO ANIQUILADA` |
| `ZombieEEObjective` | `LA ULTIMA HORDA HA CAIDO - EL SACERDOTE HA REGRESADO` |
| `ZombieEEObjective` | `VE A HABLAR CON EL SACERDOTE EGIPCIO` |

---

# 141. Tiempos principales

| Acción | Tiempo |
|---|---:|
| Aviso inicial | 3.000 ms |
| Sleep por unidad creada | 20 ms |
| Creación programada por tanda | ~500 ms |
| Intervalo entre tandas | 20.000 ms |
| Total de pausas entre 8 tandas | 140.000 ms |
| Control de supervivientes | 1.000 ms |
| Aviso de horda aniquilada | 2.500 ms |
| Aviso de regreso del sacerdote | 5.000 ms |

---

# 142. Resumen de composición

| Tanda | Nivel | Composición |
|---:|---:|---|
| 1 | 20 | 5 TMaceman, 5 RHastatus, 5 GAxeman, 5 CLibyanFootman, 5 BBronzeSpearman |
| 2 | 26 | 5 RPraetorian, 5 IEliteGuard, 5 BHighlander, 5 CNumidianRider, 5 EGuardian |
| 3 | 32 | 5 EAnubisWarrior, 5 EHorusWarrior, 5 TValkyrie, 5 GTridentWarrior, 5 RLiberatus |
| 4 | 38 | 5 RPraetorian, 5 BHighlander, 5 IEliteGuard, 5 EAnubisWarrior, 5 EHorusWarrior |
| 5 | 44 | 5 TValkyrie, 5 GTridentWarrior, 5 RLiberatus, 5 CWarElephant, 5 EAnubisWarrior |
| 6 | 50 | 5 RPraetorian, 5 TValkyrie, 5 GTridentWarrior, 5 EHorusWarrior, 5 EAnubisWarrior |
| 7 | 55 | 5 GTridentWarrior, 5 RLiberatus, 5 BHighlander, 5 IEliteGuard, 5 CWarElephant |
| 8 | 60 | 5 CWarElephant, 5 EAnubisWarrior, 5 EHorusWarrior, 5 TValkyrie, 5 RPraetorian |

---

# 143. Totales destacados

En las ocho tandas aparecen:

```text
200 unidades
```

Entre ellas existen:

```text
CWarElephant
EAnubisWarrior
EHorusWarrior
TValkyrie
GTridentWarrior
RLiberatus
RPraetorian
BHighlander
IEliteGuard
```

además de unidades convencionales en las primeras tandas.

---

# 144. Flujo completo

```text
validar CapitalForum_P1
↓
leer:
ENABLED
STARTED
COMPLETED
↓
validar HordeSpawn_01
↓
comprobar EE_FinalAssault vacío
↓
EE_FINAL_ASSAULT_STARTED = 1
↓
ALERTA - LA HORDA FINAL AVANZA CONTRA ROMA
↓
8 tandas:
    25 unidades
    ↓
    Player 12
    nivel según tanda
    SetFeeding(false)
    SetNoAIFlag(true)
    Group EE_FinalAssault
    advance → CapitalForum_P1
    ↓
    EE_FINAL_BATCH_DEPLOYED = tanda
    ↓
    anunciar tanda
    ↓
    20 s si no es la octava
↓
terminadas las 8 tandas
↓
esperar EE_FinalAssault.count == 0
↓
si una unidad queda idle:
    advance → CapitalForum_P1
↓
mostrar enemigos restantes
↓
LA HORDA FINAL HA SIDO ANIQUILADA
↓
leer X/Y/owner del sacerdote
↓
si ya existe:
    reutilizarlo
si no:
    Place("EPriest")
    AddToGroup("ZombieEE_Priest01")
↓
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
↓
EE_PRIEST_HIDDEN = 0
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_ASSAULT_ENABLED = 0
EE_PRIEST_PENDING = 5
↓
EL SACERDOTE HA REGRESADO
↓
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
return
```

---

# 145. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── HordeSpawn_01
│   │   └── exactamente 1 objeto
│   │
│   ├── EE_FinalAssault
│   │   └── vacío antes del inicio
│   │
│   └── ZombieEE_Priest01
│       └── puede estar vacío durante el asalto
│
└── Sequences
    ├── ZombieEE_Dialogue04
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_FinalAssault_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_FinalAssault_Run
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestKeeper
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    └── ZombieEE_DialogueFinal
        └── AUTORUN = NO
```

---

# 146. Estado esperado antes de una ejecución legítima

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
EE_PRIEST_HIDDEN = 1
```

---

# 147. Estado esperado después

```text
EE_FINAL_ASSAULT_ENABLED = 0
EE_FINAL_ASSAULT_STARTED = 1
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_BATCH_DEPLOYED = 8

EE_PRIEST_HIDDEN = 0
EE_PRIEST_PENDING = 5
```

---

# 148. Limitación arquitectónica principal

La implementación es funcional, pero no usa la lógica avanzada de:

```text
ZombieTactical_Main
```

Por tanto no contiene:

```text
ruta por nodos
detección de puertas
Siege()
fase de brecha
captura táctica
```

---

# 149. Comportamiento real ante obstáculos

Cada unidad recibe:

```text
advance → CapitalForum_P1
```

y sólo se reactiva si termina en:

```text
idle
```

La Sequence no implementa una solución especial de murallas o puertas.

---

# 150. Razón por la que se conserva

La fuente v2.0 mantiene `ZombieEE_FinalAssault_Main` como implementación completa del concepto original del asalto final.

Sin embargo, la arquitectura actual ha desplazado el punto de entrada a:

```text
ZombieEE_FinalAssault_Run
```

---

# 151. Relación actual con Dialogue04

En v2.0:

```text
ZombieEE_Dialogue04
```

contiene:

```cpp
RunSequence(
    "ZombieEE_FinalAssault_Run"
);
```

y no:

```cpp
RunSequence(
    "ZombieEE_FinalAssault_Main"
);
```

---

# 152. Consecuencia documental

`ZombieEE_FinalAssault_Main` debe considerarse:

```text
Sequence histórica/conservada
con implementación completa
pero no utilizada por el flujo principal actual
```

La Sequence 22 documentará:

```text
ZombieEE_FinalAssault_Run
```

que es el punto de entrada realmente utilizado por Dialogue04 en la versión v2.0 estable.

---

# 153. Resumen funcional

`ZombieEE_FinalAssault_Main` implementa:

```text
8 tandas
×
25 unidades
=
200 atacantes

niveles:
20
26
32
38
44
50
55
60

Player 12

Group:
EE_FinalAssault

orden:
advance → CapitalForum_P1

intervalo:
20 s entre tandas

↓
esperar muerte de todos
↓
reactivar sólo unidades idle
↓
recrear EPriest
↓
EE_PRIEST_HIDDEN = 0
↓
EE_FINAL_ASSAULT_COMPLETED = 1
↓
EE_FINAL_ASSAULT_ENABLED = 0
↓
EE_PRIEST_PENDING = 5
```

Su característica más importante en la arquitectura v2.0 es que ya no es la Sequence lanzada desde `ZombieEE_Dialogue04`; el flujo actual utiliza `ZombieEE_FinalAssault_Run`.

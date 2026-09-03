# Secuencia 22 — `ZombieEE_FinalAssault_Run`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_FinalAssault_Run` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_FinalAssault_Run` es la Sequence que ejecuta actualmente el asalto final del Easter Egg.

Es la Sequence realmente lanzada por:

```cpp
RunSequence(
    "ZombieEE_FinalAssault_Run"
);
```

desde:

```text
ZombieEE_Dialogue04
```

La arquitectura v2.0 mantiene también una Sequence histórica llamada:

```text
ZombieEE_FinalAssault_Main
```

pero `Dialogue04` no la utiliza como punto de entrada actual. La versión estable lanza expresamente `ZombieEE_FinalAssault_Run`.

La mecánica implementada es:

```text
8 tandas
×
25 unidades
=
200 atacantes
```

Todos pertenecen a:

```text
Player 12
```

y avanzan directamente hacia:

```text
CapitalForum_P1
```

mediante:

```text
advance
```

Las unidades no se integran en:

```text
HW_H1..8
```

ni utilizan:

```text
ZombieTactical_Main
```

ni el sistema normal de asedio de Zombies.

Cuando los 200 enemigos han muerto:

```text
se recrea el sacerdote egipcio
↓
EE_PRIEST_HIDDEN = 0
↓
EE_FINAL_ASSAULT_COMPLETED = 1
↓
EE_PRIEST_PENDING = 5
```

y el jugador debe regresar una última vez al sacerdote para activar:

```text
ZombieEE_DialogueFinal
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo canónico actual es:

```text
Gem of Power entregada
↓
EE_PRIEST_PENDING = 4
↓
César vuelve al sacerdote
↓
ZombieEE_Dialogue04
↓
sacerdote desaparece
↓
EE_FINAL_ASSAULT_ENABLED = 1
↓
RunSequence("ZombieEE_FinalAssault_Run")
↓
8 tandas × 25
↓
200 enemigos
↓
todos muertos
↓
recrear sacerdote
↓
EE_PRIEST_PENDING = 5
↓
César vuelve al sacerdote
↓
ZombieEE_DialogueFinal
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_FinalAssault_Run
→ AUTORUN = NO
```

No debe arrancar automáticamente al cargar el escenario.

Su lanzamiento normal procede de:

```text
ZombieEE_Dialogue04
```

---

# 3. Comentario canónico de comportamiento

La cabecera de la Sequence define:

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

# 4. Diferencia funcional frente al sistema normal Zombies

Las oleadas normales utilizan conjuntamente:

```text
ZombieWaves_Main
ZombieTactical_Main
ZombieRewards_Main
HW_H1..8
HW_R1..16
```

El asalto final usa:

```text
ZombieEE_FinalAssault_Run
EE_FinalAssault
```

como sistema completamente separado.

---

# 5. No utiliza `HW_H1`

Ninguna unidad del asalto final recibe:

```cpp
AddToGroup(
    "HW_H1"
);
```

---

# 6. No utiliza ningún frente táctico

Tampoco:

```text
HW_H2
HW_H3
...
HW_H8
```

---

# 7. No utiliza Groups de ronda

No se añaden a:

```text
HW_R1
...
HW_R15
HW_R16
```

---

# 8. Consecuencia para Rewards

Los 200 atacantes no forman parte de:

```text
ZombieRewards_Main
```

y su destrucción no genera recompensas normales de ronda.

---

# 9. No utiliza `ZombieTactical_Main`

La Sequence controla directamente su avance.

No existe:

```text
red de nodos
goalNode
targetNode
fase de asedio
fase de brecha
captura de ciudad
```

---

# 10. No recibe orden `capture`

La cabecera lo indica explícitamente.

El objetivo es:

```text
marchar y combatir hacia Roma
```

no ejecutar una fase especial de captura mediante esta Sequence.

---

# 11. No utiliza `Siege()`

No existe lógica:

```text
Gate
Catapult
Siege(...)
```

---

# 12. Variables principales

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

Además:

```cpp
str c1;
str c2;
str c3;
str c4;
str c5;
str cls;

int n1;
int n2;
int n3;
int n4;
int n5;

int enabled;
int started;
int completed;

int batch;
int level;

int t;
int n;
int i;
int idx;

int spawnX;
int spawnY;

int remaining;
int lastRemaining;

int priestX;
int priestY;
int priestOwner;
```

---

# 13. Group obligatorio de estado

La Sequence comienza con:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 14. Validación de `CapitalForum_P1`

Debe existir exactamente:

```text
1 objeto
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

# 15. Conversión del estado

Cuando es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 16. Objetivo militar

Se guarda:

```cpp
targetPos =
    state.pos;
```

Por tanto todos los atacantes marchan hacia:

```text
la posición de CapitalForum_P1
```

---

# 17. Doble función de `CapitalForum_P1`

Dentro de esta Sequence actúa como:

```text
objeto global de estado
+
destino físico del asalto
```

---

# 18. Lectura de `EE_FINAL_ASSAULT_ENABLED`

Se ejecuta:

```cpp
enabled =
    EnvReadInt(
        state,
        "EE_FINAL_ASSAULT_ENABLED"
    );
```

---

# 19. Lectura de `EE_FINAL_ASSAULT_STARTED`

También:

```cpp
started =
    EnvReadInt(
        state,
        "EE_FINAL_ASSAULT_STARTED"
    );
```

---

# 20. Lectura de `EE_FINAL_ASSAULT_COMPLETED`

También:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_FINAL_ASSAULT_COMPLETED"
    );
```

---

# 21. Validación `enabled`

Si:

```text
enabled != 1
```

la Sequence termina.

---

# 22. Validación `completed`

Si:

```text
completed == 1
```

también termina.

---

# 23. Validación `started`

Si:

```text
started == 1
```

también:

```cpp
return;
```

---

# 24. Estado válido de entrada

La ejecución legítima requiere:

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
```

---

# 25. Quién prepara esos valores

`ZombieEE_Dialogue04` escribe expresamente:

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
```

antes de lanzar esta Sequence.

---

# 26. Group de spawn

La Sequence utiliza:

```text
HordeSpawn_01
```

---

# 27. Validación de `HordeSpawn_01`

Se ejecuta:

```cpp
spawnList =
    Group("HordeSpawn_01")
    .GetObjList();

spawnList.ClearDead();
```

Debe cumplirse:

```text
spawnList.count == 1
```

---

# 28. Error de spawn

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR FINAL - HordeSpawn_01"
);

return;
```

---

# 29. Posición de aparición

Se guarda:

```cpp
spawnPos =
    spawnList[0]
    .pos;
```

---

# 30. Group exclusivo del asalto

Antes de iniciar se consulta:

```cpp
finalArmy =
    Group("EE_FinalAssault")
    .GetObjList();

finalArmy.ClearDead();
```

---

# 31. Protección frente a asalto residual

Si:

```text
finalArmy.count > 0
```

se muestra:

```text
ERROR FINAL - YA EXISTE UN ASALTO
```

y termina.

---

# 32. Motivo de esta validación

Aunque los flags indicaran por error:

```text
STARTED = 0
```

la Sequence no crea otros 200 atacantes si todavía existen unidades dentro de:

```text
EE_FinalAssault
```

---

# 33. Marcar inicio

Después de todas las validaciones:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_STARTED",
    1
);
```

---

# 34. El marcado ocurre antes del spawn

Esto evita que una segunda ejecución concurrente pueda comenzar otra traca mientras la primera está creando unidades.

---

# 35. Anuncio inicial

Se muestra:

```text
ALERTA - LA HORDA FINAL AVANZA CONTRA ROMA
```

mediante:

```text
ZombieEEObjective
```

---

# 36. Duración del anuncio inicial

Después:

```cpp
Sleep(
    3000
);
```

---

# 37. Número de tandas

La estructura principal es:

```cpp
for(
    batch = 1;
    batch <= 8;
    batch += 1
)
```

---

# 38. Tandas totales

```text
8
```

---

# 39. Unidades por tanda

Cada tanda define:

```text
5 clases
×
5 unidades
=
25 unidades
```

---

# 40. Total general

```text
8 × 25 = 200
```

---

# 41. Reinicio de composición en cada tanda

Al inicio de cada iteración:

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

# 42. Tanda 1

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

---

# 43. Tanda 2

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

# 44. Tanda 3

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

# 45. Tanda 4

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

# 46. Tanda 5

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

# 47. Tanda 6

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

# 48. Tanda 7

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

# 49. Tanda 8

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

# 50. Tabla de progresión

| Tanda | Nivel | Unidades |
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

# 51. Progresión de dificultad

Los niveles son:

```text
20
26
32
38
44
50
55
60
```

---

# 52. Selección interna de cada clase

Después de configurar la tanda:

```cpp
for(
    t = 1;
    t <= 5;
    t += 1
)
```

selecciona uno de:

```text
c1/n1
c2/n2
c3/n3
c4/n4
c5/n5
```

---

# 53. Variable `cls`

Se reinicia:

```cpp
cls = "";
```

para cada tipo.

---

# 54. Variable `n`

Se reinicia:

```cpp
n = 0;
```

y después recibe el número de unidades de esa clase.

---

# 55. Cada clase tiene cinco unidades

En la configuración actual:

```text
n1 = 5
n2 = 5
n3 = 5
n4 = 5
n5 = 5
```

en todas las tandas.

---

# 56. Índice de formación

Antes de crear las 25:

```cpp
idx = 0;
```

---

# 57. Formación X

Cada unidad usa:

```cpp
spawnX =
    spawnPos.x
    +
    (idx % 5) * 55
    -
    110;
```

---

# 58. Número de columnas

```text
5
```

---

# 59. Separación horizontal

```text
55
```

---

# 60. Offsets X

Las cinco columnas quedan en:

```text
-110
-55
0
+55
+110
```

respecto a `spawnPos.x`.

---

# 61. Formación Y

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

# 62. Número de filas

Con 25 unidades:

```text
5
```

---

# 63. Separación vertical

```text
55
```

---

# 64. Offsets Y

Las cinco filas quedan en:

```text
-110
-55
0
+55
+110
```

---

# 65. Formación completa

Cada tanda aparece en una cuadrícula:

```text
5 × 5
```

centrada aproximadamente sobre:

```text
HordeSpawn_01
```

---

# 66. Creación física

La llamada es:

```cpp
u =
    Place(
        cls,
        Point(
            spawnX,
            spawnY
        ),
        12
    )
    .AsUnit();
```

---

# 67. Propietario

Todos los atacantes pertenecen a:

```text
Player 12
```

---

# 68. Nivel

Después:

```cpp
u.SetLevel(
    level
);
```

---

# 69. Alimentación

Cada unidad recibe:

```cpp
u.SetFeeding(
    false
);
```

---

# 70. Exclusión de IA estratégica

También:

```cpp
u.SetNoAIFlag(
    true
);
```

---

# 71. Group exclusivo

Cada unidad recibe:

```cpp
u.AddToGroup(
    "EE_FinalAssault"
);
```

---

# 72. Orden inicial

Después:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 73. Objetivo

`targetPos` corresponde a:

```text
CapitalForum_P1.pos
```

---

# 74. Tipo de orden

La Sequence utiliza:

```text
advance
```

y no:

```text
move
capture
Siege
```

---

# 75. Motivo de `advance`

La intención es que la unidad:

```text
avance
combata si encuentra enemigos
y continúe hacia el Foro
```

---

# 76. Incremento del índice

Después de cada unidad:

```cpp
idx += 1;
```

---

# 77. Creación escalonada

También:

```cpp
Sleep(
    20
);
```

---

# 78. Tiempo programado por tanda

```text
25 × 20 ms
=
500 ms
```

más el coste de `Place()`.

---

# 79. Tiempo programado para las 200 unidades

```text
200 × 20 ms
=
4.000 ms
```

sin contar pausas entre tandas.

---

# 80. Refresco de estado tras cada tanda

Después de crear las 25:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 81. Validación entre tandas

Si:

```text
stateList.count != 1
```

la Sequence termina.

---

# 82. Renovación de `state`

Cuando es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 83. Marcar tanda desplegada

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_BATCH_DEPLOYED",
    batch
);
```

---

# 84. Significado de `EE_FINAL_BATCH_DEPLOYED`

Representa:

```text
última tanda que terminó completamente su despliegue
```

---

# 85. Valores durante el asalto

Puede pasar por:

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

# 86. Anuncio de tanda

Después:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "ASALTO FINAL - TANDA "
    + batch
    + "/8 - NIVEL "
    + level
);
```

---

# 87. Ejemplo de Tanda 1

```text
ASALTO FINAL - TANDA 1/8 - NIVEL 20
```

---

# 88. Ejemplo de Tanda 8

```text
ASALTO FINAL - TANDA 8/8 - NIVEL 60
```

---

# 89. Intervalo entre tandas

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

# 90. Tiempo exacto

```text
20 segundos
```

---

# 91. Número de pausas

Existen:

```text
7 pausas
```

porque después de Tanda 8 no se espera otros 20 segundos.

---

# 92. Tiempo total de pausas

```text
7 × 20 s
=
140 s
=
2 min 20 s
```

---

# 93. Las tandas no esperan a la anterior

La Sequence no exige:

```text
EE_FinalAssault.count == 0
```

entre tandas.

---

# 94. Consecuencia

Los ejércitos se solapan.

Puede haber supervivientes de:

```text
Tanda 1
Tanda 2
Tanda 3
...
```

mientras siguen llegando nuevas unidades.

---

# 95. Despliegue completo

Después de Tanda 8:

```text
EE_FINAL_BATCH_DEPLOYED = 8
```

---

# 96. Inicio del seguimiento final

Se inicializa:

```cpp
lastRemaining =
    -1;
```

---

# 97. Bucle principal de supervivientes

Después:

```cpp
while(1)
```

---

# 98. Refresco del ejército

Cada ciclo:

```cpp
finalArmy =
    Group("EE_FinalAssault")
    .GetObjList();

finalArmy.ClearDead();
```

---

# 99. Número actual de enemigos

Se obtiene:

```cpp
remaining =
    finalArmy.count;
```

---

# 100. Condición de victoria

Si:

```text
remaining == 0
```

el bucle termina.

---

# 101. No hay timeout

La Sequence espera indefinidamente mientras quede un atacante vivo.

---

# 102. Reactivación de unidades

Mientras quedan enemigos se recorre:

```cpp
for(
    i = 0;
    i < finalArmy.count;
    i += 1
)
```

---

# 103. Conversión individual

Cada objeto:

```cpp
u =
    finalArmy[i]
    .AsUnit();
```

---

# 104. Sólo se reactiva `idle`

La condición es:

```cpp
if(
    u.command
    ==
    "idle"
)
```

---

# 105. Orden de reactivación

Si está ociosa:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 106. No se pisan unidades que combaten

La fuente especifica:

```text
NO se pisan unidades que estén atacando.
```

---

# 107. Comportamiento deseado

```text
si está luchando
→ dejarla luchar

si termina y queda idle
→ volver a advance hacia Roma
```

---

# 108. Contador visible de supervivientes

Si:

```text
remaining != lastRemaining
```

se muestra:

```text
ASALTO FINAL - ENEMIGOS RESTANTES: X
```

---

# 109. Primera actualización

Como:

```text
lastRemaining = -1
```

la primera revisión siempre actualiza el anuncio.

---

# 110. Actualización sólo al cambiar el número

Si no muere nadie:

```text
no se reconstruye el anuncio
```

---

# 111. Actualizar `lastRemaining`

Después:

```cpp
lastRemaining =
    remaining;
```

---

# 112. Frecuencia del control

Mientras queden enemigos:

```cpp
Sleep(
    1000
);
```

---

# 113. Frecuencia aproximada

```text
1 vez por segundo
```

---

# 114. Fin de la horda

Cuando:

```text
EE_FinalAssault.count == 0
```

se muestra:

```text
LA HORDA FINAL HA SIDO ANIQUILADA
```

---

# 115. Duración del anuncio

Después:

```cpp
Sleep(
    2500
);
```

---

# 116. Refresco de `CapitalForum_P1`

Tras el combate:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 117. Validación final del estado

Si:

```text
stateList.count != 1
```

la Sequence termina.

---

# 118. Renovación de `state`

Después:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 119. Leer posición X del sacerdote

Se obtiene:

```cpp
priestX =
    EnvReadInt(
        state,
        "EE_PRIEST_HOME_X"
    );
```

---

# 120. Leer posición Y

También:

```cpp
priestY =
    EnvReadInt(
        state,
        "EE_PRIEST_HOME_Y"
    );
```

---

# 121. Leer propietario

También:

```cpp
priestOwner =
    EnvReadInt(
        state,
        "EE_PRIEST_OWNER"
    );
```

---

# 122. Origen de estos tres flags

Fueron escritos por:

```text
ZombieEE_Dialogue04
```

antes de borrar al sacerdote.

---

# 123. Fallback de propietario

Si:

```text
priestOwner <= 0
```

se fuerza:

```cpp
priestOwner =
    1;
```

---

# 124. Fallback de posición

Si:

```text
priestX <= 0
```

o:

```text
priestY <= 0
```

se usa:

```cpp
priestPos =
    targetPos;
```

---

# 125. Significado del fallback

Si no existe una posición válida guardada, el sacerdote reaparece en:

```text
CapitalForum_P1.pos
```

---

# 126. Posición normal

Si X/Y son válidos:

```cpp
priestPos =
    Point(
        priestX,
        priestY
    );
```

---

# 127. Buscar sacerdote existente

Antes de crear:

```cpp
priestList =
    Group("ZombieEE_Priest01")
    .GetObjList();

priestList.ClearDead();
```

---

# 128. Si ya existe

Cuando:

```text
priestList.count > 0
```

se utiliza:

```cpp
u_sacerdote =
    priestList[0]
    .AsUnit();
```

---

# 129. No se crea un duplicado

Si ya existe un sacerdote válido dentro del Group:

```text
no hay Place()
```

---

# 130. Si no existe sacerdote

La Sequence ejecuta:

```cpp
u_sacerdote =
    Place(
        "EPriest",
        priestPos,
        priestOwner
    )
    .AsUnit();
```

---

# 131. Clase recreada

La clase es exactamente:

```text
EPriest
```

---

# 132. Añadir al Group persistente

Después:

```cpp
u_sacerdote.AddToGroup(
    "ZombieEE_Priest01"
);
```

---

# 133. Protección de la unidad recreada

Después, exista previamente o sea nueva:

```cpp
u_sacerdote.SetNoAIFlag(
    true
);
```

---

# 134. Alimentación

También:

```cpp
u_sacerdote.SetFeeding(
    false
);
```

---

# 135. Salud

Se fuerza:

```cpp
u_sacerdote.SetHealth(
    1000
);
```

---

# 136. Interacción con PriestKeeper

Cuando el sacerdote ya vuelve a existir en:

```text
ZombieEE_Priest01
```

y se escriba:

```text
EE_PRIEST_HIDDEN = 0
```

`ZombieEE_PriestKeeper` puede volver a adquirirlo y continuar protegiéndolo.

---

# 137. Marcar sacerdote visible

La Sequence escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_HIDDEN",
    0
);
```

---

# 138. Marcar asalto completado

También:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_COMPLETED",
    1
);
```

---

# 139. Deshabilitar asalto

Después:

```cpp
EnvWriteInt(
    state,
    "EE_FINAL_ASSAULT_ENABLED",
    0
);
```

---

# 140. Estado de `STARTED`

La Sequence no vuelve a poner:

```text
EE_FINAL_ASSAULT_STARTED = 0
```

---

# 141. Estado final normal

Por tanto queda:

```text
ENABLED = 0
STARTED = 1
COMPLETED = 1
BATCH_DEPLOYED = 8
```

---

# 142. Preparar visita final al sacerdote

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    5
);
```

---

# 143. Significado de `pending = 5`

`ZombieEE_PriestInteraction_Main` interpreta:

```text
5
→ ZombieEE_DialogueFinal
```

---

# 144. Primer anuncio tras reaparición

Se muestra:

```text
LA ULTIMA HORDA HA CAIDO - EL SACERDOTE HA REGRESADO
```

---

# 145. Duración

Después:

```cpp
Sleep(
    5000
);
```

---

# 146. Segundo anuncio

Después se muestra:

```text
VE A HABLAR CON EL SACERDOTE EGIPCIO
```

---

# 147. No se oculta explícitamente

La Sequence no ejecuta `HideAnnouncement()` después de este segundo mensaje.

---

# 148. No lanza DialogueFinal directamente

La Sequence termina con:

```cpp
return;
```

---

# 149. Interacción final presencial

El flujo esperado es:

```text
sacerdote reaparece
↓
EE_PRIEST_PENDING = 5
↓
PriestInteraction detecta el estado
↓
César debe acercarse a ≤180
↓
RunSequence("ZombieEE_DialogueFinal")
```

---

# 150. Groups obligatorios

La Sequence necesita:

```text
CapitalForum_P1
HordeSpawn_01
```

---

# 151. Group dinámico principal

```text
EE_FinalAssault
```

Debe estar vacío antes del inicio.

---

# 152. Group del sacerdote

```text
ZombieEE_Priest01
```

puede estar vacío durante el asalto.

---

# 153. Groups que no utiliza

No consulta:

```text
HW_H1..8
HW_R1..16
EE_PortalGuardiansActive
EE_AnubisWave01
```

---

# 154. Areas necesarias

Ninguna.

---

# 155. Holders necesarios

Ninguno.

---

# 156. Conversations necesarias

Ninguna directamente.

---

# 157. Sequence anterior

Es lanzada por:

```text
ZombieEE_Dialogue04
```

---

# 158. Sequence posterior indirecta

Al terminar prepara:

```text
ZombieEE_DialogueFinal
```

a través de:

```text
ZombieEE_PriestInteraction_Main
```

---

# 159. Flags que lee

| Flag | Función |
|---|---|
| `EE_FINAL_ASSAULT_ENABLED` | Autoriza la ejecución |
| `EE_FINAL_ASSAULT_STARTED` | Evita doble inicio |
| `EE_FINAL_ASSAULT_COMPLETED` | Evita repetir fase |
| `EE_PRIEST_HOME_X` | Posición X para reaparición |
| `EE_PRIEST_HOME_Y` | Posición Y para reaparición |
| `EE_PRIEST_OWNER` | Propietario del sacerdote |

---

# 160. Flags que escribe

| Flag | Valor | Función |
|---|---:|---|
| `EE_FINAL_ASSAULT_STARTED` | 1 | Marca inicio |
| `EE_FINAL_BATCH_DEPLOYED` | 1..8 | Última tanda desplegada |
| `EE_PRIEST_HIDDEN` | 0 | Sacerdote vuelve a estar visible |
| `EE_FINAL_ASSAULT_COMPLETED` | 1 | Fase completada |
| `EE_FINAL_ASSAULT_ENABLED` | 0 | Desactiva nueva ejecución |
| `EE_PRIEST_PENDING` | 5 | Habilita diálogo final |

---

# 161. Anuncios utilizados

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

# 162. Tiempos principales

| Acción | Tiempo |
|---|---:|
| Aviso inicial | 3.000 ms |
| Sleep por atacante creado | 20 ms |
| Creación programada por tanda | ~500 ms |
| Intervalo entre tandas | 20.000 ms |
| Total de intervalos | 140.000 ms |
| Control final de supervivientes | 1.000 ms |
| Aviso de horda aniquilada | 2.500 ms |
| Aviso de regreso del sacerdote | 5.000 ms |

---

# 163. Tiempo mínimo aproximado de despliegue

Ignorando coste real de `Place()`:

```text
7 intervalos × 20 s
=
140 s

+
8 tandas × 0,5 s de Sleeps de creación
=
4 s

≈
144 s
```

Por tanto el despliegue completo dura al menos aproximadamente:

```text
2 min 24 s
```

desde el inicio de la creación, además del aviso inicial de 3 segundos.

---

# 164. El combate puede durar más

El tiempo total real depende de:

```text
duración de combates
pathfinding
supervivencia de las unidades
defensas del jugador
```

La Sequence no impone un tiempo máximo.

---

# 165. Preparación exacta en el editor

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
│       └── vacío mientras el sacerdote está oculto
│
└── Sequences
    ├── ZombieEE_Dialogue04
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

# 166. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `HordeSpawn_01` contiene exactamente un objeto.
3. `EE_FinalAssault` está vacío antes del lanzamiento.
4. `ZombieEE_Dialogue04` escribe `EE_FINAL_ASSAULT_ENABLED = 1`.
5. `ZombieEE_Dialogue04` reinicia `STARTED`, `COMPLETED` y `BATCH_DEPLOYED`.
6. `ZombieEE_Dialogue04` guarda `EE_PRIEST_HOME_X/Y/OWNER`.
7. `ZombieEE_Dialogue04` pone `EE_PRIEST_HIDDEN = 1`.
8. `ZombieEE_FinalAssault_Run` existe con ese nombre exacto.
9. `ZombieEE_FinalAssault_Run` tiene Autorun desactivado.
10. `ZombieEE_PriestKeeper` sigue activo.
11. `ZombieEE_PriestInteraction_Main` sigue activo.
12. `ZombieEE_DialogueFinal` existe.

---

# 167. Estado esperado antes de iniciar

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
EE_PRIEST_HIDDEN = 1
```

Además:

```text
EE_FinalAssault.count = 0
```

---

# 168. Estado durante el despliegue

Ejemplo tras completar Tanda 5:

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 1
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 5
EE_PRIEST_HIDDEN = 1
```

---

# 169. Estado tras desplegar Tanda 8

```text
EE_FINAL_BATCH_DEPLOYED = 8
```

pero:

```text
EE_FINAL_ASSAULT_COMPLETED
```

sigue en cero hasta que mueran todos los atacantes.

---

# 170. Estado final

Después de eliminar a todos:

```text
EE_FINAL_ASSAULT_ENABLED = 0
EE_FINAL_ASSAULT_STARTED = 1
EE_FINAL_ASSAULT_COMPLETED = 1
EE_FINAL_BATCH_DEPLOYED = 8

EE_PRIEST_HIDDEN = 0
EE_PRIEST_PENDING = 5
```

---

# 171. Reaparición segura del sacerdote

La lógica contempla dos casos:

```text
A)
ZombieEE_Priest01 ya contiene una unidad
→ reutilizarla

B)
ZombieEE_Priest01 está vacío
→ crear EPriest
→ AddToGroup
```

---

# 172. No exige exactamente un sacerdote al restaurar

La condición es:

```cpp
if(
    priestList.count > 0
)
```

No:

```text
count == 1
```

---

# 173. Consecuencia

Si por una inconsistencia existieran varios objetos en `ZombieEE_Priest01`, la Sequence utilizaría:

```text
priestList[0]
```

---

# 174. No limpia sacerdotes duplicados

No elimina unidades adicionales.

---

# 175. PriestKeeper después de la reaparición

Al quedar:

```text
EE_PRIEST_HIDDEN = 0
```

PriestKeeper volverá a consultar:

```text
ZombieEE_Priest01
```

y sólo aplicará su protección normal si el Group contiene exactamente una unidad.

---

# 176. Limitación táctica principal

El asalto final no incluye el sistema avanzado de entrada por murallas.

No tiene:

```text
detección de Gate
catapultas
Siege()
breachKnown
cruce de puerta
fase de captura
```

---

# 177. Comportamiento frente a obstáculos

Los atacantes reciben:

```text
advance → targetPos
```

y se reactivan únicamente si quedan:

```text
idle
```

---

# 178. Prioridad de combate

La Sequence evita sobrescribir órdenes mientras una unidad está luchando.

Eso cumple la intención:

```text
arrasar enemigos durante el trayecto
```

sin reemitir `advance` constantemente.

---

# 179. Diferencia frente a un `move`

La orden usada es:

```text
advance
```

precisamente para mantener un comportamiento combativo hacia el destino.

---

# 180. Diferencia entre `FinalAssault_Main` y `FinalAssault_Run`

En la compilación v2.0 ambas Sequences conservan una implementación del mismo asalto final.

La diferencia arquitectónica crítica es:

```text
ZombieEE_Dialogue04
→ lanza FinalAssault_Run
```

Por tanto:

```text
FinalAssault_Run
```

es el punto de entrada efectivo de la versión estable.

---

# 181. Motivo del cambio de entrada

`ZombieEE_Dialogue04` documenta que se utiliza una Sequence nueva:

```text
para evitar cualquier problema de registro
asociado al antiguo ZombieEE_FinalAssault_Main
```

---

# 182. Flujo exacto de despliegue

```text
RunSequence("ZombieEE_FinalAssault_Run")
↓
validar estado
↓
validar HordeSpawn_01
↓
validar EE_FinalAssault vacío
↓
EE_FINAL_ASSAULT_STARTED = 1
↓
aviso inicial
↓
Tanda 1
25 unidades nivel 20
↓
EE_FINAL_BATCH_DEPLOYED = 1
↓
20 s
↓
Tanda 2
25 unidades nivel 26
↓
...
↓
Tanda 8
25 unidades nivel 60
↓
EE_FINAL_BATCH_DEPLOYED = 8
```

---

# 183. Flujo exacto después del despliegue

```text
leer EE_FinalAssault
↓
ClearDead
↓
remaining = count
↓
si remaining > 0:
    para cada unidad:
        si command == idle:
            advance → CapitalForum_P1
    ↓
    si cambia remaining:
        actualizar contador
    ↓
    Sleep(1000)
    ↓
    repetir
↓
remaining == 0
```

---

# 184. Flujo exacto de cierre

```text
LA HORDA FINAL HA SIDO ANIQUILADA
↓
Sleep(2500)
↓
refrescar CapitalForum_P1
↓
leer:
EE_PRIEST_HOME_X
EE_PRIEST_HOME_Y
EE_PRIEST_OWNER
↓
buscar ZombieEE_Priest01
↓
si no existe:
    Place("EPriest", priestPos, priestOwner)
    AddToGroup("ZombieEE_Priest01")
↓
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
↓
EE_PRIEST_HIDDEN = 0
↓
EE_FINAL_ASSAULT_COMPLETED = 1
↓
EE_FINAL_ASSAULT_ENABLED = 0
↓
EE_PRIEST_PENDING = 5
↓
LA ULTIMA HORDA HA CAIDO
EL SACERDOTE HA REGRESADO
↓
Sleep(5000)
↓
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
return
```

---

# 185. Resumen funcional

`ZombieEE_FinalAssault_Run` es la Sequence activa que ejecuta el último combate del Easter Egg:

```text
Dialogue04
↓
RunSequence("ZombieEE_FinalAssault_Run")
↓
8 tandas
×
25 enemigos
=
200 atacantes
↓
niveles:
20
26
32
38
44
50
55
60
↓
Player 12
↓
Group exclusivo:
EE_FinalAssault
↓
advance → CapitalForum_P1
↓
20 s entre tandas
↓
después de la octava:
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
↓
jugador vuelve al sacerdote
↓
ZombieEE_DialogueFinal
```

La característica arquitectónica más importante de v2.0 es que esta Sequence, y no `ZombieEE_FinalAssault_Main`, es la que `ZombieEE_Dialogue04` lanza realmente para ejecutar el asalto final.

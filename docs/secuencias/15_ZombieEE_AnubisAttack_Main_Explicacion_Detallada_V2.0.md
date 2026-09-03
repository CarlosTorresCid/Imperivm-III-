# Secuencia 15 — `ZombieEE_AnubisAttack_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_AnubisAttack_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_AnubisAttack_Main` es la Sequence que transforma la finalización del sacrificio de cincuenta aldeanos en el siguiente desafío del Easter Egg:

```text
50 Guerreros de Anubis
nivel 40
Player 12
```

La Sequence:

1. valida que el sacrificio ya esté completado;
2. evita que el ataque pueda iniciarse dos veces;
3. valida `HordeSpawn_01`;
4. comprueba que no exista una oleada residual anterior;
5. marca el ataque como iniciado;
6. crea 50 `EAnubisWarrior`;
7. los registra en `EE_AnubisWave01`;
8. los manda hacia `CapitalForum_P1`;
9. mantiene activas únicamente las unidades que queden `idle`;
10. muestra el número de enemigos restantes;
11. espera hasta que mueran los 50;
12. marca la fase como completada;
13. activa la segunda visita presencial al sacerdote mediante:

```text
EE_PRIEST_PENDING = 2
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

La transición narrativa es:

```text
ZombieEE_Dialogue01
↓
EE_SACRIFICE_ENABLED = 1
↓
ZombieEE_Sacrifice_Main
↓
50 aldeanos sacrificados
↓
EE_SACRIFICE_COMPLETED = 1
↓
RunSequence("ZombieEE_AnubisAttack_Main")
↓
50 Guerreros de Anubis
↓
todos muertos
↓
EE_PRIEST_PENDING = 2
↓
segunda visita al sacerdote
↓
ZombieEE_Dialogue02
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_AnubisAttack_Main
→ AUTORUN = NO
```

No debe ejecutarse al cargar el mapa.

Su entrada normal procede de:

```text
ZombieEE_Sacrifice_Main
```

---

# 3. Condición previa principal

Antes de crear ninguna unidad exige:

```cpp
if(
    EnvReadInt(
        state,
        "EE_SACRIFICE_COMPLETED"
    )
    !=
    1
)
    return;
```

Por tanto el ataque no puede empezar legítimamente antes de completar las cincuenta almas.

---

# 4. Variables principales

La Sequence declara:

```cpp
ObjList q;
ObjList stateList;
ObjList anubis;

Building state;
Unit u;

point spawnPos;
point targetPos;

int started;
int completed;
int i;
int spawnX;
int spawnY;
int alive;
int lastAlive;
```

---

# 5. `stateList`

Se utiliza para recuperar:

```text
CapitalForum_P1
```

---

# 6. `state`

Es el `Building` global usado como almacenamiento persistente del Easter Egg.

---

# 7. `q`

Es una lista reutilizada para recuperar:

```text
HordeSpawn_01
```

---

# 8. `anubis`

Contiene las unidades vivas del Group:

```text
EE_AnubisWave01
```

---

# 9. `u`

Representa cada `EAnubisWarrior` individual durante la creación o el control.

---

# 10. `spawnPos`

Es la posición del único objeto dentro de:

```text
HordeSpawn_01
```

---

# 11. `targetPos`

Se asigna directamente a:

```cpp
state.pos;
```

Por tanto el objetivo inicial de los 50 Anubis es la posición de:

```text
CapitalForum_P1
```

---

# 12. `started`

Representa:

```text
EE_ANUBIS_ATTACK_STARTED
```

---

# 13. `completed`

Representa:

```text
EE_ANUBIS_ATTACK_COMPLETED
```

---

# 14. `alive`

Contiene el número actual de Guerreros de Anubis vivos.

---

# 15. `lastAlive`

Se utiliza para actualizar la interfaz únicamente cuando cambia el número de supervivientes.

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

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR ANUBIS - CapitalForum_P1"
);

return;
```

---

# 18. Obtención del estado global

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 19. El Foro también es el objetivo militar

Inmediatamente:

```cpp
targetPos =
    state.pos;
```

Por tanto el mismo Building cumple dos funciones:

```text
memoria global del Easter Egg
+
punto objetivo del ataque de Anubis
```

---

# 20. Protección frente a una fase ya completada

Se lee:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_ANUBIS_ATTACK_COMPLETED"
    );
```

Si:

```text
completed == 1
```

la Sequence termina.

---

# 21. Protección frente a doble inicio

Después:

```cpp
started =
    EnvReadInt(
        state,
        "EE_ANUBIS_ATTACK_STARTED"
    );
```

Si:

```text
started == 1
```

también:

```cpp
return;
```

---

# 22. Diferencia entre `started` y `completed`

```text
EE_ANUBIS_ATTACK_STARTED
→ impide crear una segunda oleada

EE_ANUBIS_ATTACK_COMPLETED
→ indica que la fase terminó definitivamente
```

---

# 23. Por qué existen ambos flags

Durante el tiempo en el que los 50 enemigos siguen vivos:

```text
STARTED = 1
COMPLETED = 0
```

Si otra ejecución accidental intentara arrancar la Sequence en ese periodo:

```text
return
```

antes de crear otros 50.

---

# 24. Validación del sacrificio

Después de comprobar los dos flags:

```cpp
if(
    EnvReadInt(
        state,
        "EE_SACRIFICE_COMPLETED"
    )
    !=
    1
)
    return;
```

---

# 25. Qué ocurre si se lanza demasiado pronto

Si el sacrificio todavía no ha terminado:

```text
no mensaje
no unidades
no cambios de flags
return
```

---

# 26. Group obligatorio de spawn

La Sequence consulta:

```cpp
q =
    Group("HordeSpawn_01")
    .GetObjList();

q.ClearDead();
```

---

# 27. Validación de `HordeSpawn_01`

Debe existir:

```text
exactamente 1 objeto
```

Si no:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR ANUBIS - HordeSpawn_01"
);

return;
```

---

# 28. Función del objeto de spawn

La Sequence sólo utiliza:

```cpp
spawnPos =
    q[0]
    .pos;
```

No exige una clase concreta.

---

# 29. Reutilización del spawn normal Zombies

La fase del Easter Egg utiliza el mismo punto:

```text
HordeSpawn_01
```

que forma parte de los ocho spawns de `ZombieWaves_Main`.

---

# 30. Group especial de seguimiento

Antes de crear nada se consulta:

```cpp
anubis =
    Group("EE_AnubisWave01")
    .GetObjList();

anubis.ClearDead();
```

---

# 31. Protección frente a una oleada residual

Si:

```cpp
anubis.count > 0
```

se muestra:

```text
ERROR ANUBIS - YA EXISTE UNA OLEADA
```

y se ejecuta:

```cpp
return;
```

---

# 32. Por qué se comprueba el Group además del flag `started`

Los flags protegen el estado lógico.

El Group protege además frente a una situación inconsistente donde:

```text
existen Guerreros de Anubis residuales
pero el flag STARTED no refleja correctamente ese estado
```

---

# 33. Orden de marcado del inicio

Sólo después de validar:

```text
CapitalForum_P1
sacrificio completado
HordeSpawn_01
EE_AnubisWave01 vacío
```

se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_ANUBIS_ATTACK_STARTED",
    1
);
```

---

# 34. Marcado antes de crear unidades

El flag de inicio se escribe antes de los 50 `Place()`.

Esto reduce el riesgo de duplicar una oleada si otra ejecución se inicia mientras la primera aún se está construyendo.

---

# 35. Número de enemigos

El bucle es:

```cpp
for(
    i = 0;
    i < 50;
    i += 1
)
```

Por tanto se intentan crear exactamente:

```text
50 Guerreros de Anubis
```

---

# 36. Clase utilizada

Cada unidad es:

```cpp
"EAnubisWarrior"
```

---

# 37. Propietario

La creación utiliza:

```cpp
Place(
    "EAnubisWarrior",
    ...,
    12
)
```

Por tanto:

```text
Player 12
```

es el propietario de toda la oleada.

---

# 38. Relación con el Player zombie

Es el mismo Player técnico utilizado por:

```text
ZombieWaves_Main
ZombieTactical_Main
```

---

# 39. Nivel

Cada unidad recibe:

```cpp
u.SetLevel(
    40
);
```

Por tanto los 50 Guerreros de Anubis son:

```text
nivel 40
```

---

# 40. Alimentación

Cada unidad recibe:

```cpp
u.SetFeeding(
    false
);
```

No dependen de comida.

---

# 41. Exclusión de IA estratégica

También:

```cpp
u.SetNoAIFlag(
    true
);
```

La IA estratégica normal no debe apropiarse de estas unidades.

---

# 42. Group de seguimiento

Cada Anubis se añade a:

```cpp
u.AddToGroup(
    "EE_AnubisWave01"
);
```

---

# 43. Función de `EE_AnubisWave01`

El Group sirve para:

```text
contar supervivientes
reactivar unidades idle
detectar final de fase
```

---

# 44. No se añaden a `HW_H1`

La Sequence no ejecuta:

```text
AddToGroup("HW_H1")
```

sobre estos 50 enemigos.

---

# 45. Consecuencia táctica

La oleada especial no depende de:

```text
ZombieTactical_Main
```

para avanzar.

`ZombieEE_AnubisAttack_Main` mantiene su propia lógica mínima de movimiento.

---

# 46. No se añaden a `HW_R16`

Tampoco forman parte de la contabilidad de las oleadas normales para Rewards.

Son un ejército narrativo independiente.

---

# 47. Formación de aparición

Las coordenadas son:

```cpp
spawnX =
    spawnPos.x
    -
    225
    +
    (i % 10)
    *
    50;

spawnY =
    spawnPos.y
    +
    180
    +
    (i / 10)
    *
    55;
```

---

# 48. Número de columnas

La expresión:

```text
i % 10
```

produce:

```text
10 columnas
```

---

# 49. Número de filas

Con 50 unidades:

```text
50 / 10
=
5 filas
```

---

# 50. Separación horizontal

Cada columna está separada:

```text
50 unidades
```

---

# 51. Separación vertical

Cada fila está separada:

```text
55 unidades
```

---

# 52. Primera coordenada X

Para:

```text
i = 0
```

la posición X es:

```text
spawnPos.x - 225
```

---

# 53. Última columna

Para:

```text
i % 10 = 9
```

la posición X es:

```text
spawnPos.x + 225
```

La formación queda centrada horizontalmente alrededor del spawn.

---

# 54. Primera fila Y

La primera fila aparece en:

```text
spawnPos.y + 180
```

---

# 55. Última fila Y

La quinta fila aparece en:

```text
spawnPos.y + 400
```

porque:

```text
180 + 4 × 55 = 400
```

---

# 56. Orden inicial de movimiento

Nada más crearse:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 57. Destino inicial

`targetPos` es:

```text
CapitalForum_P1.pos
```

Los 50 enemigos marchan hacia el Foro capital del Player 1.

---

# 58. No se busca otro Townhall

La Sequence no consulta:

```text
BaseTownhall
Players 1..8
objetivo más cercano
```

Su destino es fijo.

---

# 59. No utiliza red de nodos

La lógica territorial de:

```text
ZombieTactical_Main
```

no participa.

---

# 60. Creación escalonada

Después de cada unidad:

```cpp
Sleep(
    20
);
```

---

# 61. Tiempo programado de creación

Con 50 unidades:

```text
50 × 20 ms
=
1.000 ms
```

de espera programada acumulada, además del coste del motor.

---

# 62. Motivo documentado

El comentario interno indica:

```text
No crear cincuenta recursos
en una sola seccion atomica.
```

La creación se reparte ligeramente para mejorar estabilidad.

---

# 63. Conteo inicial tras el spawn

Después de terminar:

```cpp
anubis =
    Group("EE_AnubisWave01")
    .GetObjList();

anubis.ClearDead();

alive =
    anubis.count;
```

---

# 64. Primer anuncio

Se muestra:

```text
LAS ALMAS SE HAN CONVERTIDO EN GUERREROS DE ANUBIS
```

mediante:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    ...
);
```

---

# 65. Duración del primer anuncio

Después:

```cpp
Sleep(
    4000
);
```

El mensaje permanece aproximadamente:

```text
4 segundos
```

---

# 66. Segundo anuncio

Después se reemplaza por:

```text
DERROTA A LOS 50 GUERREROS DE ANUBIS
```

---

# 67. Inicio del control de combate

Se inicializa:

```cpp
lastAlive =
    -1;
```

Después:

```cpp
while(
    alive > 0
)
```

mantiene activa la fase.

---

# 68. Refresco del Group

En cada ciclo:

```cpp
anubis =
    Group("EE_AnubisWave01")
    .GetObjList();

anubis.ClearDead();

alive =
    anubis.count;
```

---

# 69. Condición de finalización

La fase termina únicamente cuando:

```text
alive == 0
```

---

# 70. No hay timeout

No existe un tiempo máximo.

Si queda un solo Guerrero de Anubis vivo durante muchos minutos:

```text
la Sequence sigue esperando
```

---

# 71. Control individual durante el ataque

Para cada superviviente:

```cpp
u =
    anubis[i]
    .AsUnit();
```

---

# 72. Regla de reactivación

El código comprueba:

```cpp
if(
    u.command
    ==
    "idle"
)
```

---

# 73. Orden sólo a unidades ociosas

Sólo una unidad `idle` recibe:

```cpp
u.SetCommand(
    "advance",
    targetPos
);
```

---

# 74. No se pisa `attack`

El comentario canónico dice:

```text
No interrumpir attack/engage:
solo reactivar unidades ociosas.
```

Por tanto una unidad que está luchando no recibe constantemente `advance`.

---

# 75. No se pisa `engage`

La misma regla preserva combates gestionados por el motor.

---

# 76. Filosofía táctica

La orden permanente es:

```text
si está haciendo algo útil
→ dejarla

si queda idle
→ volver a empujarla hacia CapitalForum_P1
```

---

# 77. No hay búsqueda local de enemigos

La Sequence no ejecuta:

```text
EnemyObjs
ObjsInRange
```

para decidir contra quién luchar.

El combate se deja al comportamiento normal de la unidad al avanzar.

---

# 78. No hay asedio especial

No utiliza:

```text
Siege()
Gate
Catapult
```

---

# 79. Consecuencia ante murallas

Los Guerreros de Anubis sólo reciben:

```text
advance → CapitalForum_P1
```

cuando están `idle`.

No disponen de la máquina táctica completa de `ZombieTactical_Main`.

---

# 80. Contador visible de supervivientes

Si:

```cpp
alive != lastAlive
```

se muestra:

```text
GUERREROS DE ANUBIS RESTANTES: X/50
```

---

# 81. Cuándo cambia la UI

El mensaje se actualiza sólo cuando cambia:

```text
alive
```

No se reconstruye cada segundo si no ha muerto nadie.

---

# 82. Primera actualización del contador

Como:

```text
lastAlive = -1
```

el primer ciclo siempre muestra el número actual, normalmente:

```text
50/50
```

si todos siguen vivos.

---

# 83. Actualización tras cada muerte

Ejemplo:

```text
50/50
↓
mueren 3
↓
47/50
↓
sin nuevas muertes
→ no cambia el anuncio
↓
muere 1
↓
46/50
```

---

# 84. Actualización de `lastAlive`

Después de mostrar:

```cpp
lastAlive =
    alive;
```

---

# 85. Frecuencia del bucle

Si quedan enemigos:

```cpp
Sleep(
    1000
);
```

Por tanto:

```text
Group
órdenes idle
contador
```

se revisan aproximadamente una vez por segundo.

---

# 86. Detección del último enemigo muerto

Cuando `ClearDead()` deja:

```text
alive = 0
```

ya no se ejecuta el `Sleep(1000)` final.

La Sequence pasa directamente al bloque de finalización.

---

# 87. Refresco del estado tras una espera larga

Después de matar a los 50 no reutiliza ciegamente el handle de `state`.

Vuelve a ejecutar:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 88. Segunda validación de `CapitalForum_P1`

Si:

```text
stateList.count != 1
```

la Sequence termina:

```cpp
return;
```

---

# 89. Renovación de `state`

Cuando sigue siendo válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 90. Marcar el ataque como completado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_ANUBIS_ATTACK_COMPLETED",
    1
);
```

---

# 91. El flag `started` no vuelve a cero

La Sequence no ejecuta:

```text
EE_ANUBIS_ATTACK_STARTED = 0
```

El estado final normal queda:

```text
STARTED = 1
COMPLETED = 1
```

---

# 92. Consecuencia

Cualquier ejecución posterior queda bloqueada tanto por:

```text
COMPLETED
```

como por:

```text
STARTED
```

---

# 93. Anuncio de victoria

Después se muestra:

```text
LOS GUERREROS DE ANUBIS HAN SIDO DERROTADOS
```

---

# 94. Tiempo de victoria visible

La Sequence espera:

```cpp
Sleep(
    3000
);
```

Por tanto el mensaje permanece aproximadamente:

```text
3 segundos
```

---

# 95. Segundo refresco del estado

Después de esos 3 segundos vuelve a recuperar:

```text
CapitalForum_P1
```

---

# 96. Motivo

Durante un `Sleep(3000)` se evita reutilizar innecesariamente una referencia antigua antes de escribir el siguiente flag narrativo.

---

# 97. Tercera validación de `CapitalForum_P1`

Si el Group ya no resuelve exactamente a uno:

```cpp
return;
```

---

# 98. Activación de la segunda visita al sacerdote

Finalmente:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    2
);
```

---

# 99. Significado de `pending = 2`

`ZombieEE_PriestInteraction_Main` interpreta:

```text
2
→ ZombieEE_Dialogue02
```

---

# 100. No ejecuta Dialogue02 directamente

La Sequence no hace:

```cpp
RunSequence(
    "ZombieEE_Dialogue02"
);
```

---

# 101. Motivo

El jugador debe:

```text
terminar el combate
↓
volver físicamente al sacerdote
↓
acercar a César a ≤180
```

antes de que empiece la conversación.

---

# 102. Interacción con `ZombieEE_PriestInteraction_Main`

Después de:

```text
EE_PRIEST_PENDING = 2
```

el gestor:

```text
muestra:
VE A HABLAR CON EL SACERDOTE EGIPCIO
↓
recordatorio cada 15 s
↓
espera César <=180
↓
borra pending
↓
RunSequence("ZombieEE_Dialogue02")
```

---

# 103. No escribe `EE_DIALOGUE02_COMPLETED`

Ese flag pertenece a:

```text
ZombieEE_Dialogue02
```

---

# 104. No activa portales directamente

La fase de los portales se inicia posteriormente.

`ZombieEE_AnubisAttack_Main` sólo autoriza la segunda conversación.

---

# 105. No modifica `EE_SACRIFICE_ENABLED`

El sacrificio ya ha sido completado.

Esta Sequence no necesita desactivar ese flag.

---

# 106. No modifica `EE_SOULS_DELIVERED`

El contador de almas permanece como lo dejó `ZombieEE_Sacrifice_Main`.

---

# 107. No modifica Waves

No detiene:

```text
ZombieWaves_Main
```

Las oleadas normales continúan durante este combate.

---

# 108. No modifica Rewards

No utiliza:

```text
ZR_MASK
ZR_REWARDED
ZR_ENDLESS_*
```

---

# 109. No mezcla estos 50 enemigos con Rewards

Los Guerreros de Anubis no forman parte de:

```text
HW_R1..15
HW_R16
```

Por tanto su muerte no dispara la recompensa militar normal de una ronda Zombies.

---

# 110. No mezcla estos 50 enemigos con Tactical

Tampoco se añaden a:

```text
HW_H1..8
```

La Sequence gestiona su avance directamente.

---

# 111. Independencia del ejército especial

El sistema puede verse así:

```text
oleadas Zombies normales
→ Waves + Tactical + Rewards

oleada de 50 Anubis
→ AnubisAttack_Main
→ Group EE_AnubisWave01
→ objetivo fijo
→ trigger narrativo
```

---

# 112. Groups necesarios

## Obligatorio

```text
CapitalForum_P1
HordeSpawn_01
```

## Group dinámico de seguimiento

```text
EE_AnubisWave01
```

---

# 113. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 114. `HordeSpawn_01`

Debe contener:

```text
exactamente 1 objeto
```

---

# 115. `EE_AnubisWave01`

No necesita estar poblado manualmente.

Debe estar vacío antes de iniciar la fase.

La propia Sequence lo llena mediante:

```cpp
AddToGroup(
    "EE_AnubisWave01"
);
```

---

# 116. Groups que no necesita

No consulta directamente:

```text
ZombieEE_Caesar
ZombieEE_Priest01
ZombieEE_SacrificePyramids
HW_H1..8
HW_R1..16
```

---

# 117. Areas necesarias

Ninguna.

---

# 118. Holders necesarios

Ninguno.

---

# 119. Conversations necesarias

Ninguna directamente.

---

# 120. Sequence anterior

La transición normal llega desde:

```text
ZombieEE_Sacrifice_Main
```

---

# 121. Sequence posterior indirecta

El resultado:

```text
EE_PRIEST_PENDING = 2
```

acabará permitiendo:

```text
ZombieEE_Dialogue02
```

a través de:

```text
ZombieEE_PriestInteraction_Main
```

---

# 122. Flags leídos

| Flag | Función |
|---|---|
| `EE_ANUBIS_ATTACK_COMPLETED` | Evita repetir una fase ya terminada |
| `EE_ANUBIS_ATTACK_STARTED` | Evita crear un segundo ejército |
| `EE_SACRIFICE_COMPLETED` | Condición necesaria de entrada |

---

# 123. Flags escritos

| Flag | Valor | Función |
|---|---:|---|
| `EE_ANUBIS_ATTACK_STARTED` | 1 | Marca que ya se inició la oleada |
| `EE_ANUBIS_ATTACK_COMPLETED` | 1 | Marca que los 50 fueron derrotados |
| `EE_PRIEST_PENDING` | 2 | Habilita segunda visita al sacerdote |

---

# 124. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR ANUBIS - CapitalForum_P1` |
| `ZombieHelp` | `ERROR ANUBIS - HordeSpawn_01` |
| `ZombieHelp` | `ERROR ANUBIS - YA EXISTE UNA OLEADA` |
| `ZombieEEObjective` | `LAS ALMAS SE HAN CONVERTIDO EN GUERREROS DE ANUBIS` |
| `ZombieEEObjective` | `DERROTA A LOS 50 GUERREROS DE ANUBIS` |
| `ZombieEEObjective` | `GUERREROS DE ANUBIS RESTANTES: X/50` |
| `ZombieEEObjective` | `LOS GUERREROS DE ANUBIS HAN SIDO DERROTADOS` |

---

# 125. Tiempos internos

| Acción | Tiempo |
|---|---:|
| `Sleep()` por unidad creada | 20 ms |
| Creación programada de 50 | ~1.000 ms |
| Primer anuncio narrativo | 4.000 ms |
| Control del combate | 1.000 ms |
| Aviso de victoria | 3.000 ms |

---

# 126. Configuración de las 50 unidades

```text
Clase:
EAnubisWarrior

Cantidad:
50

Player:
12

Nivel:
40

Feeding:
false

NoAIFlag:
true

Group:
EE_AnubisWave01

Orden inicial:
advance → CapitalForum_P1.pos
```

---

# 127. Formación completa

```text
10 columnas
×
5 filas

separación X:
50

separación Y:
55

X:
spawnPos.x -225 .. +225

Y:
spawnPos.y +180 .. +400
```

---

# 128. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── HordeSpawn_01
│   │   └── exactamente 1 objeto
│   │
│   └── EE_AnubisWave01
│       └── vacío al inicio
│
└── Sequences
    ├── ZombieEE_Sacrifice_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_AnubisAttack_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    └── ZombieEE_Dialogue02
        └── AUTORUN = NO
```

---

# 129. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `HordeSpawn_01` contiene exactamente un objeto.
3. `EE_AnubisWave01` no contiene unidades al iniciar la fase.
4. `EE_SACRIFICE_COMPLETED` llega a 1 después de las 50 almas.
5. `ZombieEE_Sacrifice_Main` ejecuta `ZombieEE_AnubisAttack_Main`.
6. Player 12 está reservado para los enemigos Zombies.
7. `ZombieEE_PriestInteraction_Main` sigue activo.
8. `ZombieEE_Dialogue02` existe con el nombre correcto.

---

# 130. Flujo de inicio

```text
RunSequence("ZombieEE_AnubisAttack_Main")
↓
CapitalForum_P1 válido
↓
¿COMPLETED == 1?
Sí → return
↓
¿STARTED == 1?
Sí → return
↓
¿SACRIFICE_COMPLETED != 1?
Sí → return
↓
HordeSpawn_01 válido
↓
EE_AnubisWave01 vacío
↓
EE_ANUBIS_ATTACK_STARTED = 1
```

---

# 131. Flujo de creación

```text
for i = 0..49
↓
calcular posición 10×5
↓
Place("EAnubisWarrior", ..., 12)
↓
SetLevel(40)
↓
SetFeeding(false)
↓
SetNoAIFlag(true)
↓
AddToGroup("EE_AnubisWave01")
↓
advance → CapitalForum_P1
↓
Sleep(20)
```

---

# 132. Flujo de combate

```text
leer EE_AnubisWave01
↓
ClearDead
↓
alive = count
↓
para cada superviviente:
    si command == idle
        advance → CapitalForum_P1
↓
si cambia alive:
    actualizar:
    GUERREROS DE ANUBIS RESTANTES X/50
↓
si alive > 0:
    Sleep(1000)
↓
repetir
```

---

# 133. Flujo de finalización

```text
alive == 0
↓
refrescar CapitalForum_P1
↓
EE_ANUBIS_ATTACK_COMPLETED = 1
↓
LOS GUERREROS DE ANUBIS HAN SIDO DERROTADOS
↓
Sleep(3000)
↓
refrescar CapitalForum_P1 otra vez
↓
EE_PRIEST_PENDING = 2
↓
return
```

---

# 134. Resumen funcional

`ZombieEE_AnubisAttack_Main` implementa el segundo gran desafío del Easter Egg:

```text
50 almas sacrificadas
↓
validar que no exista otra oleada especial
↓
marcar ataque como iniciado
↓
crear 50 EAnubisWarrior
nivel 40
Player 12
↓
formación 10×5 en HordeSpawn_01
↓
mandarlos hacia CapitalForum_P1
↓
si alguno queda idle:
volver a darle advance
↓
mostrar supervivientes
↓
esperar hasta count == 0
↓
EE_ANUBIS_ATTACK_COMPLETED = 1
↓
EE_PRIEST_PENDING = 2
↓
jugador debe volver al sacerdote
```

La Sequence mantiene este ejército completamente separado de las oleadas Zombies normales: no utiliza `HW_H1..8`, no utiliza `HW_R1..16` y no depende de `ZombieTactical_Main` ni de `ZombieRewards_Main`.

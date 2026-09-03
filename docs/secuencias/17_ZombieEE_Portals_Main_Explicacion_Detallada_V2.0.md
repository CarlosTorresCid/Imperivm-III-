# Secuencia 17 — `ZombieEE_Portals_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Portals_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Portals_Main` controla la fase de los ocho portales del Easter Egg.

La mecánica actual es:

```text
HordeSpawn_01..08
también funcionan como centros físicos de los 8 portales

↓
cualquier RPriest de Player 1
puede activar un portal abierto
si entra a ≤220

↓
aparecen:
10 EAnubisWarrior
10 EHorusWarrior

↓
todos nivel 20
Player 12

↓
hay que matar a los 20 guardianes

↓
el portal queda cerrado

↓
Player 1 recibe:
20 RPraetorian
15 RHastatus
15 RArcher
todos nivel 25

↓
cerrar 4 portales cualesquiera
es suficiente

↓
al registrar el cuarto cierre:
se detienen inmediatamente
las nuevas hordas normales

↓
EE_PRIEST_PENDING = 3
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

y es iniciada desde:

```text
ZombieEE_Dialogue02
```

mediante:

```cpp
RunSequence(
    "ZombieEE_Portals_Main"
);
```

---

# 1. Papel dentro del Easter Egg

El flujo completo de entrada es:

```text
50 Guerreros de Anubis derrotados
↓
EE_PRIEST_PENDING = 2
↓
César vuelve al sacerdote
↓
ZombieEE_Dialogue02
↓
EE_PORTALS_ENABLED = 1
↓
reinicio de los 8 estados
↓
RunSequence("ZombieEE_Portals_Main")
↓
cerrar 4 de 8 portales
↓
EE_PRIEST_PENDING = 3
↓
César vuelve al sacerdote
↓
ZombieEE_Dialogue03
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_Portals_Main
→ AUTORUN = NO
```

No debe empezar al cargar el mapa.

La fase sólo debe arrancar después de:

```text
ZombieEE_Dialogue02
```

---

# 3. Variables principales

La Sequence declara:

```cpp
ObjList stateList;
ObjList portalList;
ObjList priests;
ObjList guardians;

Building state;

Unit priest;
Unit u;

point portalPos;
point portalPos1;
point portalPos2;
point portalPos3;
point portalPos4;
point portalPos5;
point portalPos6;
point portalPos7;
point portalPos8;

str rewardClass;

IntArray portalClosed;

int enabled;
int completed;

int portal;
int triggeredPortal;

int i;
int alive;
int lastAlive;

int spawnX;
int spawnY;

int closedCount;

int rewardType;
int rewardCount;
int rewardGranted;

int PORTAL_TRIGGER_RADIUS;
int REWARD_LEVEL;
```

---

# 4. Configuración actual

La Sequence define:

```cpp
PORTAL_TRIGGER_RADIUS = 220;
REWARD_LEVEL = 25;
```

---

# 5. Radio de activación

Un sacerdote romano puede activar un portal si:

```text
DistTo(portalPos) <= 220
```

---

# 6. Nivel de recompensas

Todas las tropas entregadas al cerrar un portal reciben:

```text
nivel 25
```

---

# 7. Group obligatorio de estado

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

# 8. Error de `CapitalForum_P1`

Si no existe exactamente un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR PORTALS - CapitalForum_P1"
);

return;
```

---

# 9. Obtención del estado global

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 10. Comprobar que la fase está habilitada

Se lee:

```cpp
enabled =
    EnvReadInt(
        state,
        "EE_PORTALS_ENABLED"
    );
```

---

# 11. Comprobar que no esté ya completada

También:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_PORTALS_COMPLETED"
    );
```

---

# 12. Salida si la fase no está activa

Si:

```text
EE_PORTALS_ENABLED != 1
```

la Sequence ejecuta:

```cpp
return;
```

---

# 13. Salida si la fase ya terminó

Si:

```text
EE_PORTALS_COMPLETED == 1
```

también:

```cpp
return;
```

---

# 14. Marcar el sistema como iniciado

Cuando ambas condiciones son correctas:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_STARTED",
    1
);
```

---

# 15. Los ocho `HordeSpawn` son los ocho portales

La fase reutiliza:

```text
HordeSpawn_01
HordeSpawn_02
HordeSpawn_03
HordeSpawn_04
HordeSpawn_05
HordeSpawn_06
HordeSpawn_07
HordeSpawn_08
```

como posiciones físicas de los portales.

---

# 16. No existen Groups `Portal_01..08`

No hace falta crear:

```text
Portal_01
Portal_02
...
Portal_08
```

La implementación canónica usa directamente los Groups de spawn ya existentes.

---

# 17. Validación de `HordeSpawn_01`

La Sequence obtiene:

```cpp
portalList =
    Group("HordeSpawn_01")
    .GetObjList();

portalList.ClearDead();
```

Debe haber:

```text
exactamente 1 objeto
```

---

# 18. Error del Portal 1

Si no:

```text
ERROR PORTAL 1 - HordeSpawn_01
```

y:

```cpp
return;
```

---

# 19. Posición del Portal 1

Se guarda:

```cpp
portalPos1 =
    portalList[0]
    .pos;
```

---

# 20. Validación de los otros siete portales

Se repite exactamente el mismo patrón para:

```text
HordeSpawn_02
HordeSpawn_03
HordeSpawn_04
HordeSpawn_05
HordeSpawn_06
HordeSpawn_07
HordeSpawn_08
```

---

# 21. Mensajes de error individuales

Los errores posibles son:

```text
ERROR PORTAL 1 - HordeSpawn_01
ERROR PORTAL 2 - HordeSpawn_02
ERROR PORTAL 3 - HordeSpawn_03
ERROR PORTAL 4 - HordeSpawn_04
ERROR PORTAL 5 - HordeSpawn_05
ERROR PORTAL 6 - HordeSpawn_06
ERROR PORTAL 7 - HordeSpawn_07
ERROR PORTAL 8 - HordeSpawn_08
```

---

# 22. Posiciones memorizadas

Al terminar la validación quedan guardadas:

```text
portalPos1
portalPos2
portalPos3
portalPos4
portalPos5
portalPos6
portalPos7
portalPos8
```

---

# 23. No vuelve a consultar los ocho Groups durante cada detección

Las posiciones se guardan una sola vez al inicio.

Esto evita realizar repetidamente:

```text
8 Group lookups
+
8 ClearDead
```

por sacerdote y por ciclo.

---

# 24. Reconstrucción del contador al arrancar

La Sequence no confía ciegamente en:

```text
EE_PORTALS_CLOSED
```

---

# 25. Estado individual de cada portal

Para:

```cpp
for(
    portal = 1;
    portal <= 8;
    portal += 1
)
```

lee:

```cpp
portalClosed[portal] =
    EnvReadInt(
        state,
        "EE_PORTAL_CLOSED" + portal
    );
```

---

# 26. Reconstrucción de `closedCount`

Se inicia:

```cpp
closedCount = 0;
```

y por cada:

```text
portalClosed[portal] == 1
```

se incrementa:

```cpp
closedCount += 1;
```

---

# 27. Sincronización del contador global

Después:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_CLOSED",
    closedCount
);
```

---

# 28. Motivo de esta reconstrucción

El comentario canónico indica:

```text
Reconstruir el contador desde las ocho marcas individuales
evita que una carga interrumpida deje
EE_PORTALS_CLOSED desincronizado.
```

---

# 29. Condición principal de la fase

La Sequence mantiene:

```cpp
while(
    closedCount < 4
)
```

Por tanto la fase termina al registrar:

```text
4 portales cerrados
```

---

# 30. No hay que cerrar los ocho

El requisito real es:

```text
4 de 8
```

---

# 31. Orden libre

No existe una secuencia obligatoria:

```text
1 → 2 → 3 → 4
```

Se puede cerrar cualquier combinación.

---

# 32. Ejemplos válidos

Son válidos:

```text
1,2,3,4
```

o:

```text
8,2,6,5
```

o:

```text
7,1,4,3
```

---

# 33. Inicio de cada ciclo

Al principio:

```cpp
triggeredPortal = 0;
```

Esto significa:

```text
todavía no se ha detectado un portal activado
en este ciclo
```

---

# 34. Sacerdotes válidos

La Sequence busca:

```cpp
ClassPlayerObjs(
    "RPriest",
    1
)
.GetObjList();
```

---

# 35. Sólo sacerdotes romanos de Player 1

La clase debe ser:

```text
RPriest
```

y el propietario:

```text
Player 1
```

---

# 36. El sacerdote egipcio no activa portales

`ZombieEE_Priest01` no participa en la detección.

---

# 37. Sacerdotes de otros Players no sirven

Aunque exista otro `RPriest` de Player 2–8:

```text
no aparece en la consulta
```

---

# 38. El jugador puede producir sacerdotes normalmente

La Sequence no crea ningún `RPriest`.

El comentario canónico establece:

```text
La Sequence NO crea sacerdotes.
El jugador puede crear RPriest cuando quiera.
```

---

# 39. Limpiar sacerdotes muertos

Después de la consulta:

```cpp
priests.ClearDead();
```

---

# 40. Revisión sacerdote por sacerdote

Se ejecuta:

```cpp
for(
    i = 0;
    i < priests.count;
    i += 1
)
```

---

# 41. Conversión a Unit

Cada objeto:

```cpp
priest =
    priests[i]
    .AsUnit();
```

---

# 42. Prioridad interna de portales

Para cada sacerdote se comprueban los portales en orden:

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

# 43. Portal 1

Se activa si:

```cpp
triggeredPortal == 0
&&
portalClosed[1] != 1
&&
priest.DistTo(portalPos1)
<=
PORTAL_TRIGGER_RADIUS
```

---

# 44. Portal 2

Sólo se evalúa si todavía:

```text
triggeredPortal == 0
```

y Portal 2 sigue abierto.

---

# 45. Mismo patrón hasta Portal 8

Todos usan:

```text
portalClosed[N] != 1
```

y:

```text
DistTo(portalPosN) <= 220
```

---

# 46. Sólo se activa un portal por ciclo

En cuanto se detecta uno:

```text
triggeredPortal != 0
```

las comprobaciones posteriores quedan bloqueadas.

---

# 47. Salir del bucle de sacerdotes

Cuando se encuentra un portal:

```cpp
if(
    triggeredPortal != 0
)
    i = priests.count;
```

Esto finaliza el `for`.

---

# 48. Consecuencia con varios sacerdotes simultáneos

Aunque haya sacerdotes junto a varios portales al mismo tiempo:

```text
se procesa un único portal
```

---

# 49. El siguiente portal espera

Mientras el portal actual esté en combate:

```text
no se procesa otro
```

---

# 50. Ningún sacerdote en rango

Si:

```text
triggeredPortal == 0
```

se ejecuta:

```cpp
Sleep(
    1000
);

continue;
```

---

# 51. Frecuencia de detección cuando no ocurre nada

La proximidad se revisa aproximadamente:

```text
1 vez por segundo
```

---

# 52. No existe anuncio permanente en este bucle

La Sequence no muestra continuamente:

```text
PORTALES 0/4
PORTALES 1/4
```

---

# 53. Portal activado

Cuando:

```text
triggeredPortal = N
```

también:

```text
portalPos
```

queda apuntando a la posición correspondiente.

---

# 54. Group global de guardianes activos

Antes de crear enemigos:

```cpp
guardians =
    Group("EE_PortalGuardiansActive")
    .GetObjList();

guardians.ClearDead();
```

---

# 55. Debe estar vacío

Si:

```text
guardians.count > 0
```

la Sequence considera que existe una oleada de guardianes todavía activa.

---

# 56. Error por guardianes residuales

Se muestra:

```text
ERROR PORTAL - YA EXISTEN GUARDIANES ACTIVOS: X
```

y:

```cpp
return;
```

---

# 57. Un solo Group de guardianes para todos los portales

No existen:

```text
EE_PortalGuardians1
EE_PortalGuardians2
...
```

Todos los guardianes del portal activo usan:

```text
EE_PortalGuardiansActive
```

---

# 58. Consecuencia

La arquitectura está diseñada para:

```text
1 portal en combate cada vez
```

---

# 59. Crear 10 Guerreros de Anubis

El primer bloque es:

```cpp
for(
    i = 0;
    i < 10;
    i += 1
)
```

---

# 60. Clase Anubis

Se crea:

```text
EAnubisWarrior
```

---

# 61. Player

Los guardianes pertenecen a:

```text
Player 12
```

---

# 62. Nivel

Cada Anubis recibe:

```cpp
u.SetLevel(
    20
);
```

---

# 63. Alimentación

Cada uno:

```cpp
u.SetFeeding(
    false
);
```

---

# 64. Exclusión de IA estratégica

También:

```cpp
u.SetNoAIFlag(
    true
);
```

---

# 65. Group de guardianes

Cada uno:

```cpp
u.AddToGroup(
    "EE_PortalGuardiansActive"
);
```

---

# 66. Formación de Anubis

La posición X es:

```cpp
portalPos.x
-
225
+
(i % 5)
*
90
```

---

# 67. Formación horizontal

Hay:

```text
5 columnas
```

con separación:

```text
90
```

---

# 68. Formación vertical de Anubis

La Y es:

```cpp
portalPos.y
-
180
+
(i / 5)
*
90
```

---

# 69. Filas de Anubis

Con 10 unidades:

```text
2 filas
```

en:

```text
portalPos.y -180
portalPos.y -90
```

---

# 70. Creación escalonada

Después de cada Anubis:

```cpp
Sleep(
    20
);
```

---

# 71. Tiempo programado de los 10 Anubis

```text
10 × 20 ms
=
200 ms
```

más coste de creación.

---

# 72. Crear 10 Guerreros de Horus

Después se ejecuta otro:

```cpp
for(
    i = 0;
    i < 10;
    i += 1
)
```

---

# 73. Clase Horus

Se crea:

```text
EHorusWarrior
```

---

# 74. Player y nivel de Horus

También:

```text
Player 12
Nivel 20
```

---

# 75. Propiedades de Horus

Cada unidad recibe:

```cpp
SetLevel(20);
SetFeeding(false);
SetNoAIFlag(true);
AddToGroup("EE_PortalGuardiansActive");
```

---

# 76. Formación X de Horus

Usa exactamente la misma estructura:

```text
5 columnas
separación 90
```

---

# 77. Formación Y de Horus

La base es:

```cpp
portalPos.y
+
90
```

y la segunda fila:

```text
portalPos.y +180
```

---

# 78. Distribución total

La formación queda aproximadamente:

```text
ANUBIS
fila 1 → Y -180
fila 2 → Y -90

PORTAL
Y = 0

HORUS
fila 1 → Y +90
fila 2 → Y +180
```

---

# 79. Número total de guardianes

Cada portal genera:

```text
10 Anubis
+
10 Horus
=
20 guardianes
```

---

# 80. Tiempo programado de creación total

```text
20 × 20 ms
=
400 ms
```

más coste del motor.

---

# 81. Los guardianes no reciben orden explícita de ataque

La Sequence no ejecuta:

```text
advance
attack
engage
```

sobre ellos.

---

# 82. Consecuencia táctica

Su comportamiento depende de:

```text
comportamiento natural de la unidad
proximidad del sacerdote
enemigos cercanos
motor del juego
```

---

# 83. No se añaden a `HW_H1..8`

Los guardianes son independientes de:

```text
ZombieTactical_Main
```

---

# 84. No se añaden a `HW_R1..16`

Tampoco forman parte de:

```text
ZombieRewards_Main
```

---

# 85. Comprobar spawn completo

Después de crear 20:

```cpp
guardians =
    Group("EE_PortalGuardiansActive")
    .GetObjList();

guardians.ClearDead();

alive =
    guardians.count;
```

---

# 86. Esperar su muerte

Se inicializa:

```cpp
lastAlive =
    -1;
```

y entra:

```cpp
while(
    alive > 0
)
```

---

# 87. Refresco del Group

Cada ciclo:

```cpp
guardians =
    Group("EE_PortalGuardiansActive")
    .GetObjList();

guardians.ClearDead();

alive =
    guardians.count;
```

---

# 88. `lastAlive`

Si:

```cpp
alive != lastAlive
```

se actualiza:

```cpp
lastAlive =
    alive;
```

---

# 89. No existe HUD de restantes

Aunque `lastAlive` se actualiza, la versión canónica no ejecuta ningún:

```text
ShowAnnouncement
```

con el número de guardianes vivos.

---

# 90. Frecuencia durante combate

Mientras:

```text
alive > 0
```

se ejecuta:

```cpp
Sleep(
    1000
);
```

---

# 91. Condición de cierre

El portal no se considera cerrado hasta que:

```text
EE_PortalGuardiansActive.count == 0
```

---

# 92. No hay timeout

Si queda un guardián vivo:

```text
la fase espera indefinidamente
```

---

# 93. Refresco del estado después del combate

Después de matar los 20:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 94. Validación

Si:

```text
stateList.count != 1
```

se ejecuta:

```cpp
return;
```

---

# 95. Renovación de `state`

Cuando es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 96. Marcar el portal concreto

El código tiene ocho ramas explícitas.

Ejemplo Portal 1:

```cpp
EnvWriteInt(
    state,
    "EE_PORTAL_CLOSED1",
    1
);
```

---

# 97. Portal 2

```cpp
EE_PORTAL_CLOSED2 = 1
```

---

# 98. Hasta Portal 8

Cada índice usa su propia clave:

```text
EE_PORTAL_CLOSED1
...
EE_PORTAL_CLOSED8
```

---

# 99. Actualización en memoria

Además:

```cpp
portalClosed[
    triggeredPortal
]
=
1;
```

---

# 100. Incrementar contador

Después:

```cpp
closedCount += 1;
```

---

# 101. Actualizar contador persistente

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_CLOSED",
    closedCount
);
```

---

# 102. Momento exacto de detener nuevas hordas

Inmediatamente después del incremento:

```cpp
if(
    closedCount >= 4
)
```

---

# 103. Flag de parada

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_ZOMBIE_SPAWNS_DISABLED",
    1
);
```

---

# 104. Orden crítico

El comentario canónico indica:

```text
Cortar las nuevas apariciones
en el mismo instante en que se registra
el cuarto cierre,
antes incluso de crear sus refuerzos.
```

---

# 105. Consecuencia

El cuarto portal produce este orden:

```text
guardianes mueren
↓
marcar portal cerrado
↓
closedCount = 4
↓
EE_ZOMBIE_SPAWNS_DISABLED = 1
↓
después entregar recompensa
```

---

# 106. `ZombieWaves_Main` detecta el flag

Waves consulta periódicamente:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

y cuando vale 1 deja de crear nuevas rondas.

---

# 107. Zombies ya existentes

La parada no elimina:

```text
zombies que ya estaban vivos
```

`ZombieTactical_Main` puede seguir controlándolos.

---

# 108. Recompensa por portal

Cada cierre recompensa a Player 1 con:

```text
20 RPraetorian
15 RHastatus
15 RArcher
```

---

# 109. Total por portal

```text
20 + 15 + 15
=
50 unidades
```

---

# 110. Nivel de recompensa

Todas:

```text
nivel 25
```

---

# 111. Propietario de la recompensa

Todas se crean para:

```text
Player 1
```

---

# 112. Group de recompensas

Cada unidad se añade a:

```text
EE_PortalRewards
```

---

# 113. Función de `EE_PortalRewards`

Permite identificar globalmente las tropas entregadas por esta mecánica.

---

# 114. Protección contra recompensa duplicada

Antes de crear tropas se lee:

```cpp
rewardGranted =
    EnvReadInt(
        state,
        "EE_PORTAL_REWARD_GRANTED"
        +
        triggeredPortal
    );
```

---

# 115. Si ya fue entregada

Si:

```text
rewardGranted == 1
```

no se crea ningún refuerzo adicional.

---

# 116. Marcar antes de crear

Si todavía no se entregó:

```cpp
EnvWriteInt(
    state,
    "EE_PORTAL_REWARD_GRANTED"
    +
    triggeredPortal,
    1
);
```

se ejecuta **antes** del primer `Place()`.

---

# 117. Motivo

El comentario indica:

```text
La marca se escribe antes de crear las unidades
para impedir que una segunda ejecucion
entregue dos ejercitos por el mismo portal.
```

---

# 118. Riesgo asociado al marcado previo

Si la creación se interrumpe después de marcar:

```text
no existe reintento automático
```

porque el portal ya queda registrado como recompensado.

Es una decisión deliberada para priorizar la protección frente a duplicados.

---

# 119. Tres tipos de recompensa

El bucle es:

```cpp
for(
    rewardType = 1;
    rewardType <= 3;
    rewardType += 1
)
```

---

# 120. Tipo 1

```text
RPraetorian
cantidad 20
```

---

# 121. Tipo 2

```text
RHastatus
cantidad 15
```

---

# 122. Tipo 3

```text
RArcher
cantidad 15
```

---

# 123. Las tropas aparecen en el Foro

Antes de cada unidad:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 124. Refresco antes de cada `Place()`

Si:

```text
stateList.count != 1
```

la Sequence termina.

---

# 125. Motivo del refresco

El comentario canónico indica:

```text
Place() y Sleep() ceden el turno al motor.
Volver a obtener el Foro antes de cada unidad
evita conservar un Building obsoleto
y garantiza que ForceAddUnit usa el Foro actual.
```

---

# 126. Creación física

Cada unidad se crea mediante:

```cpp
u =
    Place(
        rewardClass,
        state.pos,
        1
    )
    .AsUnit();
```

---

# 127. Nivel

Después:

```cpp
u.SetLevel(
    REWARD_LEVEL
);
```

con:

```text
REWARD_LEVEL = 25
```

---

# 128. Alimentación

Las tropas reciben:

```cpp
u.SetFeeding(
    true
);
```

---

# 129. IA normal

También:

```cpp
u.SetNoAIFlag(
    false
);
```

---

# 130. Añadir al Group

Después:

```cpp
u.AddToGroup(
    "EE_PortalRewards"
);
```

---

# 131. Inserción dentro del Foro

La línea clave es:

```cpp
state
    .settlement
    .ForceAddUnit(
        u
    );
```

---

# 132. Recompensa dentro del Foro

Las tropas no quedan desplegadas alrededor.

La arquitectura actual las inserta:

```text
DENTRO de CapitalForum_P1
```

---

# 133. Motivo del cambio

El comentario canónico dice:

```text
Esto evita calcular casillas exteriores bloqueadas
y que alguna unidad quede atrapada.
```

---

# 134. No hay formación exterior

La Sequence no calcula:

```text
filas
columnas
offsets
```

para las recompensas.

---

# 135. Creación escalonada de recompensas

Después de cada unidad:

```cpp
Sleep(
    20
);
```

---

# 136. Tiempo programado por recompensa completa

50 unidades:

```text
50 × 20 ms
=
1.000 ms
```

más coste de motor.

---

# 137. Recompensa máxima durante la fase

Si se cierran exactamente cuatro portales:

```text
4 × 50
=
200 unidades
```

entregadas en total.

---

# 138. Composición total de cuatro cierres

```text
80 RPraetorian
60 RHastatus
60 RArcher
=
200 unidades
```

---

# 139. Todas nivel 25

Los 200 refuerzos potenciales mantienen:

```text
nivel 25
```

---

# 140. Pausa después de cada portal

Después de gestionar la recompensa:

```cpp
Sleep(
    2500
);
```

---

# 141. Consecuencia de esa pausa

La Sequence espera:

```text
2,5 segundos
```

antes de volver a buscar otro sacerdote junto a otro portal.

---

# 142. No hay activaciones simultáneas

La combinación de:

```text
un solo triggeredPortal
esperar muerte de sus guardianes
entregar recompensa
Sleep(2500)
```

hace que los portales se procesen estrictamente de uno en uno.

---

# 143. Cuarto portal cerrado

Cuando:

```text
closedCount == 4
```

el `while` termina.

---

# 144. Refresco final del estado

Se vuelve a obtener:

```text
CapitalForum_P1
```

---

# 145. Validación final

Si no existe exactamente uno:

```cpp
return;
```

---

# 146. Marcar fase completada

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_COMPLETED",
    1
);
```

---

# 147. Deshabilitar sistema de portales

También:

```cpp
EnvWriteInt(
    state,
    "EE_PORTALS_ENABLED",
    0
);
```

---

# 148. Confirmar parada de nuevas hordas

Se vuelve a escribir:

```cpp
EnvWriteInt(
    state,
    "EE_ZOMBIE_SPAWNS_DISABLED",
    1
);
```

---

# 149. Preparar tercera visita al sacerdote

Finalmente:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    3
);
```

---

# 150. Significado de `pending = 3`

`ZombieEE_PriestInteraction_Main` interpreta:

```text
3
→ ZombieEE_Dialogue03
```

---

# 151. No ejecuta Dialogue03 directamente

No contiene:

```cpp
RunSequence(
    "ZombieEE_Dialogue03"
);
```

---

# 152. Motivo

Después de cerrar los cuatro portales:

```text
César debe volver físicamente al sacerdote
```

---

# 153. Anuncio final

La Sequence muestra:

```text
CUATRO PORTALES SELLADOS - NO APARECERAN MAS HORDAS
```

---

# 154. ID del anuncio

Utiliza:

```text
ZombieEEObjective
```

---

# 155. Duración del anuncio final

Después:

```cpp
Sleep(
    4000
);
```

---

# 156. Final de Sequence

Después:

```cpp
return;
```

---

# 157. No espera a que Waves confirme su parada

La Sequence no espera:

```text
ZWAVES_STOPPED_BY_PORTALS == 1
```

---

# 158. Coordinación con Waves

La arquitectura es:

```text
Portals escribe:
EE_ZOMBIE_SPAWNS_DISABLED = 1
↓
ZombieWaves_Main lo detecta
↓
deja de crear nuevas hordas
↓
Waves escribe:
ZWAVES_STOPPED_BY_PORTALS = 1
```

---

# 159. Los zombies supervivientes permanecen

Ni Portals ni Waves borran automáticamente:

```text
HW_H1..8
```

---

# 160. Tactical sigue funcionando

Los zombies ya existentes pueden:

```text
seguir marchando
seguir atacando
seguir capturando
```

hasta morir.

---

# 161. No se modifica `EE_PORTAL_PHASE_FINISHED`

En esta Sequence canónica no se escribe:

```text
EE_PORTAL_PHASE_FINISHED = 1
```

aunque Dialogue02 lo haya reiniciado a cero.

---

# 162. Estado real de final de fase

La condición canónica que representa el cierre es:

```text
EE_PORTALS_COMPLETED = 1
```

junto a:

```text
EE_PORTALS_ENABLED = 0
EE_ZOMBIE_SPAWNS_DISABLED = 1
EE_PRIEST_PENDING = 3
```

---

# 163. No se destruyen físicamente los marcadores

La Sequence no elimina:

```text
HordeSpawn_01..08
```

Los portales se consideran cerrados mediante flags.

---

# 164. Un portal cerrado deja de activarse

La detección exige:

```cpp
portalClosed[N] != 1
```

---

# 165. Los otros cuatro portales pueden quedar abiertos

Al cerrar el cuarto:

```text
el while termina
```

No es necesario:

```text
cerrar los otros cuatro
```

---

# 166. Sus flags permanecen en cero

Ejemplo:

```text
cerrados:
1,3,6,8

estado final:
EE_PORTAL_CLOSED1 = 1
EE_PORTAL_CLOSED2 = 0
EE_PORTAL_CLOSED3 = 1
EE_PORTAL_CLOSED4 = 0
EE_PORTAL_CLOSED5 = 0
EE_PORTAL_CLOSED6 = 1
EE_PORTAL_CLOSED7 = 0
EE_PORTAL_CLOSED8 = 1
```

---

# 167. No se entregan recompensas de portales no cerrados

Sólo los cuatro realmente completados cambian:

```text
EE_PORTAL_REWARD_GRANTEDN = 1
```

---

# 168. Group obligatorio de guardianes

`EE_PortalGuardiansActive` no necesita contenido manual.

Debe estar vacío al empezar cada enfrentamiento.

---

# 169. Group de recompensas

`EE_PortalRewards` tampoco necesita estar poblado manualmente.

La Sequence añade allí cada unidad premiada.

---

# 170. Groups necesarios

## Obligatorios manualmente

```text
CapitalForum_P1

HordeSpawn_01
HordeSpawn_02
HordeSpawn_03
HordeSpawn_04
HordeSpawn_05
HordeSpawn_06
HordeSpawn_07
HordeSpawn_08
```

---

# 171. Groups dinámicos utilizados

```text
EE_PortalGuardiansActive
EE_PortalRewards
```

---

# 172. Groups que no necesita

No consulta directamente:

```text
ZombieEE_Caesar
ZombieEE_Priest01
EE_AnubisWave01
HW_H1..8
HW_R1..16
```

---

# 173. César no participa directamente

La presencia de César no es necesaria para activar un portal.

La activación depende exclusivamente de:

```text
RPriest de Player 1
```

---

# 174. Sacerdote egipcio no participa directamente

`ZombieEE_Priest01` no interviene durante el cierre físico de los portales.

---

# 175. Areas necesarias

Ninguna.

---

# 176. Holders necesarios

Ninguno.

---

# 177. Conversations necesarias

Ninguna directamente.

---

# 178. Sequence anterior

Es lanzada por:

```text
ZombieEE_Dialogue02
```

---

# 179. Sequence posterior indirecta

Al terminar prepara:

```text
EE_PRIEST_PENDING = 3
```

para que:

```text
ZombieEE_PriestInteraction_Main
```

termine lanzando:

```text
ZombieEE_Dialogue03
```

---

# 180. Flags de entrada

| Flag | Valor esperado | Función |
|---|---:|---|
| `EE_PORTALS_ENABLED` | 1 | Autoriza la fase |
| `EE_PORTALS_COMPLETED` | 0 | Indica que aún no terminó |

---

# 181. Flag de inicio

| Flag | Valor |
|---|---:|
| `EE_PORTALS_STARTED` | 1 |

---

# 182. Flags individuales de cierre

```text
EE_PORTAL_CLOSED1..8
```

Cada uno representa:

```text
0 = abierto
1 = cerrado
```

---

# 183. Flag contador global

```text
EE_PORTALS_CLOSED
```

se reconstruye desde los ocho flags individuales al arrancar.

---

# 184. Flags individuales de recompensa

```text
EE_PORTAL_REWARD_GRANTED1..8
```

evitan duplicados.

---

# 185. Flags finales

Al completar cuatro:

```text
EE_PORTALS_COMPLETED = 1
EE_PORTALS_ENABLED = 0
EE_ZOMBIE_SPAWNS_DISABLED = 1
EE_PRIEST_PENDING = 3
```

---

# 186. Configuración de cada portal

```text
Trigger:
RPriest de Player 1

Radio:
220

Guardianes:
10 EAnubisWarrior
10 EHorusWarrior

Player:
12

Nivel:
20

Feeding:
false

NoAIFlag:
true

Group:
EE_PortalGuardiansActive
```

---

# 187. Configuración de recompensa

```text
20 RPraetorian
15 RHastatus
15 RArcher

Player:
1

Nivel:
25

Feeding:
true

NoAIFlag:
false

Group:
EE_PortalRewards

Destino:
interior de CapitalForum_P1
mediante ForceAddUnit
```

---

# 188. Tiempos principales

| Acción | Tiempo |
|---|---:|
| Detección sin portal activo | 1.000 ms |
| Sleep por guardián creado | 20 ms |
| 20 guardianes | ~400 ms programados |
| Comprobación de guardianes vivos | 1.000 ms |
| Sleep por unidad de recompensa | 20 ms |
| 50 unidades recompensa | ~1.000 ms programados |
| Pausa después de cada portal | 2.500 ms |
| Anuncio final | 4.000 ms |

---

# 189. Orden exacto de cierre de un portal

```text
detectar RPriest a <=220
↓
seleccionar portal abierto
↓
verificar EE_PortalGuardiansActive vacío
↓
crear 10 Anubis
↓
crear 10 Horus
↓
esperar hasta guardianes == 0
↓
refrescar CapitalForum_P1
↓
EE_PORTAL_CLOSEDN = 1
↓
portalClosed[N] = 1
↓
closedCount += 1
↓
EE_PORTALS_CLOSED = closedCount
↓
si closedCount >=4:
    EE_ZOMBIE_SPAWNS_DISABLED = 1
↓
comprobar EE_PORTAL_REWARD_GRANTEDN
↓
si no estaba:
    marcar = 1
    ↓
    crear 20 RPraetorian
    crear 15 RHastatus
    crear 15 RArcher
    ↓
    ForceAddUnit en CapitalForum_P1
↓
Sleep(2500)
↓
buscar siguiente portal
```

---

# 190. Flujo completo de la fase

```text
ZombieEE_Dialogue02
↓
EE_PORTALS_ENABLED = 1
↓
RunSequence("ZombieEE_Portals_Main")
↓
validar CapitalForum_P1
↓
validar HordeSpawn_01..08
↓
reconstruir closedCount
↓
while closedCount < 4
    ↓
    buscar RPriest de Player 1
    ↓
    ¿alguno <=220 de portal abierto?
        No
        ↓
        Sleep(1000)
        ↓
        repetir

        Sí
        ↓
        comprobar que no hay guardianes previos
        ↓
        crear 10 Anubis + 10 Horus
        ↓
        esperar muerte de los 20
        ↓
        marcar portal cerrado
        ↓
        closedCount += 1
        ↓
        si es el cuarto:
            detener nuevos spawns Zombies
        ↓
        entregar:
        20 Praetorian
        15 Hastatus
        15 Archer
        ↓
        insertarlos dentro de CapitalForum_P1
        ↓
        Sleep(2500)
↓
closedCount == 4
↓
EE_PORTALS_COMPLETED = 1
EE_PORTALS_ENABLED = 0
EE_ZOMBIE_SPAWNS_DISABLED = 1
EE_PRIEST_PENDING = 3
↓
CUATRO PORTALES SELLADOS
NO APARECERAN MAS HORDAS
↓
Sleep(4000)
↓
return
```

---

# 191. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── HordeSpawn_01
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_02
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_03
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_04
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_05
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_06
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_07
│   │   └── exactamente 1 objeto
│   ├── HordeSpawn_08
│   │   └── exactamente 1 objeto
│   ├── EE_PortalGuardiansActive
│   │   └── vacío inicialmente
│   └── EE_PortalRewards
│       └── vacío inicialmente
│
└── Sequences
    ├── ZombieEE_Dialogue02
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Portals_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Dialogue03
    │   └── AUTORUN = NO
    │
    └── ZombieWaves_Main
        └── AUTORUN = NO
```

---

# 192. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. Los ocho `HordeSpawn_XX` contienen exactamente un objeto.
3. Existen `RPriest` producibles para Player 1.
4. `EE_PORTALS_ENABLED` llega a 1 desde Dialogue02.
5. Los ocho `EE_PORTAL_CLOSEDN` se reinician a 0.
6. Los ocho `EE_PORTAL_REWARD_GRANTEDN` se reinician a 0.
7. `EE_PortalGuardiansActive` está vacío al empezar.
8. `EE_PortalRewards` puede recibir unidades dinámicamente.
9. Player 12 está reservado para enemigos Zombies.
10. `ZombieWaves_Main` sigue comprobando `EE_ZOMBIE_SPAWNS_DISABLED`.
11. `ZombieEE_PriestInteraction_Main` sigue activo.
12. `ZombieEE_Dialogue03` existe.

---

# 193. Diferencia respecto a versiones anteriores

La versión v2.0 documentada tiene estas características estables:

```text
8 portales
4 necesarios
cualquier orden
RPriest de Player 1
radio 220
20 guardianes por portal
nivel 20
50 unidades de recompensa por portal
nivel 25
recompensas dentro del Foro
Waves se corta exactamente al cuarto cierre
sin mensajes visibles de debug
```

---

# 194. Resumen funcional

`ZombieEE_Portals_Main` v2.0 puede resumirse así:

```text
activar fase
↓
usar HordeSpawn_01..08 como portales
↓
buscar RPriest de Player 1
↓
si entra a <=220 de un portal abierto:
    crear 10 Anubis
    crear 10 Horus
    nivel 20
↓
esperar a que mueran los 20
↓
marcar ese portal cerrado
↓
entregar dentro del Foro:
20 RPraetorian
15 RHastatus
15 RArcher
nivel 25
↓
repetir en cualquier orden
↓
al cerrar el cuarto:
    EE_ZOMBIE_SPAWNS_DISABLED = 1
↓
terminar la fase
↓
EE_PORTALS_COMPLETED = 1
EE_PORTALS_ENABLED = 0
EE_PRIEST_PENDING = 3
↓
César debe volver al sacerdote
```

La Sequence mantiene una única batalla de portal activa cada vez, reconstruye el contador de cierres desde flags individuales para mejorar la persistencia y entrega cada recompensa dentro de `CapitalForum_P1` para evitar unidades atrapadas alrededor del Foro.

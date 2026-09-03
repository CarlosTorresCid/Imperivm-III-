# Secuencia 19 — `ZombieEE_Amulet_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Amulet_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Amulet_Main` controla la fase posterior a `ZombieEE_Dialogue03`: el ataque al campamento cartaginés y la derrota del caudillo `CHero1`.

La mecánica v2.0 ya **no utiliza Gem of Power como objeto físico de inventario**. La condición real de victoria es únicamente:

```text
matar al caudillo cartaginés CHero1
```

El resto del ejército cartaginés puede seguir vivo.

Cuando muere el caudillo:

```text
EE_AMULET_DELIVERED = 1
EE_AMULET_HUNT_ENABLED = 0
EE_AMULET_PHASE_COMPLETED = 1
EE_PRIEST_PENDING = 4
```

`ZombieEE_PriestInteraction_Main` queda entonces preparado para lanzar `ZombieEE_Dialogue04` cuando César vuelva a acercarse al sacerdote egipcio.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo canónico es:

```text
4 portales sellados
↓
ZombieEE_Portals_Main
↓
EE_PRIEST_PENDING = 3
↓
César vuelve al sacerdote
↓
ZombieEE_Dialogue03
↓
EE_AMULET_HUNT_ENABLED = 1
↓
RunSequence("ZombieEE_Amulet_Main")
↓
aparece campamento cartaginés
↓
aparece CHero1 + ejército
↓
matar únicamente a CHero1
↓
EE_AMULET_PHASE_COMPLETED = 1
↓
EE_PRIEST_PENDING = 4
↓
César vuelve al sacerdote
↓
ZombieEE_Dialogue04
```

---

# 2. Nota importante sobre el comentario histórico del Source

La cabecera de `ZombieEE_Amulet_Main` todavía contiene:

```text
Tras cerrar los 8 portales
```

pero la arquitectura v2.0 de `ZombieEE_Portals_Main` completa la fase al cerrar:

```text
4 de los 8 portales
```

Por tanto, funcionalmente esta Sequence comienza después de completar los **cuatro portales necesarios**, no los ocho.

---

# 3. Autorun

La configuración correcta es:

```text
ZombieEE_Amulet_Main
→ AUTORUN = NO
```

Su lanzamiento normal procede de:

```cpp
RunSequence(
    "ZombieEE_Amulet_Main"
);
```

desde `ZombieEE_Dialogue03`.

---

# 4. Variables principales

La Sequence declara:

```cpp
ObjList stateList;
ObjList campList;
ObjList carrier;
ObjList army;

Building state;

Unit u;
Unit u_hero;

point p;

int i;
int idx;
int alive;
int lastAlive;
int heroDefeated;
int started;

int CARTAGO_PLAYER;
int HERO_LEVEL;
int ARMY_LEVEL;
int SP;
```

---

# 5. Configuración exacta

```cpp
CARTAGO_PLAYER = 2;
HERO_LEVEL = 25;
ARMY_LEVEL = 20;
SP = 80;
```

Por tanto:

```text
Cartago = Player 2
Caudillo = nivel 25
Resto del ejército = nivel 20
Separación base de formación = 80
```

---

# 6. Group obligatorio de estado

La Sequence obtiene:

```text
CapitalForum_P1
```

mediante:

```cpp
stateList =
    Group(
        "CapitalForum_P1"
    )
    .GetObjList();

stateList.ClearDead();
```

Debe contener exactamente:

```text
1 Building
```

---

# 7. Error de `CapitalForum_P1`

Si:

```text
stateList.count != 1
```

se muestra:

```text
ERROR AMULETO - CapitalForum_P1
```

También se ejecuta un mensaje interno `pr(...)`:

```text
EE AMULET ERROR - CapitalForum_P1 count=X
```

Después:

```cpp
return;
```

---

# 8. Obtención del estado global

Cuando el Group es válido:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 9. Protección frente a una fase ya completada

La primera protección es:

```cpp
if(
    EnvReadInt(
        state,
        "EE_AMULET_PHASE_COMPLETED"
    )
    ==
    1
)
{
    return;
}
```

Si la fase ya terminó, no se crea un segundo campamento.

---

# 10. Espera de `EE_AMULET_HUNT_ENABLED`

La Sequence no presupone que el flag esté activo inmediatamente.

Utiliza:

```cpp
while(
    EnvReadInt(
        state,
        "EE_AMULET_HUNT_ENABLED"
    )
    !=
    1
)
```

---

# 11. Frecuencia de espera

Dentro de ese bucle:

```cpp
Sleep(1000);
```

Por tanto comprueba aproximadamente:

```text
1 vez por segundo
```

---

# 12. Refresco de `CapitalForum_P1` durante la espera

Después de cada segundo:

```cpp
stateList = Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count != 1)
    return;

state = stateList[0].AsBuilding();
```

No conserva indefinidamente un `Building` obsoleto mientras espera la habilitación.

---

# 13. Quién habilita la fase

`ZombieEE_Dialogue03` escribe:

```text
EE_AMULET_HUNT_ENABLED = 1
```

y después ejecuta:

```text
ZombieEE_Amulet_Main
```

---

# 14. Group del punto del campamento

La Sequence necesita:

```text
ZombieEE_AmuletCampPoint
```

mediante:

```cpp
campList =
    Group(
        "ZombieEE_AmuletCampPoint"
    )
    .GetObjList();

campList.ClearDead();
```

---

# 15. Contenido requerido

Debe contener exactamente:

```text
1 objeto marcador
```

No se exige una clase concreta; sólo se usa su posición.

---

# 16. Error del punto del campamento

Si:

```text
campList.count != 1
```

se muestra:

```text
ERROR AMULETO - ZombieEE_AmuletCampPoint
```

También se escribe por `pr(...)`:

```text
EE AMULET ERROR - CampPoint count=X
```

Después:

```cpp
return;
```

---

# 17. Posición del campamento

La coordenada base es:

```cpp
p =
    campList[0]
    .pos;
```

Toda la formación cartaginesa se calcula relativamente a `p`.

---

# 18. Protección frente a doble ejecución

Se lee:

```cpp
started =
    EnvReadInt(
        state,
        "EE_AMULET_HUNT_STARTED"
    );
```

Si:

```text
started == 1
```

la Sequence termina.

---

# 19. Comprobación física de ejército residual

Además de `started`, se consultan:

```text
ZombieEE_AmuletCarrier
ZombieEE_AmuletArmy
```

---

# 20. Limpieza de referencias muertas

```cpp
carrier = Group("ZombieEE_AmuletCarrier").GetObjList();
carrier.ClearDead();

army = Group("ZombieEE_AmuletArmy").GetObjList();
army.ClearDead();
```

---

# 21. Error por ejército ya existente

Si:

```text
carrier.count > 0
```

o:

```text
army.count > 0
```

se muestra:

```text
ERROR AMULETO - EJERCITO YA EXISTENTE
```

y se ejecuta:

```cpp
return;
```

---

# 22. Marcar inicio antes del spawn

Después de todas las validaciones:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_HUNT_STARTED",
    1
);
```

Esto evita crear dos campamentos superpuestos.

---

# 23. Nueva semántica de `EE_AMULET_DELIVERED`

La versión actual mantiene este flag por compatibilidad con `ZombieEE_Dialogue04`.

Ya no significa literalmente:

```text
Gem of Power entregada como objeto
```

Ahora significa:

```text
0 = caudillo todavía vivo
1 = caudillo muerto / objetivo recuperado
```

---

# 24. Inicialización del estado del objetivo

Antes de crear al caudillo:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_DELIVERED",
    0
);

EnvWriteInt(
    state,
    "EE_AMULET_PHASE_COMPLETED",
    0
);
```

---

# 25. Crear al caudillo cartaginés

Se utiliza:

```cpp
u_hero =
    Place(
        "CHero1",
        Point(
            p.x,
            p.y - 120
        ),
        CARTAGO_PLAYER
    )
    .AsUnit();
```

---

# 26. Clase del caudillo

```text
CHero1
```

---

# 27. Propietario del caudillo

```text
Player 2
```

porque:

```text
CARTAGO_PLAYER = 2
```

---

# 28. Posición del caudillo

```text
X = p.x
Y = p.y - 120
```

---

# 29. Nivel del caudillo

```cpp
u_hero.SetLevel(
    HERO_LEVEL
);
```

con:

```text
HERO_LEVEL = 25
```

---

# 30. Alimentación del caudillo

```cpp
u_hero.SetFeeding(
    false
);
```

---

# 31. IA estratégica del caudillo

```cpp
u_hero.SetNoAIFlag(
    true
);
```

---

# 32. Group `ZombieEE_AmuletCarrier`

El caudillo se añade a:

```cpp
u_hero.AddToGroup(
    "ZombieEE_AmuletCarrier"
);
```

Este Group debe contener únicamente al `CHero1`.

---

# 33. Función de `ZombieEE_AmuletCarrier`

La condición real de victoria es:

```text
ZombieEE_AmuletCarrier.count == 0
```

después de `ClearDead()`.

---

# 34. Group `ZombieEE_AmuletArmy`

El caudillo también se añade a:

```cpp
u_hero.AddToGroup(
    "ZombieEE_AmuletArmy"
);
```

Este Group representa al ejército completo, incluido el héroe.

---

# 35. Validación inmediata del caudillo

Después del `Place()`:

```cpp
carrier = Group("ZombieEE_AmuletCarrier").GetObjList();
carrier.ClearDead();
```

Debe cumplirse:

```text
carrier.count == 1
```

---

# 36. Error si el caudillo no quedó creado/registrado

Si:

```text
carrier.count != 1
```

se ejecuta:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_HUNT_STARTED",
    0
);
```

Después se muestra:

```text
ERROR AMULETO - CAUDILLO NO CREADO
```

y se termina.

---

# 37. Mensaje interno de debug

Si el caudillo se crea correctamente:

```text
EE AMULET - CHERO1 CREATED
```

se envía mediante:

```cpp
pr(...);
```

---

# 38. Composición completa del ejército

La composición exacta es:

```text
1 CHero1
10 CNumidianRider
10 CNoble
10 CJavelinThrower
15 CLibyanFootman
4 CWarElephant
```

Total:

```text
50 unidades
```

---

# 39. Nivel del ejército normal

Todas las tropas que no son el héroe reciben:

```text
nivel 20
```

porque:

```text
ARMY_LEVEL = 20
```

---

# 40. Propiedades comunes del ejército

Cada tropa normal recibe:

```cpp
u.SetLevel(
    ARMY_LEVEL
);

u.SetFeeding(
    false
);

u.SetNoAIFlag(
    true
);

u.AddToGroup(
    "ZombieEE_AmuletArmy"
);
```

---

# 41. `idx`

La formación comienza con:

```cpp
idx = 1;
```

El índice cero queda conceptualmente asociado a la posición central del héroe, aunque el héroe utiliza una coordenada fija independiente.

---

# 42. 10 `CNumidianRider`

Primer bloque:

```text
10 jinetes númidas
```

Clase exacta:

```text
CNumidianRider
```

---

# 43. 10 `CNoble`

Segundo bloque:

```text
10 nobles cartagineses
```

Clase exacta:

```text
CNoble
```

---

# 44. 10 `CJavelinThrower`

Tercer bloque:

```text
10 lanzadores de jabalina
```

Clase exacta:

```text
CJavelinThrower
```

---

# 45. 15 `CLibyanFootman`

Cuarto bloque:

```text
15 infantes libios
```

Clase exacta:

```text
CLibyanFootman
```

---

# 46. Formación de las primeras 45 tropas normales

Para estas clases se utiliza:

```cpp
Point(
    p.x
    +
    ((idx % 10) * SP)
    -
    (5 * SP),

    p.y
    +
    ((idx / 10) * SP)
    -
    160
)
```

---

# 47. Separación base

```text
SP = 80
```

---

# 48. Columnas de formación

La expresión:

```text
idx % 10
```

produce una rejilla de:

```text
10 columnas
```

---

# 49. Filas de formación

La expresión:

```text
idx / 10
```

va aumentando la fila cada diez unidades.

---

# 50. Desplazamiento X

El centro aproximado usa:

```text
-5 × SP
=
-400
```

respecto a `p.x`.

---

# 51. Desplazamiento Y

La formación normal empieza con una base de:

```text
p.y - 160
```

y crece de 80 en 80 por fila.

---

# 52. Incremento de `idx`

Después de cada unidad:

```cpp
idx += 1;
```

---

# 53. Creación escalonada

Después de cada tropa normal:

```cpp
Sleep(20);
```

---

# 54. 4 `CWarElephant`

El bloque final crea:

```text
4 elefantes de guerra
```

Clase exacta:

```text
CWarElephant
```

---

# 55. Formación especial de elefantes

Los elefantes no usan la rejilla de `SP = 80`.

La coordenada es:

```cpp
Point(
    p.x
    +
    ((idx % 4) * 140)
    -
    210,

    p.y
    +
    350
)
```

---

# 56. Separación horizontal de elefantes

```text
140
```

---

# 57. Línea Y de elefantes

Todos aparecen en:

```text
p.y + 350
```

---

# 58. Número total esperado en `ZombieEE_AmuletArmy`

Después del spawn:

```text
1 héroe
+
49 tropas normales
=
50
```

---

# 59. Comprobación del ejército tras crearlo

La Sequence consulta:

```cpp
army =
    Group(
        "ZombieEE_AmuletArmy"
    )
    .GetObjList();

army.ClearDead();
```

---

# 60. Debug de ejército creado

Se ejecuta:

```text
EE AMULET - ARMY CREATED count=X
```

mediante `pr(...)`.

---

# 61. Objetivo mostrado

Después del spawn:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "DERROTA AL CAUDILLO CARTAGINES"
);
```

---

# 62. Condición real de victoria

La cabecera canónica lo deja explícito:

```text
El jugador SOLO tiene que matar al caudillo.
```

---

# 63. El ejército completo no controla la fase

Aunque `ZombieEE_AmuletArmy` se cuenta y se muestra en pantalla, su supervivencia:

```text
NO controla el final
```

---

# 64. Inicio del bucle de seguimiento

Se inicializa:

```cpp
heroDefeated = 0;
lastAlive = -1;
```

Después:

```cpp
while(heroDefeated == 0)
```

---

# 65. Frecuencia del bucle

La primera instrucción es:

```cpp
Sleep(500);
```

Por tanto se comprueba aproximadamente:

```text
2 veces por segundo
```

---

# 66. Refresco del caudillo

Cada ciclo:

```cpp
carrier =
    Group(
        "ZombieEE_AmuletCarrier"
    )
    .GetObjList();

carrier.ClearDead();
```

---

# 67. Refresco del ejército

También:

```cpp
army =
    Group(
        "ZombieEE_AmuletArmy"
    )
    .GetObjList();

army.ClearDead();

alive =
    army.count;
```

---

# 68. HUD del ejército restante

Si cambia `alive`:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "DERROTA AL CAUDILLO - EJERCITO CARTAGINES: "
    + alive
    + "/50"
);
```

---

# 69. Significado del contador

El contador muestra:

```text
unidades cartaginesas supervivientes / 50
```

pero no es una condición de victoria.

---

# 70. Ejemplo válido de finalización

Puede ocurrir:

```text
EJERCITO CARTAGINES: 43/50
↓
muere CHero1
↓
carrier.count = 0
↓
fase completada
```

Las 42 unidades restantes pueden seguir vivas.

---

# 71. Detección de muerte del héroe

La condición exacta es:

```cpp
if(carrier.count == 0)
{
    heroDefeated = 1;
}
```

---

# 72. No existe comprobación de inventario

La versión actual no utiliza:

```text
Item
Inventory
Gem of Power física
entrega de objeto
```

---

# 73. No existe transporte del amuleto

No hay ninguna lógica de:

```text
recoger item
llevar item
soltar item
comprobar item en César
comprobar item en pirámides
```

---

# 74. Nuevo significado narrativo

Matar al caudillo equivale a:

```text
recuperar Gem of Power
```

a nivel de historia, aunque no exista objeto físico.

---

# 75. Debug al morir el caudillo

Se ejecuta:

```text
EE AMULET - CHERO1 DEFEATED
```

mediante `pr(...)`.

---

# 76. Anuncio de caída del caudillo

Se muestra:

```text
EL CAUDILLO CARTAGINES HA CAIDO
```

con ID:

```text
ZombieEEObjective
```

---

# 77. Notificación al jugador

También se ejecuta:

```cpp
UserNotification(
    "El caudillo cartagines ha sido derrotado. Regresa junto al sacerdote egipcio.",
    "",
    p,
    1
);
```

---

# 78. Posición asociada a la notificación

La notificación utiliza:

```text
p
```

es decir:

```text
posición del campamento cartaginés
```

---

# 79. Player de la notificación

El último parámetro es:

```text
1
```

por lo que la notificación está dirigida a Player 1.

---

# 80. Pausa antes de actualizar flags

Después:

```cpp
Sleep(2500);
```

---

# 81. Refresco de `CapitalForum_P1`

Después de esos 2,5 segundos:

```cpp
stateList = Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count != 1)
    return;

state = stateList[0].AsBuilding();
```

---

# 82. Marcar objetivo recuperado

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_DELIVERED",
    1
);
```

---

# 83. Semántica exacta de `EE_AMULET_DELIVERED = 1`

El propio Source aclara:

```text
EL CAUDILLO HA SIDO DERROTADO Y LA FASE ESTA RESUELTA
```

No significa una entrega física.

---

# 84. Deshabilitar búsqueda

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_HUNT_ENABLED",
    0
);
```

---

# 85. Marcar fase completada

También:

```cpp
EnvWriteInt(
    state,
    "EE_AMULET_PHASE_COMPLETED",
    1
);
```

---

# 86. Activar cuarta visita al sacerdote

Finalmente:

```cpp
EnvWriteInt(
    state,
    "EE_PRIEST_PENDING",
    4
);
```

---

# 87. Significado de `pending = 4`

`ZombieEE_PriestInteraction_Main` interpreta:

```text
4 → ZombieEE_Dialogue04
```

---

# 88. No ejecuta Dialogue04 directamente

No contiene:

```cpp
RunSequence(
    "ZombieEE_Dialogue04"
);
```

---

# 89. Motivo

César debe:

```text
volver físicamente al sacerdote egipcio
```

y entrar en el radio de interacción del gestor presencial.

---

# 90. Debug final

Se ejecuta:

```text
EE AMULET - PHASE COMPLETED pending=4
```

mediante `pr(...)`.

---

# 91. Anuncio final

La Sequence muestra:

```text
REGRESA JUNTO AL SACERDOTE EGIPCIO
```

con ID:

```text
ZombieEEObjective
```

---

# 92. Final de la Sequence

Después:

```cpp
return;
```

---

# 93. El ejército cartaginés superviviente no se borra

La Sequence no ejecuta:

```text
Erase
Kill
Damage
```

sobre las tropas restantes después de morir `CHero1`.

---

# 94. Consecuencia jugable

Puede quedar un ejército cartaginés vivo en el campamento después de que la fase narrativa ya haya avanzado.

Eso es coherente con el comentario canónico:

```text
El resto del ejercito cartagines NO necesita morir.
```

---

# 95. No se modifica el propietario del ejército

Las tropas continúan siendo:

```text
Player 2
```

---

# 96. No se activa IA estratégica después de completar la fase

La Sequence no ejecuta:

```text
SetNoAIFlag(false)
```

sobre los supervivientes.

Por tanto mantienen el último estado asignado por esta Sequence:

```text
SetNoAIFlag(true)
SetFeeding(false)
```

---

# 97. No se ordena movimiento ni ataque

Ni el héroe ni el resto del ejército reciben aquí:

```text
move
advance
attack
engage
```

---

# 98. Consecuencia táctica

La fase representa un campamento cartaginés defensivo estático.

Su comportamiento de combate depende de las reacciones naturales del motor cuando el jugador se acerca o los ataca.

---

# 99. No utiliza `ZombieTactical_Main`

El ejército cartaginés no se añade a:

```text
HW_H1..8
```

---

# 100. No utiliza `ZombieRewards_Main`

Tampoco se añade a:

```text
HW_R1..15
HW_R16
```

---

# 101. No utiliza Player 12

Esta fase usa:

```text
Player 2
```

para Cartago.

---

# 102. No toca Waves

No modifica:

```text
EE_ZOMBIE_SPAWNS_DISABLED
ZWAVES_STOPPED_BY_PORTALS
```

Las nuevas hordas normales ya deberían estar detenidas desde la fase de portales.

---

# 103. No modifica `EE_PORTALS_COMPLETED`

Dialogue03 ya validó y cerró narrativamente esa fase.

---

# 104. No modifica `EE_DIALOGUE04_COMPLETED`

Ese flag fue preparado por Dialogue03 y será escrito por Dialogue04.

---

# 105. Flags leídos

| Flag | Función |
|---|---|
| `EE_AMULET_PHASE_COMPLETED` | Impide repetir una fase ya completada |
| `EE_AMULET_HUNT_ENABLED` | Espera hasta que Dialogue03 habilite la misión |
| `EE_AMULET_HUNT_STARTED` | Impide crear un segundo campamento |

---

# 106. Flags escritos

| Flag | Valor | Función |
|---|---:|---|
| `EE_AMULET_HUNT_STARTED` | 1 | Marca que el campamento ya se ha iniciado |
| `EE_AMULET_HUNT_STARTED` | 0 | Sólo si falla la creación/registro del caudillo |
| `EE_AMULET_DELIVERED` | 0 | Caudillo todavía vivo |
| `EE_AMULET_PHASE_COMPLETED` | 0 | Reinicia estado al comenzar |
| `EE_AMULET_DELIVERED` | 1 | Caudillo derrotado / objetivo recuperado |
| `EE_AMULET_HUNT_ENABLED` | 0 | Desactiva búsqueda tras victoria |
| `EE_AMULET_PHASE_COMPLETED` | 1 | Marca fase completada |
| `EE_PRIEST_PENDING` | 4 | Habilita cuarta visita al sacerdote |

---

# 107. Flags preparados por Dialogue03 pero no usados directamente aquí

`ZombieEE_Dialogue03` también reinicia:

```text
EE_AMULET_ARMY_SPAWNED
EE_AMULET_CARRIER_DEFEATED
EE_AMULET_ARMY_DEFEATED
```

Sin embargo la implementación canónica actual de `ZombieEE_Amulet_Main` no lee ni escribe esos tres flags durante su lógica principal.

La condición efectiva se basa en:

```text
EE_AMULET_HUNT_STARTED
EE_AMULET_DELIVERED
EE_AMULET_PHASE_COMPLETED
ZombieEE_AmuletCarrier.count
```

---

# 108. Groups necesarios

## Obligatorios manualmente

```text
CapitalForum_P1
ZombieEE_AmuletCampPoint
```

---

# 109. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 110. `ZombieEE_AmuletCampPoint`

Debe contener:

```text
exactamente 1 objeto marcador
```

---

# 111. Groups dinámicos

```text
ZombieEE_AmuletCarrier
ZombieEE_AmuletArmy
```

No deben estar poblados manualmente al comenzar la fase.

---

# 112. Contenido de `ZombieEE_AmuletCarrier`

Durante la fase activa debe contener únicamente:

```text
CHero1
```

---

# 113. Contenido de `ZombieEE_AmuletArmy`

Debe recibir:

```text
CHero1
10 CNumidianRider
10 CNoble
10 CJavelinThrower
15 CLibyanFootman
4 CWarElephant
```

---

# 114. Groups que no necesita

No consulta directamente:

```text
ZombieEE_Caesar
ZombieEE_Priest01
HordeSpawn_01..08
EE_PortalGuardiansActive
EE_PortalRewards
HW_H1..8
HW_R1..16
```

---

# 115. Areas necesarias

Ninguna.

---

# 116. Holders necesarios

Ninguno.

---

# 117. Conversations necesarias

Ninguna directamente.

---

# 118. Sequence anterior

Es iniciada por:

```text
ZombieEE_Dialogue03
```

---

# 119. Sequence posterior indirecta

Al terminar prepara:

```text
EE_PRIEST_PENDING = 4
```

para que:

```text
ZombieEE_PriestInteraction_Main
```

termine ejecutando:

```text
ZombieEE_Dialogue04
```

---

# 120. Anuncios visibles

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR AMULETO - CapitalForum_P1` |
| `ZombieHelp` | `ERROR AMULETO - ZombieEE_AmuletCampPoint` |
| `ZombieHelp` | `ERROR AMULETO - EJERCITO YA EXISTENTE` |
| `ZombieHelp` | `ERROR AMULETO - CAUDILLO NO CREADO` |
| `ZombieEEObjective` | `DERROTA AL CAUDILLO CARTAGINES` |
| `ZombieEEObjective` | `DERROTA AL CAUDILLO - EJERCITO CARTAGINES: X/50` |
| `ZombieEEObjective` | `EL CAUDILLO CARTAGINES HA CAIDO` |
| `ZombieEEObjective` | `REGRESA JUNTO AL SACERDOTE EGIPCIO` |

---

# 121. `UserNotification`

Al morir el caudillo se envía:

```text
El caudillo cartagines ha sido derrotado. Regresa junto al sacerdote egipcio.
```

asociada a:

```text
posición del campamento
Player 1
```

---

# 122. Mensajes `pr(...)` presentes en la versión canónica

Esta Sequence sí contiene salidas internas de debug:

```text
EE AMULET ERROR - CapitalForum_P1 count=X
EE AMULET ERROR - CampPoint count=X
EE AMULET - CHERO1 CREATED
EE AMULET - ARMY CREATED count=X
EE AMULET - CHERO1 DEFEATED
EE AMULET - PHASE COMPLETED pending=4
```

---

# 123. Tiempos internos

| Acción | Tiempo |
|---|---:|
| Espera de habilitación | 1.000 ms |
| Sleep por tropa normal | 20 ms |
| Seguimiento del caudillo | 500 ms |
| Pausa tras derrota del héroe | 2.500 ms |

---

# 124. Tiempo programado de creación del ejército normal

Hay 49 unidades normales después del héroe.

Cada una tiene:

```text
Sleep(20)
```

Por tanto:

```text
49 × 20 ms = 980 ms
```

de espera programada acumulada, además del coste de `Place()`.

---

# 125. Composición resumida

| Clase | Cantidad | Nivel | Player |
|---|---:|---:|---:|
| `CHero1` | 1 | 25 | 2 |
| `CNumidianRider` | 10 | 20 | 2 |
| `CNoble` | 10 | 20 | 2 |
| `CJavelinThrower` | 10 | 20 | 2 |
| `CLibyanFootman` | 15 | 20 | 2 |
| `CWarElephant` | 4 | 20 | 2 |
| **Total** | **50** | — | **2** |

---

# 126. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── ZombieEE_AmuletCampPoint
│   │   └── exactamente 1 objeto marcador
│   │
│   ├── ZombieEE_AmuletCarrier
│   │   └── vacío inicialmente
│   │
│   └── ZombieEE_AmuletArmy
│       └── vacío inicialmente
│
└── Sequences
    ├── ZombieEE_Dialogue03
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Amulet_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    └── ZombieEE_Dialogue04
        └── AUTORUN = NO
```

---

# 127. Comprobaciones antes de probar

1. `CapitalForum_P1` contiene exactamente un Building.
2. `ZombieEE_AmuletCampPoint` contiene exactamente un marcador.
3. `ZombieEE_AmuletCarrier` está vacío antes de la fase.
4. `ZombieEE_AmuletArmy` está vacío antes de la fase.
5. Player 2 corresponde a Cartago en el escenario.
6. `ZombieEE_Dialogue03` escribe `EE_AMULET_HUNT_ENABLED = 1`.
7. `ZombieEE_Dialogue03` ejecuta `ZombieEE_Amulet_Main`.
8. `ZombieEE_PriestInteraction_Main` sigue activo.
9. `ZombieEE_Dialogue04` existe.
10. No debe existir ninguna dependencia externa de una Gem of Power física para completar esta fase.

---

# 128. Estado esperado antes de la fase

Un estado normal es:

```text
EE_DIALOGUE03_COMPLETED = 1
EE_PORTAL_PHASE_FINISHED = 1
EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_HUNT_STARTED = 0
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0
```

---

# 129. Estado durante el combate

```text
EE_AMULET_HUNT_ENABLED = 1
EE_AMULET_HUNT_STARTED = 1
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0

ZombieEE_AmuletCarrier.count = 1
ZombieEE_AmuletArmy.count = 1..50
```

---

# 130. Estado final

Después de morir `CHero1`:

```text
EE_AMULET_HUNT_STARTED = 1
EE_AMULET_DELIVERED = 1
EE_AMULET_HUNT_ENABLED = 0
EE_AMULET_PHASE_COMPLETED = 1
EE_PRIEST_PENDING = 4
```

El flag `EE_AMULET_HUNT_STARTED` no vuelve a cero en una finalización normal.

---

# 131. Flujo exacto de arranque

```text
RunSequence("ZombieEE_Amulet_Main")
↓
validar CapitalForum_P1
↓
¿EE_AMULET_PHASE_COMPLETED == 1?
Sí → return
↓
esperar EE_AMULET_HUNT_ENABLED == 1
↓
validar ZombieEE_AmuletCampPoint
↓
¿EE_AMULET_HUNT_STARTED == 1?
Sí → return
↓
comprobar:
ZombieEE_AmuletCarrier vacío
ZombieEE_AmuletArmy vacío
↓
EE_AMULET_HUNT_STARTED = 1
↓
EE_AMULET_DELIVERED = 0
EE_AMULET_PHASE_COMPLETED = 0
```

---

# 132. Flujo exacto de creación

```text
crear CHero1
Player 2
nivel 25
↓
Carrier + Army
↓
crear 10 CNumidianRider
↓
crear 10 CNoble
↓
crear 10 CJavelinThrower
↓
crear 15 CLibyanFootman
↓
crear 4 CWarElephant
↓
Army total = 50
↓
mostrar:
DERROTA AL CAUDILLO CARTAGINES
```

---

# 133. Flujo exacto de combate

```text
while heroDefeated == 0
↓
Sleep(500)
↓
refrescar ZombieEE_AmuletCarrier
↓
refrescar ZombieEE_AmuletArmy
↓
alive = Army.count
↓
si cambia alive:
mostrar X/50
↓
¿Carrier.count == 0?
No → repetir
Sí → heroDefeated = 1
```

---

# 134. Flujo exacto de finalización

```text
CHero1 muere
↓
EL CAUDILLO CARTAGINES HA CAIDO
↓
UserNotification:
regresa junto al sacerdote
↓
Sleep(2500)
↓
refrescar CapitalForum_P1
↓
EE_AMULET_DELIVERED = 1
↓
EE_AMULET_HUNT_ENABLED = 0
↓
EE_AMULET_PHASE_COMPLETED = 1
↓
EE_PRIEST_PENDING = 4
↓
REGRESA JUNTO AL SACERDOTE EGIPCIO
↓
return
```

---

# 135. Resumen funcional

`ZombieEE_Amulet_Main` v2.0 implementa una versión simplificada y estable de la antigua mecánica de Gem of Power:

```text
no existe objeto físico
↓
no existe inventario
↓
no existe transporte del amuleto
↓
aparece campamento cartaginés
↓
50 unidades totales
↓
CHero1 es el único objetivo obligatorio
↓
matar CHero1
↓
EE_AMULET_DELIVERED = 1
↓
EE_AMULET_PHASE_COMPLETED = 1
↓
EE_PRIEST_PENDING = 4
↓
volver al sacerdote
```

El resto del ejército cartaginés no controla el progreso de la fase y puede seguir vivo después de la muerte del caudillo.

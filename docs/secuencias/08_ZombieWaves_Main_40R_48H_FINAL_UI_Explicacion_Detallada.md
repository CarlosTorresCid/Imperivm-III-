# Secuencia 8 — `ZombieWaves_Main_40R_48H_FINAL_UI`

`ZombieWaves_Main_40R_48H_FINAL_UI` es la Sequence encargada de **crear físicamente las oleadas del modo Zombies, organizar el calendario de rondas, seleccionar los puntos de aparición, construir la composición de cada horda y registrar cada ejército en los slots `HW_H1` a `HW_H48`**.

Esta Sequence es el origen del sistema Zombies. No decide por sí sola qué ciudad debe atacar cada horda y tampoco gestiona el asedio posterior. Su responsabilidad termina esencialmente cuando:

1. crea todas las unidades de una horda;
2. las asigna a Player 12;
3. las añade al Group dinámico `HW_HS`;
4. escribe el estado `HW_*` correspondiente;
5. marca el slot como activo.

A partir de ahí la IA táctica debe recoger ese Group y dirigirlo contra un Foro.

La Sequence está diseñada para:

```text
40 rondas
48 hordas internas como máximo

R1-R32  → 1 horda por ronda
R33-R40 → 2 hordas por ronda
```

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Preparación necesaria en el editor

Hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── ZombieWaves_Main_40R_48H_FINAL_UI
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

Esta Sequence sí necesita varios Groups manuales de configuración.

---

# 2. Groups manuales obligatorios

Deben existir exactamente estos Groups:

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

Cada uno debe resolver a **exactamente un objeto válido**.

---

# 3. `CapitalForum_P1`

Al arrancar se ejecuta:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después:

```cpp
if(stateList.count != 1)
{
    while(1)
        Sleep(60000);
}
```

Por tanto `CapitalForum_P1` es obligatorio.

Su único objeto se convierte a:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

y se utiliza como **objeto de estado global** del modo Zombies.

---

# 4. Función de `CapitalForum_P1`

Esta Sequence escribe sobre ese Building variables como:

```text
HW_ACTIVE1..48
HW_ROUND1..48
HW_TX1..48
HW_TY1..48
HW_OWNER1..48
HW_REWARDED1..48
```

Por tanto ese Building funciona como memoria persistente compartida con las demás Sequences del modo Zombies.

Conviene que sea un objeto estable durante toda la partida.

---

# 5. Los ocho `HordeSpawn_XX`

La Sequence resuelve manualmente:

```text
HordeSpawn_01
...
HordeSpawn_08
```

Cada Group debe contener exactamente un objeto.

Ejemplo:

```cpp
q =
    Group("HordeSpawn_01")
    .GetObjList();

q.ClearDead();

if(q.count != 1)
{
    while(1)
        Sleep(60000);
}
else
{
    s1 = q[0].pos;
}
```

La misma lógica se repite para los ocho puntos.

---

# 6. Qué objeto debe contener cada `HordeSpawn_XX`

El código únicamente utiliza:

```cpp
q[0].pos
```

Por tanto el objeto sirve como **marcador espacial**.

No necesita ser un Townhall ni un edificio concreto; lo importante es que:

- exista;
- permanezca válido al inicio;
- tenga una posición adecuada;
- el Group contenga exactamente un objeto.

En la práctica conviene utilizar objetos de referencia que no interfieran con la partida.

---

# 7. Qué ocurre si falta un Spawn

Si cualquiera de los ocho Groups:

```text
HordeSpawn_01..08
```

no contiene exactamente un objeto, la Sequence entra en:

```cpp
while(1)
    Sleep(60000);
```

y deja de continuar con el sistema de oleadas.

No muestra una notificación explicativa.

Por tanto los ocho spawns son obligatorios incluso aunque una partida concreta no llegue a utilizar todos.

---

# 8. `HordeSpawn_07` tiene dos funciones

`HordeSpawn_07` puede ser seleccionado como un punto de aparición normal, igual que los otros siete.

Además su posición:

```text
s7
```

se utiliza como punto visual de **todas las notificaciones de rondas**:

```cpp
UserNotification(
    ...,
    s7,
    k
);
```

Por tanto:

```text
HordeSpawn_07
```

es simultáneamente:

```text
punto de spawn posible
+
referencia espacial para la interfaz de avisos
```

---

# 9. No hay que crear manualmente `HW_H1..HW_H48`

Las hordas se registran mediante:

```cpp
u.AddToGroup(
    "HW_H" + S
);
```

Por tanto la intención del código es utilizar Groups dinámicos:

```text
HW_H1
HW_H2
...
HW_H48
```

No hay que introducir manualmente soldados en esos Groups.

`ZombieWaves_Main` los va poblando cuando crea cada horda.

Después otras Sequences, como `ZombieTactical_Main`, recuperan las unidades con:

```cpp
Group("HW_Hx").GetObjList()
```

---

# 10. No hacen falta Areas ni rutas manuales

Esta Sequence no utiliza Areas.

Tampoco requiere:

- rutas predefinidas;
- puntos intermedios de marcha;
- marcadores de ciudad objetivo;
- Groups de Gates;
- Holders;
- puntos de asedio.

Sólo necesita los ocho puntos de aparición y el objeto global de estado.

---

# 11. Player de las hordas

Se define:

```cpp
HP = 12;
```

Todas las unidades Zombies son creadas para:

```text
Player 12
```

mediante:

```cpp
Place(
    cls,
    pos,
    HP
);
```

Por tanto Player 12 debe reservarse para el sistema de hordas.

---

# 12. Parámetros generales

El código utiliza:

```cpp
HP = 12;
START_DELAY = 0;
WAVE_INTERVAL = 120000;
MAX_ROUNDS = 40;
SP = 55;
```

| Parámetro | Valor real del código | Función |
|---|---:|---|
| `HP` | 12 | Player técnico de la horda |
| `START_DELAY` | **0 ms** | Espera antes de la primera ronda |
| `WAVE_INTERVAL` | 120.000 ms | 2 minutos entre rondas |
| `MAX_ROUNDS` | 40 | Número total de rondas |
| `SP` | 55 | Separación entre unidades en la formación |

---

# 13. Discrepancia importante: el comentario dice 30 minutos, el código usa `START_DELAY = 0`

La cabecera afirma:

```text
Delay inicial: 30 minutos
```

Sin embargo la implementación real contiene:

```cpp
START_DELAY = 0;
```

y después:

```cpp
nextWave =
    GetTime()
    +
    START_DELAY;
```

Por tanto **esta versión no espera 30 minutos**.

La primera ronda queda programada prácticamente para el mismo instante en el que arranca la Sequence.

Si el diseño final debe ser realmente:

```text
30 minutos
```

el valor tendría que ser equivalente a:

```cpp
START_DELAY = 1800000;
```

La documentación de esta versión debe distinguir claramente entre el comentario de cabecera y el código ejecutado.

---

# 14. Consecuencia de `START_DELAY = 0`

Como:

```text
nextWave ≈ GetTime()
```

al entrar en el bucle:

```cpp
now = GetTime();
```

normalmente se cumplirá:

```text
now >= nextWave
```

y la ronda 1 comenzará inmediatamente.

Por tanto, en la primera ronda normalmente tampoco habrá tiempo para mostrar:

```text
aviso de 30 segundos
3
2
1
```

Los avisos previos sí funcionan para las rondas posteriores porque éstas se programan con el intervalo de dos minutos.

---

# 15. Intervalo entre rondas

Después de generar una ronda:

```cpp
nextWave += WAVE_INTERVAL;
```

con:

```text
WAVE_INTERVAL = 120000 ms
```

Por tanto el intervalo programado es:

```text
2 minutos
```

entre comienzos de ronda.

---

# 16. El intervalo se suma al calendario anterior

El código utiliza:

```cpp
nextWave += WAVE_INTERVAL;
```

y no:

```cpp
nextWave =
    GetTime()
    +
    WAVE_INTERVAL;
```

Esto mantiene un calendario acumulativo.

Si el procesamiento se retrasara mucho, la Sequence podría intentar recuperar rondas atrasadas con menos separación real, porque `nextWave` sigue avanzando desde la programación anterior.

En condiciones normales no debería apreciarse.

---

# 17. Bucle de interfaz y temporización

El controlador despierta cada:

```cpp
Sleep(250);
```

Por tanto revisa el reloj aproximadamente cuatro veces por segundo.

Esto permite mostrar los avisos de cuenta atrás con bastante precisión.

---

# 18. Aviso de 30 segundos

Cuando:

```cpp
now >= nextWave - 30000
```

se muestra:

```text
RONDA X/40 - Nueva horda en 30 segundos
```

a los Players 1..8.

La variable:

```text
warn30
```

impide repetir el mismo aviso continuamente.

---

# 19. Cuenta atrás 3, 2, 1

También existen:

```text
warn3
warn2
warn1
```

Las notificaciones aparecen aproximadamente:

```text
3 segundos antes
2 segundos antes
1 segundo antes
```

---

# 20. Cambio de mensaje desde la ronda 33

Para:

```text
R1..R32
```

la interfaz anuncia:

```text
NUEVA HORDA
```

A partir de:

```text
R33
```

muestra:

```text
DOS HORDAS
```

porque `spawnCount` pasa a 2.

---

# 21. Inicio de una ronda

Cuando:

```text
now >= nextWave
```

se ejecuta:

```cpp
w += 1;
```

Por tanto `w` representa el número de ronda actual.

---

# 22. Rondas 1 a 32

Para:

```cpp
w < 33
```

se establece:

```cpp
spawnCount = 1;
```

y se muestra:

```text
RONDA X/40 - ¡LA HORDA HA LLEGADO!
```

Cada una de estas rondas genera exactamente una horda.

---

# 23. Rondas 33 a 40

Para:

```cpp
w >= 33
```

se establece:

```cpp
spawnCount = 2;
```

y se muestra:

```text
RONDA X/40 - ¡DOS HORDAS HAN LLEGADO!
```

Cada ronda genera dos copias completas de la composición definida para esa ronda.

---

# 24. Elección aleatoria de spawns

En cada ronda se seleccionan:

```cpp
sa = rand(8) + 1;
sb = rand(8) + 1;
```

Después:

```cpp
while(sb == sa)
    sb = rand(8) + 1;
```

Por tanto los dos índices siempre son distintos.

---

# 25. En R1..R32 sólo se usa el primer spawn

Aunque `sb` también se calcula, cuando:

```text
spawnCount = 1
```

el bucle sólo ejecuta:

```text
A = 0
```

y por tanto utiliza:

```text
sa
```

`sb` queda sin uso para esa ronda.

---

# 26. En R33..R40 las dos hordas aparecen en puntos distintos

Cuando:

```text
spawnCount = 2
```

se utilizan:

```text
A = 0 → sa
A = 1 → sb
```

Como:

```text
sb != sa
```

las dos hordas de la misma ronda no pueden aparecer en el mismo `HordeSpawn`.

---

# 27. Los ocho spawns tienen la misma probabilidad base

La selección utiliza:

```cpp
rand(8) + 1
```

Por tanto cualquiera de:

```text
1..8
```

puede ser seleccionado.

No existe una preferencia por civilización, región o distancia a ciudades.

---

# 28. Mapeo de ronda a slot interno

Para las primeras 32 rondas:

```cpp
S = w;
```

Por tanto:

```text
R1  → H1
R2  → H2
...
R32 → H32
```

---

# 29. Mapeo de las rondas dobles

Desde R33:

```cpp
S =
    33
    +
    (w - 33) * 2
    +
    A;
```

El resultado es:

| Ronda | Primera horda | Segunda horda |
|---:|---:|---:|
| 33 | H33 | H34 |
| 34 | H35 | H36 |
| 35 | H37 | H38 |
| 36 | H39 | H40 |
| 37 | H41 | H42 |
| 38 | H43 | H44 |
| 39 | H45 | H46 |
| 40 | H47 | H48 |

Así se alcanzan exactamente:

```text
48 slots internos
```

---

# 30. Observación crítica de compatibilidad con `ZombieTactical_Main_v10_5`

La versión de `ZombieTactical_Main_v10_5_WALL_STUCK_GATE` documentada inmediatamente antes recorre:

```cpp
for(H = 1; H <= 32; H += 1)
```

y sólo lee:

```text
HW_H1..HW_H32
HW_ACTIVE1..HW_ACTIVE32
```

Sin embargo esta Sequence genera:

```text
HW_H33..HW_H48
```

durante R33-R40.

Por tanto, **con las dos versiones exactamente como están ahora, existe una incompatibilidad importante**:

```text
R1-R32
→ H1-H32
→ sí son recogidas por ZombieTactical_Main_v10_5

R33-R40
→ H33-H48
→ ZombieWaves las crea
→ pero esa versión de ZombieTactical_Main no las recorre
```

En consecuencia, salvo que exista otra Sequence táctica adicional para H33-H48:

- las hordas de R33-R40 aparecerán;
- tendrán `HW_ACTIVE33..48 = 1`;
- estarán en `HW_H33..48`;
- pero `ZombieTactical_Main_v10_5` no las dirigirá hacia ningún Foro;
- tampoco será esa Sequence la que detecte su destrucción;
- no preparará `ZR_PENDING33..48`.

Este punto debe corregirse o coordinarse antes de considerar cerrado el modo de 48 hordas.

---

# 31. Relación con `ZombieRewards_Main_48H_40R`

`ZombieRewards_Main_48H_40R` sí está preparado para leer:

```text
ZR_PENDING1..ZR_PENDING48
```

Por tanto la capa de recompensas tiene capacidad para 48 slots.

El cuello de botella actual está en la versión táctica de 32 slots, no en `ZombieRewards_Main_48H_40R`.

---

# 32. Inicialización de la composición

Antes de cargar cada ronda se limpian:

```text
c1..c13
n1..n13
```

y:

```cpp
lv = 1;
```

Después el bloque correspondiente a `w` establece:

- clases;
- cantidades;
- nivel.

---

# 33. Hasta 13 clases distintas por horda

La Sequence dispone de:

```text
c1..c13
```

y:

```text
n1..n13
```

La ronda 40 utiliza los 13 slots.

Las rondas tempranas utilizan menos.

---

# 34. No hay héroes Zombies

Ninguna de las composiciones de las 40 rondas incluye héroes.

La cabecera coincide con el código:

```text
Sin héroes zombies
```

---

# 35. Elefantes desde R33

`CWarElephant` comienza a aparecer en:

```text
R33
```

y continúa hasta R40.

Cantidad por **cada horda**:

| Ronda | `CWarElephant` por horda | Hordas | Elefantes totales de la ronda |
|---:|---:|---:|---:|
| 33 | 4 | 2 | 8 |
| 34 | 4 | 2 | 8 |
| 35 | 5 | 2 | 10 |
| 36 | 5 | 2 | 10 |
| 37 | 6 | 2 | 12 |
| 38 | 6 | 2 | 12 |
| 39 | 7 | 2 | 14 |
| 40 | 8 | 2 | 16 |

---

# 36. Nivel de las hordas

La progresión es:

```text
R1-R2   → nivel 6
R3-R4   → nivel 7
R5-R6   → nivel 8
R7-R8   → nivel 9
R9      → nivel 10
R10-R11 → nivel 11
R12-R13 → nivel 12
R14     → nivel 13
R15-R16 → nivel 14
R17-R18 → nivel 15
R19     → nivel 16
R20-R21 → nivel 17
R22-R23 → nivel 18
R24     → nivel 19
R25-R40 → nivel 20
```

Todas las unidades de una misma horda reciben el mismo `lv`.

---

# 37. Tabla completa — Rondas 1 a 10

| Ronda | Nivel | Hordas | Unidades por horda | Total de la ronda | Composición de cada horda |
|---:|---:|---:|---:|---:|---|
| 1 | 6 | 1 | 120 | 120 | 50 `TMaceman` + 40 `RHastatus` + 20 `GAxeman` + 10 `ISlinger` |
| 2 | 6 | 1 | 130 | 130 | 45 `TMaceman` + 40 `GAxeman` + 25 `RHastatus` + 20 `RArcher` |
| 3 | 7 | 1 | 140 | 140 | 45 `RHastatus` + 40 `CLibyanFootman` + 25 `BBronzeSpearman` + 20 `ISlinger` + 10 `CJavelinThrower` |
| 4 | 7 | 1 | 150 | 150 | 50 `TMaceman` + 30 `GAxeman` + 30 `RHastatus` + 20 `EGuardian` + 20 `RArcher` |
| 5 | 8 | 1 | 160 | 160 | 55 `TMaceman` + 35 `RHastatus` + 25 `GAxeman` + 20 `EGuardian` + 15 `ISlinger` + 10 `GHorseman` |
| 6 | 8 | 1 | 170 | 170 | 55 `CLibyanFootman` + 35 `TMaceman` + 30 `BBronzeSpearman` + 20 `EGuardian` + 20 `CJavelinThrower` + 10 `CNumidianRider` |
| 7 | 9 | 1 | 180 | 180 | 60 `RHastatus` + 40 `GAxeman` + 30 `TMaceman` + 20 `EGuardian` + 15 `ISlinger` + 15 `GHorseman` |
| 8 | 9 | 1 | 190 | 190 | 60 `TMaceman` + 40 `CLibyanFootman` + 30 `RHastatus` + 20 `BBronzeSpearman` + 20 `RArcher` + 20 `CNumidianRider` |
| 9 | 10 | 1 | 200 | 200 | 65 `TMaceman` + 45 `RHastatus` + 30 `GAxeman` + 20 `EGuardian` + 20 `CJavelinThrower` + 20 `GHorseman` |
| 10 | 11 | 1 | 235 | 235 | 65 `TMaceman` + 50 `RHastatus` + 35 `GAxeman` + 25 `EGuardian` + 20 `ISlinger` + 15 `CJavelinThrower` + 10 `GHorseman` + 15 `RPraetorian` |

---

# 38. Tabla completa — Rondas 11 a 20

| Ronda | Nivel | Hordas | Unidades por horda | Total de la ronda | Composición de cada horda |
|---:|---:|---:|---:|---:|---|
| 11 | 11 | 1 | 245 | 245 | 70 `CLibyanFootman` + 50 `TMaceman` + 35 `RHastatus` + 25 `EGuardian` + 20 `CJavelinThrower` + 15 `CNumidianRider` + 10 `RPraetorian` + 20 `RArcher` |
| 12 | 12 | 1 | 255 | 255 | 70 `RHastatus` + 55 `TMaceman` + 35 `GAxeman` + 25 `EGuardian` + 20 `ISlinger` + 20 `CJavelinThrower` + 20 `GHorseman` + 10 `IEliteGuard` |
| 13 | 12 | 1 | 265 | 265 | 75 `TMaceman` + 55 `RHastatus` + 40 `CLibyanFootman` + 25 `GAxeman` + 25 `EGuardian` + 20 `RArcher` + 15 `CNumidianRider` + 10 `BHighlander` |
| 14 | 13 | 1 | 275 | 275 | 75 `CLibyanFootman` + 55 `TMaceman` + 40 `RHastatus` + 25 `EGuardian` + 20 `ISlinger` + 20 `CJavelinThrower` + 15 `GHorseman` + 15 `EAnubisWarrior` + 10 `RArcher` |
| 15 | 14 | 1 | 285 | 285 | 80 `TMaceman` + 60 `RHastatus` + 35 `GAxeman` + 25 `CLibyanFootman` + 20 `EGuardian` + 20 `ISlinger` + 10 `CJavelinThrower` + 15 `GHorseman` + 10 `RPraetorian` + 10 `IEliteGuard` |
| 16 | 14 | 1 | 295 | 295 | 80 `RHastatus` + 60 `TMaceman` + 40 `CLibyanFootman` + 25 `GAxeman` + 20 `EGuardian` + 20 `RArcher` + 25 `CJavelinThrower` + 15 `CNumidianRider` + 10 `TValkyrie` |
| 17 | 15 | 1 | 305 | 305 | 85 `TMaceman` + 65 `RHastatus` + 40 `GAxeman` + 25 `EGuardian` + 20 `ISlinger` + 20 `RArcher` + 15 `CJavelinThrower` + 15 `GHorseman` + 10 `GTridentWarrior` + 10 `BHighlander` |
| 18 | 15 | 1 | 315 | 315 | 85 `CLibyanFootman` + 65 `TMaceman` + 45 `RHastatus` + 20 `GAxeman` + 25 `EGuardian` + 20 `ISlinger` + 20 `CJavelinThrower` + 15 `CNumidianRider` + 10 `EAnubisWarrior` + 10 `EHorusWarrior` |
| 19 | 16 | 1 | 330 | 330 | 90 `TMaceman` + 65 `RHastatus` + 50 `GAxeman` + 30 `CLibyanFootman` + 20 `EGuardian` + 20 `RArcher` + 15 `ISlinger` + 15 `GHorseman` + 15 `CNoble` + 10 `RPraetorian` |
| 20 | 17 | 1 | 340 | 340 | 95 `TMaceman` + 70 `RHastatus` + 40 `GAxeman` + 25 `EGuardian` + 25 `ISlinger` + 25 `CJavelinThrower` + 15 `GHorseman` + 15 `TValkyrie` + 15 `BHighlander` + 15 `EAnubisWarrior` |

---

# 39. Tabla completa — Rondas 21 a 32

| Ronda | Nivel | Hordas | Unidades por horda | Total de la ronda | Composición de cada horda |
|---:|---:|---:|---:|---:|---|
| 21 | 17 | 1 | 350 | 350 | 90 `TMaceman` + 70 `RHastatus` + 50 `GAxeman` + 35 `CLibyanFootman` + 25 `ISlinger` + 20 `CJavelinThrower` + 15 `CNumidianRider` + 15 `RPraetorian` + 15 `IEliteGuard` + 15 `EAnubisWarrior` |
| 22 | 18 | 1 | 360 | 360 | 95 `CLibyanFootman` + 75 `TMaceman` + 55 `RHastatus` + 30 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 15 `EChariot` + 15 `CNoble` + 15 `BHighlander` + 15 `EHorusWarrior` |
| 23 | 18 | 1 | 370 | 370 | 95 `TMaceman` + 75 `RHastatus` + 55 `GAxeman` + 30 `EGuardian` + 25 `ISlinger` + 20 `GHorseman` + 20 `RPraetorian` + 20 `TValkyrie` + 15 `GTridentWarrior` + 15 `IEliteGuard` |
| 24 | 19 | 1 | 380 | 380 | 100 `RHastatus` + 80 `TMaceman` + 55 `CLibyanFootman` + 30 `EGuardian` + 25 `CJavelinThrower` + 20 `CNumidianRider` + 20 `EAnubisWarrior` + 20 `EHorusWarrior` + 15 `CNoble` + 15 `BHighlander` |
| 25 | 20 | 1 | 390 | 390 | 100 `TMaceman` + 80 `RHastatus` + 55 `GAxeman` + 30 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 20 `RPraetorian` + 20 `TValkyrie` + 20 `IEliteGuard` + 20 `EAnubisWarrior` |
| 26 | 20 | 1 | 400 | 400 | 105 `CLibyanFootman` + 85 `TMaceman` + 60 `RHastatus` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 20 `CNoble` + 20 `BHighlander` + 15 `EHorusWarrior` + 15 `GTridentWarrior` |
| 27 | 20 | 1 | 410 | 410 | 105 `TMaceman` + 85 `RHastatus` + 60 `GAxeman` + 35 `EGuardian` + 25 `ISlinger` + 20 `GHorseman` + 20 `RPraetorian` + 20 `TValkyrie` + 20 `IEliteGuard` + 20 `EAnubisWarrior` |
| 28 | 20 | 1 | 420 | 420 | 110 `RHastatus` + 90 `TMaceman` + 65 `CLibyanFootman` + 35 `EGuardian` + 25 `CJavelinThrower` + 20 `CNumidianRider` + 20 `CNoble` + 20 `BHighlander` + 20 `EHorusWarrior` + 15 `GTridentWarrior` |
| 29 | 20 | 1 | 435 | 435 | 115 `TMaceman` + 90 `RHastatus` + 65 `GAxeman` + 35 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 25 `RPraetorian` + 20 `TValkyrie` + 20 `IEliteGuard` + 20 `EAnubisWarrior` |
| 30 | 20 | 1 | 445 | 445 | 120 `CLibyanFootman` + 90 `TMaceman` + 65 `RHastatus` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 25 `CNoble` + 25 `BHighlander` + 20 `EHorusWarrior` + 20 `GTridentWarrior` |
| 31 | 20 | 1 | 455 | 455 | 120 `TMaceman` + 95 `RHastatus` + 65 `GAxeman` + 35 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 25 `RPraetorian` + 25 `TValkyrie` + 25 `IEliteGuard` + 20 `EAnubisWarrior` |
| 32 | 20 | 1 | 465 | 465 | 125 `RHastatus` + 95 `TMaceman` + 70 `CLibyanFootman` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 25 `CNoble` + 25 `BHighlander` + 25 `EHorusWarrior` + 20 `GTridentWarrior` |

---

# 40. Tabla completa — Rondas 33 a 40

A partir de aquí la composición indicada en la tabla se genera **dos veces**, una por cada horda de la ronda.

| Ronda | Nivel | Hordas | Unidades por horda | Total de la ronda | Composición de cada horda |
|---:|---:|---:|---:|---:|---|
| 33 | 20 | 2 | 475 | 950 | 121 `TMaceman` + 100 `RHastatus` + 70 `GAxeman` + 35 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 25 `RPraetorian` + 25 `TValkyrie` + 25 `IEliteGuard` + 25 `EAnubisWarrior` + 4 `CWarElephant` |
| 34 | 20 | 2 | 485 | 970 | 126 `CLibyanFootman` + 100 `TMaceman` + 70 `RHastatus` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 30 `CNoble` + 25 `BHighlander` + 25 `EHorusWarrior` + 25 `GTridentWarrior` + 4 `CWarElephant` |
| 35 | 20 | 2 | 495 | 990 | 125 `TMaceman` + 105 `RHastatus` + 75 `GAxeman` + 35 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 30 `RPraetorian` + 25 `TValkyrie` + 25 `IEliteGuard` + 25 `EAnubisWarrior` + 5 `CWarElephant` |
| 36 | 20 | 2 | 505 | 1010 | 130 `RHastatus` + 105 `TMaceman` + 75 `CLibyanFootman` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 30 `CNoble` + 30 `BHighlander` + 25 `EHorusWarrior` + 25 `GTridentWarrior` + 5 `CWarElephant` |
| 37 | 20 | 2 | 515 | 1030 | 129 `TMaceman` + 110 `RHastatus` + 80 `GAxeman` + 35 `ISlinger` + 25 `CJavelinThrower` + 20 `GHorseman` + 30 `RPraetorian` + 30 `TValkyrie` + 25 `IEliteGuard` + 25 `EAnubisWarrior` + 6 `CWarElephant` |
| 38 | 20 | 2 | 525 | 1050 | 134 `CLibyanFootman` + 110 `TMaceman` + 80 `RHastatus` + 35 `EGuardian` + 25 `RArcher` + 20 `CNumidianRider` + 30 `CNoble` + 30 `BHighlander` + 30 `EHorusWarrior` + 25 `GTridentWarrior` + 6 `CWarElephant` |
| 39 | 20 | 2 | 550 | 1100 | 143 `TMaceman` + 115 `RHastatus` + 85 `GAxeman` + 40 `ISlinger` + 30 `CJavelinThrower` + 20 `GHorseman` + 30 `RPraetorian` + 30 `TValkyrie` + 25 `IEliteGuard` + 25 `EAnubisWarrior` + 7 `CWarElephant` |
| 40 | 20 | 2 | 575 | 1150 | 112 `TMaceman` + 90 `RHastatus` + 60 `GAxeman` + 45 `CLibyanFootman` + 35 `ISlinger` + 30 `CJavelinThrower` + 20 `GHorseman` + 20 `CNumidianRider` + 40 `RPraetorian` + 40 `TValkyrie` + 40 `IEliteGuard` + 35 `EAnubisWarrior` + 8 `CWarElephant` |

---

# 41. Volumen total de unidades

Sumando literalmente las composiciones del código:

```text
R1-R32:
9.465 unidades

R33-R40:
8.250 unidades
porque cada composición se genera dos veces

TOTAL TEÓRICO DE LAS 40 RONDAS:
17.715 unidades
```

Estas cifras son acumulativas a lo largo de toda la partida; no significan que todas tengan que existir simultáneamente.

---

# 42. Escalada de tamaño

La primera ronda contiene:

```text
120 unidades
```

La ronda 32 contiene:

```text
465 unidades
```

por una sola horda.

La ronda 33 genera:

```text
475 unidades por horda
×
2 hordas
=
950 unidades
```

La ronda 40 genera:

```text
575 unidades por horda
×
2 hordas
=
1.150 unidades
```

sólo en esa ronda.

Este salto debe tenerse en cuenta tanto para balance como para rendimiento.

---

# 43. Creación física de las unidades

La Sequence utiliza:

```cpp
u =
    Place(
        cls,
        Point(...),
        HP
    )
    .AsUnit();
```

Por tanto las unidades aparecen físicamente alrededor del punto de spawn seleccionado.

---

# 44. Formación rectangular

La posición se calcula así:

```cpp
Point(
    p.x
    +
    (idx % 20) * SP
    -
    10 * SP,

    p.y
    +
    (idx / 20) * SP
    -
    6 * SP
)
```

con:

```text
SP = 55
```

---

# 45. Número de columnas

La expresión:

```cpp
idx % 20
```

produce:

```text
20 columnas
```

por fila.

La separación horizontal entre unidades es:

```text
55
```

---

# 46. Offset horizontal

La primera columna comienza aproximadamente en:

```text
p.x - 550
```

porque:

```text
10 × 55 = 550
```

La última columna queda aproximadamente en:

```text
p.x + 495
```

La formación está casi centrada respecto al spawn.

---

# 47. Filas de la formación

Cada grupo de 20 unidades incrementa:

```cpp
idx / 20
```

en una fila.

La separación vertical también es:

```text
55
```

La primera fila comienza aproximadamente en:

```text
p.y - 330
```

porque:

```text
6 × 55 = 330
```

---

# 48. Las hordas grandes ocupan un área considerable

Con una horda de 575 unidades:

```text
575 / 20
≈
29 filas
```

Por tanto la formación puede extenderse más de 1.500 unidades en vertical desde la primera fila hasta la última.

Los puntos `HordeSpawn_XX` deben colocarse en zonas suficientemente amplias.

---

# 49. No existe validación de terreno

La Sequence no comprueba si cada `Point(...)` cae sobre:

- agua;
- roca;
- muralla;
- edificio;
- zona inaccesible;
- otra formación.

Por tanto la colocación de los ocho spawns es una decisión importante del diseño del mapa.

---

# 50. Configuración de cada zombie

Después de `Place()` se ejecuta:

```cpp
u.SetLevel(lv);
u.SetFeeding(false);
u.SetNoAIFlag(true);
u.AddToGroup("HW_H" + S);
```

---

# 51. `SetFeeding(false)`

Las unidades de la horda no dependen de comida.

Esto evita que un ejército técnico de Player 12 sufra hambre durante las marchas prolongadas.

---

# 52. `SetNoAIFlag(true)`

La IA estratégica normal no debe apropiarse de estas unidades.

Su comportamiento queda reservado al sistema específico de hordas.

---

# 53. `AddToGroup("HW_H" + S)`

Cada zombie queda registrado en el Group correspondiente al slot actual.

Ejemplo:

```text
Ronda 12
↓
S = 12
↓
todas las unidades:
HW_H12
```

En R33:

```text
primera horda  → HW_H33
segunda horda  → HW_H34
```

---

# 54. Un solo Group por horda

Todas las clases de una misma horda se añaden al mismo:

```text
HW_HS
```

No se separan por:

- infantería;
- arqueros;
- caballería;
- elefantes.

`ZombieTactical_Main` recibe una sola lista de unidades.

---

# 55. Escritura del estado de la horda

Después de crear todas las unidades se ejecuta:

```cpp
EnvWriteInt(state,"HW_ACTIVE"+S,1);
EnvWriteInt(state,"HW_ROUND"+S,w);
EnvWriteInt(state,"HW_TX"+S,0);
EnvWriteInt(state,"HW_TY"+S,0);
EnvWriteInt(state,"HW_OWNER"+S,0);
EnvWriteInt(state,"HW_REWARDED"+S,0);
```

---

# 56. Significado de los estados iniciales

## `HW_ACTIVE = 1`

El slot contiene una horda activa.

## `HW_ROUND = w`

Conserva la ronda de origen para el sistema de recompensas.

## `HW_TX = 0`

Todavía no tiene Foro objetivo guardado.

## `HW_TY = 0`

Todavía no tiene coordenada Y de objetivo.

## `HW_OWNER = 0`

Todavía no se ha registrado propietario del objetivo.

## `HW_REWARDED = 0`

La destrucción de esa horda todavía puede generar premio.

---

# 57. La IA táctica selecciona el objetivo después

`ZombieWaves_Main` no busca ninguna ciudad.

Después de crear:

```text
HW_TX = 0
HW_TY = 0
```

deja que `ZombieTactical_Main` detecte que no existe target y seleccione el `BaseTownhall` correspondiente.

La separación conceptual es:

```text
ZombieWaves
→ crea

ZombieTactical
→ dirige

ZombieRewards
→ recompensa
```

---

# 58. Uso de claves dinámicas en `EnvWriteInt`

Esta Sequence utiliza construcciones como:

```cpp
EnvWriteInt(
    state,
    "HW_ACTIVE" + S,
    1
);
```

Esto contrasta con las lecturas de `EnvReadInt` que en otras Sequences se han desenrollado manualmente debido al error observado con claves dinámicas.

En el proyecto actual el patrón utilizado es:

```text
EnvReadInt con clave dinámica
→ evitado

EnvWriteInt con clave dinámica
→ conservado
```

La versión suministrada depende de que estas escrituras dinámicas funcionen correctamente.

---

# 59. También se usa un nombre dinámico de Group

La llamada:

```cpp
u.AddToGroup(
    "HW_H" + S
);
```

construye el nombre del Group a partir del slot.

Esto evita escribir 48 bloques distintos de creación.

---

# 60. Fin de la ronda

Después de crear todas las hordas correspondientes:

```cpp
nextWave += WAVE_INTERVAL;
```

y se reinician:

```text
warn30
warn3
warn2
warn1
```

para permitir los avisos de la ronda siguiente.

---

# 61. Qué ocurre después de R40

Al principio del bucle se comprueba:

```cpp
if(w >= MAX_ROUNDS)
    continue;
```

Como:

```text
MAX_ROUNDS = 40
```

una vez generada R40 la Sequence permanece viva, despertando cada 250 ms, pero ya no genera nuevas rondas.

---

# 62. No existe un mensaje específico de finalización

Después de R40 no se emite ninguna notificación adicional del tipo:

```text
TODAS LAS RONDAS COMPLETADAS
```

La última notificación de creación es:

```text
RONDA 40/40 - ¡DOS HORDAS HAN LLEGADO!
```

---

# 63. No espera a que una horda anterior muera

El calendario de oleadas es puramente temporal.

No existe una condición:

```text
esperar hasta que la horda anterior sea destruida
```

Por tanto una nueva ronda aparece aunque todavía existan zombies de rondas anteriores.

---

# 64. Consecuencia del intervalo de dos minutos

Con hordas tan grandes y ciudades amuralladas, es posible que una oleada siga activa cuando llegue la siguiente.

A partir de R33 pueden añadirse dos nuevas hordas cada dos minutos aunque otras continúen vivas.

---

# 65. No existe límite global de zombies vivos

La Sequence no consulta el número total de zombies activos antes de crear otra ronda.

No existe un cap global.

El único límite programado es:

```text
40 rondas
```

---

# 66. Dificultad

La cabecera describe la configuración como:

```text
ligeramente superior a HARD
```

Eso es una etiqueta de diseño.

El código no contiene una variable `difficulty`.

La dificultad se implementa mediante:

- cantidad de unidades;
- nivel;
- composición;
- frecuencia;
- aparición de unidades especiales;
- doble horda final.

---

# 67. No hay escalado según número de jugadores

Las composiciones son fijas.

No se comprueba:

- cuántos jugadores humanos quedan;
- cuántas ciudades siguen vivas;
- cuánto territorio controla la horda.

Por tanto una ronda siempre tiene la misma composición para un mismo `w`.

---

# 68. Composición multicultural

Las hordas mezclan unidades de distintas civilizaciones.

Todas se crean como Player 12 independientemente de su cultura original.

Esto permite utilizar las unidades más adecuadas de varios rosters dentro de un mismo ejército zombie.

---

# 69. Flujo completo de una ronda

```text
esperar hasta nextWave
        ↓
mostrar avisos previos
        ↓
w += 1
        ↓
determinar:
1 horda o 2 hordas
        ↓
elegir sa y sb distintos
        ↓
por cada horda:
    calcular slot S
        ↓
    elegir posición HordeSpawn
        ↓
    cargar composición de ronda
        ↓
    Place() de todas las unidades
        ↓
    SetLevel(lv)
    SetFeeding(false)
    SetNoAIFlag(true)
        ↓
    AddToGroup("HW_H"+S)
        ↓
    escribir:
    HW_ACTIVE = 1
    HW_ROUND = w
    HW_TX = 0
    HW_TY = 0
    HW_OWNER = 0
    HW_REWARDED = 0
        ↓
ZombieTactical debe hacerse cargo
        ↓
nextWave += 120000
```

---

# 70. Arquitectura completa con las otras Sequences

El diseño pretende funcionar así:

```text
ZombieWaves_Main_40R_48H_FINAL_UI
        ↓
crea horda
HW_HS
HW_ACTIVES = 1
HW_ROUNDS = ronda
        ↓
ZombieTactical_Main
        ↓
selecciona Foro
marcha
asedio
captura
        ↓
si horda muere:
ZR_OWNERS
ZR_ROUNDS
ZR_XS
ZR_YS
ZR_PENDINGS = 1
        ↓
ZombieRewards_Main_48H_40R
        ↓
entrega refuerzos
```

La arquitectura es modular: cada Sequence tiene una responsabilidad distinta.

---

# 71. Configuración exacta en el editor

La parte manual debe quedar aproximadamente así:

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   ├── HordeSpawn_01
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_02
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_03
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_04
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_05
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_06
│   │   └── exactamente 1 marcador/objeto
│   ├── HordeSpawn_07
│   │   └── exactamente 1 marcador/objeto
│   └── HordeSpawn_08
│       └── exactamente 1 marcador/objeto
│
└── Sequences
    └── ZombieWaves_Main_40R_48H_FINAL_UI
        ├── pegar código
        ├── Compile
        └── Autorun allowed = Sí
```

---

# 72. Elementos que no hay que crear manualmente

No son necesarios:

- `HW_H1..HW_H48` poblados manualmente;
- Areas;
- Holders;
- rutas;
- Groups de Gates;
- Groups de Townhalls objetivo;
- puntos de brecha;
- puntos de asedio;
- una Sequence por ronda;
- una Sequence por spawn.

---

# 73. Comprobaciones antes de probar

Conviene verificar expresamente:

1. `CapitalForum_P1` contiene exactamente un Building.
2. Los ocho `HordeSpawn_XX` contienen exactamente un objeto.
3. Los ocho puntos tienen espacio suficiente para formaciones de cientos de unidades.
4. Player 12 está reservado para la horda.
5. `ZombieTactical_Main` está activo.
6. `ZombieRewards_Main_48H_40R` está activo si se quieren recompensas.
7. La versión táctica utilizada soporta los mismos slots que `ZombieWaves_Main`.
8. Si se desea un inicio a 30 minutos, corregir `START_DELAY`, porque actualmente vale 0.

---

# 74. Dos puntos que deben corregirse o decidirse antes de considerar esta versión final

## 74.1 Delay inicial

Comentario:

```text
30 minutos
```

Código:

```cpp
START_DELAY = 0;
```

El comportamiento real actual es inicio inmediato.

## 74.2 Hordas 33 a 48

Esta Sequence genera:

```text
HW_H33..HW_H48
```

pero la versión de `ZombieTactical_Main_v10_5_WALL_STUCK_GATE` aportada en el paso anterior sólo controla:

```text
HW_H1..HW_H32
```

Por tanto las versiones actuales no están completamente alineadas para R33-R40.

---

# 75. Resumen funcional

`ZombieWaves_Main_40R_48H_FINAL_UI` realiza este trabajo:

```text
resolver CapitalForum_P1
        ↓
resolver 8 puntos HordeSpawn
        ↓
programar 40 rondas
        ↓
mostrar avisos de interfaz
        ↓
R1-R32:
    crear 1 horda
        ↓
R33-R40:
    crear 2 hordas
    en spawns distintos
        ↓
asignar slot H1..H48
        ↓
crear composición fija de la ronda
        ↓
todas las unidades → Player 12
        ↓
SetLevel
SetFeeding(false)
SetNoAIFlag(true)
        ↓
AddToGroup("HW_H"+S)
        ↓
activar estado HW_*
        ↓
dejar el control táctico a ZombieTactical_Main
```

Es la capa de **generación y calendario** del modo Zombies. La principal revisión pendiente en la combinación actual de Sequences es alinear el soporte de `H33..H48` en la IA táctica y decidir si el `START_DELAY` final debe ser realmente 0 o 30 minutos.

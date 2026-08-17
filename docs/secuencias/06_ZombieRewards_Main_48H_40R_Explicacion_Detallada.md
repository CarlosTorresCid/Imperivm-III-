# Secuencia 6 — `ZombieRewards_Main_48H_40R`

`ZombieRewards_Main_48H_40R` es la Sequence encargada de **entregar las recompensas militares del modo Zombies cuando una horda ha sido aniquilada**.

No detecta por sí misma la muerte de las hordas y tampoco decide qué ciudad estaba siendo atacada. Su función comienza cuando otra parte del sistema Zombies deja preparada una recompensa pendiente mediante las variables `ZR_PENDING1` a `ZR_PENDING48` y sus datos asociados.

La Sequence revisa continuamente esos 48 slots. Cuando encuentra uno pendiente, recupera:

- el jugador que debe recibir la recompensa;
- la ronda de la horda destruida;
- las coordenadas del Foro objetivo;
- la composición fija de recompensa correspondiente a esa ronda.

Después genera los refuerzos alrededor de las coordenadas guardadas, intenta vincularlos al `Settlement` del Foro correspondiente y muestra una notificación.

El sistema está preparado para:

```text
48 slots simultáneos de seguimiento de hordas
40 rondas distintas de recompensa
```

La Sequence debe configurarse con **`Autorun allowed`**.

---

# 1. Preparación necesaria en el editor

Hay que crear una única Sequence:

```text
Scenario
└── Map
    └── Sequences
        └── ZombieRewards_Main_48H_40R
```

Dentro de ella:

1. Pegar el código completo.
2. Marcar **`Autorun allowed`**.
3. Compilar.
4. Guardar el escenario.

Esta Sequence forma parte del sistema Zombies y **no funciona de manera autónoma**. Necesita que otra Sequence escriba los estados `ZR_PENDING`, `ZR_OWNER`, `ZR_ROUND`, `ZR_X` y `ZR_Y`.

---

# 2. Group manual obligatorio

Esta Sequence sí necesita un Group concreto:

```text
CapitalForum_P1
```

Debe existir en el editor y resolver exactamente a **un objeto**.

Al arrancar se ejecuta:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

Después se exige:

```cpp
if (stateList.count != 1)
```

Si no contiene exactamente un objeto, la Sequence muestra un error y se detiene permanentemente.

---

# 3. Qué debe contener `CapitalForum_P1`

El único objeto del Group debe poder convertirse correctamente a `Building`:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

En la arquitectura actual se utiliza el Foro capital de Player 1 como **objeto de estado global**.

Esto significa que `CapitalForum_P1` cumple aquí una función doble:

```text
objeto real del mapa
+
soporte persistente para las variables del sistema Zombies
```

No se utiliza necesariamente como lugar donde aparecen todas las recompensas.

---

# 4. `CapitalForum_P1` funciona como memoria global

La variable:

```cpp
Building state;
```

queda apuntando al edificio contenido en:

```text
CapitalForum_P1
```

Sobre ese Building se realizan todas las operaciones:

```cpp
EnvReadInt(state, ...)
EnvWriteInt(state, ...)
```

Por ejemplo:

```cpp
EnvReadInt(
    state,
    "ZR_PENDING17"
);
```

Por tanto los 48 slots de recompensa comparten un mismo objeto físico como almacenamiento.

Conceptualmente:

```text
CapitalForum_P1
└── estado global Zombies
    ├── ZR_PENDING1
    ├── ZR_OWNER1
    ├── ZR_ROUND1
    ├── ZR_X1
    ├── ZR_Y1
    ├── ...
    ├── ZR_PENDING48
    ├── ZR_OWNER48
    ├── ZR_ROUND48
    ├── ZR_X48
    └── ZR_Y48
```

---

# 5. Qué ocurre si `CapitalForum_P1` está mal configurado

Si al arrancar:

```text
CapitalForum_P1.count != 1
```

se ejecuta:

```cpp
UserNotification(
    "ZombieRewards_Main: FALLO - grupo CapitalForum_P1 no resuelve a 1 objeto",
    "",
    Point(0,0),
    1
);
```

y después:

```cpp
while(1)
    Sleep(60000);
```

La Sequence entra en un bucle infinito de espera.

Por tanto no continuará procesando ninguna recompensa.

Este Group es obligatorio.

---

# 6. No hacen falta `CapitalForum_P2` a `CapitalForum_P8` para esta Sequence

Aunque otras Sequences del proyecto utilizan:

```text
CapitalForum_P1
CapitalForum_P2
...
CapitalForum_P8
```

esta Sequence concreta sólo hace referencia literal a:

```text
CapitalForum_P1
```

El Foro que recibe cada recompensa se localiza después de forma dinámica mediante:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    owner
)
```

y las coordenadas almacenadas.

Por tanto, para **esta Sequence concreta**, el único Group manual que lee directamente es:

```text
CapitalForum_P1
```

---

# 7. No hacen falta Groups para las hordas

La Sequence no utiliza:

```cpp
Group("Horde...")
```

para determinar qué horda ha muerto.

Toda esa información debe llegar ya procesada mediante el sistema:

```text
ZR_PENDING1..48
```

Por tanto no hay que crear Groups adicionales de recompensa para los 48 slots.

---

# 8. No hacen falta Areas ni Holders

La Sequence no utiliza Areas.

Tampoco necesita Holders manuales.

Las posiciones de aparición se calculan mediante coordenadas:

```text
x
y
```

guardadas por el sistema Zombies.

---

# 9. Dependencia de otras Sequences del modo Zombies

`ZombieRewards_Main_48H_40R` es un **consumidor de eventos**.

Otra parte del sistema debe escribir para un slot determinado:

```text
ZR_PENDINGH = 1
ZR_OWNERH   = jugador recompensado
ZR_ROUNDH   = ronda
ZR_XH       = coordenada X del Foro
ZR_YH       = coordenada Y del Foro
```

Ejemplo conceptual:

```text
Horda 12 eliminada
↓
otra Sequence decide que Player 4 la ha detenido
↓
escribe:

ZR_PENDING12 = 1
ZR_OWNER12   = 4
ZR_ROUND12   = 17
ZR_X12       = 15200
ZR_Y12       = 8800
```

Después `ZombieRewards_Main_48H_40R` consume ese estado.

---

# 10. Los 48 slots no significan 48 rondas

El nombre:

```text
48H_40R
```

refleja dos dimensiones diferentes:

```text
48H
→ hasta 48 slots de horda/evento

40R
→ 40 configuraciones de recompensa por ronda
```

La Sequence recorre:

```cpp
for(H = 1; H <= 48; H += 1)
```

pero sólo acepta:

```cpp
roundNow >= 1
&&
roundNow <= 40
```

Por tanto puede haber más slots de seguimiento que rondas distintas.

---

# 11. Frecuencia de comprobación

El bucle principal es:

```cpp
while(1)
{
    Sleep(250);
    ...
}
```

Por tanto la Sequence revisa los 48 slots aproximadamente cada:

```text
250 ms
```

Es decir, hasta cuatro veces por segundo.

Una recompensa pendiente debería ser detectada muy rápidamente.

---

# 12. Por qué las lecturas `ZR_PENDING` están desenrolladas

El código contiene 48 comprobaciones explícitas:

```cpp
if(H==1)
    pending =
        EnvReadInt(
            state,
            "ZR_PENDING1"
        );

if(H==2)
    pending =
        EnvReadInt(
            state,
            "ZR_PENDING2"
        );
```

y así hasta:

```text
ZR_PENDING48
```

Esto es deliberado.

La cabecera indica que una versión anterior utilizaba una clave dinámica equivalente a:

```cpp
EnvReadInt(
    state,
    "ZR_PENDING" + H
);
```

y ese patrón producía:

```text
No matching function with name EnvReadInt
```

Por eso las lecturas se han escrito manualmente una a una.

---

# 13. Regla importante para `EnvReadInt`

En esta versión se evita construir dinámicamente el nombre de la clave para `EnvReadInt`.

Se utiliza:

```cpp
if(H==N)
    EnvReadInt(
        state,
        "CLAVE_LITERAL"
    );
```

Esto afecta no sólo a `ZR_PENDING`, sino también a:

```text
ZR_OWNER
ZR_ROUND
ZR_X
ZR_Y
```

Todos esos accesos están escritos con nombres literales para cada slot.

---

# 14. Qué significa `pending`

Cada slot tiene un indicador:

```text
ZR_PENDING1
...
ZR_PENDING48
```

La Sequence empieza cada iteración con:

```cpp
pending = 0;
```

Después lee la variable correspondiente a `H`.

Si:

```cpp
pending != 1
```

ejecuta:

```cpp
continue;
```

Por tanto sólo se procesa un slot cuando su valor es exactamente:

```text
1
```

---

# 15. Consumo de una recompensa pendiente

En cuanto detecta:

```text
ZR_PENDINGH = 1
```

la Sequence escribe inmediatamente:

```text
ZR_PENDINGH = 0
```

y recupera:

```text
ZR_OWNERH
ZR_ROUNDH
ZR_XH
ZR_YH
```

Ejemplo para el slot 5:

```cpp
if(H==5)
{
    EnvWriteInt(
        state,
        "ZR_PENDING5",
        0
    );

    owner =
        EnvReadInt(
            state,
            "ZR_OWNER5"
        );

    roundNow =
        EnvReadInt(
            state,
            "ZR_ROUND5"
        );

    x =
        EnvReadInt(
            state,
            "ZR_X5"
        );

    y =
        EnvReadInt(
            state,
            "ZR_Y5"
        );
}
```

---

# 16. El `pending` se limpia antes de validar los datos

Este detalle es importante.

El orden real es:

```text
detectar pending = 1
↓
poner pending = 0
↓
leer owner / round / x / y
↓
validar owner y round
```

Después se comprueba:

```cpp
if(
    owner < 1
    ||
    owner > 8
    ||
    roundNow < 1
    ||
    roundNow > 40
)
    continue;
```

Por tanto si los datos son inválidos, el slot ya ha sido consumido.

---

# 17. Consecuencia de un slot mal escrito

Ejemplo:

```text
ZR_PENDING7 = 1
ZR_OWNER7   = 12
ZR_ROUND7   = 10
```

La Sequence hará:

```text
ZR_PENDING7 = 0
↓
owner = 12
↓
owner no está entre 1 y 8
↓
continue
```

La recompensa queda descartada.

No existe un reintento automático.

---

# 18. Players válidos

Sólo se permiten:

```text
Player 1
...
Player 8
```

La condición es:

```cpp
owner < 1
||
owner > 8
```

Por tanto Player 12 —utilizado como jugador técnico para las hordas— nunca puede recibir estas recompensas.

---

# 19. Rondas válidas

Sólo se admiten:

```text
1
...
40
```

La composición militar está definida manualmente para cada una de esas 40 rondas.

Una recompensa con:

```text
roundNow = 41
```

sería descartada.

---

# 20. Arquitectura de la composición de recompensa

La Sequence dispone de hasta diez slots de clase:

```text
c1 ... c10
```

y diez cantidades:

```text
n1 ... n10
```

Antes de procesar cada ronda se limpian:

```cpp
c1="";
c2="";
...
c10="";

n1=0;
n2=0;
...
n10=0;
```

Después se establece:

```cpp
lv = 1;
```

y cada ronda sobrescribe:

- el nivel;
- las clases;
- las cantidades.

---

# 21. Recompensas normales y recompensas especiales

El diseño distingue:

```text
rondas normales
```

y:

```text
cada 5 rondas
```

Las rondas:

```text
5
10
15
20
25
30
35
40
```

tienen recompensas de mayor tamaño y variedad.

Además:

```text
R20
R30
R40
```

incluyen héroes.

---

# 22. Héroes

Según el código, sólo aparecen héroes en:

```text
Ronda 20
Ronda 30
Ronda 40
```

Concretamente:

```text
R20 → 1 BHero1
R30 → 1 CHero1
R40 → 1 MHero1 + 1 THero1
```

No hay héroes en las demás rondas.

---

# 23. Tabla completa de recompensas — Rondas 1 a 10

| Ronda | Nivel | Recompensa |
|---:|---:|---|
| 1 | 4 | 3 `RPraetorian` + 3 `BHighlander` |
| 2 | 4 | 3 `IEliteGuard` + 3 `CNoble` |
| 3 | 5 | 3 `RLiberatus` + 3 `EAnubisWarrior` |
| 4 | 5 | 3 `TValkyrie` + 3 `GTridentWarrior` |
| 5 | 6 | 5 `RPraetorian` + 5 `IEliteGuard` + 5 `BHighlander` |
| 6 | 6 | 4 `CNoble` + 4 `EAnubisWarrior` |
| 7 | 7 | 4 `RLiberatus` + 4 `TValkyrie` |
| 8 | 7 | 4 `GTridentWarrior` + 4 `BHighlander` |
| 9 | 8 | 4 `EHorusWarrior` + 4 `IEliteGuard` |
| 10 | 8 | 5 `RPraetorian` + 5 `RLiberatus` + 5 `TValkyrie` + 2 `CWarElephant` |

---

# 24. Número de unidades — Rondas 1 a 10

| Ronda | Total |
|---:|---:|
| 1 | 6 |
| 2 | 6 |
| 3 | 6 |
| 4 | 6 |
| 5 | 15 |
| 6 | 8 |
| 7 | 8 |
| 8 | 8 |
| 9 | 8 |
| 10 | 17 |

Las primeras rondas entregan refuerzos deliberadamente pequeños.

---

# 25. Tabla completa de recompensas — Rondas 11 a 20

| Ronda | Nivel | Recompensa |
|---:|---:|---|
| 11 | 9 | 5 `CNoble` + 5 `EAnubisWarrior` |
| 12 | 9 | 5 `BHighlander` + 5 `GTridentWarrior` |
| 13 | 10 | 5 `IEliteGuard` + 5 `EHorusWarrior` |
| 14 | 10 | 5 `RLiberatus` + 5 `RPraetorian` |
| 15 | 11 | 5 `BHighlander` + 5 `EAnubisWarrior` + 5 `CNoble` + 5 `IEliteGuard` + 2 `CWarElephant` |
| 16 | 11 | 6 `TValkyrie` + 6 `GTridentWarrior` |
| 17 | 12 | 6 `RLiberatus` + 6 `EHorusWarrior` |
| 18 | 12 | 6 `RPraetorian` + 6 `CNoble` |
| 19 | 13 | 6 `IEliteGuard` + 6 `EAnubisWarrior` |
| 20 | 13 | 5 `RLiberatus` + 5 `TValkyrie` + 5 `GTridentWarrior` + 5 `BHighlander` + 3 `CWarElephant` + 1 `BHero1` |

---

# 26. Número de unidades — Rondas 11 a 20

| Ronda | Total |
|---:|---:|
| 11 | 10 |
| 12 | 10 |
| 13 | 10 |
| 14 | 10 |
| 15 | 22 |
| 16 | 12 |
| 17 | 12 |
| 18 | 12 |
| 19 | 12 |
| 20 | 24 |

La ronda 20 es la primera recompensa con héroe.

---

# 27. Tabla completa de recompensas — Rondas 21 a 30

| Ronda | Nivel | Recompensa |
|---:|---:|---|
| 21 | 14 | 7 `EHorusWarrior` + 7 `CNoble` |
| 22 | 14 | 7 `RPraetorian` + 7 `IEliteGuard` |
| 23 | 15 | 7 `RLiberatus` + 7 `EAnubisWarrior` |
| 24 | 15 | 7 `TValkyrie` + 7 `GTridentWarrior` |
| 25 | 16 | 6 `RLiberatus` + 6 `TValkyrie` + 6 `BHighlander` + 6 `IEliteGuard` + 4 `CWarElephant` |
| 26 | 16 | 8 `CNoble` + 8 `EHorusWarrior` |
| 27 | 17 | 8 `RPraetorian` + 8 `GTridentWarrior` |
| 28 | 17 | 8 `EAnubisWarrior` + 8 `BHighlander` |
| 29 | 18 | 8 `RLiberatus` + 8 `TValkyrie` |
| 30 | 18 | 6 `RLiberatus` + 6 `TValkyrie` + 6 `GTridentWarrior` + 6 `IEliteGuard` + 6 `EHorusWarrior` + 5 `CWarElephant` + 1 `CHero1` |

---

# 28. Número de unidades — Rondas 21 a 30

| Ronda | Total |
|---:|---:|
| 21 | 14 |
| 22 | 14 |
| 23 | 14 |
| 24 | 14 |
| 25 | 28 |
| 26 | 16 |
| 27 | 16 |
| 28 | 16 |
| 29 | 16 |
| 30 | 36 |

---

# 29. Tabla completa de recompensas — Rondas 31 a 40

| Ronda | Nivel | Recompensa |
|---:|---:|---|
| 31 | 19 | 9 `IEliteGuard` + 9 `CNoble` |
| 32 | 19 | 9 `BHighlander` + 9 `EHorusWarrior` |
| 33 | 20 | 9 `RPraetorian` + 9 `EAnubisWarrior` |
| 34 | 20 | 9 `RLiberatus` + 9 `GTridentWarrior` |
| 35 | 20 | 8 `RLiberatus` + 8 `TValkyrie` + 8 `IEliteGuard` + 8 `EHorusWarrior` + 5 `CWarElephant` |
| 36 | 21 | 10 `CNoble` + 10 `BHighlander` |
| 37 | 21 | 10 `RPraetorian` + 10 `EAnubisWarrior` |
| 38 | 22 | 10 `RLiberatus` + 10 `TValkyrie` |
| 39 | 22 | 10 `GTridentWarrior` + 10 `IEliteGuard` |
| 40 | 22 | 7 `RLiberatus` + 7 `TValkyrie` + 7 `GTridentWarrior` + 7 `BHighlander` + 7 `IEliteGuard` + 7 `EHorusWarrior` + 7 `EAnubisWarrior` + 6 `CWarElephant` + 1 `MHero1` + 1 `THero1` |

---

# 30. Número de unidades — Rondas 31 a 40

| Ronda | Total |
|---:|---:|
| 31 | 18 |
| 32 | 18 |
| 33 | 18 |
| 34 | 18 |
| 35 | 37 |
| 36 | 20 |
| 37 | 20 |
| 38 | 20 |
| 39 | 20 |
| 40 | 57 |

La ronda 40 es la recompensa más grande del sistema.

---

# 31. Progresión de nivel

Los niveles aumentan de manera gradual:

```text
R1-R2   → nivel 4
R3-R4   → nivel 5
R5-R6   → nivel 6
R7-R8   → nivel 7
R9-R10  → nivel 8
R11-R12 → nivel 9
R13-R14 → nivel 10
R15-R16 → nivel 11
R17-R18 → nivel 12
R19-R20 → nivel 13
R21-R22 → nivel 14
R23-R24 → nivel 15
R25-R26 → nivel 16
R27-R28 → nivel 17
R29-R30 → nivel 18
R31-R32 → nivel 19
R33-R35 → nivel 20
R36-R37 → nivel 21
R38-R40 → nivel 22
```

El nivel se aplica a todas las unidades creadas en esa recompensa:

```cpp
u.SetLevel(lv);
```

---

# 32. Las recompensas mezclan civilizaciones

La composición no depende de la civilización del jugador recompensado.

Por ejemplo, Player 1 puede recibir:

```text
BHighlander
EAnubisWarrior
CNoble
TValkyrie
...
```

según la ronda.

La recompensa representa tropas especiales mezcladas de distintas culturas.

El propietario de todas ellas será siempre:

```cpp
owner
```

es decir, el jugador que recibió el premio.

---

# 33. Localización del Foro objetivo

Después de definir la recompensa, la Sequence intenta localizar el Foro al que corresponde el evento.

Primero obtiene todos los Townhall actuales del propietario:

```cpp
forums =
    ClassPlayerObjs(
        "BaseTownhall",
        owner
    )
    .GetObjList();

forums.ClearDead();
```

Después recorre la lista.

---

# 34. El Foro se identifica por coordenadas exactas

La condición es:

```cpp
if(
    cand.pos.x == x
    &&
    cand.pos.y == y
)
```

Si ambas coordenadas coinciden exactamente con los valores almacenados en:

```text
ZR_XH
ZR_YH
```

se considera encontrado:

```cpp
forum = cand;
foundForum = 1;
```

---

# 35. Qué significa esto para el sistema Zombies

La Sequence que escribe el evento pendiente debe guardar las coordenadas exactas del Foro objetivo.

Debe existir coherencia entre:

```text
ZR_XH
ZR_YH
```

y:

```text
forum.pos.x
forum.pos.y
```

No se utiliza una búsqueda por proximidad.

Es una igualdad exacta.

---

# 36. El Foro debe pertenecer todavía al jugador recompensado para ser encontrado

La búsqueda se realiza sobre:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    owner
)
```

Por tanto sólo aparecen Townhall que en ese momento pertenecen al `owner`.

Si las coordenadas apuntan a un Foro que ya ha cambiado de propietario, no se encontrará mediante esta consulta.

---

# 37. `foundForum` no impide generar las tropas

Este es un detalle muy importante del código.

Después de la búsqueda:

```cpp
foundForum = 0;
```

puede seguir valiendo 0.

Sin embargo la creación de unidades **no está dentro de una condición `if(foundForum==1)`**.

Las unidades se generan igualmente mediante:

```cpp
u =
    Place(
        cls,
        pos,
        owner
    )
    .AsUnit();
```

Por tanto el Foro no necesita encontrarse para que aparezcan los refuerzos.

---

# 38. Para qué sirve realmente `foundForum`

Sólo controla esta línea:

```cpp
if(foundForum == 1)
    forum
        .settlement
        .ForceAddUnit(u);
```

Así:

```text
Foro encontrado
→ tropas aparecen
→ además se añaden a su Settlement

Foro no encontrado
→ tropas aparecen igualmente
→ pero no se ejecuta ForceAddUnit
```

La recompensa no se pierde por no localizar el Building.

---

# 39. Posición de aparición de las tropas

La Sequence utiliza un contador:

```cpp
rp = 0;
```

Cada unidad recibe una posición calculada alrededor de:

```text
(x, y)
```

que son las coordenadas guardadas del Foro objetivo.

---

# 40. Primera formación: hasta 28 unidades

Mientras:

```cpp
rp < 28
```

se utiliza:

```cpp
pos =
    Point(
        x + 450 + (rp % 7) * 110,
        y - 330 + (rp / 7) * 110
    );
```

Esto crea una cuadrícula de:

```text
7 columnas
×
4 filas
=
28 posiciones
```

a un lado del Foro.

---

# 41. Geometría de la primera formación

Las coordenadas X son:

```text
x + 450
x + 560
x + 670
x + 780
x + 890
x + 1000
x + 1110
```

Las filas Y son aproximadamente:

```text
y - 330
y - 220
y - 110
y
```

Por tanto los primeros 28 refuerzos se distribuyen en una formación ordenada.

---

# 42. Segunda formación: unidades 29 en adelante

Si:

```cpp
rp >= 28
```

se calcula:

```cpp
k = rp - 28;
```

y después:

```cpp
pos =
    Point(
        x - 1150 + (k % 7) * 110,
        y - 330 + (k / 7) * 110
    );
```

Esta segunda cuadrícula aparece al lado contrario.

---

# 43. La Sequence sí utiliza realmente las posiciones de spawn

A diferencia de algunas Sequences anteriores de recompensa, aquí:

```cpp
pos
```

sí se pasa directamente a:

```cpp
Place(
    cls,
    pos,
    owner
);
```

Por tanto las formaciones calculadas tienen efecto real.

No son variables sin usar.

---

# 44. Capacidad de las dos formaciones

La primera cuadrícula dispone de 28 posiciones iniciales.

La segunda continúa creciendo en filas según sea necesario.

Como la recompensa máxima es de 57 unidades en la ronda 40:

```text
28 unidades
→ primera formación

29 unidades restantes
→ segunda formación
```

El código puede acomodar toda la recompensa de la ronda 40.

---

# 45. Las unidades no aparecen dentro del Foro

La creación utiliza:

```cpp
Place(
    cls,
    pos,
    owner
)
```

donde `pos` está desplazado respecto a `x,y`.

Por tanto las tropas aparecen físicamente alrededor del Foro.

Después, si el Building correcto ha sido localizado:

```cpp
forum.settlement.ForceAddUnit(u);
```

las unidades se asocian además a ese Settlement.

---

# 46. Las tropas son normales

Esta Sequence no ejecuta:

```cpp
SetNoAIFlag(true)
```

ni:

```cpp
SetFeeding(false)
```

Tampoco impone órdenes posteriores.

Las recompensas son tropas normales del jugador.

Pueden:

- moverse libremente;
- ser usadas por el jugador;
- ser usadas por la IA;
- consumir comida según las reglas normales;
- combatir en cualquier lugar.

---

# 47. No hay regeneración de la recompensa

Una vez creadas las unidades, la Sequence no las sigue.

No existe ningún Group de recompensa.

Si mueren:

```text
no reaparecen
```

La recompensa sólo se concede de nuevo cuando otra horda genera otro evento `ZR_PENDING`.

---

# 48. No hay recompensa duplicada por el mismo evento si `pending` se consume correctamente

La primera operación sobre un evento válido es:

```text
ZR_PENDINGH = 0
```

Por tanto el mismo slot no se procesa otra vez en el siguiente ciclo salvo que otra Sequence vuelva a escribir:

```text
ZR_PENDINGH = 1
```

El productor de eventos controla cuándo un slot vuelve a estar disponible.

---

# 49. Los slots pueden reutilizarse

Nada en `ZombieRewards_Main_48H_40R` marca un slot como utilizado permanentemente.

Después de consumirlo:

```text
ZR_PENDINGH = 0
```

Otra Sequence puede más adelante reutilizar ese mismo número de slot con:

```text
nuevo owner
nueva ronda
nuevas coordenadas
ZR_PENDINGH = 1
```

Por tanto los 48 slots son canales de comunicación reutilizables.

---

# 50. Notificación de recompensa normal

Si la ronda no es múltiplo de 5:

```cpp
if(roundNow % 5 != 0)
```

se utiliza el texto:

```text
HORDA ANIQUILADA. Player X recibe refuerzos de ronda Y
```

---

# 51. Notificación de recompensa especial

Si:

```cpp
roundNow % 5 == 0
```

se utiliza:

```text
HORDA ANIQUILADA - RECOMPENSA ESPECIAL RONDA Y para Player X
```

Esto incluye:

```text
R5
R10
R15
R20
R25
R30
R35
R40
```

---

# 52. La notificación se envía a los ocho Players

El código hace:

```cpp
for(k = 1; k <= 8; k += 1)
{
    UserNotification(
        ...,
        Point(x,y),
        k
    );
}
```

Por tanto la misma notificación se envía individualmente a:

```text
Player 1
Player 2
Player 3
Player 4
Player 5
Player 6
Player 7
Player 8
```

No sólo al jugador recompensado.

---

# 53. Consecuencia del envío global

Todos los jugadores pueden saber:

- que una horda ha sido destruida;
- qué ronda era;
- qué Player recibió la recompensa.

Esto convierte la recompensa en un evento visible globalmente.

---

# 54. La notificación apunta a las coordenadas del Foro objetivo

Se utiliza:

```cpp
Point(x,y)
```

en `UserNotification`.

Por tanto la notificación queda espacialmente asociada a la ciudad/Foro correspondiente al evento.

---

# 55. No existe una comprobación de que la horda esté realmente muerta

Esta Sequence confía completamente en:

```text
ZR_PENDINGH = 1
```

No consulta:

- Group de la horda;
- unidades vivas;
- contador de zombies;
- propietario del ejército;
- objetivo táctico.

La detección de aniquilación pertenece a otra parte del sistema.

---

# 56. No determina quién “mató” la horda

El valor:

```text
ZR_OWNERH
```

ya debe contener el jugador que el sistema ha decidido recompensar.

`ZombieRewards_Main_48H_40R` no calcula:

- último golpe;
- mayor daño;
- jugador con más tropas;
- propietario de la ciudad;
- jugador más cercano.

Simplemente confía en el dato `owner`.

---

# 57. No decide la ronda actual global

Tampoco consulta una variable global de oleada.

Utiliza el valor:

```text
ZR_ROUNDH
```

asociado al slot de horda concreto.

Esto permite que distintos slots puedan estar asociados, al menos arquitectónicamente, a rondas diferentes.

---

# 58. Diseño desacoplado

La arquitectura puede representarse así:

```text
ZombieWaves / control de hordas
        ↓
crea y sigue una horda
        ↓
ZombieTactical / lógica de combate
        ↓
la horda es eliminada
        ↓
otra lógica decide:
    owner
    round
    forum X/Y
        ↓
escribe ZR_PENDINGH = 1
        ↓
ZombieRewards_Main_48H_40R
        ↓
consume el evento
        ↓
crea la recompensa
```

La ventaja es que el sistema de recompensa no necesita conocer la implementación interna de la IA de la horda.

---

# 59. Qué ocurre si dos hordas son eliminadas casi al mismo tiempo

En cada ciclo se recorren los slots:

```cpp
for(H = 1; H <= 48; H += 1)
```

Por tanto pueden existir simultáneamente:

```text
ZR_PENDING4 = 1
ZR_PENDING19 = 1
ZR_PENDING27 = 1
```

La Sequence procesará los tres dentro de la misma pasada, uno detrás de otro.

No existe una limitación de una recompensa por ciclo.

---

# 60. Orden de procesamiento de eventos simultáneos

Los slots se procesan en orden:

```text
1
2
3
...
48
```

Por tanto si varias recompensas están pendientes, primero se procesa la de menor número de slot.

Esto normalmente no cambia la lógica del juego, pero define el orden de creación en un mismo ciclo.

---

# 61. Posible carga en un mismo ciclo

La ronda 40 genera:

```text
57 unidades
```

Si varias hordas de ronda alta son eliminadas simultáneamente, la Sequence puede ejecutar múltiples `Place()` en una misma pasada.

Ejemplo:

```text
4 recompensas R40 simultáneas
→ 4 × 57
→ 228 unidades creadas en una pasada
```

El código no escalona la generación.

Esto debe tenerse en cuenta en pruebas de rendimiento.

---

# 62. La recompensa se define por ronda, no por civilización del defensor

Todos los Players reciben exactamente la misma composición para una ronda concreta.

Ejemplo:

```text
Ronda 10
```

si la recibe Player 1:

```text
5 RPraetorian
5 RLiberatus
5 TValkyrie
2 CWarElephant
```

Si la recibe Player 8:

```text
las mismas clases
```

pero todas son propiedad de Player 8 porque `Place()` utiliza:

```cpp
owner
```

---

# 63. Uso de unidades especiales

Las recompensas recurren principalmente a unidades destacadas o especiales de varias civilizaciones:

```text
RPraetorian
RLiberatus
TValkyrie
GTridentWarrior
BHighlander
IEliteGuard
CNoble
CWarElephant
EHorusWarrior
EAnubisWarrior
```

A partir de las rondas avanzadas aumenta tanto la cantidad como la variedad.

---

# 64. Aparición progresiva de elefantes

`CWarElephant` aparece en las rondas especiales:

```text
R10 → 2
R15 → 2
R20 → 3
R25 → 4
R30 → 5
R35 → 5
R40 → 6
```

No aparece en las rondas normales.

---

# 65. Progresión de tamaño de las recompensas normales

Las rondas normales avanzan aproximadamente así:

```text
R1-R4   → 6 unidades
R6-R9   → 8 unidades
R11-R14 → 10 unidades
R16-R19 → 12 unidades
R21-R24 → 14 unidades
R26-R29 → 16 unidades
R31-R34 → 18 unidades
R36-R39 → 20 unidades
```

Esto produce una progresión muy regular.

---

# 66. Progresión de las recompensas especiales

Las rondas múltiplo de 5 aumentan notablemente:

```text
R5  → 15
R10 → 17
R15 → 22
R20 → 24
R25 → 28
R30 → 36
R35 → 37
R40 → 57
```

Son hitos de recompensa claramente superiores a las rondas normales.

---

# 67. Hitos con héroe

Las recompensas heroicas son:

## Ronda 20

```text
1 BHero1
```

## Ronda 30

```text
1 CHero1
```

## Ronda 40

```text
1 MHero1
+
1 THero1
```

El código no crea héroes en R10, R15, R25 o R35 aunque también sean rondas especiales.

---

# 68. No se aplica `SetFood()`

Las unidades únicamente reciben:

```cpp
u.SetLevel(lv);
```

No se ejecuta:

```cpp
SetFood(...)
```

ni:

```cpp
SetFeeding(false)
```

Por tanto la Sequence deja el sistema de comida con sus valores y reglas normales.

---

# 69. No se aplica `SetNoAIFlag()`

Las unidades de recompensa no quedan protegidas frente a la IA estratégica.

Si el propietario es una CPU, puede utilizarlas según su comportamiento normal.

---

# 70. Uso de `ForceAddUnit()`

Cuando se encuentra el Foro:

```cpp
if(foundForum == 1)
{
    forum
        .settlement
        .ForceAddUnit(u);
}
```

Las unidades aparecen físicamente en la formación exterior y, además, quedan asociadas al Settlement.

La creación física no depende de `ForceAddUnit()`.

---

# 71. Qué ocurre si el Foro no se encuentra

Supongamos que:

```text
owner = 3
x = 15000
y = 9000
```

pero Player 3 ya no posee ningún `BaseTownhall` exactamente en esas coordenadas.

Entonces:

```text
foundForum = 0
```

pero la Sequence continúa:

```text
calcula posiciones alrededor de x,y
↓
Place(...)
↓
crea las tropas de Player 3
↓
no ejecuta ForceAddUnit
```

Por tanto la recompensa sigue existiendo.

---

# 72. Qué ocurre si las coordenadas son incorrectas

Como `Place()` usa directamente:

```text
x
y
```

un error en `ZR_XH` o `ZR_YH` puede hacer que las tropas aparezcan en una posición incorrecta del mapa.

La Sequence no valida:

- accesibilidad;
- terreno;
- distancia a un Townhall;
- agua;
- obstáculos;
- si las coordenadas están dentro de la zona jugable.

La responsabilidad de escribir coordenadas correctas pertenece al productor del evento.

---

# 73. La búsqueda del Foro es exacta, no tolerante

El código utiliza:

```cpp
cand.pos.x == x
&&
cand.pos.y == y
```

No existe margen como:

```text
DistTo < 100
```

Por tanto cualquier diferencia entre las coordenadas almacenadas y las coordenadas reales del Building hará que:

```text
foundForum = 0
```

aunque el punto esté muy cerca.

---

# 74. No se utiliza el Group de capital para localizar la ciudad recompensada

Una vez iniciado el sistema, el destino se determina por:

```text
owner
+
x
+
y
```

No por:

```text
CapitalForum_Powner
```

Esto permite que la recompensa se entregue a **cualquier Foro actual del jugador**, no sólo a su capital inicial, siempre que las coordenadas correspondan a ese Foro.

---

# 75. Soporte para ciudades conquistadas

Como la búsqueda utiliza:

```cpp
ClassPlayerObjs(
    "BaseTownhall",
    owner
)
```

incluye cualquier Townhall que actualmente pertenezca al jugador, incluso si originalmente era neutral y fue conquistado después.

Por tanto la arquitectura permite recompensar una ciudad adquirida durante la partida.

---

# 76. Diferencia frente a sistemas basados en `CapitalForum_P1..P8`

En esta Sequence:

```text
CapitalForum_P1
→ sólo almacena estado global
```

mientras que el destino real:

```text
se busca dinámicamente
```

Esto evita tener que crear un Group manual para cada una de las posibles ciudades que pueden ser atacadas por las hordas.

---

# 77. Flujo completo de un evento de recompensa

```text
otra Sequence detecta horda aniquilada
        ↓
elige slot H
        ↓
escribe:
ZR_OWNERH
ZR_ROUNDH
ZR_XH
ZR_YH
ZR_PENDINGH = 1
        ↓
ZombieRewards_Main espera máximo ~250 ms
        ↓
detecta ZR_PENDINGH = 1
        ↓
lo pone a 0
        ↓
lee owner / round / x / y
        ↓
valida Player 1..8 y ronda 1..40
        ↓
carga composición fija de esa ronda
        ↓
busca BaseTownhall del owner en x,y
        ↓
calcula formación
        ↓
crea todas las tropas
        ↓
SetLevel(lv)
        ↓
si encuentra Foro:
    ForceAddUnit
        ↓
envía notificación a Players 1..8
```

---

# 78. Flujo de una ronda normal

Ejemplo:

```text
Ronda 17
```

La configuración es:

```cpp
lv = 12;
c1 = "RLiberatus";
n1 = 6;
c2 = "EHorusWarrior";
n2 = 6;
```

Resultado:

```text
12 unidades nivel 12
```

propiedad del Player almacenado en `ZR_OWNERH`.

---

# 79. Flujo de una ronda especial

Ejemplo:

```text
Ronda 30
```

La composición es:

```text
6 RLiberatus
6 TValkyrie
6 GTridentWarrior
6 IEliteGuard
6 EHorusWarrior
5 CWarElephant
1 CHero1
```

Total:

```text
36 unidades nivel 18
```

Después se muestra:

```text
HORDA ANIQUILADA - RECOMPENSA ESPECIAL RONDA 30 para Player X
```

a los ocho Players.

---

# 80. Preparación exacta en el editor

La configuración mínima de esta Sequence es:

```text
Map
├── Sequences
│   └── ZombieRewards_Main_48H_40R
│       ├── pegar código
│       ├── Compile
│       └── Autorun allowed = Sí
│
└── Groups
    └── CapitalForum_P1
        └── exactamente 1 Building
```

---

# 81. Elementos adicionales que no hay que crear para esta Sequence

No necesita manualmente:

- `CapitalForum_P2` a `CapitalForum_P8` para su propia lógica;
- Groups de recompensa;
- Groups para cada horda;
- 48 Groups para los slots;
- Areas;
- Holders;
- marcadores de spawn;
- una Sequence por ronda;
- una Sequence por horda;
- una Sequence por jugador.

Los 48 canales se almacenan mediante `EnvReadInt/EnvWriteInt` sobre el Building `state`.

---

# 82. Dependencias que sí deben existir en el sistema completo

Aunque esta Sequence sólo exige directamente `CapitalForum_P1`, el **modo Zombies completo** necesita otra lógica capaz de producir los datos:

```text
ZR_PENDING1..48
ZR_OWNER1..48
ZR_ROUND1..48
ZR_X1..48
ZR_Y1..48
```

Si nadie escribe:

```text
ZR_PENDINGH = 1
```

esta Sequence permanecerá activa pero nunca generará una recompensa.

---

# 83. Puntos técnicos que conviene conservar al modificarla

## 83.1 No volver a usar `EnvReadInt(state, "clave" + H)`

La versión actual desenrolla manualmente las 48 lecturas para evitar el error ya observado con claves dinámicas en `EnvReadInt`.

## 83.2 Mantener coherencia exacta de índices

Para cada `H` deben corresponder:

```text
ZR_PENDINGH
ZR_OWNERH
ZR_ROUNDH
ZR_XH
ZR_YH
```

No debe mezclarse información de slots distintos.

## 83.3 No olvidar que `pending` se limpia antes de validar

Un evento incorrecto se pierde.

## 83.4 Las coordenadas se utilizan tanto para localizar el Foro como para hacer spawn

Un error en `x,y` afecta directamente al lugar de aparición.

## 83.5 `foundForum == 0` no cancela la recompensa

Sólo evita `ForceAddUnit()`.

---

# 84. Resumen de configuración manual

### Sequence

```text
ZombieRewards_Main_48H_40R
```

- `Autorun allowed`: **Sí**.

### Group obligatorio

```text
CapitalForum_P1
```

- Debe existir.
- Debe contener exactamente 1 objeto.
- Ese objeto debe ser un `Building`.
- Conviene que sea permanente y no destruible durante la partida, porque almacena todo el estado de recompensas Zombies.

### Groups adicionales

Para esta Sequence concreta:

```text
ninguno
```

---

# 85. Resumen funcional

`ZombieRewards_Main_48H_40R` puede resumirse como:

```text
usar CapitalForum_P1 como memoria global
        ↓
revisar 48 slots cada 250 ms
        ↓
buscar ZR_PENDINGH = 1
        ↓
consumir el evento
        ↓
leer:
    jugador
    ronda
    coordenadas del Foro
        ↓
seleccionar recompensa fija de R1-R40
        ↓
buscar el Townhall actual del jugador
en las coordenadas guardadas
        ↓
crear los refuerzos en dos formaciones exteriores
        ↓
aplicar nivel de la ronda
        ↓
si el Foro existe:
    asociar tropas al Settlement
        ↓
enviar una notificación a los 8 Players
        ↓
esperar el siguiente evento
```

Es, por tanto, la capa de **entrega de recompensas** del modo Zombies. No controla las hordas, no detecta su muerte y no decide quién merece el premio: consume una decisión ya preparada por el resto del sistema y transforma esa información en tropas reales sobre el mapa.

# Secuencia 9 — `ZombieIntro_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieIntro_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieIntro_Main` es la Sequence que controla el arranque cinematográfico del modo Zombies y sincroniza el inicio de los tres sistemas que deben comenzar después de la introducción:

```text
ZombieEE_PriestInteraction_Main
ZombieEE_FirstHordeTrigger
ZombieWaves_Main
```

La Sequence:

1. bloquea el control del jugador;
2. reproduce el vídeo introductorio;
3. localiza a César;
4. activa la protección del sacerdote egipcio del Easter Egg;
5. crea el mensajero cartaginés, el sacerdote romano y una comitiva de 30 soldados;
6. ejecuta la entrada cinematográfica;
7. reproduce `ZombieIntroConv`;
8. muestra la retirada de los actores temporales;
9. elimina esos actores;
10. devuelve el control al jugador;
11. inicia el sistema presencial del Easter Egg;
12. inicia el detector de la primera horda;
13. inicia el reloj de `ZombieWaves_Main`.

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = SI
```

---

# 1. Papel de `ZombieIntro_Main`

La introducción es el punto de sincronización principal del modo Zombies.

La arquitectura es:

```text
cargar escenario
        ↓
ZombieIntro_Main AUTORUN
        ↓
video
        ↓
cinemática en mapa
        ↓
conversación
        ↓
retirada
        ↓
UnblockUserInput()
        ↓
RunSequence("ZombieEE_PriestInteraction_Main")
        ↓
RunSequence("ZombieEE_FirstHordeTrigger")
        ↓
RunSequence("ZombieWaves_Main")
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieIntro_Main
→ AUTORUN = SI
```

En cambio:

```text
ZombieWaves_Main
ZombieEE_PriestInteraction_Main
ZombieEE_FirstHordeTrigger
ZombieEE_PriestKeeper
```

deben poder ser iniciadas mediante `RunSequence()`.

---

# 3. Bloqueo inicial del jugador

La primera acción funcional es:

```cpp
BlockUserInput();
```

Esto ocurre antes de reproducir el vídeo.

Por tanto el jugador no puede intervenir durante:

```text
video
entrada de actores
formación
conversación
retirada
```

---

# 4. Vídeo introductorio

La Sequence reproduce:

```cpp
PlayMovie(
    Translate("movies\\ZombieIntro.avi")
);
```

La ruta esperada es:

```text
movies\ZombieIntro.avi
```

Después:

```cpp
Sleep(500);
```

da medio segundo de separación antes de continuar con la escena en el mapa.

---

# 5. Group obligatorio de César

La versión v2.0 utiliza:

```text
ZombieEE_Caesar
```

y no el antiguo:

```text
ZombieIntro_Captain
```

La consulta es:

```cpp
q =
    Group("ZombieEE_Caesar")
    .GetObjList();

q.ClearDead();
```

Después exige:

```cpp
q.count == 1
```

---

# 6. Qué debe contener `ZombieEE_Caesar`

Debe contener:

```text
exactamente una Unit
```

y esa unidad debe ser César.

El código la obtiene mediante:

```cpp
u_capitan =
    q[0]
    .AsUnit();
```

---

# 7. Error si César no existe correctamente

Si:

```text
ZombieEE_Caesar.count != 1
```

se muestra:

```text
ERROR INTRO - ZombieEE_Caesar
```

mediante:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR INTRO - ZombieEE_Caesar"
);
```

Después:

```cpp
UnblockUserInput();
return;
```

La Sequence evita dejar al jugador bloqueado si falla la referencia principal.

---

# 8. César queda temporalmente fuera de la IA normal

Durante la introducción:

```cpp
u_capitan.SetNoAIFlag(true);
```

César se mantiene así hasta el final de la escena.

Después, si sigue vivo:

```cpp
u_capitan.SetNoAIFlag(false);
```

---

# 9. Activación temprana del sacerdote egipcio

Nada más obtener correctamente a César se ejecuta:

```cpp
RunSequence(
    "ZombieEE_PriestKeeper"
);
```

Esto ocurre antes de crear los actores temporales de la intro.

---

# 10. Función de `ZombieEE_PriestKeeper` durante la intro

El sacerdote egipcio del Easter Egg ya debe existir en:

```text
ZombieEE_Priest01
```

`ZombieEE_PriestKeeper` se encarga de:

```text
mantenerlo protegido
mantenerlo inmóvil
conservarlo como personaje persistente
```

Esto evita mezclarlo con:

```text
u_sacerdote
```

de `ZombieIntro_Main`, que es un `RPriest` temporal y representa al sacerdote romano.

---

# 11. Dos sacerdotes diferentes

La arquitectura distingue claramente:

```text
Sacerdote egipcio del Easter Egg
→ precolocado
→ Group ZombieEE_Priest01
→ gestionado por ZombieEE_PriestKeeper
→ persiste tras la intro
```

y:

```text
Sacerdote romano de la introducción
→ creado con Place("RPriest")
→ sólo existe durante la cinemática
→ se elimina después
```

---

# 12. Lista de actores romanos temporales

La Sequence utiliza:

```cpp
ObjList romanos;
```

Antes de crear la escolta:

```cpp
romanos.Clear();
```

En esta lista se almacenan únicamente los 30 soldados de atrezzo.

No se añaden:

```text
César
mensajero
sacerdote romano
```

---

# 13. Mensajero cartaginés

El mensajero se crea con:

```cpp
u_mensajero =
    Place(
        "CLibyanFootman",
        Point(
            u_capitan.pos.x - 350,
            u_capitan.pos.y + 250
        ),
        1
    )
    .AsUnit();
```

Por tanto:

```text
clase = CLibyanFootman
propietario = Player 1
```

---

# 14. Por qué el mensajero es Player 1

Aunque visualmente representa a un cartaginés, se crea como:

```text
Player 1
```

para que la propia ciudad romana no lo trate como enemigo durante la introducción.

---

# 15. Mensajero fuera de la IA normal

Después de crearlo:

```cpp
u_mensajero.SetNoAIFlag(true);
```

Sus movimientos quedan controlados por la Sequence.

---

# 16. Punto inicial de la comitiva romana

Se calcula:

```cpp
romanStartX =
    u_capitan.pos.x + 350;

romanStartY =
    u_capitan.pos.y - 250;
```

Ese punto sirve como base para:

```text
sacerdote romano
12 pretorianos
12 hastati
6 velites
```

---

# 17. Sacerdote romano

Se crea mediante:

```cpp
u_sacerdote =
    Place(
        "RPriest",
        Point(
            romanStartX,
            romanStartY
        ),
        1
    )
    .AsUnit();
```

Después:

```cpp
u_sacerdote.SetNoAIFlag(true);
```

---

# 18. Pretorianos

Se crean:

```text
12 RPraetorian
```

mediante:

```cpp
for(i = 0; i < 12; i += 1)
```

La posición inicial utiliza:

```cpp
romanStartX + (i % 6) * 45
romanStartY + (i / 6) * 55
```

---

# 19. Hastati

Se crean:

```text
12 RHastatus
```

con:

```cpp
romanStartX
+
100
+
(i % 6) * 45
```

y:

```cpp
romanStartY
+
(i / 6) * 55
```

---

# 20. Velites

Se crean:

```text
6 RVelit
```

con:

```cpp
romanStartX + 200 + i * 45
romanStartY + 100
```

---

# 21. Número total de soldados de la comitiva

La escolta contiene:

```text
12 RPraetorian
+
12 RHastatus
+
6 RVelit
=
30 soldados
```

Aparte están:

```text
1 sacerdote romano
1 mensajero cartaginés
César
```

---

# 22. Creación escalonada de la escolta

Después de cada soldado:

```cpp
Sleep(20);
```

Por tanto la creación de los 30 soldados introduce:

```text
30 × 20 ms
=
600 ms
```

de espera programada acumulada.

---

# 23. Los 30 soldados quedan fuera de la IA normal

Cada uno recibe:

```cpp
u.SetNoAIFlag(true);
```

y después:

```cpp
romanos.Add(u);
```

Durante la intro sólo obedecen a la lógica cinematográfica.

---

# 24. Inicio de la cámara

Después de crear todos los actores:

```cpp
StartViewFollow(
    u_capitan
);
```

La cámara sigue a César.

Después:

```cpp
Sleep(500);
```

antes de iniciar los movimientos.

---

# 25. Movimiento del mensajero

El destino es:

```cpp
Point(
    u_capitan.pos.x - 90,
    u_capitan.pos.y + 40
)
```

Por tanto termina delante y ligeramente desplazado respecto a César.

---

# 26. Movimiento del sacerdote romano

Su destino es:

```cpp
Point(
    u_capitan.pos.x + 70,
    u_capitan.pos.y - 55
)
```

El sacerdote queda al lado de César.

---

# 27. Formación romana final

Los 30 soldados forman:

```text
5 filas × 6 columnas
```

porque:

```cpp
fila =
    i / 6;

columna =
    i % 6;
```

---

# 28. Coordenadas de la formación

Cada soldado recibe:

```cpp
Point(
    u_capitan.pos.x
    +
    140
    +
    (fila * 70),

    u_capitan.pos.y
    -
    190
    +
    (columna * 75)
)
```

La formación queda desplegada detrás y a un lado de César.

---

# 29. Espera de llegada del mensajero

La Sequence no espera indefinidamente.

Guarda:

```cpp
arrivalStart =
    GetTime();
```

y espera mientras:

```text
César esté vivo
mensajero esté vivo
distancia > 120
tiempo transcurrido < 10 segundos
```

---

# 30. Timeout de llegada

La condición:

```cpp
GetTime()
-
arrivalStart
<
10000
```

establece un máximo de:

```text
10 segundos
```

Si el mensajero se atasca, la introducción no queda bloqueada para siempre.

---

# 31. Tiempo adicional para cerrar la formación

Después de la llegada o del timeout:

```cpp
Sleep(2000);
```

Esto da dos segundos adicionales a la comitiva romana para terminar su desplazamiento.

---

# 32. Validación de actores tras la entrada

Después de varios movimientos y `Sleep`, el código no reutiliza ciegamente handles posiblemente muertos.

Comprueba:

```cpp
if(
    !u_capitan.IsAlive()
    ||
    !u_mensajero.IsAlive()
    ||
    !u_sacerdote.IsAlive()
)
```

Si alguno ha desaparecido:

```cpp
StopViewFollow();
UnblockUserInput();
return;
```

---

# 33. Limpieza de soldados muertos antes del diálogo

También ejecuta:

```cpp
romanos.ClearDead();
```

Así el siguiente bucle sólo intenta controlar soldados que siguen existiendo.

---

# 34. Detener actores antes del diálogo

El mensajero recibe:

```cpp
SetCommand(
    "stand_position"
);
```

El sacerdote romano también.

---

# 35. Detener la formación

Cada unidad de:

```text
romanos
```

recibe:

```cpp
u.SetCommand(
    "stand_position"
);
```

La escena queda estática antes de iniciar la conversación.

---

# 36. Pausa previa a la conversación

Después:

```cpp
Sleep(750);
```

se deja estabilizar la escena.

---

# 37. Fin del seguimiento de cámara antes del diálogo

Se ejecuta:

```cpp
StopViewFollow();
Sleep(250);
```

El jugador sigue bloqueado.

Este `StopViewFollow()` sólo termina el movimiento de cámara previo; no devuelve el control del juego.

---

# 38. Conversation obligatoria

La conversación utilizada es:

```text
ZombieIntroConv
```

Inicialización:

```cpp
conv.Init(
    "ZombieIntroConv"
);
```

---

# 39. Actores de `ZombieIntroConv`

La Conversation debe utilizar exactamente estos nombres:

```text
Mensajero
Capitan
Sacerdote
```

La asignación es:

```cpp
conv.SetActor(
    "Mensajero",
    u_mensajero
);

conv.SetActor(
    "Capitan",
    u_capitan
);

conv.SetActor(
    "Sacerdote",
    u_sacerdote
);
```

---

# 40. Ejecución del diálogo

La Conversation se reproduce mediante:

```cpp
conv.Run();
```

La Sequence permanece bloqueada hasta que termina la conversación.

---

# 41. Pausa tras la frase final

Después:

```cpp
Sleep(1200);
```

se deja una pausa de:

```text
1,2 segundos
```

antes de iniciar la retirada.

---

# 42. Segunda validación de actores

Después de la conversación se vuelve a comprobar:

```text
César
mensajero
sacerdote romano
```

Si alguno no está vivo:

```cpp
UnblockUserInput();
return;
```

---

# 43. Segunda limpieza de la comitiva

Se ejecuta otra vez:

```cpp
romanos.ClearDead();
```

antes de iniciar la retirada.

---

# 44. Cámara de retirada

La Sequence vuelve a:

```cpp
StartViewFollow(
    u_capitan
);
```

y espera:

```cpp
Sleep(250);
```

César pasa a ser el centro visual mientras el resto se marcha.

---

# 45. Retirada del mensajero

El mensajero recibe:

```cpp
Point(
    u_capitan.pos.x - 650,
    u_capitan.pos.y + 450
)
```

Es un desplazamiento visible hacia el lado aproximado por el que entró.

---

# 46. Retirada del sacerdote romano

El sacerdote recibe:

```cpp
Point(
    u_capitan.pos.x + 600,
    u_capitan.pos.y - 350
)
```

Se marcha con la comitiva romana.

---

# 47. Retirada de la formación romana

Los soldados mantienen aproximadamente su estructura mediante:

```cpp
fila =
    i / 6;

columna =
    i % 6;
```

y reciben:

```cpp
Point(
    u_capitan.pos.x
    +
    650
    +
    (fila * 70),

    u_capitan.pos.y
    -
    450
    +
    (columna * 75)
)
```

---

# 48. Retirada visible

Después de emitir las órdenes:

```cpp
Sleep(3500);
```

La Sequence no borra inmediatamente a los actores.

El jugador puede ver cómo abandonan la escena durante unos 3,5 segundos.

---

# 49. Timeout de retirada del mensajero

Después se inicia:

```cpp
retreatStart =
    GetTime();
```

y se espera mientras:

```text
César esté vivo
mensajero esté vivo
distancia entre ambos < 400
tiempo < 7 segundos
```

---

# 50. Máximo de espera de retirada

La condición:

```cpp
GetTime()
-
retreatStart
<
7000
```

impide que un atasco del mensajero bloquee permanentemente la intro.

---

# 51. Tiempo adicional para la comitiva

Después:

```cpp
Sleep(1500);
```

da 1,5 segundos adicionales al sacerdote y a los soldados romanos para alejarse.

---

# 52. Eliminación del mensajero

Sólo se borra si sigue vivo:

```cpp
if(
    u_mensajero.IsAlive()
)
{
    u_mensajero.Erase();
}
```

---

# 53. Eliminación del sacerdote romano

También se protege con:

```cpp
if(
    u_sacerdote.IsAlive()
)
{
    u_sacerdote.Erase();
}
```

---

# 54. Eliminación de los 30 soldados

Antes:

```cpp
romanos.ClearDead();
```

Después cada superviviente se elimina con:

```cpp
if(u.IsAlive())
    u.Erase();
```

---

# 55. Los actores temporales no permanecen en la partida

Al terminar la intro desaparecen:

```text
mensajero cartaginés
sacerdote romano
12 pretorianos
12 hastati
6 velites
```

César es el único actor de la escena que permanece.

---

# 56. César queda solo

Después de borrar la comitiva:

```cpp
Sleep(750);
```

La escena deja a César solo durante una breve pausa.

---

# 57. Fin definitivo de la cámara

Se ejecuta:

```cpp
StopViewFollow();
Sleep(250);
```

---

# 58. Restauración de César

Si sigue vivo:

```cpp
u_capitan.SetNoAIFlag(
    false
);
```

Desde ese momento vuelve a comportarse como una unidad normal.

---

# 59. Devolver el control al jugador

La introducción termina oficialmente con:

```cpp
UnblockUserInput();
```

Este punto es importante para la sincronización general.

---

# 60. Cuándo empieza el reloj de oleadas

`ZombieWaves_Main` no tiene Autorun.

Su reloj de 30 minutos empieza cuando la intro ejecuta:

```cpp
RunSequence(
    "ZombieWaves_Main"
);
```

Esto ocurre **después** de:

```text
video
entrada
diálogo
retirada
limpieza
UnblockUserInput
```

---

# 61. Activar primero el gestor presencial del Easter Egg

Antes de iniciar Waves:

```cpp
RunSequence(
    "ZombieEE_PriestInteraction_Main"
);
```

Ese gestor queda esperando:

```text
un EE_PRIEST_PENDING válido
+
César cerca del sacerdote egipcio
```

---

# 62. Activar el detector de la primera horda

Después:

```cpp
RunSequence(
    "ZombieEE_FirstHordeTrigger"
);
```

Esta Sequence queda esperando a que:

```text
se genere la primera horda de HordeSpawn_01
+
esa horda sea destruida
```

---

# 63. Orden exacto de arranque

El orden canónico es:

```text
1. ZombieEE_PriestInteraction_Main
2. ZombieEE_FirstHordeTrigger
3. ZombieWaves_Main
```

Este orden garantiza que los gestores del Easter Egg ya estén esperando cuando Waves empiece su reloj.

---

# 64. `ZombieEE_PriestKeeper` se inicia antes

Existe una cuarta Sequence lanzada por Intro:

```text
ZombieEE_PriestKeeper
```

pero se inicia al comienzo de la escena, inmediatamente después de obtener a César.

Por tanto el orden global es:

```text
ZombieIntro_Main
↓
ZombieEE_PriestKeeper
↓
cinemática
↓
ZombieEE_PriestInteraction_Main
↓
ZombieEE_FirstHordeTrigger
↓
ZombieWaves_Main
```

---

# 65. Groups necesarios

## Obligatorio

```text
ZombieEE_Caesar
```

Debe contener exactamente una Unit: César.

## Utilizado indirectamente

`ZombieEE_PriestKeeper` requiere:

```text
ZombieEE_Priest01
```

pero `ZombieIntro_Main` no lo consulta directamente.

---

# 66. Groups antiguos que ya no utiliza

La versión canónica ya no necesita:

```text
ZombieIntro_Captain
ZombieIntro_MessengerSpawn
ZombieIntro_Arrival
```

Las posiciones temporales se calculan directamente desde:

```text
u_capitan.pos
```

---

# 67. Areas necesarias

No necesita ninguna Area manual.

---

# 68. Holders necesarios

No necesita Holders manuales.

---

# 69. Marcadores de llegada

No necesita marcadores de llegada.

El mensajero, sacerdote y soldados usan posiciones calculadas relativamente a César.

---

# 70. Dependencias de archivo

Debe existir:

```text
movies\ZombieIntro.avi
```

en la ubicación esperada por:

```cpp
PlayMovie(
    Translate(...)
);
```

---

# 71. Dependencias de Conversation

Debe existir:

```text
ZombieIntroConv
```

con actores:

```text
Mensajero
Capitan
Sacerdote
```

---

# 72. Dependencias de Sequences

Deben existir con estos nombres exactos:

```text
ZombieEE_PriestKeeper
ZombieEE_PriestInteraction_Main
ZombieEE_FirstHordeTrigger
ZombieWaves_Main
```

---

# 73. Autorun recomendado de las dependencias

La arquitectura actual espera:

```text
ZombieIntro_Main
→ AUTORUN SI

ZombieEE_PriestKeeper
→ AUTORUN NO

ZombieEE_PriestInteraction_Main
→ AUTORUN NO

ZombieEE_FirstHordeTrigger
→ AUTORUN NO

ZombieWaves_Main
→ AUTORUN NO
```

---

# 74. Uso de `SetNoAIFlag`

Durante la intro reciben:

```cpp
SetNoAIFlag(true)
```

estos actores:

```text
César
mensajero
sacerdote romano
30 soldados romanos
```

Al final sólo César necesita restaurarse porque los demás son eliminados.

---

# 75. No se modifica alimentación

La intro no utiliza:

```cpp
SetFeeding(false)
```

sobre los actores temporales.

Su duración es breve y no forman parte de un sistema permanente de guarnición.

---

# 76. No se aplican niveles especiales

Las unidades de atrezzo se crean con su nivel normal.

No existe:

```cpp
SetLevel(...)
```

en esta Sequence.

---

# 77. No se muestran mensajes de depuración

La versión canónica no contiene:

```text
pr("INTRO...")
```

ni mensajes internos de monitorización.

Sólo utiliza un anuncio visible si falla:

```text
ZombieEE_Caesar
```

---

# 78. Protección frente a handles muertos

La versión v2.0 incorpora comprobaciones `IsAlive()` en los puntos donde los actores han atravesado varios `Sleep`.

Esto evita reutilizar una referencia a una Unit que haya desaparecido por una intervención externa.

---

# 79. Protección frente a bloqueos de pathfinding

Existen dos timeouts:

```text
llegada del mensajero → 10 segundos
retirada del mensajero → 7 segundos
```

Ninguno de los dos movimientos puede bloquear indefinidamente la Sequence.

---

# 80. Qué ocurre si falla un actor durante la entrada

Si tras la entrada falta:

```text
César
mensajero
sacerdote romano
```

la Sequence:

```text
detiene seguimiento de cámara
desbloquea al jugador
termina
```

No inicia el sistema de oleadas.

---

# 81. Qué ocurre si falla un actor después del diálogo

Después de `conv.Run()` se repite la comprobación.

En ese caso:

```text
UnblockUserInput()
return
```

Tampoco se inician Waves ni los gestores posteriores.

---

# 82. Flujo completo

```text
AUTORUN
↓
BlockUserInput
↓
PlayMovie ZombieIntro.avi
↓
obtener ZombieEE_Caesar
↓
SetNoAIFlag(true)
↓
RunSequence ZombieEE_PriestKeeper
↓
crear mensajero
↓
crear RPriest
↓
crear:
12 RPraetorian
12 RHastatus
6 RVelit
↓
StartViewFollow(César)
↓
mover todos a formación
↓
esperar mensajero
máximo 10 s
↓
stand_position
↓
StopViewFollow
↓
ZombieIntroConv
↓
StartViewFollow(César)
↓
retirada visible
↓
esperar mensajero
máximo 7 s
↓
Erase actores temporales
↓
César queda solo
↓
StopViewFollow
↓
César SetNoAIFlag(false)
↓
UnblockUserInput
↓
RunSequence ZombieEE_PriestInteraction_Main
↓
RunSequence ZombieEE_FirstHordeTrigger
↓
RunSequence ZombieWaves_Main
```

---

# 83. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── ZombieEE_Caesar
│   │   └── César
│   │
│   └── ZombieEE_Priest01
│       └── sacerdote egipcio persistente
│
├── Conversations
│   └── ZombieIntroConv
│       ├── Mensajero
│       ├── Capitan
│       └── Sacerdote
│
└── Sequences
    ├── ZombieIntro_Main
    │   └── AUTORUN = SI
    │
    ├── ZombieEE_PriestKeeper
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_PriestInteraction_Main
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_FirstHordeTrigger
    │   └── AUTORUN = NO
    │
    └── ZombieWaves_Main
        └── AUTORUN = NO
```

---

# 84. Resumen funcional

`ZombieIntro_Main` v2.0 puede resumirse así:

```text
bloquear jugador
        ↓
reproducir vídeo
        ↓
localizar César
        ↓
activar PriestKeeper
        ↓
crear actores temporales
        ↓
30 soldados romanos
+
mensajero
+
sacerdote romano
        ↓
cámara sobre César
        ↓
entrada y formación
        ↓
ZombieIntroConv
        ↓
retirada visible
        ↓
eliminar actores temporales
        ↓
César permanece
        ↓
devolver control
        ↓
activar gestor de conversaciones del Easter Egg
        ↓
activar detector de primera horda
        ↓
arrancar ZombieWaves_Main
```

La Sequence es el punto de arranque sincronizado del modo Zombies. La cuenta de 30 minutos de `ZombieWaves_Main` empieza únicamente cuando toda la introducción ya ha terminado y el jugador ha recuperado el control.

# Secuencia 14 — `ZombieEE_Sacrifice_Main`

> **Actualizado para Imperivm III — Guerra Total v2.0 (03/09/2026).**  
> Este documento describe la implementación canónica de `ZombieEE_Sacrifice_Main` incluida en `V2.0ImperivmIII.txt`.

`ZombieEE_Sacrifice_Main` controla la fase de las **50 almas** del Easter Egg.

La Sequence comienza después de `ZombieEE_Dialogue01`, espera a que la fase esté habilitada, recupera el progreso guardado y vigila la zona de las pirámides. Cada aldeano de Player 1 que entre en el radio del sacrificio:

```text
se contabiliza como una nueva alma
↓
se persiste el contador
↓
se actualiza el objetivo en pantalla
↓
el aldeano muere
```

Cuando se alcanzan:

```text
50 / 50
```

la Sequence:

```text
desactiva el sacrificio
marca la fase como completada
muestra el mensaje final
espera 3 segundos
lanza ZombieEE_AnubisAttack_Main
```

La Sequence debe configurarse con:

```text
AUTORUN ALLOWED = NO
```

---

# 1. Papel dentro del Easter Egg

El flujo es:

```text
ZombieEE_Dialogue01
↓
EE_SOULS_DELIVERED = 0
EE_SACRIFICE_COMPLETED = 0
EE_SACRIFICE_ENABLED = 1
↓
RunSequence("ZombieEE_Sacrifice_Main")
↓
el jugador lleva aldeanos a las pirámides
↓
50 aldeanos sacrificados
↓
EE_SACRIFICE_ENABLED = 0
EE_SACRIFICE_COMPLETED = 1
↓
ZombieEE_AnubisAttack_Main
```

---

# 2. Autorun

La configuración correcta es:

```text
ZombieEE_Sacrifice_Main
→ AUTORUN = NO
```

No debe arrancar al cargar el mapa.

Su lanzamiento normal procede de:

```cpp
RunSequence(
    "ZombieEE_Sacrifice_Main"
);
```

ejecutado al final de `ZombieEE_Dialogue01`.

---

# 3. Versión V2 Stability

La cabecera canónica indica:

```text
VERSION V2 STABILITY
```

La optimización principal es:

```text
Escaneo rotatorio:
consulta una sola clase de aldeano por ciclo
```

en vez de consultar las 16 variantes cada 500 ms.

---

# 4. Variables principales

La Sequence declara:

```cpp
ObjList q;
ObjList stateList;
ObjList villagers;

Building state;
Unit u;

point sacrificePos;

int enabled;
int completed;
int souls;
int i;
int found;
int classIndex;
```

---

# 5. `q`

Se utiliza para recuperar:

```text
ZombieEE_SacrificePyramids
```

---

# 6. `stateList`

Se utiliza repetidamente para refrescar:

```text
CapitalForum_P1
```

y obtener el `Building state` actual.

---

# 7. `villagers`

Contiene temporalmente los aldeanos de una única clase cultural en cada ciclo.

Ejemplo:

```text
ciclo 0 → RVillager
ciclo 1 → RWVillager
ciclo 2 → IVillager
...
ciclo 15 → MWVillager
```

---

# 8. `state`

Es el `Building` global de estado.

Sobre él se utilizan:

```text
EE_SACRIFICE_COMPLETED
EE_SACRIFICE_ENABLED
EE_SOULS_DELIVERED
```

---

# 9. `u`

Representa el aldeano concreto que está siendo examinado o sacrificado.

---

# 10. `sacrificePos`

Es la posición exacta del único objeto incluido en:

```text
ZombieEE_SacrificePyramids
```

La Sequence no necesita mantener una referencia permanente a ese objeto después de obtener su posición.

---

# 11. `enabled`

Representa:

```text
EE_SACRIFICE_ENABLED
```

Mientras sea 0, la Sequence espera.

---

# 12. `completed`

Representa:

```text
EE_SACRIFICE_COMPLETED
```

Si ya vale 1 al arrancar:

```text
return
```

---

# 13. `souls`

Contiene el número actual de aldeanos sacrificados.

Rango funcional:

```text
0..50
```

---

# 14. `found`

Se utiliza para limitar cada ciclo a:

```text
como máximo un aldeano sacrificado
```

de la clase que se está examinando.

---

# 15. `classIndex`

Controla qué una de las 16 variantes de aldeano se consulta en el ciclo actual.

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
    "ERROR ALMAS - CapitalForum_P1"
);

return;
```

---

# 18. Obtención de `state`

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 19. Protección frente a repetición

Nada más obtener `state`:

```cpp
completed =
    EnvReadInt(
        state,
        "EE_SACRIFICE_COMPLETED"
    );
```

Si:

```text
completed == 1
```

se ejecuta:

```cpp
return;
```

---

# 20. Consecuencia

Una fase de sacrificio ya terminada no puede volver a iniciarse accidentalmente mediante un segundo `RunSequence()`.

---

# 21. Group obligatorio de las pirámides

La Sequence consulta:

```cpp
q =
    Group("ZombieEE_SacrificePyramids")
    .GetObjList();

q.ClearDead();
```

---

# 22. Validación de `ZombieEE_SacrificePyramids`

Debe cumplirse:

```text
q.count == 1
```

---

# 23. Error del marcador de sacrificio

Si no resuelve exactamente a un objeto:

```cpp
ShowAnnouncement(
    "ZombieHelp",
    "ERROR ALMAS - ZombieEE_SacrificePyramids"
);

return;
```

---

# 24. Tipo de objeto requerido

La Sequence sólo utiliza:

```cpp
q[0].pos
```

Por tanto `ZombieEE_SacrificePyramids` funciona como marcador espacial.

No necesita ser una clase específica.

---

# 25. Captura de la posición

Se ejecuta:

```cpp
sacrificePos =
    q[0].pos;
```

A partir de ese momento el Group no se vuelve a consultar.

---

# 26. Posición persistente

La zona de sacrificio queda definida por:

```text
sacrificePos
```

capturada al principio de la Sequence.

Si el objeto marcador se moviera después:

```text
la zona no se movería con él
```

---

# 27. Espera de habilitación

La Sequence inicializa:

```cpp
enabled = 0;
```

Después entra en:

```cpp
while(enabled == 0)
```

---

# 28. Refresco de `CapitalForum_P1` durante la espera

Cada iteración vuelve a ejecutar:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 29. Si el estado desaparece durante la espera

Si:

```text
stateList.count != 1
```

se ejecuta:

```cpp
return;
```

---

# 30. Renovación de `state`

Dentro del bucle:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 31. Lectura de `EE_SACRIFICE_ENABLED`

Después:

```cpp
enabled =
    EnvReadInt(
        state,
        "EE_SACRIFICE_ENABLED"
    );
```

---

# 32. Frecuencia de espera

Si sigue desactivado:

```cpp
Sleep(1000);
```

Por tanto se revisa aproximadamente:

```text
una vez por segundo
```

---

# 33. Activación normal

`ZombieEE_Dialogue01` escribe:

```text
EE_SACRIFICE_ENABLED = 1
```

antes de ejecutar:

```text
ZombieEE_Sacrifice_Main
```

Por tanto, en la ruta normal, esta espera debería resolverse casi inmediatamente.

---

# 34. Motivo de conservar la espera

Aunque Dialogue01 ya habilite la fase antes del `RunSequence()`, el bucle protege frente a:

```text
orden de ejecución inesperado
partidas cargadas
activación manual accidental
```

---

# 35. Recuperación del progreso

Al salir de la espera:

```cpp
souls =
    EnvReadInt(
        state,
        "EE_SOULS_DELIVERED"
    );
```

---

# 36. Protección contra valores negativos

Si:

```cpp
souls < 0
```

se fuerza:

```cpp
souls = 0;
```

---

# 37. Protección contra valores superiores a 50

Si:

```cpp
souls > 50
```

se fuerza:

```cpp
souls = 50;
```

---

# 38. La corrección local no reescribe inmediatamente el Env

El código corrige la variable local `souls`.

No ejecuta en ese punto una escritura adicional para normalizar inmediatamente un valor persistido fuera de rango.

---

# 39. Objetivo inicial de progreso

Se muestra:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "ALMAS ENTREGADAS: " + souls + "/50"
);
```

---

# 40. Canal de interfaz

El ID utilizado es:

```text
ZombieEEObjective
```

El mismo canal se actualiza cada vez que entra una nueva alma.

---

# 41. Inicio del escaneo rotatorio

Se establece:

```cpp
classIndex = 0;
```

---

# 42. Condición del bucle principal

La fase continúa mientras:

```cpp
while(souls < 50)
```

---

# 43. Máximo de sacrificios por ciclo

Al empezar cada ciclo:

```cpp
found = 0;
```

El bucle de aldeanos utiliza:

```cpp
for(
    i = 0;
    i < villagers.count
    &&
    found == 0;
    i += 1
)
```

Por tanto se procesa como máximo:

```text
1 aldeano por ciclo
```

---

# 44. Las 16 clases admitidas

La versión v2.0 reconoce exactamente:

```text
0  → RVillager
1  → RWVillager
2  → IVillager
3  → IWVillager
4  → CVillager
5  → CWVillager
6  → GVillager
7  → GWVillager
8  → TVillager
9  → TWVillager
10 → BVillager
11 → BWVillager
12 → EVillager
13 → EWVillager
14 → MVillager
15 → MWVillager
```

---

# 45. Player válido

Todas las consultas utilizan:

```cpp
ClassPlayerObjs(
    "Clase",
    1
)
```

Por tanto sólo se sacrifican aldeanos de:

```text
Player 1
```

---

# 46. Aldeanos de otros Players

Un aldeano válido culturalmente pero perteneciente a:

```text
Player 2..16
```

no aparece en estas consultas.

No cuenta como alma.

---

# 47. Romanos

Se consultan:

```text
RVillager
RWVillager
```

---

# 48. Íberos

Se consultan:

```text
IVillager
IWVillager
```

---

# 49. Cartagineses

Se consultan:

```text
CVillager
CWVillager
```

---

# 50. Galos

Se consultan:

```text
GVillager
GWVillager
```

---

# 51. Germanos

Se consultan:

```text
TVillager
TWVillager
```

---

# 52. Britanos

Se consultan:

```text
BVillager
BWVillager
```

---

# 53. Egipcios

Se consultan:

```text
EVillager
EWVillager
```

---

# 54. Variantes `M`

También se incluyen:

```text
MVillager
MWVillager
```

---

# 55. Limpieza de referencias muertas

Después de obtener la lista de la clase actual:

```cpp
villagers.ClearDead();
```

---

# 56. Conversión del candidato

Cada objeto se convierte a:

```cpp
u =
    villagers[i]
    .AsUnit();
```

---

# 57. Radio exacto del sacrificio

La condición es:

```cpp
if(
    u.DistTo(
        sacrificePos
    )
    <=
    220
)
```

Por tanto el radio efectivo es:

```text
220 unidades
```

---

# 58. No existe una orden específica de entrada

La Sequence no mueve aldeanos hacia la zona.

El jugador debe conducirlos físicamente hasta:

```text
DistTo(sacrificePos) <= 220
```

---

# 59. El aldeano puede estar simplemente pasando

No se exige:

```text
idle
stand_position
orden concreta
```

Si entra en el radio durante el escaneo de su clase:

```text
puede ser sacrificado
```

---

# 60. Refresco del estado antes de contabilizar

Justo antes de sumar una nueva alma:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 61. Si el estado falla en ese instante

Si:

```text
stateList.count != 1
```

se ejecuta:

```cpp
return;
```

El aldeano no se sacrifica desde esa iteración.

---

# 62. Renovación de `state` antes del evento

Después:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 63. Orden de operaciones al sacrificar

El código ejecuta:

```text
1. souls += 1
2. found = 1
3. EnvWriteInt(EE_SOULS_DELIVERED)
4. actualizar anuncio
5. Damage(100000)
```

---

# 64. Persistencia antes de la muerte

El comentario canónico indica:

```text
Persistir antes de la muerte evita perder el progreso
si otra Sequence reacciona a la baja de la unidad
en el mismo instante.
```

---

# 65. Incremento del contador

Se ejecuta:

```cpp
souls += 1;
```

---

# 66. Bloqueo del ciclo

Después:

```cpp
found = 1;
```

Esto evita sacrificar un segundo aldeano de esa misma lista en el mismo ciclo.

---

# 67. Escritura persistente

Se ejecuta:

```cpp
EnvWriteInt(
    state,
    "EE_SOULS_DELIVERED",
    souls
);
```

---

# 68. Actualización visual inmediata

Después:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "ALMAS ENTREGADAS: " + souls + "/50"
);
```

Ejemplos:

```text
ALMAS ENTREGADAS: 1/50
ALMAS ENTREGADAS: 17/50
ALMAS ENTREGADAS: 49/50
ALMAS ENTREGADAS: 50/50
```

---

# 69. Muerte del aldeano

Finalmente:

```cpp
u.Damage(
    100000
);
```

---

# 70. La Sequence utiliza daño, no `Erase()`

El sacrificio se implementa con:

```text
Damage(100000)
```

y no mediante:

```text
Erase()
```

---

# 71. Consecuencia de utilizar `Damage`

El aldeano muere mediante el sistema normal de daño del motor, en lugar de desaparecer instantáneamente por borrado técnico.

---

# 72. El progreso ya está guardado antes del daño

Incluso si la muerte dispara otra lógica inmediatamente:

```text
EE_SOULS_DELIVERED
```

ya contiene el nuevo total.

---

# 73. Rotación de clase

Al terminar el ciclo:

```cpp
classIndex += 1;
```

---

# 74. Reinicio después de la clase 15

Si:

```cpp
classIndex >= 16
```

se ejecuta:

```cpp
classIndex = 0;
```

---

# 75. Frecuencia del escaneo

Al final de cada ciclo:

```cpp
Sleep(250);
```

Por tanto existen como máximo:

```text
4 consultas de clase por segundo
```

---

# 76. Duración de una vuelta completa

Como existen:

```text
16 clases
```

y se consulta una cada 250 ms:

```text
16 × 250 ms
=
4.000 ms
```

Una clase concreta se vuelve a examinar aproximadamente cada:

```text
4 segundos
```

---

# 77. Consecuencia jugable del escaneo rotatorio

Un aldeano puede entrar en las pirámides y no ser sacrificado instantáneamente.

El retraso máximo aproximado depende de cuándo vuelva a tocar su clase:

```text
hasta ~4 segundos
```

---

# 78. Optimización frente a la versión anterior

La cabecera explica que la versión anterior podía consultar:

```text
16 clases cada 500 ms
```

La V2 consulta:

```text
1 clase cada 250 ms
```

reduciendo de forma importante el número permanente de `ClassPlayerObjs()`.

---

# 79. Tasa máxima teórica de sacrificio

Como sólo se sacrifica:

```text
1 unidad por ciclo
```

y hay:

```text
4 ciclos por segundo
```

la tasa máxima teórica es aproximadamente:

```text
4 aldeanos por segundo
```

si cada clase consultada dispone de un aldeano válido en el radio.

---

# 80. Si todos los aldeanos son de una sola clase

Esa clase sólo se consulta aproximadamente cada:

```text
4 segundos
```

y sólo se sacrifica uno por consulta.

Por tanto un grupo de 50 aldeanos todos de la misma clase puede tardar mucho más que una mezcla de clases.

---

# 81. El diseño prioriza estabilidad

La versión V2 acepta ese retraso a cambio de reducir:

```text
búsquedas permanentes de objetos
carga de CPU de la Sequence
```

---

# 82. No se procesan dos aldeanos de la misma clase en una pasada

Aunque existan diez `RVillager` dentro del radio:

```text
se sacrifica uno
↓
found = 1
↓
siguiente ciclo pasa a RWVillager
```

El siguiente `RVillager` deberá esperar la vuelta completa del índice.

---

# 83. Persistencia del progreso

Después de cada sacrificio:

```text
EE_SOULS_DELIVERED = souls
```

Por tanto el progreso no existe sólo en la variable local.

---

# 84. Recuperación tras una ejecución nueva

Si la Sequence vuelve a arrancar y:

```text
EE_SACRIFICE_COMPLETED == 0
```

puede recuperar:

```text
EE_SOULS_DELIVERED
```

y continuar desde ese valor.

---

# 85. Ejemplo de recuperación

Si el estado contiene:

```text
EE_SOULS_DELIVERED = 31
```

la interfaz comienza mostrando:

```text
ALMAS ENTREGADAS: 31/50
```

y sólo necesita 19 sacrificios adicionales.

---

# 86. Llegada a 50

Cuando el último aldeano incrementa:

```text
49 → 50
```

la condición:

```cpp
while(souls < 50)
```

dejará de cumplirse después de terminar ese ciclo.

---

# 87. Refresco final de `CapitalForum_P1`

Antes de marcar la fase:

```cpp
stateList =
    Group("CapitalForum_P1")
    .GetObjList();

stateList.ClearDead();
```

---

# 88. Si falla el estado al completar 50

Si:

```text
stateList.count != 1
```

se ejecuta:

```cpp
return;
```

El contador de 50 ya habrá quedado persistido desde el último sacrificio, pero no se escribirán los flags finales de esta ejecución.

---

# 89. Renovación final de `state`

Cuando el Group es correcto:

```cpp
state =
    stateList[0]
    .AsBuilding();
```

---

# 90. Desactivar la mecánica

Se escribe:

```cpp
EnvWriteInt(
    state,
    "EE_SACRIFICE_ENABLED",
    0
);
```

---

# 91. Marcar completado

Después:

```cpp
EnvWriteInt(
    state,
    "EE_SACRIFICE_COMPLETED",
    1
);
```

---

# 92. Orden de flags finales

El orden es:

```text
EE_SACRIFICE_ENABLED = 0
↓
EE_SACRIFICE_COMPLETED = 1
```

---

# 93. Mensaje final

Se muestra:

```cpp
ShowAnnouncement(
    "ZombieEEObjective",
    "LAS 50 ALMAS HAN SIDO ENTREGADAS"
);
```

---

# 94. Duración del mensaje antes del ataque

Después:

```cpp
Sleep(3000);
```

Por tanto existe una pausa de aproximadamente:

```text
3 segundos
```

entre completar las 50 almas y lanzar la siguiente fase.

---

# 95. Inicio de la emboscada

Después:

```cpp
RunSequence(
    "ZombieEE_AnubisAttack_Main"
);
```

---

# 96. Final de la Sequence

Finalmente:

```cpp
return;
```

`ZombieEE_Sacrifice_Main` deja de ejecutarse.

---

# 97. No oculta el anuncio final

La Sequence no ejecuta después:

```cpp
HideAnnouncement(
    "ZombieEEObjective"
);
```

Por tanto el canal queda con el último texto hasta que otra Sequence lo actualice u oculte.

---

# 98. No activa directamente un nuevo `EE_PRIEST_PENDING`

El final del sacrificio no manda al jugador de vuelta inmediatamente al sacerdote.

Primero inicia:

```text
ZombieEE_AnubisAttack_Main
```

---

# 99. No controla la muerte de los Anubis

Una vez lanzada la siguiente Sequence:

```text
ZombieEE_Sacrifice_Main
```

ya no participa.

---

# 100. No crea unidades enemigas

Esta Sequence no contiene:

```text
Place("EAnubisWarrior", ...)
```

La creación pertenece a:

```text
ZombieEE_AnubisAttack_Main
```

---

# 101. No controla al sacerdote

No consulta:

```text
ZombieEE_Priest01
```

---

# 102. No controla a César

No consulta:

```text
ZombieEE_Caesar
```

---

# 103. No necesita proximidad de César

El sacrificio funciona aunque César esté en otra zona del mapa.

El único requisito espacial es:

```text
aldeano Player 1
↓
DistTo(sacrificePos) <= 220
```

---

# 104. No bloquea el input

La fase es gameplay normal.

No utiliza:

```cpp
BlockUserInput();
```

---

# 105. No mueve aldeanos

No ejecuta:

```text
move
advance
capture
```

sobre ellos.

El jugador controla completamente cómo llegan a las pirámides.

---

# 106. No comprueba el comando del aldeano

No importa si el aldeano está:

```text
idle
move
trabajando
```

Si está dentro del radio cuando se consulta su clase:

```text
es válido
```

---

# 107. No comprueba nivel

El nivel del aldeano no afecta al sacrificio.

---

# 108. No comprueba comida

No se utiliza:

```text
SetFood
SetFeeding
```

---

# 109. No comprueba salud previa

Un aldeano herido cuenta igual que uno con salud completa si sigue vivo en el momento del escaneo.

---

# 110. No se exige una clase cultural concreta

Las 16 variantes permiten reunir aldeanos de diferentes culturas que estén bajo control de Player 1.

---

# 111. Groups obligatorios

La Sequence necesita directamente:

```text
CapitalForum_P1
ZombieEE_SacrificePyramids
```

---

# 112. `CapitalForum_P1`

Debe contener:

```text
exactamente 1 Building
```

---

# 113. `ZombieEE_SacrificePyramids`

Debe contener:

```text
exactamente 1 objeto
```

cuya posición marque el centro del sacrificio.

---

# 114. Groups que no necesita

No consulta directamente:

```text
ZombieEE_Caesar
ZombieEE_Priest01
HordeSpawn_01
EE_AnubisWave01
CapitalForum_P2..P8
```

---

# 115. Areas necesarias

Ninguna.

La zona se construye mediante:

```text
DistTo(sacrificePos) <= 220
```

---

# 116. Holders necesarios

Ninguno.

---

# 117. Conversations necesarias

Ninguna directamente.

---

# 118. Dependencia anterior

Es iniciada por:

```text
ZombieEE_Dialogue01
```

---

# 119. Dependencia siguiente

Al terminar lanza:

```text
ZombieEE_AnubisAttack_Main
```

---

# 120. Flags que lee

| Flag | Función |
|---|---|
| `EE_SACRIFICE_COMPLETED` | Impide repetir una fase ya terminada |
| `EE_SACRIFICE_ENABLED` | Espera a que Dialogue01 habilite el sacrificio |
| `EE_SOULS_DELIVERED` | Recupera el progreso persistente |

---

# 121. Flags que escribe

| Flag | Valor | Momento |
|---|---:|---|
| `EE_SOULS_DELIVERED` | 1..50 | Antes de matar cada aldeano |
| `EE_SACRIFICE_ENABLED` | 0 | Al alcanzar 50 |
| `EE_SACRIFICE_COMPLETED` | 1 | Al alcanzar 50 |

---

# 122. Anuncios utilizados

| ID | Texto |
|---|---|
| `ZombieHelp` | `ERROR ALMAS - CapitalForum_P1` |
| `ZombieHelp` | `ERROR ALMAS - ZombieEE_SacrificePyramids` |
| `ZombieEEObjective` | `ALMAS ENTREGADAS: X/50` |
| `ZombieEEObjective` | `LAS 50 ALMAS HAN SIDO ENTREGADAS` |

---

# 123. Frecuencias y radios

| Parámetro | Valor |
|---|---:|
| Espera de activación | 1.000 ms |
| Escaneo de clase | 250 ms |
| Clases rotatorias | 16 |
| Vuelta completa | ~4 s |
| Radio del sacrificio | 220 |
| Máximo por ciclo | 1 aldeano |
| Pausa tras 50 almas | 3.000 ms |

---

# 124. Preparación exacta en el editor

```text
Map
├── Groups
│   ├── CapitalForum_P1
│   │   └── exactamente 1 Building
│   │
│   └── ZombieEE_SacrificePyramids
│       └── exactamente 1 marcador/objeto
│
└── Sequences
    ├── ZombieEE_Dialogue01
    │   └── AUTORUN = NO
    │
    ├── ZombieEE_Sacrifice_Main
    │   └── AUTORUN = NO
    │
    └── ZombieEE_AnubisAttack_Main
        └── AUTORUN = NO
```

---

# 125. Flujo de una sola alma

```text
classIndex selecciona una clase
↓
ClassPlayerObjs(clase, 1)
↓
ClearDead
↓
recorrer aldeanos
↓
¿DistTo(sacrificePos) <=220?
        No → siguiente
        Sí
        ↓
refrescar CapitalForum_P1
        ↓
souls += 1
        ↓
EE_SOULS_DELIVERED = souls
        ↓
actualizar:
ALMAS ENTREGADAS: X/50
        ↓
Damage(100000)
        ↓
found = 1
        ↓
no sacrificar otro en este ciclo
```

---

# 126. Flujo de las 50 almas

```text
Dialogue01
↓
EE_SACRIFICE_ENABLED = 1
↓
RunSequence Sacrifice
↓
recuperar EE_SOULS_DELIVERED
↓
mostrar X/50
↓
escanear una clase cada 250 ms
↓
aldeano Player 1 entra a <=220
↓
persistir nueva alma
↓
matar aldeano
↓
repetir
↓
50/50
↓
EE_SACRIFICE_ENABLED = 0
↓
EE_SACRIFICE_COMPLETED = 1
↓
LAS 50 ALMAS HAN SIDO ENTREGADAS
↓
Sleep(3000)
↓
RunSequence("ZombieEE_AnubisAttack_Main")
↓
return
```

---

# 127. Resumen funcional

`ZombieEE_Sacrifice_Main` v2.0 implementa la primera gran mecánica activa del Easter Egg:

```text
esperar fase habilitada
        ↓
recuperar progreso
        ↓
mostrar ALMAS ENTREGADAS X/50
        ↓
rotar 16 clases de aldeano
una clase cada 250 ms
        ↓
Player 1 + radio <=220
        ↓
persistir alma antes de la muerte
        ↓
Damage(100000)
        ↓
50 almas
        ↓
desactivar sacrificio
        ↓
marcar completado
        ↓
3 segundos
        ↓
ZombieEE_AnubisAttack_Main
```

La optimización clave de la versión estable es el **escaneo rotatorio**, que reduce drásticamente las consultas permanentes a `ClassPlayerObjs()` a cambio de que cada clase concreta pueda tardar aproximadamente cuatro segundos en volver a comprobarse.

<div align="center">

# Imperivm III â€” Guerra Total

### Un escenario estratÃ©gico a gran escala para Imperivm III / Great Battles of Rome HD

**Guerra territorial Â· Fortalezas dinÃ¡micas Â· Recompensas estratÃ©gicas Â· Modo Zombies endless Â· Easter Egg completo**

**VersiÃ³n 2.0 Â· 03/09/2026 Â· ESTABLE**

<br>

<img src="imagenes/pantalla%20carga/Portada.png"
     alt="Imperivm III Guerra Total - Modo Zombies"
     width="900">

</div>

---

# Sobre el proyecto

**Imperivm III â€” Guerra Total** es un proyecto de modificaciÃ³n, scripting y diseÃ±o de escenario para **Imperivm III / Imperivm: Great Battles of Rome HD**.

El objetivo es ampliar considerablemente la profundidad estratÃ©gica del juego mediante una combinaciÃ³n de:

- diseÃ±o territorial;
- Sequences `.vs`;
- sistemas defensivos persistentes;
- generaciÃ³n dinÃ¡mica de tropas;
- control tÃ¡ctico personalizado;
- recompensas por expansiÃ³n;
- un Modo Zombies completamente integrado;
- un Easter Egg narrativo de varias fases;
- ingenierÃ­a inversa del motor y de los escenarios oficiales.

El proyecto se desarrolla sobre el mapa:

```text
Carlos Guerra Total prueba zombie
```

Estado de la compilaciÃ³n documentada:

```text
VersiÃ³n: 2.0
Fecha: 03/09/2026
Estado: ESTABLE
```

<div align="center">
  <img src="mapa/Mapa.jpg"
       alt="Mapa de Imperivm III Guerra Total"
       width="900">
</div>

La intenciÃ³n no es sustituir las mecÃ¡nicas originales de Imperivm III, sino utilizarlas como base para construir una guerra territorial mÃ¡s larga, dinÃ¡mica y estratÃ©gica.

---

# El mapa

<div align="center">
  <img src="mapa/MapaNodos.png"
       alt="Mapa de nodos de Imperivm III Guerra Total"
       width="900">
</div>

El mapa estÃ¡ estructurado como una red de **18 ciudades principales**.

| Tipo | Cantidad |
|---|---:|
| Ciudades ocupadas al inicio | 9 |
| Ciudades neutrales | 9 |
| Total | 18 |
| Civilizaciones / jugadores principales | 8 |

Germania constituye una excepciÃ³n al comenzar con dos posiciones separadas geogrÃ¡ficamente.

## Civilizaciones

| Player | CivilizaciÃ³n |
|---:|---|
| 1 | Roma Imperial |
| 2 | Cartago |
| 3 | Iberia |
| 4 | Galia |
| 5 | Britania |
| 6 | Germania |
| 7 | Roma Republicana |
| 8 | Egipto |

La geografÃ­a estÃ¡ diseÃ±ada para producir:

```text
frentes regionales
corredores de invasiÃ³n
ciudades-puerta
posiciones defensivas
rutas alternativas
cuellos de botella
```

Algunas ciudades funcionan como autÃ©nticos puntos de paso territorial:

```text
N1
N3
O6
N4
O7
O9
```

El control de estas posiciones puede abrir o cerrar regiones completas del mapa.

Mapa estratÃ©gico:

[`mapa/MapaNodos.png`](mapa/MapaNodos.png)

---

# Arquitectura general de la versiÃ³n 2.0

La versiÃ³n estable utiliza **23 Sequences documentadas**.

```text
SISTEMAS TERRITORIALES
â”œâ”€â”€ Fortresses_Main
â”œâ”€â”€ ForumCaptureReward_Main
â”œâ”€â”€ GGuardPost
â”œâ”€â”€ GuardPostsFrontierReward_Main
â””â”€â”€ OutpostAuxDefense_Main

MODO ZOMBIES
â”œâ”€â”€ ZombieIntro_Main
â”œâ”€â”€ ZombieRewards_Main
â”œâ”€â”€ ZombieTactical_Main
â””â”€â”€ ZombieWaves_Main

EASTER EGG
â”œâ”€â”€ ZombieEE_FirstHordeTrigger
â”œâ”€â”€ ZombieEE_PriestKeeper
â”œâ”€â”€ ZombieEE_PriestInteraction_Main
â”œâ”€â”€ ZombieEE_Dialogue01
â”œâ”€â”€ ZombieEE_Sacrifice_Main
â”œâ”€â”€ ZombieEE_AnubisAttack_Main
â”œâ”€â”€ ZombieEE_Dialogue02
â”œâ”€â”€ ZombieEE_Portals_Main
â”œâ”€â”€ ZombieEE_Dialogue03
â”œâ”€â”€ ZombieEE_Amulet_Main
â”œâ”€â”€ ZombieEE_Dialogue04
â”œâ”€â”€ ZombieEE_FinalAssault_Main
â”œâ”€â”€ ZombieEE_FinalAssault_Run
â””â”€â”€ ZombieEE_DialogueFinal
```

Cada Sequence tiene una responsabilidad concreta y se coordina con las demÃ¡s mediante:

```text
Groups
EnvReadInt / EnvWriteInt
RunSequence
Conversation
ShowAnnouncement / HideAnnouncement
UserNotification
```

---

# MecÃ¡nicas territoriales

## 1. Fortalezas

### `Fortresses_Main`

Convierte los Outposts culturales del mapa en fortalezas defensivas persistentes.

La Sequence:

- detecta automÃ¡ticamente todos los Outposts culturales;
- conserva las guarniciones neutrales originales cuando corresponde;
- aplica tratamiento especial al `EOutpost`;
- crea guarniciones especÃ­ficas por cultura despuÃ©s de la conquista;
- mantiene las tropas vinculadas a la fortaleza;
- evita que la IA estratÃ©gica se las lleve;
- desactiva su dependencia de comida;
- las saca a combatir cuando hay enemigos;
- las devuelve al fortÃ­n cuando desaparece la amenaza;
- regenera bajas progresivamente;
- impide capturas mientras todavÃ­a existan defensores reales;
- reconstruye la guarniciÃ³n tras cada cambio de propietario;
- permite ciclos de reconquista ilimitados.

Guarniciones estructurales actuales:

```text
TOutpost â†’ 10 TValkyrie
GOutpost â†’ 4 GTridentWarrior
BOutpost â†’ 10 BHighlander
IOutpost â†’ 12 ISlinger + 10 IDefender
COutpost â†’ 24 CMacemen
ROutpost â†’ 20 RLiberatus
EOutpost â†’ 10 EHorusWarrior + 10 EAnubisWarrior
```

RegeneraciÃ³n:

```text
1 baja cada 20 segundos
sÃ³lo cuando no hay enemigos
```

DocumentaciÃ³n:

[`docs/secuencias/01_Fortresses_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/01_Fortresses_Main_Explicacion_Detallada_V2.0.md)

---

## 2. Recompensa por ciudades neutrales

### `ForumCaptureReward_Main`

Al comenzar la partida descubre todos los `BaseTownhall` inicialmente neutrales de:

```text
Player 15
Player 16
```

Cuando uno de esos Foros es conquistado por primera vez por un Player 1-8:

```text
primera conquista
â†“
100 tropas
â†“
recompensa asociada a la civilizaciÃ³n del conquistador
```

CaracterÃ­sticas:

- una recompensa mÃ¡xima por cada Foro inicialmente neutral;
- unidades de nivel 12;
- tropas normales;
- alimentaciÃ³n normal;
- control normal del jugador o IA;
- creaciÃ³n en el Foro conquistado;
- seguimiento persistente de quÃ© ciudad ya entregÃ³ su recompensa.

DocumentaciÃ³n:

[`docs/secuencias/02_ForumCaptureReward_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/02_ForumCaptureReward_Main_Explicacion_Detallada_V2.0.md)

---

## 3. Guard Posts

### `GGuardPost`

La Sequence de producciÃ³n se encuentra en la secciÃ³n/editor:

```text
GGuardPost
```

El comentario histÃ³rico del Source conserva el nombre antiguo:

```text
GuardPosts_Main
```

pero la documentaciÃ³n v2.0 utiliza el nombre real actual:

```text
GGuardPost
```

Cada `GGuardPost` conserva sus:

```text
12 sentinelas nativos
```

y la Sequence aÃ±ade una escolta terrestre adicional de:

```text
10 guardianes
```

segÃºn la cultura del propietario.

Ejemplos:

```text
Roma Imperial â†’ 5 RHastatus + 5 RPraetorian
Cartago       â†’ 5 CNoble + 5 CBerberAssassin
Iberia        â†’ 5 IDefender + 5 IEliteGuard
Galia         â†’ 5 GWomanWarrior + 5 GAxeman
Britania      â†’ 5 BBronzeSpearman + 5 BHighlander
Germania      â†’ 5 TMaceman + 5 THuntress
```

Los guardianes:

- permanecen fuera del Settlement;
- no dependen de comida;
- quedan excluidos de la IA estratÃ©gica;
- defienden automÃ¡ticamente el puesto;
- regresan a sus posiciones de guardia;
- regeneran una baja cada 30 segundos en paz;
- bloquean la captura mientras sobreviva al menos uno.

DocumentaciÃ³n:

[`docs/secuencias/03_GGuardPost_Explicacion_Detallada_V2.0.md`](docs/secuencias/03_GGuardPost_Explicacion_Detallada_V2.0.md)

---

## 4. Recompensas estratÃ©gicas de frontera

### `GuardPostsFrontierReward_Main`

El mapa utiliza diez zonas territoriales:

```text
RewardZone_01
RewardZone_02
...
RewardZone_10
```

Cuando todos los objetos de una zona pertenecen al mismo Player 1-8:

```text
control regional completo
â†“
100 tropas de recompensa
```

Cada combinaciÃ³n:

```text
zona + jugador
```

sÃ³lo puede cobrarse una vez.

El sistema permite que una misma regiÃ³n entregue recompensa a propietarios distintos si cambia de manos durante la partida.

DocumentaciÃ³n:

[`docs/secuencias/04_GuardPostsFrontierReward_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/04_GuardPostsFrontierReward_Main_Explicacion_Detallada_V2.0.md)

---

## 5. Defensa auxiliar de Outposts

### `OutpostAuxDefense_Main`

Las tropas normales almacenadas por un jugador dentro de un Outpost pueden actuar temporalmente como defensa auxiliar.

```text
PAZ
â†’ la Sequence no toca las tropas normales

ATAQUE
â†’ las tropas almacenadas salen a combatir

JUGADOR DA UNA ORDEN MANUAL
â†’ la unidad se desvincula del sistema auxiliar

VUELVE A ENTRAR EN EL OUTPOST
â†’ puede quedar vinculada de nuevo en una defensa futura

FIN DE LA AMENAZA
â†’ las auxiliares regresan al Outpost
```

Las tropas auxiliares:

- son soldados reales del jugador;
- consumen comida normalmente;
- no se regeneran;
- no forman parte de la guarniciÃ³n estructural;
- pueden volver al control manual del jugador.

DocumentaciÃ³n:

[`docs/secuencias/05_OutpostAuxDefense_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/05_OutpostAuxDefense_Main_Explicacion_Detallada_V2.0.md)

---

# Modo Zombies v2.0

<div align="center">

<img src="imagenes/pantalla%20carga/Portada.png"
     alt="Modo Zombies de Imperivm III Guerra Total"
     width="850">

</div>

La versiÃ³n 2.0 sustituye por completo la antigua arquitectura de:

```text
40 rondas
48 hordas
HW_H1..HW_H48
ZR_PENDING
```

La arquitectura canÃ³nica actual utiliza:

```text
8 frentes persistentes
R1-R15 estructuradas
R16+ endless
scheduler no bloqueante
red tÃ¡ctica de 18 nodos
parada definitiva de nuevas hordas al cerrar 4 portales
```

Los cuatro mÃ³dulos principales son:

```text
ZombieIntro_Main
ZombieWaves_Main
ZombieTactical_Main
ZombieRewards_Main
```

---

# IntroducciÃ³n Zombies

## `ZombieIntro_Main`

Es la entrada narrativa y tÃ©cnica del Modo Zombies.

Flujo:

```text
vÃ­deo introductorio
â†“
cinemÃ¡tica en el mapa
â†“
mensajero cartaginÃ©s
â†“
comitiva romana
â†“
conversaciÃ³n
â†“
retirada de actores temporales
â†“
CÃ©sar permanece en el mapa
â†“
control vuelve al jugador
â†“
arranque del sistema Zombies
```

La Sequence inicia despuÃ©s:

```text
ZombieEE_PriestKeeper
ZombieEE_PriestInteraction_Main
ZombieEE_FirstHordeTrigger
ZombieWaves_Main
```

DocumentaciÃ³n:

[`docs/secuencias/09_ZombieIntro_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/09_ZombieIntro_Main_Explicacion_Detallada_V2.0.md)

---

# GeneraciÃ³n de rondas

## `ZombieWaves_Main`

ConfiguraciÃ³n canÃ³nica:

| ParÃ¡metro | Valor |
|---|---:|
| PreparaciÃ³n inicial | 30 minutos |
| Player Zombies | 12 |
| Puntos de apariciÃ³n | 8 |
| Intervalo base tras despliegue | 2 minutos |
| Pausa especial tras R5 | 10 minutos |
| Pausa especial tras R10 | 10 minutos |
| Rondas finitas | Ninguna |
| Inicio endless | R16 |
| Intervalo entre apariciones internas | 20 segundos |

Puntos:

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

## Rondas 1-15

Cada ronda usa:

```text
8 apariciones
```

Cada uno de los ocho `HordeSpawn_XX` aparece:

```text
exactamente una vez
```

en orden aleatorio.

Los grupos de seguimiento son:

```text
HW_R1
HW_R2
...
HW_R15
```

## Ronda 16 y posteriores

Desde R16:

```text
16 apariciones por ronda
```

Cada spawn se utiliza:

```text
exactamente 2 veces
```

La composiciÃ³n base endless contiene:

```text
50 unidades por apariciÃ³n
```

Por tanto una ronda endless normal despliega:

```text
16 Ã— 50
=
800 unidades
```

Los niveles progresan:

```text
R16 â†’ nivel 20
R17 â†’ nivel 21
R18 â†’ nivel 22
...
R56 â†’ nivel 60
R57+ â†’ nivel 60
```

Cada cinco rondas a partir de R20:

```text
+10 RHastatus
+10 TMaceman
por apariciÃ³n
```

La ronda especial pasa a:

```text
70 unidades Ã— 16
=
1120 unidades
```

## Scheduler endless

Desde R16:

```text
la siguiente ronda NO espera
a que HW_R16 quede vacÃ­o
```

Las rondas pueden solaparse.

El scheduler utiliza generaciones:

```text
ZR_ENDLESS_GENERATION
ZR_ENDLESS_DEPLOYED_GENERATION
ZR_ENDLESS_REWARDED_GENERATION
```

## Parada por portales

`ZombieWaves_Main` comprueba periÃ³dicamente:

```text
EE_ZOMBIE_SPAWNS_DISABLED
```

Cuando el Easter Egg cierra el cuarto portal:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 1
â†“
no se generan nuevas hordas
â†“
las hordas que ya existen permanecen vivas
```

DocumentaciÃ³n:

[`docs/secuencias/08_ZombieWaves_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/08_ZombieWaves_Main_Explicacion_Detallada_V2.0.md)

---

# IA tÃ¡ctica Zombies

## `ZombieTactical_Main`

La IA actual sustituye el antiguo sistema de decenas de slots independientes por:

```text
8 frentes persistentes
```

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
```

Cada frente corresponde a uno de los ocho puntos de apariciÃ³n.

## Red territorial

El controlador utiliza una red fija de:

```text
18 nodos
```

correspondiente a las ciudades del mapa.

La ruta se calcula mediante una estructura Dijkstra-like implementada con `IntArray`.

El sistema decide:

- ciudad objetivo;
- nodo ancla;
- siguiente nodo;
- ruta territorial;
- acceso a la ciudad;
- Gate relevante;
- fase de asedio;
- brecha;
- entrada;
- captura.

## Fases tÃ¡cticas

```text
0 â†’ marcha
1 â†’ asedio
2 â†’ avance por la brecha
3 â†’ captura
```

## Asedio

La horda:

- detecta Gates;
- utiliza `ObjList.Siege()`;
- intenta mantener la presiÃ³n;
- reagrupa unidades alejadas;
- detecta progreso a travÃ©s de la brecha;
- evita abandonar la ciudad objetivo para ir a una Gate irrelevante;
- mantiene combates durante el avance.

## Captura

Cuando existe acceso al Foro:

```text
las unidades cercanas reducen loyalty
â†“
al llegar al umbral
â†“
Player 12 toma temporalmente la ciudad
```

El sistema puede continuar desde esa nueva posiciÃ³n hacia otro objetivo.

DocumentaciÃ³n:

[`docs/secuencias/07_ZombieTactical_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/07_ZombieTactical_Main_Explicacion_Detallada_V2.0.md)

---

# Recompensas Zombies

## `ZombieRewards_Main`

La arquitectura actual separa dos sistemas.

## R1-R15

La recompensa se entrega cuando:

```text
HW_RN
queda completamente vacÃ­o
```

Cada ronda sÃ³lo puede pagarse una vez.

## R16+

Las generaciones endless no esperan a morir completamente.

La recompensa se activa cuando:

```text
el despliegue completo de la generaciÃ³n
ha sido confirmado
```

mediante:

```text
ZR_ENDLESS_DEPLOYED_GENERATION
```

y queda protegida contra duplicados mediante:

```text
ZR_ENDLESS_REWARDED_GENERATION
```

## Destinatarios

El sistema utiliza la mÃ¡scara de propietarios publicada por Tactical.

Si ningÃºn frente ha publicado propietario vÃ¡lido, existe un fallback sobre Players 1-8 que todavÃ­a posean un `BaseTownhall`.

## Recompensa endless

Desde R16:

```text
28 tropas
```

por jugador recompensado.

Nivel:

```text
20 + (ronda - 16)
mÃ¡ximo 60
```

DocumentaciÃ³n:

[`docs/secuencias/06_ZombieRewards_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/06_ZombieRewards_Main_Explicacion_Detallada_V2.0.md)

---

# Arquitectura actual del Modo Zombies

```mermaid
flowchart TD
    INTRO[ZombieIntro_Main] --> WAVES[ZombieWaves_Main]
    INTRO --> TRIGGER[ZombieEE_FirstHordeTrigger]
    INTRO --> PRIEST[ZombieEE_PriestInteraction_Main]

    WAVES --> FRONTS[HW_H1..HW_H8]
    FRONTS --> TACTICAL[ZombieTactical_Main]

    TACTICAL --> ROUTE[Red territorial de 18 nodos]
    ROUTE --> MARCH[Marcha]
    MARCH --> SIEGE[Asedio]
    SIEGE --> BREACH[Brecha]
    BREACH --> CAPTURE[Captura]

    WAVES --> REWARDS[ZombieRewards_Main]
    TACTICAL --> REWARDS

    PORTALS[4 portales cerrados] --> STOP[EE_ZOMBIE_SPAWNS_DISABLED]
    STOP --> WAVES
```

---

# Easter Egg â€” El Eclipse de Anubis

La versiÃ³n 2.0 incorpora un Easter Egg completo integrado dentro del Modo Zombies.

No es una mecÃ¡nica separada del mapa.

Utiliza:

```text
CÃ©sar
sacerdote egipcio
sacrificio de aldeanos
Guerreros de Anubis
ocho portales
Gem of Power
campamento cartaginÃ©s
asalto final
diÃ¡logo final
recompensas especiales
```

El flujo general es:

```text
primera mini-horda de HordeSpawn_01 destruida
â†“
Dialogue01
â†“
50 aldeanos sacrificados
â†“
50 Guerreros de Anubis
â†“
Dialogue02
â†“
cerrar 4 de 8 portales
â†“
se detienen nuevas hordas Zombies
â†“
Dialogue03
â†“
campamento cartaginÃ©s / Gem of Power
â†“
Dialogue04
â†“
sacerdote desaparece
â†“
asalto final de 200 enemigos
â†“
sacerdote reaparece
â†“
DialogueFinal
â†“
recompensa final
```

---

# Primera activaciÃ³n

## `ZombieEE_FirstHordeTrigger`

Durante R1, las unidades creadas especÃ­ficamente desde:

```text
HordeSpawn_01
```

tambiÃ©n se registran en:

```text
EE_FirstHorde_Spawn01
```

Cuando esa mini-horda ha terminado de generarse y todos sus miembros han muerto:

```text
EE_PRIEST_PENDING = 1
```

CÃ©sar debe regresar fÃ­sicamente al sacerdote.

DocumentaciÃ³n:

[`docs/secuencias/10_ZombieEE_FirstHordeTrigger_Explicacion_Detallada_V2.0.md`](docs/secuencias/10_ZombieEE_FirstHordeTrigger_Explicacion_Detallada_V2.0.md)

---

# Sacerdote persistente

## `ZombieEE_PriestKeeper`

Mantiene al sacerdote:

```text
SetNoAIFlag(true)
SetFeeding(false)
SetHealth(1000)
```

y lo devuelve a su posiciÃ³n de origen si se aleja.

Durante el asalto final:

```text
EE_PRIEST_HIDDEN = 1
```

permite que el sacerdote desaparezca temporalmente sin que PriestKeeper intente recuperarlo.

Cuando reaparece:

```text
EE_PRIEST_HIDDEN = 0
```

y vuelve a ser protegido.

DocumentaciÃ³n:

[`docs/secuencias/11_ZombieEE_PriestKeeper_Explicacion_Detallada_V2.0.md`](docs/secuencias/11_ZombieEE_PriestKeeper_Explicacion_Detallada_V2.0.md)

---

# InteracciÃ³n presencial

## `ZombieEE_PriestInteraction_Main`

Toda la narrativa utiliza una Ãºnica variable:

```text
EE_PRIEST_PENDING
```

Mapa actual:

```text
1 â†’ ZombieEE_Dialogue01
2 â†’ ZombieEE_Dialogue02
3 â†’ ZombieEE_Dialogue03
4 â†’ ZombieEE_Dialogue04
5 â†’ ZombieEE_DialogueFinal
```

Cuando existe un diÃ¡logo pendiente:

```text
VE A HABLAR CON EL SACERDOTE EGIPCIO
```

se recuerda aproximadamente cada 15 segundos.

El diÃ¡logo sÃ³lo comienza cuando:

```text
CÃ©sar <= 180
```

del sacerdote.

DocumentaciÃ³n:

[`docs/secuencias/12_ZombieEE_PriestInteraction_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/12_ZombieEE_PriestInteraction_Main_Explicacion_Detallada_V2.0.md)

---

# Dialogue01 â€” Las cincuenta almas

## `ZombieEE_Dialogue01`

DespuÃ©s de la primera visita al sacerdote:

```text
EE_SACRIFICE_ENABLED = 1
â†“
RunSequence("ZombieEE_Sacrifice_Main")
```

Objetivo:

```text
CONDUCE 50 ALDEANOS HASTA LAS PIRAMIDES
```

DocumentaciÃ³n:

[`docs/secuencias/13_ZombieEE_Dialogue01_Explicacion_Detallada_V2.0.md`](docs/secuencias/13_ZombieEE_Dialogue01_Explicacion_Detallada_V2.0.md)

---

# Sacrificio

## `ZombieEE_Sacrifice_Main`

La Sequence detecta aldeanos vÃ¡lidos alrededor de:

```text
ZombieEE_SacrificePyramids
```

y cuenta las almas entregadas.

Objetivo:

```text
50 aldeanos
```

Al completar el sacrificio:

```text
EE_SACRIFICE_COMPLETED = 1
â†“
RunSequence("ZombieEE_AnubisAttack_Main")
```

DocumentaciÃ³n:

[`docs/secuencias/14_ZombieEE_Sacrifice_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/14_ZombieEE_Sacrifice_Main_Explicacion_Detallada_V2.0.md)

---

# Ataque de Anubis

## `ZombieEE_AnubisAttack_Main`

DespuÃ©s del sacrificio aparecen:

```text
50 EAnubisWarrior
nivel 40
Player 12
```

desde:

```text
HordeSpawn_01
```

Todos pertenecen al Group:

```text
EE_AnubisWave01
```

y avanzan hacia:

```text
CapitalForum_P1
```

Cuando todos mueren:

```text
EE_ANUBIS_ATTACK_COMPLETED = 1
EE_PRIEST_PENDING = 2
```

DocumentaciÃ³n:

[`docs/secuencias/15_ZombieEE_AnubisAttack_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/15_ZombieEE_AnubisAttack_Main_Explicacion_Detallada_V2.0.md)

---

# Dialogue02 â€” Los portales

## `ZombieEE_Dialogue02`

La segunda conversaciÃ³n activa:

```text
EE_PORTALS_ENABLED = 1
```

e inicia:

```text
ZombieEE_Portals_Main
```

Objetivo:

```text
CIERRA 4 PORTALES CUALESQUIERA
CON SACERDOTES ROMANOS
```

DocumentaciÃ³n:

[`docs/secuencias/16_ZombieEE_Dialogue02_Explicacion_Detallada_V2.0.md`](docs/secuencias/16_ZombieEE_Dialogue02_Explicacion_Detallada_V2.0.md)

---

# Los ocho portales

## `ZombieEE_Portals_Main`

Los propios:

```text
HordeSpawn_01..08
```

funcionan tambiÃ©n como posiciones de portal.

Un portal abierto se activa cuando un:

```text
RPriest de Player 1
```

entra a:

```text
<=220
```

del punto.

Cada portal genera:

```text
10 EAnubisWarrior
10 EHorusWarrior
nivel 20
Player 12
```

Cuando mueren los 20 guardianes:

```text
el portal queda cerrado
```

y Player 1 recibe dentro de `CapitalForum_P1`:

```text
20 RPraetorian
15 RHastatus
15 RArcher
nivel 25
```

SÃ³lo es necesario cerrar:

```text
4 de los 8 portales
```

en cualquier orden.

Al registrar el cuarto cierre:

```text
EE_ZOMBIE_SPAWNS_DISABLED = 1
```

Las nuevas hordas Zombies dejan de aparecer.

DespuÃ©s:

```text
EE_PRIEST_PENDING = 3
```

DocumentaciÃ³n:

[`docs/secuencias/17_ZombieEE_Portals_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/17_ZombieEE_Portals_Main_Explicacion_Detallada_V2.0.md)

---

# Dialogue03 â€” Gem of Power

## `ZombieEE_Dialogue03`

DespuÃ©s de cerrar los cuatro portales necesarios:

```text
EE_PORTAL_PHASE_FINISHED = 1
EE_AMULET_HUNT_ENABLED = 1
â†“
RunSequence("ZombieEE_Amulet_Main")
```

Objetivo:

```text
ATACA EL CAMPAMENTO DEL SUR
Y RECUPERA GEM OF POWER
```

DocumentaciÃ³n:

[`docs/secuencias/18_ZombieEE_Dialogue03_Explicacion_Detallada_V2.0.md`](docs/secuencias/18_ZombieEE_Dialogue03_Explicacion_Detallada_V2.0.md)

---

# Campamento cartaginÃ©s

## `ZombieEE_Amulet_Main`

La implementaciÃ³n v2.0 simplifica la antigua idea de transportar fÃ­sicamente un objeto de inventario.

La mecÃ¡nica actual es:

```text
aparece un campamento cartaginÃ©s
â†“
aparece un caudillo CHero1 con su ejÃ©rcito
â†“
el jugador debe matar al caudillo
â†“
la fase queda completada
â†“
EE_PRIEST_PENDING = 4
```

No existe una Gem of Power fÃ­sica que el jugador tenga que transportar manualmente.

La Gem of Power funciona como elemento narrativo asociado a la derrota del caudillo.

DocumentaciÃ³n:

[`docs/secuencias/19_ZombieEE_Amulet_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/19_ZombieEE_Amulet_Main_Explicacion_Detallada_V2.0.md)

---

# Dialogue04 â€” El sacerdote parte hacia Egipto

## `ZombieEE_Dialogue04`

DespuÃ©s de completar la fase del caudillo:

```text
ZombieEE_Conv04
â†“
guardar posiciÃ³n y propietario del sacerdote
â†“
EE_PRIEST_HIDDEN = 1
â†“
RemoveFromGroup("ZombieEE_Priest01")
â†“
Erase()
â†“
el sacerdote desaparece
```

DespuÃ©s prepara:

```text
EE_FINAL_ASSAULT_ENABLED = 1
EE_FINAL_ASSAULT_STARTED = 0
EE_FINAL_ASSAULT_COMPLETED = 0
EE_FINAL_BATCH_DEPLOYED = 0
```

y lanza expresamente:

```text
ZombieEE_FinalAssault_Run
```

DocumentaciÃ³n:

[`docs/secuencias/20_ZombieEE_Dialogue04_Explicacion_Detallada_V2.0.md`](docs/secuencias/20_ZombieEE_Dialogue04_Explicacion_Detallada_V2.0.md)

---

# Asalto final histÃ³rico

## `ZombieEE_FinalAssault_Main`

La compilaciÃ³n v2.0 conserva esta Sequence porque contiene la implementaciÃ³n histÃ³rica completa del asalto final.

Sin embargo:

```text
NO es el punto de entrada utilizado actualmente
```

`ZombieEE_Dialogue04` lanza:

```text
ZombieEE_FinalAssault_Run
```

La documentaciÃ³n de `FinalAssault_Main` se conserva como referencia tÃ©cnica e histÃ³rica.

DocumentaciÃ³n:

[`docs/secuencias/21_ZombieEE_FinalAssault_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/21_ZombieEE_FinalAssault_Main_Explicacion_Detallada_V2.0.md)

---

# Asalto final activo

## `ZombieEE_FinalAssault_Run`

Es el asalto final realmente utilizado en v2.0.

ConfiguraciÃ³n:

```text
8 tandas
Ã—
25 enemigos
=
200 atacantes
```

Niveles:

```text
Tanda 1 â†’ 20
Tanda 2 â†’ 26
Tanda 3 â†’ 32
Tanda 4 â†’ 38
Tanda 5 â†’ 44
Tanda 6 â†’ 50
Tanda 7 â†’ 55
Tanda 8 â†’ 60
```

Intervalo:

```text
20 segundos entre tandas
```

Todos los enemigos:

```text
Player 12
Group EE_FinalAssault
SetFeeding(false)
SetNoAIFlag(true)
advance â†’ CapitalForum_P1
```

El sistema no utiliza:

```text
HW_H1..8
ZombieTactical_Main
orden capture
```

Cuando mueren todos:

```text
recrear EPriest
â†“
AddToGroup("ZombieEE_Priest01")
â†“
EE_PRIEST_HIDDEN = 0
â†“
EE_FINAL_ASSAULT_COMPLETED = 1
â†“
EE_FINAL_ASSAULT_ENABLED = 0
â†“
EE_PRIEST_PENDING = 5
```

DocumentaciÃ³n:

[`docs/secuencias/22_ZombieEE_FinalAssault_Run_Explicacion_Detallada_V2.0.md`](docs/secuencias/22_ZombieEE_FinalAssault_Run_Explicacion_Detallada_V2.0.md)

---

# DiÃ¡logo final

## `ZombieEE_DialogueFinal`

DespuÃ©s de la Ãºltima visita al sacerdote:

```text
ZombieEE_ConvFinal
```

cierra narrativamente el Easter Egg.

La Sequence:

- revela la conspiraciÃ³n de Egipto y Cartago;
- procesa al sacerdote;
- entrega las recompensas finales;
- marca el Easter Egg como terminado;
- deja cerrada la cadena narrativa.

DocumentaciÃ³n:

[`docs/secuencias/23_ZombieEE_DialogueFinal_Explicacion_Detallada_V2.0.md`](docs/secuencias/23_ZombieEE_DialogueFinal_Explicacion_Detallada_V2.0.md)

---

# Arquitectura completa del Easter Egg

```mermaid
flowchart TD
    A[R1 / HordeSpawn_01 destruida] --> B[FirstHordeTrigger]
    B --> C[Pending 1]
    C --> D[Dialogue01]

    D --> E[Sacrifice_Main]
    E --> F[50 aldeanos]
    F --> G[AnubisAttack]
    G --> H[50 Anubis derrotados]

    H --> I[Pending 2]
    I --> J[Dialogue02]

    J --> K[Portals_Main]
    K --> L[4 de 8 portales]
    L --> M[Detener nuevas hordas]

    M --> N[Pending 3]
    N --> O[Dialogue03]

    O --> P[Amulet_Main]
    P --> Q[Caudillo cartaginÃ©s derrotado]

    Q --> R[Pending 4]
    R --> S[Dialogue04]

    S --> T[Sacerdote desaparece]
    T --> U[FinalAssault_Run]
    U --> V[200 enemigos derrotados]

    V --> W[Sacerdote reaparece]
    W --> X[Pending 5]
    X --> Y[DialogueFinal]
    Y --> Z[Easter Egg completado]
```

---

# DocumentaciÃ³n de Sequences

La documentaciÃ³n v2.0 queda organizada asÃ­:

| NÂº | Sequence | Documento |
|---:|---|---|
| 01 | `Fortresses_Main` | [`01_Fortresses_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/01_Fortresses_Main_Explicacion_Detallada_V2.0.md) |
| 02 | `ForumCaptureReward_Main` | [`02_ForumCaptureReward_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/02_ForumCaptureReward_Main_Explicacion_Detallada_V2.0.md) |
| 03 | `GGuardPost` | [`03_GGuardPost_Explicacion_Detallada_V2.0.md`](docs/secuencias/03_GGuardPost_Explicacion_Detallada_V2.0.md) |
| 04 | `GuardPostsFrontierReward_Main` | [`04_GuardPostsFrontierReward_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/04_GuardPostsFrontierReward_Main_Explicacion_Detallada_V2.0.md) |
| 05 | `OutpostAuxDefense_Main` | [`05_OutpostAuxDefense_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/05_OutpostAuxDefense_Main_Explicacion_Detallada_V2.0.md) |
| 06 | `ZombieRewards_Main` | [`06_ZombieRewards_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/06_ZombieRewards_Main_Explicacion_Detallada_V2.0.md) |
| 07 | `ZombieTactical_Main` | [`07_ZombieTactical_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/07_ZombieTactical_Main_Explicacion_Detallada_V2.0.md) |
| 08 | `ZombieWaves_Main` | [`08_ZombieWaves_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/08_ZombieWaves_Main_Explicacion_Detallada_V2.0.md) |
| 09 | `ZombieIntro_Main` | [`09_ZombieIntro_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/09_ZombieIntro_Main_Explicacion_Detallada_V2.0.md) |
| 10 | `ZombieEE_FirstHordeTrigger` | [`10_ZombieEE_FirstHordeTrigger_Explicacion_Detallada_V2.0.md`](docs/secuencias/10_ZombieEE_FirstHordeTrigger_Explicacion_Detallada_V2.0.md) |
| 11 | `ZombieEE_PriestKeeper` | [`11_ZombieEE_PriestKeeper_Explicacion_Detallada_V2.0.md`](docs/secuencias/11_ZombieEE_PriestKeeper_Explicacion_Detallada_V2.0.md) |
| 12 | `ZombieEE_PriestInteraction_Main` | [`12_ZombieEE_PriestInteraction_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/12_ZombieEE_PriestInteraction_Main_Explicacion_Detallada_V2.0.md) |
| 13 | `ZombieEE_Dialogue01` | [`13_ZombieEE_Dialogue01_Explicacion_Detallada_V2.0.md`](docs/secuencias/13_ZombieEE_Dialogue01_Explicacion_Detallada_V2.0.md) |
| 14 | `ZombieEE_Sacrifice_Main` | [`14_ZombieEE_Sacrifice_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/14_ZombieEE_Sacrifice_Main_Explicacion_Detallada_V2.0.md) |
| 15 | `ZombieEE_AnubisAttack_Main` | [`15_ZombieEE_AnubisAttack_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/15_ZombieEE_AnubisAttack_Main_Explicacion_Detallada_V2.0.md) |
| 16 | `ZombieEE_Dialogue02` | [`16_ZombieEE_Dialogue02_Explicacion_Detallada_V2.0.md`](docs/secuencias/16_ZombieEE_Dialogue02_Explicacion_Detallada_V2.0.md) |
| 17 | `ZombieEE_Portals_Main` | [`17_ZombieEE_Portals_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/17_ZombieEE_Portals_Main_Explicacion_Detallada_V2.0.md) |
| 18 | `ZombieEE_Dialogue03` | [`18_ZombieEE_Dialogue03_Explicacion_Detallada_V2.0.md`](docs/secuencias/18_ZombieEE_Dialogue03_Explicacion_Detallada_V2.0.md) |
| 19 | `ZombieEE_Amulet_Main` | [`19_ZombieEE_Amulet_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/19_ZombieEE_Amulet_Main_Explicacion_Detallada_V2.0.md) |
| 20 | `ZombieEE_Dialogue04` | [`20_ZombieEE_Dialogue04_Explicacion_Detallada_V2.0.md`](docs/secuencias/20_ZombieEE_Dialogue04_Explicacion_Detallada_V2.0.md) |
| 21 | `ZombieEE_FinalAssault_Main` | [`21_ZombieEE_FinalAssault_Main_Explicacion_Detallada_V2.0.md`](docs/secuencias/21_ZombieEE_FinalAssault_Main_Explicacion_Detallada_V2.0.md) |
| 22 | `ZombieEE_FinalAssault_Run` | [`22_ZombieEE_FinalAssault_Run_Explicacion_Detallada_V2.0.md`](docs/secuencias/22_ZombieEE_FinalAssault_Run_Explicacion_Detallada_V2.0.md) |
| 23 | `ZombieEE_DialogueFinal` | [`23_ZombieEE_DialogueFinal_Explicacion_Detallada_V2.0.md`](docs/secuencias/23_ZombieEE_DialogueFinal_Explicacion_Detallada_V2.0.md) |

---

# Manual tÃ©cnico

El manual central actualizado del proyecto es:

[`docs/manual/Imperivm_III_Manual_Ingenieria_Inversa_V2.0_Actualizado.md`](docs/manual/Imperivm_III_Manual_Ingenieria_Inversa_V2.0_Actualizado.md)

Documenta, entre otros temas:

- CKS/VS y Sequences;
- `Obj`, `Unit`, `Building` y `Settlement`;
- Queries y `ObjList`;
- `Place()`;
- Groups estÃ¡ticos y dinÃ¡micos;
- `EnvReadInt()` / `EnvWriteInt()`;
- `IntArray`;
- `SetNoAIFlag()`;
- `SetFeeding()`;
- captura y loyalty;
- Townhalls;
- Outposts;
- `GGuardPost`;
- Gates;
- `ObjList.Siege()`;
- catapultas y `RamUnit`;
- AI Helpers;
- `RunSequence()`;
- `Conversation`;
- cinematogrÃ¡ficas;
- `PlayMovie()`;
- control de cÃ¡mara;
- anuncios;
- `UserNotification`;
- `Unit.AddItem`;
- estado compartido;
- mÃ¡quinas de estados;
- arquitectura tÃ©cnica del Modo Zombies v2.0;
- arquitectura del Easter Egg.

---

# Groups manuales principales

## Estado global / capital

```text
CapitalForum_P1
```

Es ademÃ¡s el objeto de estado compartido principal del Modo Zombies y del Easter Egg.

Las recompensas territoriales utilizan tambiÃ©n:

```text
CapitalForum_P1
CapitalForum_P2
CapitalForum_P3
CapitalForum_P4
CapitalForum_P5
CapitalForum_P6
CapitalForum_P7
CapitalForum_P8
```

segÃºn la mecÃ¡nica.

---

## Reward Zones

```text
RewardZone_01
RewardZone_02
RewardZone_03
RewardZone_04
RewardZone_05
RewardZone_06
RewardZone_07
RewardZone_08
RewardZone_09
RewardZone_10
```

---

## Spawns Zombies / Portales

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

Los ocho puntos cumplen doble funciÃ³n:

```text
spawns de Zombies
+
portales del Easter Egg
```

---

## Personajes del Easter Egg

```text
ZombieEE_Caesar
ZombieEE_Priest01
```

---

## Zona de sacrificio

```text
ZombieEE_SacrificePyramids
```

---

# Groups dinÃ¡micos importantes

Estos Groups son gestionados por las Sequences y no deben poblarse manualmente como ejÃ©rcitos iniciales.

## Fortalezas

```text
__FRT_X_Y
__FRT_AUX_X_Y
```

---

## Guard Posts

```text
__GP_X_Y
```

---

## Frentes Zombies

```text
HW_H1
HW_H2
HW_H3
HW_H4
HW_H5
HW_H6
HW_H7
HW_H8
```

---

## Rondas Zombies

```text
HW_R1
...
HW_R15
HW_R16
```

`HW_R16` actÃºa como Group compartido para las rondas endless, pero no se utiliza para bloquear el scheduler.

---

## Easter Egg

```text
EE_FirstHorde_Spawn01
EE_AnubisWave01
EE_PortalGuardiansActive
EE_PortalRewards
ZombieEE_AmuletArmy
ZombieEE_AmuletCarrier
EE_FinalAssault
ZombieEE_FinalRewards
ZombieEE_Prisoner
```

---

# Autorun y orquestaciÃ³n

No todas las Sequences deben configurarse con Autorun.

## Autorun principal

Los sistemas persistentes de producciÃ³n incluyen:

```text
Fortresses_Main
ForumCaptureReward_Main
GGuardPost
GuardPostsFrontierReward_Main
OutpostAuxDefense_Main
ZombieIntro_Main
ZombieRewards_Main
ZombieTactical_Main
```

## Lanzamiento diferido

El resto del flujo Zombies / Easter Egg se orquesta mediante:

```text
RunSequence()
```

Especialmente:

```text
ZombieWaves_Main
ZombieEE_FirstHordeTrigger
ZombieEE_PriestKeeper
ZombieEE_PriestInteraction_Main
ZombieEE_Dialogue01
ZombieEE_Sacrifice_Main
ZombieEE_AnubisAttack_Main
ZombieEE_Dialogue02
ZombieEE_Portals_Main
ZombieEE_Dialogue03
ZombieEE_Amulet_Main
ZombieEE_Dialogue04
ZombieEE_FinalAssault_Run
ZombieEE_DialogueFinal
```

`ZombieEE_FinalAssault_Main` se conserva como implementaciÃ³n histÃ³rica, pero no es el punto de entrada utilizado por Dialogue04.

---

# Estructura recomendada del repositorio

```text
Imperivm-III-Guerra-Total/
â”‚
â”œâ”€â”€ README.md
â”œâ”€â”€ .gitignore
â”‚
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ manual/
â”‚   â”‚   â””â”€â”€ Imperivm_III_Manual_Ingenieria_Inversa_V2.0_Actualizado.md
â”‚   â”‚
â”‚   â””â”€â”€ secuencias/
â”‚       â”œâ”€â”€ 01_Fortresses_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 02_ForumCaptureReward_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 03_GGuardPost_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 04_GuardPostsFrontierReward_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 05_OutpostAuxDefense_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 06_ZombieRewards_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 07_ZombieTactical_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 08_ZombieWaves_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 09_ZombieIntro_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 10_ZombieEE_FirstHordeTrigger_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 11_ZombieEE_PriestKeeper_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 12_ZombieEE_PriestInteraction_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 13_ZombieEE_Dialogue01_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 14_ZombieEE_Sacrifice_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 15_ZombieEE_AnubisAttack_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 16_ZombieEE_Dialogue02_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 17_ZombieEE_Portals_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 18_ZombieEE_Dialogue03_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 19_ZombieEE_Amulet_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 20_ZombieEE_Dialogue04_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 21_ZombieEE_FinalAssault_Main_Explicacion_Detallada_V2.0.md
â”‚       â”œâ”€â”€ 22_ZombieEE_FinalAssault_Run_Explicacion_Detallada_V2.0.md
â”‚       â””â”€â”€ 23_ZombieEE_DialogueFinal_Explicacion_Detallada_V2.0.md
â”‚
â”œâ”€â”€ mapa/
â”‚   â”œâ”€â”€ MapaNodos.png
â”‚   â”œâ”€â”€ Mapa desde Editor.jpg
â”‚   â””â”€â”€ Mapa.jpg
â”‚
â””â”€â”€ secuencias/
    â”œâ”€â”€ Fortresses_Main.vs
    â”œâ”€â”€ ForumCaptureReward_Main.vs
    â”œâ”€â”€ GGuardPost.vs
    â”œâ”€â”€ GuardPostsFrontierReward_Main.vs
    â”œâ”€â”€ OutpostAuxDefense_Main.vs
    â””â”€â”€ Modo zombie/
        â”œâ”€â”€ modo zombies.png
        â”œâ”€â”€ ZombieIntro_Main.vs
        â”œâ”€â”€ ZombieRewards_Main.vs
        â”œâ”€â”€ ZombieTactical_Main.vs
        â”œâ”€â”€ ZombieWaves_Main.vs
        â””â”€â”€ ZombieEE_*.vs
```

---

# Estado actual del proyecto

| Sistema | Estado v2.0 |
|---|---|
| Mapa estratÃ©gico | Implementado |
| Sistema de fortalezas | Estable |
| Recompensa por Foro neutral | Estable |
| Guard Posts | Estable |
| Recompensas territoriales | Estables |
| Defensa auxiliar de Outposts | Estable |
| Intro Zombies | Implementada |
| GeneraciÃ³n Zombies R1-R15 | Estable |
| Zombies R16+ endless | Implementado |
| 8 frentes tÃ¡cticos | Implementados |
| Red territorial de 18 nodos | Implementada |
| Asedio Zombies | Implementado |
| Captura Zombies | Implementada |
| Recompensas Zombies | Implementadas |
| Easter Egg | Completo |
| Sacrificio de 50 aldeanos | Implementado |
| Ataque de 50 Anubis | Implementado |
| 8 portales / cierre de 4 | Implementado |
| Parada definitiva de nuevas hordas | Implementada |
| Campamento cartaginÃ©s | Implementado |
| Asalto final de 200 unidades | Implementado |
| DiÃ¡logo y recompensa final | Implementados |
| Manual tÃ©cnico | Actualizado a v2.0 |
| DocumentaciÃ³n de Sequences | 23/23 |

---

# Limitaciones conocidas

## IA de asedio y unidades `InHolder`

El sistema Tactical puede mantener tripulaciones asociadas a un asedio.

Existe una limitaciÃ³n conocida:

```text
una unidad puede permanecer InHolder
despuÃ©s de que una Gate haya alcanzado el umbral de rotura
```

Se evitaron intentos agresivos de expulsiÃ³n forzada porque podÃ­an producir inestabilidad.

La arquitectura endless ya no depende de que esos residuos desaparezcan para lanzar la siguiente ronda.

---

## Asalto final

El asalto final del Easter Egg:

```text
NO utiliza ZombieTactical_Main
```

Los 200 atacantes reciben:

```text
advance â†’ CapitalForum_P1
```

y sÃ³lo se reactiva una unidad cuando queda:

```text
idle
```

Esto preserva los combates, pero no reproduce toda la mÃ¡quina tÃ¡ctica avanzada de Gates, brechas y captura del modo Zombies normal.

---

## NavegaciÃ³n marÃ­tima

El motor dispone de:

```text
agua
barcos
puertos
navegaciÃ³n
```

pero la IA estratÃ©gica aprovecha estas rutas de forma limitada comparada con el movimiento terrestre.

Por ello el diseÃ±o principal del mapa se apoya en corredores terrestres.

---

## Player tÃ©cnico 12

El Modo Zombies utiliza:

```text
Player 12
```

como facciÃ³n tÃ©cnica.

Su comportamiento estÃ¡ integrado en el escenario actual, pero cualquier modificaciÃ³n profunda de condiciones de victoria, diplomacia o reglas globales debe comprobarse teniendo en cuenta la existencia de este Player.

---

# FilosofÃ­a de desarrollo

Imperivm III no debe tratarse como C++ estÃ¡ndar.

El proyecto utiliza esta jerarquÃ­a de evidencia:

```text
prueba real en partida
        â†“
Sequence estable del proyecto
        â†“
Sequence oficial
        â†“
script nativo
        â†“
definiciÃ³n interna de clase
        â†“
anÃ¡lisis automatizado
        â†“
inferencia
```

No se incorporan APIs al cÃ³digo de producciÃ³n Ãºnicamente porque su nombre parezca plausible.

La investigaciÃ³n ha confirmado, entre otras, herramientas como:

```text
Place()
SetPlayer()
SetHealth()
SetLevel()
SetFood()
SetFeeding()
SetNoAIFlag()
ForceAddUnit()
ObjsInRange()
EnemyObjs()
ClassPlayerObjs()
Group()
AddToGroup()
RemoveFromGroup()
EnvReadInt()
EnvWriteInt()
IntArray
ObjList.Siege()
SetCommand()
RunSequence()
RunAIHelper()
Conversation.Init()
Conversation.SetActor()
Conversation.Run()
PlayMovie()
BlockUserInput()
UnblockUserInput()
StartViewFollow()
StopViewFollow()
ShowAnnouncement()
HideAnnouncement()
UserNotification()
Unit.AddItem()
```

---

# Objetivo del proyecto

La intenciÃ³n de **Imperivm III â€” Guerra Total** es convertir una partida normal en una guerra territorial de larga duraciÃ³n donde:

- la geografÃ­a importe;
- conquistar una posiciÃ³n tenga consecuencias;
- las fortalezas sean objetivos militares reales;
- los puestos fronterizos tengan valor;
- las ciudades neutrales impulsen la expansiÃ³n;
- las tropas almacenadas participen en la defensa;
- las regiones produzcan frentes distintos;
- la IA tenga nuevos sistemas con los que interactuar;
- el Modo Zombies altere el equilibrio entre civilizaciones;
- las rondas puedan continuar indefinidamente;
- el jugador pueda descubrir un Easter Egg completo durante la partida.

El proyecto combina:

```text
diseÃ±o de mapa
+
scripting
+
experimentaciÃ³n
+
ingenierÃ­a inversa
+
documentaciÃ³n tÃ©cnica
```

para llevar el editor de Imperivm III mucho mÃ¡s allÃ¡ de sus mecÃ¡nicas habituales.

---

# Aviso

Este es un proyecto **no oficial** realizado para **Imperivm III / Imperivm: Great Battles of Rome HD**.

No estÃ¡ afiliado ni respaldado por los desarrolladores o distribuidores originales del juego.

Todo el trabajo de scripting, documentaciÃ³n, diseÃ±o de escenario e investigaciÃ³n contenido en este repositorio corresponde al proyecto **Imperivm III â€” Guerra Total**.


<div align="center">

# Imperivm III â€” Guerra Total

### Un escenario estratÃ©gico a gran escala para Imperivm III / Great Battles of Rome HD

**Guerra territorial Â· Fortalezas dinÃ¡micas Â· Defensa automatizada Â· Recompensas estratÃ©gicas Â· Modo Zombies**

<br>

<img src="secuencias/Modo%20zombie/modo%20zombies.png"
     alt="Imperivm III Guerra Total - Modo Zombies"
     width="900">

</div>

---

## Sobre el proyecto

**Imperivm III â€” Guerra Total** es un proyecto de modificaciÃ³n y diseÃ±o de escenario para **Imperivm III / Imperivm: Great Battles of Rome HD** orientado a ampliar considerablemente la profundidad estratÃ©gica del juego.

El proyecto parte de un mapa diseÃ±ado para enfrentar a las ocho civilizaciones jugables dentro de una red territorial de ciudades, fortalezas, puestos defensivos y corredores naturales.

<div align="center">
  <img src="mapa/Mapa.jpg"
       alt="Mapa de Imperivm III Guerra Total"
       width="900">
</div>

Sobre esa base se han desarrollado sistemas propios mediante **Sequences `.vs`**, aprovechando y ampliando comportamientos existentes del motor:

* fortalezas con guarniciones persistentes;
* defensa automÃ¡tica de posiciones estratÃ©gicas;
* reconquista dinÃ¡mica;
* recompensas por expansiÃ³n;
* zonas territoriales que premian el dominio regional;
* utilizaciÃ³n defensiva de tropas almacenadas;
* un modo Zombies completo basado en oleadas, asedios y conquista de ciudades;
* documentaciÃ³n tÃ©cnica del lenguaje de scripting de Imperivm III;
* investigaciÃ³n del comportamiento interno del motor mediante ingenierÃ­a inversa.

El objetivo no es sustituir las mecÃ¡nicas originales, sino utilizarlas como base para construir una partida mÃ¡s territorial, dinÃ¡mica y prolongada.

---

# El mapa

<div align="center">
  <img src="mapa/MapaNodos.png"
       alt="Mapa de Imperivm III Guerra Total"
       width="900">
</div>


El mapa estÃ¡ estructurado como una red de **18 ciudades principales**:

| Tipo                                   | Cantidad |
| -------------------------------------- | -------: |
| Ciudades ocupadas al inicio            |        9 |
| Ciudades neutrales                     |        9 |
| Total                                  |       18 |
| Civilizaciones / jugadores principales |        8 |

Germania constituye una excepciÃ³n al comenzar con dos posiciones separadas geogrÃ¡ficamente.

## Civilizaciones

| Player | CivilizaciÃ³n     |
| -----: | ---------------- |
|      1 | Roma Imperial    |
|      2 | Cartago          |
|      3 | Iberia           |
|      4 | Galia            |
|      5 | Britania         |
|      6 | Germania         |
|      7 | Roma Republicana |
|      8 | Egipto           |

El mapa no funciona como una arena completamente abierta.

MontaÃ±as, bosques, rÃ­os, ciudades y corredores naturales dividen el territorio en regiones y generan puntos de paso estratÃ©gicos.

Algunas ciudades funcionan como autÃ©nticas **puertas territoriales**:

```text
N1
N3
O6
N4
O7
O9
```

Controlarlas puede abrir o cerrar el acceso entre regiones enteras.

La intenciÃ³n es que la geografÃ­a produzca frentes reconocibles, guerras regionales y expansiones diferentes en cada partida.

Mapa estratÃ©gico de nodos:

[`mapa/Mapa Nodos.png`](mapa/MapaNodos.png)

---

# MecÃ¡nicas principales

El escenario utiliza varias Sequences independientes.

Cada una resuelve una responsabilidad concreta y puede interactuar con las demÃ¡s sin convertir el proyecto en una Ãºnica Sequence monolÃ­tica.

## Sistema de fortalezas

### `Fortresses_Main`

Convierte los Outposts culturales del mapa en **fortalezas defensivas persistentes**.

Gestiona automÃ¡ticamente:

* descubrimiento de fortalezas;
* guarniciones especÃ­ficas segÃºn cultura;
* defensa automÃ¡tica;
* salida y retorno de los defensores;
* regeneraciÃ³n gradual de bajas;
* bloqueo de la captura mientras la posiciÃ³n siga defendida;
* cambio de propietario;
* reconstrucciÃ³n de la guarniciÃ³n tras una conquista;
* reconquistas ilimitadas.

Las guarniciones pertenecen estructuralmente a la fortaleza.

No funcionan como un ejÃ©rcito gratuito para el jugador y no dependen de la alimentaciÃ³n normal.

Una Ãºnica Sequence administra todos los Outposts culturales del escenario.

DocumentaciÃ³n:

[`docs/secuencias/01_Fortresses_Main_Explicacion_Detallada.md`](docs/secuencias/01_Fortresses_Main_Explicacion_Detallada.md)

---

## Recompensa por conquista de ciudades neutrales

### `ForumCaptureReward_Main`

Las ciudades neutrales no son Ãºnicamente posiciones territoriales.

Cuando un jugador conquista por primera vez uno de los Foros neutrales definidos por el escenario, recibe una **recompensa militar asociada a su civilizaciÃ³n**.

El sistema:

* descubre los Townhalls neutrales al comenzar la partida;
* conserva su referencia aunque cambien de propietario;
* detecta su primera conquista;
* identifica al jugador conquistador;
* genera dos bloques de 50 unidades;
* entrega un total de 100 tropas;
* marca permanentemente esa ciudad como recompensada.

A diferencia de las guarniciones de fortalezas, estas unidades son **tropas normales**:

* consumen comida;
* pueden recibir Ã³rdenes;
* pueden ser utilizadas por la IA;
* no se regeneran;
* no quedan controladas posteriormente por la Sequence.

DocumentaciÃ³n:

[`docs/secuencias/02_ForumCaptureReward_Main_Explicacion_Detallada.md`](docs/secuencias/02_ForumCaptureReward_Main_Explicacion_Detallada.md)

---

## Guard Posts

### `GuardPosts_Main`

Los `GGuardPost` utilizan un sistema distinto al de las fortalezas convencionales.

Su defensa nativa se conserva y la Sequence aÃ±ade una segunda capa terrestre.

Cada Guard Post combina:

```text
defensa nativa de sentinelas
+
10 guardianes terrestres
```

Los guardianes:

* dependen de la civilizaciÃ³n del propietario;
* permanecen ligados al puesto;
* atacan automÃ¡ticamente las amenazas cercanas;
* regresan a la posiciÃ³n defensiva;
* se regeneran progresivamente;
* no forman parte del ejÃ©rcito estratÃ©gico normal de la IA.

Mientras sobreviva al menos uno de los guardianes aÃ±adidos, el puesto continÃºa protegido frente a la captura.

DocumentaciÃ³n:

[`docs/secuencias/03_GuardPosts_Main_Explicacion_Detallada.md`](docs/secuencias/03_GuardPosts_Main_Explicacion_Detallada.md)

---

## Recompensas estratÃ©gicas de frontera

### `GuardPostsFrontierReward_Main`

Algunas regiones del mapa estÃ¡n agrupadas en zonas estratÃ©gicas:

```text
RewardZone_01
...
RewardZone_10
```

Cada zona contiene varias posiciones territoriales.

Cuando **todos los objetos de una zona pertenecen al mismo jugador**, ese jugador obtiene una recompensa estratÃ©gica.

La recompensa consiste en:

```text
2 ejÃ©rcitos Ã— 50 unidades
=
100 unidades
```

La composiciÃ³n depende de la civilizaciÃ³n del propietario e incluye unidades de diferentes funciones, como infanterÃ­a, tropas a distancia, caballerÃ­a cuando existe para esa cultura y hÃ©roes.

Una misma zona puede ser recompensada a jugadores diferentes en momentos distintos, pero cada combinaciÃ³n:

```text
zona + jugador
```

sÃ³lo puede cobrarla una vez.

Las tropas aparecen asociadas a la capital del jugador correspondiente mediante:

```text
CapitalForum_P1
...
CapitalForum_P8
```

DocumentaciÃ³n:

[`docs/secuencias/04_GuardPostsFrontierReward_Main_Explicacion_Detallada.md`](docs/secuencias/04_GuardPostsFrontierReward_Main_Explicacion_Detallada.md)

---

## Defensa auxiliar de Outposts

### `OutpostAuxDefense_Main`

Las fortalezas pueden contener tropas normales ademÃ¡s de su guarniciÃ³n estructural.

Esta Sequence permite utilizar esas tropas como **defensa auxiliar temporal**.

Cuando una fortaleza es atacada:

```text
Fortresses_Main
â†’ moviliza la guarniciÃ³n estructural

OutpostAuxDefense_Main
â†’ moviliza las tropas normales almacenadas
```

La Sequence distingue ambos grupos para evitar que dos sistemas intenten controlar las mismas unidades.

Cuando desaparece la amenaza:

1. las tropas auxiliares dejan de perseguir;
2. regresan hacia el Outpost;
3. tras un periodo continuo de paz reciben la orden de volver a entrar;
4. dejan de estar controladas por la Sequence;
5. recuperan su comportamiento normal.

Las tropas auxiliares que mueren **no se regeneran**. Son soldados reales que el propietario decidiÃ³ almacenar previamente.

DocumentaciÃ³n:

[`docs/secuencias/05_OutpostAuxDefense_Main_Explicacion_Detallada.md`](docs/secuencias/05_OutpostAuxDefense_Main_Explicacion_Detallada.md)

---

# Modo Zombies

<div align="center">

<img src="secuencias/Modo%20zombie/modo%20zombies.png" alt="Modo Zombies de Imperivm III Guerra Total" width="850">

</div>

El **Modo Zombies** introduce una amenaza independiente que aparece durante una partida normal y obliga a las civilizaciones a enfrentarse a ejÃ©rcitos controlados por scripting.

Para el jugador es una sola mecÃ¡nica.

Internamente estÃ¡ dividida en tres mÃ³dulos:

```text
ZombieWaves_Main
ZombieTactical_Main
ZombieRewards_Main
```

## DiseÃ±o de las oleadas

La configuraciÃ³n actual estÃ¡ diseÃ±ada alrededor de:

| ParÃ¡metro                    |      Valor |
| ---------------------------- | ---------: |
| Rondas                       |         40 |
| PreparaciÃ³n inicial          | 30 minutos |
| Intervalo entre rondas       |  2 minutos |
| Puntos posibles de apariciÃ³n |          8 |
| Player de la horda           |         12 |
| Rondas 1-32                  |    1 horda |
| Rondas 33-40                 |   2 hordas |
| MÃ¡ximo de hordas internas    |         48 |

Las composiciones aumentan progresivamente de dificultad y pueden mezclar unidades procedentes de distintas civilizaciones.

Las unidades de la horda pertenecen siempre al **Player 12**.

## GeneraciÃ³n

### `ZombieWaves_Main_40R_48H_FINAL_UI`

Se encarga de:

* temporizaciÃ³n;
* nÃºmero de ronda;
* avisos previos;
* selecciÃ³n aleatoria del punto de apariciÃ³n;
* composiciÃ³n de cada horda;
* nivel de las tropas;
* creaciÃ³n mediante `Place()`;
* creaciÃ³n de los Groups dinÃ¡micos `HW_Hx`;
* inicializaciÃ³n del estado de cada horda.

Los puntos de apariciÃ³n se definen mediante:

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

DocumentaciÃ³n:

[`docs/secuencias/08_ZombieWaves_Main_40R_48H_FINAL_UI_Explicacion_Detallada.md`](docs/secuencias/08_ZombieWaves_Main_40R_48H_FINAL_UI_Explicacion_Detallada.md)

---

## Control tÃ¡ctico

### `ZombieTactical_Main_v10_5_WALL_STUCK_GATE`

Es el controlador tÃ¡ctico de las hordas.

Su objetivo es que una horda no se limite a recibir una orden de movimiento, sino que pueda mantener un objetivo estratÃ©gico e intentar alcanzar una ciudad fortificada.

Gestiona:

* selecciÃ³n del Foro objetivo;
* marcha hacia la ciudad;
* mantenimiento del objetivo;
* detecciÃ³n de bloqueos;
* localizaciÃ³n de Gates;
* inicio del asedio;
* seguimiento de mÃ¡quinas de asedio;
* detecciÃ³n de brecha;
* avance tras destruir la puerta;
* bÃºsqueda de una posible segunda Gate;
* presiÃ³n sobre la loyalty;
* captura del Settlement;
* retargeting;
* detecciÃ³n de destrucciÃ³n de la horda;
* preparaciÃ³n del evento de recompensa.

DocumentaciÃ³n:

[`docs/secuencias/07_ZombieTactical_Main_v10_5_Explicacion_Detallada.md`](docs/secuencias/07_ZombieTactical_Main_v10_5_Explicacion_Detallada.md)

---

## Recompensas por detener una horda

### `ZombieRewards_Main_48H_40R`

Cuando una horda es destruida, el sistema puede entregar tropas al jugador que haya conseguido detenerla.

La Sequence de recompensas no controla el combate.

Recibe del controlador tÃ¡ctico:

```text
jugador
ronda
posiciÃ³n del Foro
evento pendiente
```

y transforma esos datos en una recompensa militar.

Las rondas cuentan con composiciones propias y determinadas rondas incluyen recompensas especiales.

DocumentaciÃ³n:

[`docs/secuencias/06_ZombieRewards_Main_48H_40R_Explicacion_Detallada.md`](docs/secuencias/06_ZombieRewards_Main_48H_40R_Explicacion_Detallada.md)

---

## Arquitectura interna del modo Zombies

```mermaid
flowchart TD
    A[ZombieWaves_Main] --> B[Crear horda]
    B --> C[HW_Hx]
    C --> D[ZombieTactical_Main]

    D --> E[Seleccionar ciudad]
    E --> F[Marcha]
    F --> G[Asedio]
    G --> H[Brecha]
    H --> I[Captura]

    D --> J{Horda destruida}
    J --> K[ZR_PENDINGx]
    K --> L[ZombieRewards_Main]
    L --> M[Recompensa militar]
```

Los tres mÃ³dulos utilizan estado compartido, pero mantienen responsabilidades separadas.

---

# Arquitectura general

El escenario puede resumirse conceptualmente asÃ­:

```mermaid
flowchart LR
    MAPA[Mapa estratÃ©gico]

    MAPA --> FORT[Fortalezas]
    MAPA --> GP[Guard Posts]
    MAPA --> FORUM[Ciudades neutrales]
    MAPA --> ZONE[Zonas territoriales]
    MAPA --> ZOMBIE[Modo Zombies]

    FORT --> FMAIN[Fortresses_Main]
    FORT --> AUX[OutpostAuxDefense_Main]

    GP --> GPMAIN[GuardPosts_Main]

    FORUM --> FCR[ForumCaptureReward_Main]

    ZONE --> GFR[GuardPostsFrontierReward_Main]

    ZOMBIE --> ZW[ZombieWaves]
    ZOMBIE --> ZT[ZombieTactical]
    ZOMBIE --> ZR[ZombieRewards]
```

---

# Estructura del repositorio

```text
Imperivm-III-Guerra-Total/
â”‚
â”œâ”€â”€ README.md
â”œâ”€â”€ .gitignore
â”‚
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ manual/
â”‚   â”‚   â””â”€â”€ Imperivm_III_Manual_Ingenieria_Inversa.md
â”‚   â”‚
â”‚   â””â”€â”€ secuencias/
â”‚       â”œâ”€â”€ 01_Fortresses_Main_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 02_ForumCaptureReward_Main_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 03_GuardPosts_Main_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 04_GuardPostsFrontierReward_Main_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 05_OutpostAuxDefense_Main_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 06_ZombieRewards_Main_48H_40R_Explicacion_Detallada.md
â”‚       â”œâ”€â”€ 07_ZombieTactical_Main_v10_5_Explicacion_Detallada.md
â”‚       â””â”€â”€ 08_ZombieWaves_Main_40R_48H_FINAL_UI_Explicacion_Detallada.md
â”‚
â”œâ”€â”€ mapa/
â”‚   â”œâ”€â”€ Mapa Nodos.png
â”‚   â”œâ”€â”€ Mapa desde Editor.jpg
â”‚   â””â”€â”€ Mapa.jpg
â”‚
â””â”€â”€ secuencias/
    â”œâ”€â”€ Fortresses_Main.vs
    â”œâ”€â”€ ForumCaptureReward_Main.vs
    â”œâ”€â”€ GuardPostsFrontierReward_Main.vs
    â”œâ”€â”€ GuardPosts_Main.vs
    â”œâ”€â”€ OutpostAuxDefense_Main.vs
    â”‚
    â””â”€â”€ Modo zombie/
        â”œâ”€â”€ modo zombies.png
        â”œâ”€â”€ ZombieRewards_Main_48H_40R.vs
        â”œâ”€â”€ ZombieTactical_Main_v10_5_WALL_STUCK_GATE.vs
        â””â”€â”€ ZombieWaves_Main_40R_48H_FINAL_UI.vs
```

---

# DocumentaciÃ³n

## Manual tÃ©cnico

El manual central del proyecto documenta el lenguaje de scripting utilizado por el juego y los resultados de la ingenierÃ­a inversa:

[`docs/manual/Imperivm_III_Manual_Ingenieria_Inversa.md`](docs/manual/Imperivm_III_Manual_Ingenieria_Inversa.md)

Incluye, entre otros temas:

* CKS/VS y Sequences;
* Groups;
* `Obj`, `Unit`, `Building` y `Settlement`;
* Queries y `ObjList`;
* `Place()`;
* `SetPlayer()`;
* `SetFeeding()`;
* `SetNoAIFlag()`;
* `ForceAddUnit()`;
* Ã³rdenes de unidades;
* Outposts;
* Guard Posts;
* loyalty y captura;
* creaciÃ³n dinÃ¡mica;
* IA;
* Townhalls;
* arquitectura de fortalezas;
* patrones de escenarios oficiales;
* seguimiento de hordas;
* anÃ¡lisis del motor.

## DocumentaciÃ³n de Sequences

Cada Sequence de producciÃ³n dispone de un documento independiente donde se explica:

* quÃ© hace;
* quÃ© objetos controla;
* quÃ© hay que preparar en el editor;
* quÃ© Groups necesita;
* quÃ© estado persiste;
* cÃ³mo funciona internamente;
* quÃ© dependencias tiene;
* quÃ© limitaciones presenta.

Consulta:

[Abrir documentaciÃ³n de Sequences](docs/secuencias/)

## InvestigaciÃ³n e ingenierÃ­a inversa

La investigaciÃ³n tÃ©cnica que sirve de base al proyecto se ha consolidado en el manual principal:

[`docs/manual/Imperivm_III_Manual_Ingenieria_Inversa.md`](docs/manual/Imperivm_III_Manual_Ingenieria_Inversa.md)

El manual reÃºne los descubrimientos obtenidos mediante anÃ¡lisis de scripts nativos, escenarios oficiales, pruebas directas en el editor e ingenierÃ­a inversa del motor.

---

# InstalaciÃ³n y uso

Este proyecto utiliza el editor de escenarios de Imperivm III y Sequences `.vs`.

La configuraciÃ³n exacta depende de cada sistema.

## Sequences principales

En:

```text
Scenario
â””â”€â”€ Map
    â””â”€â”€ Sequences
```

deben existir las Sequences que se quieran utilizar.

Para los controladores principales:

```text
Autorun allowed = activado
```

DespuÃ©s:

1. abrir `Source`;
2. introducir el contenido del `.vs` correspondiente;
3. compilar;
4. corregir cualquier error indicado por el editor;
5. guardar el escenario;
6. probar el comportamiento en partida.

La documentaciÃ³n individual de cada Sequence contiene los requisitos exactos.

---

## Groups manuales importantes

No todos los sistemas necesitan Groups manuales.

Los principales utilizados por la configuraciÃ³n actual son:

### Capitales

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

Cada uno debe apuntar al Foro capital correspondiente cuando la mecÃ¡nica que lo utiliza estÃ© activa.

### Modo Zombies

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

### Recompensas territoriales

```text
RewardZone_01
RewardZone_02
...
RewardZone_10
```

Los Groups dinÃ¡micos como:

```text
__FRT_X_Y
__FRT_AUX_X_Y
__GP_X_Y
HW_H1
...
HW_H48
```

son gestionados por las Sequences y **no deben poblarse manualmente**.

---

# Estado del proyecto

El proyecto continÃºa en desarrollo activo.

| Sistema                      | Estado                     |
| ---------------------------- | -------------------------- |
| Mapa estratÃ©gico             | DiseÃ±ado y documentado     |
| Sistema de fortalezas        | Implementado               |
| Recompensa por Foro neutral  | Implementada               |
| Guard Posts                  | Implementado               |
| Recompensas de frontera      | Implementadas              |
| Defensa auxiliar de Outposts | Implementada               |
| GeneraciÃ³n de hordas Zombies | Funcional                  |
| Recompensas Zombies          | Implementadas              |
| IA tÃ¡ctica Zombies           | En desarrollo y validaciÃ³n |
| Asedio automÃ¡tico Zombies    | En desarrollo              |
| NavegaciÃ³n tras brecha       | En desarrollo              |
| DocumentaciÃ³n de scripting   | Activa y en expansiÃ³n      |

---

# Limitaciones conocidas

Imperivm III no fue diseÃ±ado originalmente para algunas de las mecÃ¡nicas implementadas aquÃ­.

Eso obliga a trabajar alrededor de ciertas limitaciones del motor.

## IA y navegaciÃ³n

La IA puede presentar dificultades especialmente alrededor de:

* murallas;
* Gates;
* brechas;
* entradas estrechas;
* ciudades amuralladas;
* transiciÃ³n entre movimiento y asedio.

El controlador tÃ¡ctico de Zombies intenta compensar estas situaciones mediante detecciÃ³n de obstÃ¡culos, asedio, reintentos y retargeting.

## Modo Zombies: slots de las rondas finales

La generaciÃ³n actual estÃ¡ preparada para un mÃ¡ximo de:

```text
48 hordas
```

porque las rondas 33-40 generan dos hordas simultÃ¡neas.

La versiÃ³n actual documentada de:

```text
ZombieTactical_Main_v10_5_WALL_STUCK_GATE
```

controla todavÃ­a:

```text
HW_H1 ... HW_H32
```

Por tanto el soporte tÃ¡ctico de:

```text
HW_H33 ... HW_H48
```

debe alinearse antes de considerar completamente cerradas las rondas finales.

## Recompensas territoriales

Algunas Sequences calculan coordenadas para representar dos formaciones exteriores, pero su implementaciÃ³n actual introduce las tropas en el `Settlement` correspondiente.

Este comportamiento estÃ¡ documentado y puede revisarse posteriormente sin cambiar el principio general de la mecÃ¡nica.

## NavegaciÃ³n marÃ­tima

El motor dispone de agua, barcos y navegaciÃ³n, pero la utilizaciÃ³n estratÃ©gica de estas rutas por parte de la IA es limitada en comparaciÃ³n con el movimiento terrestre.

Por esta razÃ³n el diseÃ±o estratÃ©gico principal del escenario se apoya en corredores terrestres.

---

# FilosofÃ­a de desarrollo

Una de las reglas fundamentales del proyecto es no asumir que Imperivm III funciona como C++ estÃ¡ndar ni inventar APIs que el motor no posea.

La prioridad de evidencia utilizada es:

```text
prueba real en partida
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

Los sistemas del proyecto se construyen, siempre que es posible, reutilizando patrones que existen realmente dentro del juego.

Esto ha permitido confirmar y utilizar mecanismos como:

```text
Place()
SetPlayer()
SetFeeding()
SetNoAIFlag()
ForceAddUnit()
ObjsInRange()
EnemyObjs()
Group()
AddToGroup()
EnvReadInt()
EnvWriteInt()
SetCommand()
RunSequence()
SpawnGroupInHolder()
```

La documentaciÃ³n distingue expresamente entre comportamiento confirmado, evidencia parcial e inferencia.

---

# Objetivo

La intenciÃ³n final de **Imperivm III â€” Guerra Total** es convertir una partida de Imperivm III en una guerra territorial de larga duraciÃ³n en la que:

* la geografÃ­a importe;
* conquistar una posiciÃ³n tenga consecuencias;
* las fortalezas sean autÃ©nticos objetivos militares;
* los puestos fronterizos tengan valor estratÃ©gico;
* las ciudades neutrales impulsen la expansiÃ³n;
* las tropas almacenadas participen en la defensa;
* diferentes regiones produzcan diferentes frentes;
* la IA tenga nuevos sistemas con los que interactuar;
* y una amenaza externa pueda alterar por completo una guerra entre civilizaciones.

El proyecto combina diseÃ±o de mapa, scripting, experimentaciÃ³n e ingenierÃ­a inversa para llevar el editor de Imperivm III mÃ¡s allÃ¡ de sus mecÃ¡nicas habituales.

---

# Aviso

Este es un proyecto **no oficial** realizado para **Imperivm III / Imperivm: Great Battles of Rome HD**.

No estÃ¡ afiliado ni respaldado por los desarrolladores o distribuidores originales del juego.

Todo el trabajo de scripting, documentaciÃ³n, diseÃ±o de escenario e investigaciÃ³n contenido en este repositorio corresponde al proyecto **Imperivm III â€” Guerra Total**.

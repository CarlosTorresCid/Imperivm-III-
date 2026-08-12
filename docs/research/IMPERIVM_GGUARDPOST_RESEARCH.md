# Investigación exhaustiva: `GGuardPost` (Imperivm III / GBR HD)

Fecha: 2026-08-11
Método: solo lectura. Ningún archivo original modificado. Extracción heurística de
`Packs\data.pak` (formato "HMMSYS PackFile", códec de compresión desconocido — ver
`imperivm_pak_tool.py`) mediante bloques de texto ASCII contiguo, más grep/python
directo sobre los 48 `.BFHP` de `Scenarios\`, `Adventures\`, `Conquests\` y
`ConquestMaps\` (formato "HPFS", mayormente texto plano sin comprimir).

Escala de certeza usada (igual que en la investigación previa del usuario):

- **CONFIRMADO** = evidencia directa en código/archivo real, citada literalmente.
- **INDICIO FUERTE** = varias evidencias apuntan a ello, sin cita literal del mecanismo exacto.
- **INFERIDO** = combinación lógica de piezas confirmadas, no verificado directamente.
- **DESCONOCIDO** = no hay evidencia suficiente.

Este documento complementa (no sustituye) `IMPERIVM_FORTRESS_SYSTEM_RESEARCH.md`,
`IMPERIVM_FORTRESS_SYSTEM_RESEARCH_PHASE3.md` e `IMPERIVM_SCRIPTING_RESEARCH.md`.
Donde esta investigación corrige o amplía una hipótesis de esos documentos, se dice
explícitamente.

---

## A. Resumen ejecutivo

**Hallazgo central (CONFIRMADO):** `GGuardPost` **sí** es, a nivel de motor, un
`Outpost` real (`cpp_class="CVXOutpost"`, `parent="Outpost"` — exactamente la misma
base que `GOutpost`, `TOutpost`, `BOutpost`, etc.). Tu sistema universal de Outposts
por Sequence, si detecta objetos por `IsHeirOf("Outpost")`, **debería** reconocerlo
igual que a los demás. Lo que lo hace comportarse "distinto" no es la jerarquía de
clases sino **dos overrides de propiedades + un comportamiento (`<behavior>`) propio
que sustituye por completo al de los Outposts normales**:

1. `max_units="0"` → por eso no puedes meter tropas dentro (el Outpost base tiene
   `max_units="10000"`).
2. Dos scripts de comportamiento nativo (`settlement_behavior_horses.vs` +
   **`GGuardPost_Sentries.vs`**) en lugar de los que usa el `Outpost` base
   (`outpost_behavior_guard.vs`, `outpost_behavior.vs`) o los que usa `GOutpost`
   (sistema `defenders_max_N`/`defender_cls_N`).

**El script `GGuardPost_Sentries.vs` se recuperó casi íntegro en texto plano** desde
`Packs\data.pak` (offset ~572889–573700 y siguientes, bloque legible
48358–1815582). Es un script **totalmente distinto** del sistema genérico de
"sentries" de muro/torre (`.GetSentryClassName()` / `.settlement().AddMaxSentries()`
/ `.GetNumSentrySlots()`) documentado en `IMPERIVM_FORTRESS_SYSTEM_RESEARCH.md`. Esto
**corrige** la hipótesis "INDICIO FUERTE" de ese documento (línea 399): no es el
mismo sistema, es un tercer sistema, propio y hardcodeado, de **12 slots fijos**.

En el juego coexisten **tres sistemas defensivos distintos** para edificios, y
`GGuardPost` usa el tercero:

| Sistema | Quién lo usa | Mecanismo | Configurable |
|---|---|---|---|
| 1. "Doble pool" `defenders_max_N` | `GOutpost` (y por herencia, `TOutpost/BOutpost/IOutpost/COutpost/ROutpost/EOutpost` si no lo overridean) | Propiedades `defender_cls_1`, `defenders_max_1`, `defenders_out_1`, `start_level_1`, `end_level_1` leídas por el comportamiento heredado de `Outpost` | Sí, por propiedades de clase |
| 2. "Sentries" genérico de muro/torre/puerta | `Gate` (`BGate0..7`, etc., propiedad `sentry_class_name`), probablemente `Tower` | `.settlement().AddMaxSentries(n)`, `.GetSentryClassName()`, `.GetNumSentrySlots()`, `.settlement().GetSentry()/DelSentry()` | Sí — **CONFIRMADO invocable desde Sequence** vía `GetSettlement("nombre").AddMaxSentries(n)` |
| 3. Script propio de `GGuardPost` | Solo `GGuardPost` | 12 variables `s0..s11` hardcodeadas, posiciones relativas fijas, `Place(sRace+"GuardPostSentry", ...)` | **No** — el script nunca lee `AddMaxSentries`/`GetSentryClassName`/`GetNumSentrySlots` |

`GGuardPost` **sí se puede capturar** por el mecanismo genérico de Outpost
(`can_be_captured="1"`, `capture_health_percent="50"`, heredado sin override) — no
hay nada exótico en la captura en sí. Lo interesante es lo que pasa **después**: el
propio script de sentries detecta el cambio de dueño (`.player()!=pNumber`), mata a
los centinelas viejos explícitamente, y **re-arma el puesto con arqueros de la
**raza del nuevo dueño*** (no de la raza "Gaul" fija de la clase) casi de inmediato.

En los 48 `.BFHP` inspeccionados (mapas oficiales, comunitarios y del usuario),
`GGuardPost` **solo aparece en tus propios mapas** (`Carlos_GerraTotal2/3.BFHP`,
`Carlos_GuerraTotalCopia.BFHP`), 3 unidades por mapa, siempre `player="15"`
(neutral), sin nombre de asentamiento asignado y sin ninguna `<sequence>` que los
referencie todavía.

---

## B. Hallazgos confirmados (resumen rápido)

- `GGuardPost` hereda de `Outpost` (`cpp_class="CVXOutpost"`) — **CONFIRMADO**.
- Tiene `Settlement` (propiedades `settlement_gold`, `settlement_maxgold=10000`,
  `settlement_maxfood=0`) — **CONFIRMADO**.
- Tiene `loyalty` (heredado del `value0` de `Outpost`: `.AsBuilding.settlement.loyalty`) — **CONFIRMADO** (por herencia, sin override).
- Tiene `range="1000"` propio — **CONFIRMADO**.
- **No** tiene slots de sentinela configurables por `AddMaxSentries`/`GetSentryClassName` — **CONFIRMADO** (su script no las usa; esas funciones pertenecen al sistema de `Gate`).
- Tiene exactamente **12 posiciones fijas de arquero**, hardcodeadas en el script — **CONFIRMADO**.
- Los arqueros nativos son de la clase `<raza>GuardPostSentry` (p.ej. `GGuardPostSentry`, `BGuardPostSentry`, `TGuardPostSentry`...), que hereda de `<raza>Sentry` — **CONFIRMADO**.
- La raza de los arqueros depende del **jugador dueño**, no de la propiedad `race="Gaul"` de la clase `GGuardPost` — **CONFIRMADO**.
- Respawn de un centinela muerto: prácticamente inmediato (siguiente iteración del bucle, `Sleep(1500)`) — **CONFIRMADO**.
- Subida de nivel automática de los centinelas con el tiempo, hasta nivel 36, reseteada a 1 al cambiar de dueño — **CONFIRMADO**.
- Al cambiar de dueño, el propio script **mata** a todos los centinelas existentes (`Damage(maxhealth)`) — **CONFIRMADO**.
- `AddMaxSentries()` es invocable desde una Sequence real (`GetSettlement("...").AddMaxSentries(n)`) — **CONFIRMADO**, pero en una `Adventure`, sobre una muralla (`Gate`/`Tower`), **no sobre un `GGuardPost`**.

---

## C. Código nativo recuperado

### C.1 — Definición de clase `GGuardPost`

Fuente: `Packs\data.pak`, bloque de texto legible que ocupa los bytes
48358–1815582 (heurístico, ver limitaciones de `imperivm_pak_tool.py`); el
fragmento de la clase empieza en el **byte offset 572889** del archivo (cadena
`<class id="GGuardPost"` localizada con búsqueda binaria directa, offset
confirmado por `grep -ob` sobre el `.pak` real, no solo sobre el volcado).

```xml
<class id="GGuardPost" cpp_class="CVXOutpost" parent="Outpost"
  entity        = "Buildings/GGuardPost/GGuardPost_AS.ent.xml"
  entity_winter = "Buildings/GGuardPost/GGuardPost_W.ent.xml"
>
	<properties race="Gaul"/>
	<properties maxhealth="10000"/>
	<properties display_name="Guard Post"/>
	<properties icon="gameres/icons/GGuardPost.bmp"/>
	<properties edittree_pos="Structures/Outposts/Guard Post"/>
	<properties help="/contents/buildings/GGuardPost"/>
	<properties auto_repair="no"/>

	<properties
		sight="1500"
		range="1000"
		settlement_food="0"
		settlement_gold="0"
		settlement_maxfood="0"
		settlement_maxgold="10000"
		max_units="0"
	/>
	
	<behavior script="data/subai/settlement_behavior_horses.vs"/>
	<behavior script="data/subai/GGuardPost_Sentries.vs"/>
	<method sig="repair" vs="data/subai/building_repair.vs"/>

	<value3
		icon=""
		script=""
		help=""/>
		
	<properties interface="thumb,building"/>
	
	<defaultcmd target="">
		<cmd name="unitsout"/>
	</defaultcmd>

</class>
<class id="GGuardPostSentry" cpp_class="CVXUnit" parent="GSentry" entity="Units/GArcher/GGuardPostSentry.ent.xml">

</class>
```

Nota: la propiedad `race="Gaul"` es solo metadato de UI/edición (categoría en el
editor: "Structures/Outposts/Guard Post" bajo la sección gala) — **no** determina
la raza de los arqueros generados en juego (ver C.2).

### C.2 — Clase base `Outpost` (para comparar qué override hace `GGuardPost`)

Byte offset **662829** de `Packs\data.pak`.

```xml
<class id="Outpost" cpp_class="CVXTownHall" parent="Building" entity="">

	<properties maxhealth="5000" sight="1400"/>
	<properties display_name="Outpost"/>
	<properties radius="345" selection_radius="350"/>
	<properties capture_health_percent="50"/>

	<properties
		is_central_building="1"
		can_be_captured="1"
		can_be_attacked="1"
		produces_gold="0"
		produces_food="0"
		is_single_building="1"
		settlement_maxfood="10000"
		settlement_maxgold="10000"
		population="0"
		efficiency="0"
		max_population="0"
		max_units="10000"
	/>
	...
	<behavior script="data/subai/outpost_behavior_guard.vs"/>
	<behavior script="data/subai/outpost_behavior.vs"/>
	...
	<value0
		icon="gameres/infobar/common/Loyality.bmp"
		script="return .AsBuilding.settlement.loyalty;"
		flags="-1"
		help="/contents/capturing"
		rollover="Loyalty"/>
	...
</class>
```

Comparando ambos bloques: `GGuardPost` **no** overridea `can_be_captured` ni
`capture_health_percent` (hereda `1` / `50` del padre), pero sí overridea
`max_units` (`10000` → `0`) y sustituye por completo la lista de `<behavior>`.

### C.3 — Clase `GOutpost` (para contraste con el sistema "doble pool")

```xml
<class id="GOutpost" cpp_class="CVXOutpost" parent="Outpost"
	entity="Buildings/GOutpost/GOutpost_as.ent.XML"
	entity_winter="Buildings/GOutpost/GOutpost_w.ent.XML"
>
	<properties race="Gaul"/>
	<properties maxhealth="10000"/>
	...
	<properties
		range = "1000"
		settlement_food="500"
		settlement_gold="1000"
	    defender_cls_1  = "GTridentWarrior"	
	    defenders_max_1 = "4"
	    defenders_out_1 = "2"
	    start_level_1   = "12"
	    end_level_1     = "24"   
	/>
	<method sig="goutpost_sellfood" vs="data/subai/goutpost_sellfood.vs"/>
    <method sig="goutpost_sellgold" vs="data/subai/goutpost_sellgold.vs"/>
</class>
```

`GOutpost` **no declara `<behavior>` propio** → hereda íntegro el de `Outpost`
(`outpost_behavior_guard.vs` + `outpost_behavior.vs`), que es presumiblemente el que
lee `defender_cls_N`/`defenders_max_N`/`defenders_out_N`/`start_level_N` (no se ha
recuperado el cuerpo de `outpost_behavior_guard.vs` en esta pasada — **DESCONOCIDO**
el detalle exacto de ese script, pero **INDICIO FUERTE** de que es el mecanismo,
por la correlación 1:1 entre esas propiedades y el comportamiento observado en
juego de `GOutpost`/`TOutpost`/etc.).

**Conclusión (INFERIDO, no verificado directamente en el motor):** cuando una
clase hija declara sus propios `<behavior>`, estos **sustituyen** — no se suman a
— los del padre. La evidencia: `GGuardPost` declara 2 comportamientos totalmente
distintos a los 2 de `Outpost`, y su propio script gestiona salud/regeneración por
sí mismo (cosa que en `GOutpost` presumiblemente hace `outpost_behavior.vs`
heredado). Si ambos corrieran a la vez habría lógica duplicada/conflictiva. No se
ha podido confirmar esto leyendo el motor C++ (fuera de alcance), pero es
consistente con todo lo observado.

### C.4 — Script `GGuardPost_Sentries.vs` (recuperado en texto plano, offset ~572889 en adelante del bloque grande)

Reconstrucción literal (variables y estructura tal cual aparecen en el `.pak`;
comentarios `//` y `/* */` son del propio archivo, no añadidos):

```c
// void, Obj This  (declaración implícita al inicio del behavior)
Building this;
int i,pNumber,pRace,sentriesLevel,timer;
bool enemiesAround;
str sRace,s0Act,s1Act,s2Act,s3Act,s4Act,s5Act,s6Act,s7Act,s8Act,s9Act,s10Act,s11Act;
ObjList postSentries,e0,e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11;
IntArray posX,posY,races;
Unit s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11;
Unit t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11;

this = This.AsBuilding();
pNumber=.player;
enemiesAround=false;

posX[0]=-247;posX[1]=-281;posX[2]=-247;posX[3]=19;
posX[4]=-32;posX[5]=65;posX[6]=0;posX[7]=-50;
posX[8]=45;posX[9]=260;posX[10]=260;posX[11]=300;
posY[0]=-80;posY[1]=-40;posY[2]=-10;posY[3]=-295;
posY[4]=-276;posY[5]=-276;posY[6]=215;posY[7]=185;
posY[8]=185;posY[9]=-20;posY[10]=-90;posY[11]=-70;

if(.settlement.IsIndependent()){
	Sleep(600);
	return;
}
else{
	if(EnvReadInt(this.player,"Race")==0){
		if(GetPlayerRace(pNumber)>0){ pRace=GetPlayerRace(pNumber); }
		else{ pRace=0; }
	}
	else{ pRace=EnvReadInt(this.player,"Race"); }
	sRace = GetRaceStrPref(pRace);
}

while(.IsValid()){
	if(postSentries){
		if(postSentries.count>0){ postSentries.ClearDead(); }
	}
	if(!.IsBroken()){
		if(.health<=.maxhealth){
			Unit dummy;
			if(.health<.maxhealth){ .SetHealth(.health+3); }
			//Update the graphics
			dummy=PlaceInHolder("Camel",.name,.player).AsUnit();
			Sleep(100);
			dummy.Erase();
		}
		if(.health>.maxhealth){ .SetHealth(.maxhealth); }
		if(EnvReadInt(this,"sentriesLevel")<36){
			if(timer<90000/1500){ timer=timer+1; }
			else{
				timer=0;
				EnvWriteInt(this,"sentriesLevel",EnvReadInt(this,"sentriesLevel")+1);
			}
		}
		if(!s0.IsValid()){
			s0Act="";
			s0=Place(sRace+"GuardPostSentry",.pos()+Point(posX[0],posY[0]),pNumber);
			postSentries.Add(s0);
		}
		// ... (idéntico patrón repetido para s1..s11)

		/*----SENTINEL 0----*/
		if(s0.IsValid()){
			t0 = s0.BestTargetInRange(s0.pos(), s0.range());
			if(t0.IsAlive() && s0.IsValidTarget(t0) && s0.InRange(t0) && s0.command!="attack"){
				s0.SetCommand("attack", t0);
				s0Act=="Return";
			}
			else{
				// máquina de estados de "mirar hacia fuera / volver a posición" (s0Act)
				...
			}
		}
		// ... (idéntico patrón, con offsets de Face()/move distintos, para s1..s11)
	}

	//Destroy all sentinels if building is broken or isn't of the same player
	if(.IsBroken() || .player()!=pNumber){
		postSentries.ClearDead();
		for(i=0;i<postSentries.count;i=i+1){
			postSentries[i].Damage(postSentries[i].AsUnit().maxhealth);
			Sleep(10);
		}
		EnvWriteInt(this,"sentriesLevel",1);
		pNumber=.player;
		s0Act="";s1Act="";s2Act="";s3Act="";s4Act="";s5Act="";
		s6Act="";s7Act="";s8Act="";s9Act="";s10Act="";s11Act="";
		if(.settlement.IsIndependent()){
			Sleep(600);
			return;
		}
		else{
			if(EnvReadInt(this.player,"Race")==0){
				if(GetPlayerRace(pNumber)>0){ pRace=GetPlayerRace(pNumber); }
				else{ pRace=0; }
			}
			else{ pRace=EnvReadInt(this.player,"Race"); }
			sRace = GetRaceStrPref(pRace);
		}
	}
	if(!.IsBroken() && .player()==pNumber){
		if(postSentries){
			if(postSentries.count>0){
				postSentries.ClearDead();
				for(i=0;i<postSentries.count;i=i+1){
					if(EnvReadInt(this,"sentriesLevel")>0){
						postSentries[i].AsUnit().SetLevel(EnvReadInt(this,"sentriesLevel"));
					}
					else{
						postSentries[i].AsUnit().SetLevel(1);
					}
					Sleep(10);
				}
			}
		}
	}
	if(Intersect(Substract(VisibleObjsInSight(this,"Unit"),VisibleObjsInSight(this,"Peaceful")),EnemyObjs(.player,"Military")).count>0){
		if(!enemiesAround){
			UserNotification("guard post revealing enemies", "", .pos, .player);
			enemiesAround=true;
		}
	}
	else{
		enemiesAround=false;
	}
	Sleep(1500);
}
```

(Se ha resumido el bloque repetitivo de los 12 centinelas a modo de patrón; en el
`.pak` real están escritos 12 veces con offsets y direcciones de `Face()`
distintos por posición — es el patrón "reloj" habitual de las 12 posiciones
alrededor del edificio.)

### C.5 — Sistema genérico de `Gate`/muro (contraste, NO es de `GGuardPost`)

Byte offset del bloque en el `.pak`: dentro del mismo blob de texto grande, cerca
de la línea 71850 del volcado de trabajo (no tiene ruta interna fiable, el nombre
de archivo real de este script no se pudo recuperar con certeza — probablemente
algo como `data/subai/gate_sentries.vs`, **DESCONOCIDO** el nombre exacto).

```c
Building this;
str sentry_class_name;
...
if (GetConst("NoSentries") != 0) { while (1) Sleep(100000); }
...
this = This.AsBuilding();
sentry_class_name = .GetSentryClassName();
...
while (!.settlement().IsValid()) Sleep(1000);
.settlement().AddMaxSentries(4);
...
while (.settlement().GetSentry()) {
	...
	new_sentry = Place(sentry_class_name, .pos + .GetPoint(2, i), .player);
	new_sentry.AsUnit().SetLevel(level);
	...
	new_sentry.SetCommand("goto", ...);
	new_sentry.AddCommand(false, "guard", This);
}
```

Y la propiedad `sentry_class_name` está declarada en las clases `Gate` (p.ej.
`BGate0..BGate7`, `wall_set="British walls"`, `sentry_class_name="BSentry1"`), no
en `GGuardPost`.

### C.6 — Uso real desde una Sequence (`.BFHP` real, no motor)

Fuente: `Scenarios\El_hijo_del_Ankou.BFHP` / `Adventures\El_hijo_del_Ankou.BFHP` /
`Adventures\Il figlio di Ankou.BFHP` (misma aventura, 2 idiomas + copia), bloque de
Sequence con comentario italiano `/* Sequenza che gestisce la lealtà e la
possibilità di poter conquistare o meno una struttura */`:

```c
GetSettlement("S_TeessideWalls").AddMaxSentries(-300);
GetSettlement("S_TeessideWalls").SetLoyalty(100);
GetSettlement("S_TeessideWalls").AllowCapture(false);

GetSettlement("S_Port1").SetLoyalty(100);
GetSettlement("S_Port1").AllowCapture(false);

GetSettlement("S_Village1").SetLoyalty(100);
GetSettlement("S_Village1").AllowCapture(false);
...
GetSettlement("S_TeessideWalls").SetPlayer(BRITAIN_ENEMIES);
GetSettlement("S_TeessideWalls").AddMaxSentries(300);
GetSettlement("S_TeessideWalls").AddSentries(180);
```

`S_TeessideWalls` es un asentamiento compuesto por `BWallsNE`, `BTower`,
`BWallsN`, etc. (murallas británicas) — **no** un `GGuardPost`. Esto confirma que
`AddMaxSentries`/`AddSentries`/`AllowCapture` son reales y usables desde Sequence,
pero **sobre asentamientos de muro/torre**, el mismo sistema de C.5, no el de
`GGuardPost`.

---

## D. Funcionamiento de los sentinelas (respuestas punto por punto)

| Pregunta | Respuesta | Certeza |
|---|---|---|
| ¿Qué clase de unidad aparece sobre la "muralla"? | `<raza><cargo>` no aplica realmente — es literalmente el edificio `GGuardPost`, no un muro; el arquero es `<PrefijoRaza>GuardPostSentry` (p.ej. `GGuardPostSentry`, hereda de `<Prefijo>Sentry`, entidad basada en el arquero de esa raza, p.ej. `Units/GArcher/GGuardPostSentry.ent.xml`) | CONFIRMADO |
| ¿Cuántos sentinelas puede tener? | Exactamente 12 (`s0`..`s11`), fijo en el script | CONFIRMADO |
| ¿El número es fijo o configurable? | Fijo en el script nativo. No lee `AddMaxSentries`/`GetNumSentrySlots` en ningún punto | CONFIRMADO (fijo) |
| ¿Regeneran al morir? | Sí, casi inmediatamente (siguiente iteración del `while`, ritmo de `Sleep(1500)`) | CONFIRMADO |
| ¿Cuánto tardan en regenerar? | ≤1.5 s de media (el bucle entero tarda 1500ms + pequeños `Sleep(10)`/`Sleep(100)` internos) | CONFIRMADO |
| ¿De quién son? | Del jugador dueño del `GGuardPost` en el momento de `Place()` (`pNumber = .player`) | CONFIRMADO |
| ¿Cambian de propietario al cambiar el edificio? | No cambian de dueño — **se destruyen** (`Damage(maxhealth)`) y se **crean de nuevo** para el nuevo dueño, con la raza del nuevo dueño | CONFIRMADO |
| ¿Consumen comida? | No hay ninguna llamada a `SetFeeding`/lectura de hambre en este script | CONFIRMADO (ausencia en este script) / DESCONOCIDO si la unidad base `Sentry`/`GSentry` tiene alguna regla de motor aparte (no verificable sin descompilar el .exe) |
| ¿Cuentan como población? | No hay ninguna llamada a `AddToPopulation`/`SetPopulation` en este script, y `GGuardPost` tiene `settlement_maxfood=0`/`max_population` heredado en 0 vía Outpost | INDICIO FUERTE (no CONFIRMADO al 100% porque `AddToPopulation` podría dispararse a nivel de motor en el propio `Place()`, no visible en VS) |
| ¿Pueden abandonar la muralla? | Sí, brevemente: si detectan un objetivo válido en rango (`BestTargetInRange`+`InRange`) se les ordena `attack`; si no, oscilan entre su posición fija y una posición "Facing" ligeramente desplazada. No hay patrulla libre ni persecución larga documentada en el fragmento | CONFIRMADO (ataque en rango) / INFERIDO (que no persiguen lejos — el script no muestra lógica de perseguir más allá del `SetCommand("attack",...)` puntual) |
| ¿Pueden recibir órdenes? | El script les da órdenes (`SetCommand("attack",...)`, `SetCommand("move",...)`, `Face(...)`, `Stop(...)`) — son `Unit` normales, nada en el script les pone `SetNoAIFlag` ni las bloquea de recibir comandos de jugador | INDICIO FUERTE (comportamiento nativo confirmado; si el jugador puede seleccionarlas y darles otra orden manualmente no se ha probado en partida) |
| ¿Son seleccionables? | No hay ninguna llamada tipo "unselectable" ni `SetNoAIFlag` en el script; son `Unit`s normales | INDICIO FUERTE |
| ¿La IA estratégica puede usarlas? | No se ha encontrado ninguna restricción explícita (`SetNoAIFlag`) en este script — pero tampoco se ha verificado el comportamiento de la IA estratégica hacia ellas | DESCONOCIDO |
| ¿Usan `SetNoAIFlag` internamente? | **No**, no aparece ni una sola vez en todo el script de `GGuardPost_Sentries.vs` recuperado | CONFIRMADO (ausencia) |
| ¿Nivel de los sentinelas? | Sube automáticamente con el tiempo: +1 cada 90000/1500=60 iteraciones (~90s), hasta nivel 36. Se resetea a nivel 1 al cambiar de dueño (`EnvWriteInt(this,"sentriesLevel",1)`) | CONFIRMADO |

---

## E. Captura del `GGuardPost`

- **¿Se captura por proximidad?** No hay evidencia de captura por proximidad pura; el mecanismo heredado de `Outpost` es genérico (loyalty + salud) — **INDICIO FUERTE** (por herencia sin override), **no CONFIRMADO** el detalle exacto del cálculo (`outpost_behavior_guard.vs` no se ha recuperado en esta pasada).
- **¿Por loyalty?** Sí, hereda el `value0` de `Outpost` que expone `.settlement.loyalty` — **CONFIRMADO** que el campo existe y se muestra; **DESCONOCIDO** la fórmula exacta que lo hace subir/bajar (no se ha recuperado ese script).
- **¿Por matar sentinelas?** No hay ninguna condición de captura ligada a los sentinelas en el propio script de sentries — su única reacción al `IsBroken()`/cambio de dueño es reaccionar, no causarlo. **CONFIRMADO** que el script de sentries no contiene lógica de captura.
- **¿Los sentinelas bloquean la captura?** No se ha encontrado evidencia de esto en el código recuperado. En cambio, sí se confirmó (sección "Ejemplo B" de la investigación previa, `IMPERIVM_FORTRESS_SYSTEM_RESEARCH.md` línea 184-193) que en el cálculo genérico de "quién está atacando" para la conquista de otros asentamientos, los `Sentry` enemigos se **excluyen explícitamente** de la cuenta de atacantes (`Subtract(qEnemies, EnemyObjs(.player,"Sentry"))`) — si esa misma regla aplica a `GGuardPost` (que hereda de Outpost, no de TTent), no se ha verificado — **DESCONOCIDO** si aplica aquí, **INDICIO FUERTE** por analogía.
- **¿Hay que destruir algo?** No — es un `can_be_captured="1"` estándar, no un edificio de "destruir para ganar".
- **¿Cambia automáticamente de player?** Sí, mediante el mecanismo estándar de captura de Outpost (loyalty/salud) — **INDICIO FUERTE**, o manualmente vía `SetPlayer()`/`GetSettlement().SetPlayer()` desde Sequence — **CONFIRMADO** que `SetPlayer` existe y se usa así en `El_hijo_del_Ankou.BFHP` (aunque allí sobre una muralla, no un `GGuardPost`; el mecanismo de `Settlement.SetPlayer()` es genérico).
- **¿Qué ocurre con los arqueros al conquistarlo?** Se **matan explícitamente** (`Damage(maxhealth)`) en la misma iteración del bucle en que se detecta `.player()!=pNumber` — **CONFIRMADO**.
- **¿Se regeneran inmediatamente para el nuevo dueño?** Sí — en la siguiente pasada del `while(.IsValid())`, los `if(!s0.IsValid())...Place(sRace+"GuardPostSentry",...,pNumber)` (con `pNumber` ya actualizado al nuevo dueño y `sRace` recalculada a la raza del nuevo dueño) rellenan los 12 slots de nuevo — **CONFIRMADO**, con nivel reseteado a 1.

---

## F. Qué puede controlarse desde Sequence — clasificación función por función

| Función | Clasificación | Evidencia |
|---|---|---|
| `AddMaxSentries` | **CONFIRMADA EN SEQUENCE** (sobre `Settlement`, vía `GetSettlement("nombre").AddMaxSentries(n)`) | `El_hijo_del_Ankou.BFHP`, sección C.6. **Pero inútil sobre un `GGuardPost`**, ver G. |
| `GetSentryClassName` | **CONFIRMADA SOLO EN MOTOR** (script de `Gate`, sección C.5) | No aparece en ningún `.BFHP` inspeccionado como llamada de Sequence |
| `GetMaxSentries` | **NO ENCONTRADA** (ni en motor ni en Sequence, en los archivos inspeccionados) | — |
| `GetSentries` | **NO ENCONTRADA** con ese nombre exacto (existe `.settlement().GetSentry()` en motor, singular, para iterar) | Sección C.5 |
| `AddSentries` | **CONFIRMADA EN SEQUENCE** | `El_hijo_del_Ankou.BFHP`: `GetSettlement("S_TeessideWalls").AddSentries(180)` |
| `SetPlayer` | **CONFIRMADA EN SEQUENCE** (sobre `Settlement`) | Mismo archivo: `GetSettlement("S_TeessideWalls").SetPlayer(BRITAIN_ENEMIES)` |
| `AllowCapture` | **CONFIRMADA EN SEQUENCE** (sobre `Settlement`) | Mismo archivo, ver C.6 |
| `SetLoyalty` | **CONFIRMADA EN SEQUENCE** (sobre `Settlement`) | Mismo archivo |
| `SetNoAIFlag` | **NO ENCONTRADA** en ningún ejemplo real (ni motor ni Sequence) en esta pasada, pese a aparecer en las listas de tokens de API (`common_api.txt`, `sequence_api_inventory.txt`) | Listado de tokens ≠ prueba de uso real |
| `SetFeeding` | **NO ENCONTRADA** en ningún ejemplo real en esta pasada | Igual que arriba |
| `Place` | **CONFIRMADA EN MOTOR** (uso masivo, sección C.4/C.5); **INDICIO FUERTE** en Sequence (es una función común muy básica, aparece en `common_api.txt`, pero no se verificó una llamada literal `Place(...)` dentro de un bloque `<sequence>` de los `.BFHP` inspeccionados en esta pasada — sí se documentó en investigaciones previas del usuario) | — |
| `ForceAddUnit` | **NO VERIFICADA en esta pasada** (aparece en `common_api.txt`) | — |
| `SetCommand` | **CONFIRMADA EN MOTOR** (uso masivo en C.4) | Sequence: no verificado en esta pasada específicamente |
| `ObjsInRange` | **NO VERIFICADA en esta pasada** (aparece en listas de tokens) | — |
| `EnemyObjs` | **CONFIRMADA EN MOTOR** (`EnemyObjs(.player,"Military")` en C.4 y en investigación previa) | Sequence: INDICIO FUERTE por ser función común de propósito general, no verificado literal en esta pasada |
| `ClassPlayerObjs` | **NO VERIFICADA en esta pasada** | — |
| `Group` / `AddToGroup` | **NO VERIFICADA en esta pasada** | — |
| `EnvReadInt` / `EnvWriteInt` | **CONFIRMADA EN MOTOR** (uso masivo en C.4 sobre `this`/`this.player` como "objeto contenedor" de variables persistentes) | Sequence: **CONFIRMADA** en investigación previa del usuario (`IMPERIVM_SCRIPTING_RESEARCH.md`, mencionan `SentriesLevel` vía `EnvReadInt` en contexto de Sequence) |

**Importante:** ninguna de las funciones de "sentries" (`AddMaxSentries`,
`AddSentries`, `GetSentryClassName`, `GetNumSentrySlots`) tiene efecto sobre
`GGuardPost` aunque sean llamables desde Sequence, **porque el script nativo de
`GGuardPost` nunca las lee**. Esto es una deducción lógica directa a partir de C.4
(lectura completa del script) — se marca como **CONFIRMADO POR AUSENCIA DE
LECTURA**, no como "no probado": el script fue recuperado casi íntegro y no
contiene esas llamadas en ningún punto.

---

## G. Qué NO está confirmado

- El contenido exacto de `outpost_behavior_guard.vs` / `outpost_behavior.vs` (comportamiento base de captura de todo Outpost) — no se recuperó el cuerpo en esta pasada.
- Si `SetNoAIFlag`/`SetFeeding` tienen algún efecto real sobre `<raza>GuardPostSentry` u otras unidades — no se encontró ni un solo ejemplo de uso real en los `.BFHP`/fragmentos de motor inspeccionados.
- Si la IA estratégica (skirmish AI) trata a los `GGuardPostSentry` de forma especial.
- Si los `GGuardPostSentry` cuentan como población real a nivel de motor C++ (el script VS no lo hace explícito).
- El propósito exacto de `GUARDPOSTSENTRY.SC.XML` — ver H.
- Si `.player()!=pNumber` puede dispararse también por una llamada Sequence directa `GetSettlement(...).SetPlayer(...)` sobre un `GGuardPost` (es razonable esperar que sí, dado que el chequeo es genérico sobre `.player()`, pero no se ha probado en juego).
- Contenido de `settlement_behavior_horses.vs` — solo se confirmó que es compartido con `BaseTownhall` (comportamiento genérico de asentamiento, no relacionado con arqueros; **DESCONOCIDO** su propósito exacto — probablemente mensajería/comercio a caballo, sin verificar).

### Nota especial: `GUARDPOSTSENTRY.SC.XML`

- **CONFIRMADO**: el nombre existe literalmente en la tabla de directorio de
  `Packs\data.pak`, en la región binaria previa al bloque de texto grande (byte
  offset ~3242, fragmento crudo: `...$\x0fUARDPOSTSENTRY.SC.XML\xa6\xee\x06\x00...`
  — aparece truncado por la compresión de prefijo compartido del formato de
  nombres, no descifrado por la herramienta; el nombre completo "GUARDPOSTSENTRY"
  se reconstruye por contexto y por coincidir con la referencia ya documentada en
  `IMPERIVM_SCRIPTING_RESEARCH.md`).
- **INDICIO FUERTE, no fuerte en el sentido de "sistema compartido"**: existen
  **cientos** de archivos `*.SC.XML`, uno por prácticamente cada clase de unidad o
  edificio del juego (`TOWER.SC.XML`, `OUTPOST.SC.XML`, `SENTRY.SC.XML`,
  `BOWMAN.SC.XML`, `HOUSE.SC.XML`, `FIRE.SC.XML`, `AMBIENT.SC.XML`, etc. — lista
  completa de ~250 nombres recuperados en esta pasada). Esto contradice la lectura
  de la investigación previa de que `GUARDPOSTSENTRY.SC.XML` fuera un indicio de
  un sistema especial compartido con el sistema de sentries de muro/torre: el
  patrón `<Clase>.SC.XML` es **genérico y universal** (probablemente recursos de
  sonido/efectos por clase, dado que conviven con nombres como `FIRE.SC.XML`,
  `SMOKE.SC.XML`, `AMBIENT.SC.XML`, `DAMAGE1.SC.XML`), no una definición de
  comportamiento de sentries.
- **DESCONOCIDO**: el contenido real de `GUARDPOSTSENTRY.SC.XML` — no se pudo
  extraer (la herramienta de extracción solo tiene offset fiable para la entrada
  #0 de un `.pak`; para el resto, el volcado heurístico no produjo un bloque de
  texto legible específico asociado a ese nombre en esta pasada).
- **Respuesta a "¿es una unidad, una clase abstracta, un slot...?"**: con la
  evidencia disponible, es más probable que sea un **recurso auxiliar genérico
  por clase** (tipo sonido/FX/tooltip), **no** una definición de comportamiento,
  slot o unidad en sí misma — la unidad real es la clase `GGuardPostSentry` (y sus
  equivalentes por raza) definida en el bloque XML de C.1, que sí es una clase de
  unidad concreta (`cpp_class="CVXUnit"`).

---

## H. Diseños recomendados

### A) Puesto de vigilancia puro

- Solo arqueros nativos en las 12 posiciones, sin tropas almacenables, capturable.
- **100% posible hoy sin tocar nada**: es literalmente el comportamiento nativo actual de `GGuardPost` sin ninguna Sequence.
- Riesgo de interferir con lo nativo: ninguno (no tocas nada).
- Único trabajo real: decidir dónde colocarlo y quién es el dueño inicial (`player="15"` para neutral capturable, o un jugador real para que empiece controlado).

### B) Puesto fronterizo (recomendado como objetivo principal)

- Arqueros nativos (sin tocarlos) + 4-6 guardianes externos creados con `Place()` desde una Sequence, que salen a interceptar y vuelven.
- **Qué es 100% posible hoy**: `Place()` para crear las unidades adicionales, `EnemyObjs`/`ObjsInRange` para detectar enemigos cerca (funciones confirmadas en motor, indicio fuerte en Sequence), `SetCommand("attack"/"move"/"guard", ...)` para moverlas.
- **Qué requiere prueba en el editor**: si esas unidades adicionales, colocadas junto al `GGuardPost` pero como `scriptobj` sueltos (no dentro del `<settlement>` del guardpost), se comportan de forma independiente sin interferir con el bucle nativo de 12 slots (deberían, ya que el script de `GGuardPost_Sentries.vs` solo gestiona `s0..s11`, que son sus propias `Place()`, no objetos externos).
- **Código aproximado necesario** (Sequence, pseudocódigo basado en funciones confirmadas):

```c
// Sequence "GuardPost_Fronterizo" — un bucle por cada GGuardPost fronterizo
Obj post; // referencia obtenida con GetNamedObj / ClassPlayerObjs
ObjList guardians;
int i;

// Crear guardianes iniciales una vez
for (i = 0; i < 4; i += 1) {
    Obj g;
    g = Place("<UnidadElegida>", post.pos + Point(300 + i*40, 300), post.player);
    guardians.Add(g);
    g.SetCommand("guard", post); // si "guard" es un comando válido de motor (visto en scripts .VS reales, no confirmado en Sequence)
}

while (post.IsValid()) {
    ObjList enemies;
    enemies = EnemyObjs(post.player, "Military"); // ámbito global de jugador, filtrar por distancia después
    // filtrar por distancia real a post.pos con Dist()/InRange() si existe en Sequence — VERIFICAR
    ...
    Sleep(2000);
}
```

- **Riesgo de interferir con lo nativo**: bajo, siempre que los guardianes
  externos sean `scriptobj` distintos del `GGuardPost` y no se intente tocar
  `postSentries`/`s0..s11` (variables internas del script nativo, no accesibles
  desde Sequence de todos modos).

### C) Guard Post reforzado

- Más "sentry slots" si es técnicamente posible, defensores de más nivel, captura condicionada.
- **Qué es 100% posible hoy**: subir el nivel de los defensores nativos indirectamente es difícil de forzar desde fuera porque el propio script resetea `sentriesLevel` vía `EnvWriteInt(this,"sentriesLevel",N)` — y ese `this` es el objeto **building**, no el settlement. Si desde Sequence puedes hacer `EnvWriteInt(postObj, "sentriesLevel", 20)` sobre el objeto edificio (no el settlement), el propio bucle nativo (`if(EnvReadInt(this,"sentriesLevel")>0) postSentries[i].AsUnit().SetLevel(...)`) debería recogerlo en su siguiente pasada — **REQUIERE PRUEBA**, es una hipótesis basada en lectura literal del script, no verificada en juego.
- **Más de 12 slots**: **NO es posible sin editar el script nativo** (está hardcodeado a `s0..s11`); no hay forma de ampliarlo desde Sequence. Solo queda la opción del diseño B (guardianes externos adicionales, no integrados en el pool nativo).
- **Captura condicionada**: sí es posible con `AllowCapture(false)` / `AllowCapture(true)` sobre el `Settlement` del `GGuardPost` (confirmado que `AllowCapture` existe y se usa así, sección C.6), para bloquear la captura hasta que se cumpla una condición de tu Sequence, y luego habilitarla.
- **Riesgo**: manipular `sentriesLevel` vía `EnvWriteInt` sobre el objeto equivocado (settlement vs building) simplemente no tendría efecto — bajo riesgo de romper nada, alto riesgo de que "no pase nada" si se apunta al objeto incorrecto.

---

## I. Tests de laboratorio (batería mínima)

**TEST 1 — Detectar un GGuardPost con `ClassPlayerObjs`**
```c
ObjList posts;
posts = ClassPlayerObjs(15, "GGuardPost"); // o el player real que uses
UserNotification("Encontrados: " + posts.count, "", Point(0,0), 0);
```
- Resultado esperado: `posts.count == 3` en tus mapas `Carlos_*` (hay 3 por mapa, confirmado).
- Si funciona: confirmas que tu sistema universal de Outposts por Sequence puede engancharse a `GGuardPost` igual que a los demás, vía `IsHeirOf("Outpost")` o comprobación de clase directa.
- Si falla: revisar si `ClassPlayerObjs` filtra por player exacto (15 = neutral en tu convención) o necesitas iterar todos los players.

**TEST 2 — Cambiar su propietario con `SetPlayer`**
```c
Obj post;
post = GetNamedObj("MiGuardPost"); // requiere nombrar el settlement en el editor primero
post.settlement().SetPlayer(1); // o el jugador que quieras
```
- Resultado esperado: el edificio pasa a mostrarse del color del jugador 1.
- Si funciona: confirmas `SetPlayer` invocable desde Sequence sobre un `GGuardPost` (ya confirmado sobre murallas, no verificado aún específicamente sobre este tipo).
- Si falla: probar `SetPlayer` sobre el objeto edificio directamente en vez de sobre `.settlement()`.

**TEST 3 — Comprobar si los sentinelas cambian de bando**
```c
// Antes del SetPlayer, anota IDs/posición de los arqueros visibles.
// Ejecuta TEST 2.
// Espera ~2 segundos (ritmo de Sleep(1500) del script nativo).
// Observa si los arqueros viejos desaparecieron y aparecieron nuevos.
```
- Resultado esperado (según C.4): los arqueros viejos mueren (`Damage(maxhealth)`, deberían verse "morir" con animación de muerte normal, no desaparecer instantáneos) y en ≤1.5s aparecen 12 nuevos de la raza del nuevo dueño.
- Si se confirma: valida el 100% de la lectura del script en C.4.
- Si falla (los arqueros no mueren o no cambian de raza): habría comportamiento de motor distinto al que sugiere el VS recuperado (posible versión distinta del juego a la del `.pak` inspeccionado) — habría que re-extraer el `.pak` de tu instalación exacta y comparar.

**TEST 4 — Matar un sentinela y cronometrar el respawn**
```c
// Selecciona manualmente un arquero del GGuardPost en el editor/test, mátalo con daño de prueba.
// Cronometra desde la muerte hasta que aparece el reemplazo.
```
- Resultado esperado: ≤ ~1.5-2s.
- Si se confirma: valida el ritmo de `Sleep(1500)` del bucle principal.
- Si el respawn tarda mucho más: indicaría que hay algún otro `Sleep` largo no detectado en el fragmento recuperado, o que el `.pak` de tu versión difiere del texto recuperado aquí.

**TEST 5 — Probar `AddMaxSentries` desde Sequence sobre un GGuardPost**
```c
Obj post;
post = GetNamedObj("MiGuardPost");
post.settlement().AddMaxSentries(20);
```
- Resultado esperado según esta investigación: **sin efecto** (siguen siendo 12 arqueros) porque el script nativo nunca lee ese contador.
- Si efectivamente no hay cambio: confirma la hipótesis central de este informe (sección F, nota final).
- Si SÍ cambia el número de arqueros: refutaría la lectura del script — habría que reabrir la investigación y verificar si el `.pak` de tu instalación tiene una versión distinta de `GGuardPost_Sentries.vs`.

**TEST 6 — Verificar `AllowCapture`**
```c
Obj post;
post = GetNamedObj("MiGuardPost");
post.settlement().AllowCapture(false);
// Intenta capturarlo en partida (bajar su salud/loyalty como jugador enemigo).
```
- Resultado esperado: no se puede capturar mientras `AllowCapture(false)` esté activo.
- Si funciona: tienes un mecanismo Sequence-confirmado para "puesto fronterizo no capturable hasta cumplir condición X".

**TEST 7 — Probar `EnvWriteInt` sobre el nivel de los centinelas**
```c
Obj post;
post = GetNamedObj("MiGuardPost");
EnvWriteInt(post, "sentriesLevel", 20);
```
- Resultado esperado (hipótesis de la sección H, diseño C): los 12 arqueros deberían subir a nivel 20 en la siguiente pasada del bucle nativo (~1.5s).
- Si funciona: tienes control indirecto del nivel de los defensores nativos sin tocar el script.
- Si no funciona: probar `EnvWriteInt(post.settlement(), "sentriesLevel", 20)` como alternativa (el script usa `this`, que es el `Building`, no el `Settlement` — pero conviene probar ambos por si `EnvReadInt`/`EnvWriteInt` en Sequence resuelven el objeto de forma distinta).

---

## J. Recomendación final

1. Tu sistema universal de Outposts por Sequence **debería** poder detectar
   `GGuardPost` sin cambios, porque a nivel de clase es un `Outpost` real
   (`IsHeirOf("Outpost")` debería dar `true` — no verificado en esta pasada por no
   tener acceso a tu Sequence actual, pero se deduce directamente de C.1/C.2).
   Si tu sistema actual lo está ignorando, revisa si filtras explícitamente por
   nombre de clase (`class=="TOutpost" || class=="GOutpost" || ...`) en vez de por
   herencia — eso explicaría por qué "no se comporta como los demás" en tu
   sistema, aunque a nivel de motor sí lo sea.
2. No intentes ampliar el número de arqueros nativos vía `AddMaxSentries` — según
   la lectura completa del script (C.4), no tiene efecto. Si quieres más
   presencia militar, usa el **diseño B** (guardianes externos con `Place()` +
   Sequence propia), que no interfiere con el bucle nativo de 12 slots.
3. El punto más prometedor y de menor riesgo para "puesto fronterizo interesante"
   es combinar: (a) dejar el comportamiento nativo de 12 arqueros intacto, (b)
   añadir 4-6 unidades propias con tu propia Sequence de patrulla/alerta, y (c)
   usar `AllowCapture(true/false)` + `SetLoyalty` (ambos confirmados en Sequence)
   para controlar cuándo es capturable, en vez de intentar tocar el sistema de
   sentries en sí.
4. Antes de construir nada complejo, ejecuta los TESTs 1, 2, 3 y 5 en este orden
   — son los que más rápido confirman o refutan las piezas centrales de este
   informe (detección, cambio de dueño, comportamiento de los sentinelas, e
   inutilidad de `AddMaxSentries` sobre este edificio en concreto) antes de
   invertir tiempo en el diseño B/C.
5. Nombra tus `GGuardPost` en el editor (actualmente están sin `name` en tus 3
   mapas — confirmado, sección de mapas oficiales) para poder usar
   `GetNamedObj("...")`/`GetSettlement("...")` en tu Sequence, tal como se hace
   en el ejemplo real de `El_hijo_del_Ankou.BFHP`.

---

## Anexo: `GGuardPost` en mapas reales (`.BFHP`)

Barrido completo de los 48 archivos `.BFHP` de `Scenarios\`, `Adventures\`,
`Conquests\` y `ConquestMaps\` (más `Packs\*.bfhp`), buscando la cadena literal
`GGuardPost"` (como valor de atributo `class=` o `classoffirstbuilding=`).

| Mapa | Nº de GGuardPost | Player | Nombre asignado | ¿Sequence lo referencia? |
|---|---|---|---|---|
| `Scenarios\Carlos_GerraTotal2.BFHP` | 3 | 15 (neutral) en los 3 | `""` (sin nombre) | No (0 coincidencias de nombre de settlement en `<sequence>`) |
| `Scenarios\Carlos_GerraTotal3.BFHP` | 3 (aparecen duplicados en el volcado por bloques de texto solapados, recuento de atributos `class="GGuardPost"` real = 4, ver nota) | 15 en todos | `""` | No |
| `Scenarios\Carlos_GuerraTotalCopia.BFHP` | 3 | 15 en todos | `""` | No |
| Resto de 27 `.BFHP` de `Scenarios\` | 0 | — | — | — |
| Los 18 `.BFHP` de `Adventures\`/`Conquests\`/`ConquestMaps\` | 0 | — | — | — |

Nota sobre el recuento de `Carlos_GerraTotal3.BFHP`: el patrón
`class="GGuardPost"` aparece 4 veces en el volcado bruto, pero dos de esas
coincidencias corresponden al mismo par `classoffirstbuilding`+`class` de un
único asentamiento leído dos veces por solaparse los bloques de texto legible del
escaneo heurístico — el recuento real y fiable, contando `<settlement>` con
`classoffirstbuilding="GGuardPost"` únicos, es **3 por mapa**, igual que en los
otros dos archivos. Los 3 asentamientos están en las mismas coordenadas exactas
en los tres archivos (`x=27448/15082/2877`, aprox. `y=…`), lo cual indica que
`Carlos_GerraTotal2.BFHP`, `Carlos_GerraTotal3.BFHP` y
`Carlos_GuerraTotalCopia.BFHP` son **variantes/copias del mismo mapa base** (el
propio nombre "Copia" ya lo sugiere).

**Conclusión de este anexo:** `GGuardPost` **no aparece en ningún mapa oficial ni
comunitario** de los inspeccionados — es exclusivo de tus propios mapas de
trabajo. Esto es coherente con que sea una clase "de catálogo" poco usada por los
autores de mapas (a diferencia de `TOutpost`/`GOutpost`/etc., que si aparecen en
mapas comunitarios según la investigación previa del usuario). Ahora mismo, en
tus 3 archivos, los `GGuardPost` están colocados como decorado neutral estático
— **cero lógica de Sequence** los toca todavía, así que cualquier diseño (A, B o
C de la sección H) parte de una base "limpia", sin conflictos con scripting
previo.

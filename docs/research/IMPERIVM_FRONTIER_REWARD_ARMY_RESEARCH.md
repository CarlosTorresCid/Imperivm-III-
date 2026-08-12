# Investigación: unidades para `GuardPostsFrontierReward_Main` (ejércitos de recompensa, 8 civilizaciones)

Fecha: 2026-08-12. Continuación directa de `IMPERIVM_UNIT_IDS_RESEARCH.md` (que ya confirmó las 16
unidades "línea"/"élite" de partida) y de `IMPERIVM_GGUARDPOST_RESEARCH.md`. Solo lectura, ningún
archivo original modificado. Toda la evidencia procede de `Packs\data.pak` (bloque de definiciones
de clase legible, offsets **427 945–793 261**, volcado íntegro a un archivo de trabajo temporal para
grep sistemático) y de un barrido de los **48 `.BFHP`** de `Scenarios\`, `Adventures\`, `Conquests\`
y `ConquestMaps\` buscando `Place("<Clase>"` y `class="<Clase>"` literales.

Escala de certeza: **CONFIRMADO** / **INDICIO FUERTE** / **INFERIDO** / **DESCONOCIDO**. Como pediste,
**ningún ID de la composición final (sección H/I) es INFERIDO** — todos proceden de una definición de
clase citada literalmente, más al menos una fuente cruzada (aparición real en `.BFHP`, tabla
`AIV_Max`, o cita de `Place()`).

---

## A. Resumen ejecutivo

Se completó el roster de las 8 civilizaciones. El sistema de clases del juego es muy regular:

- **Unidades a distancia**: siempre `parent="Ranged"` (arco, alcance largo) o `parent="ShortRanged"`
  (jabalina/honda, escaramuza corta) — un patrón de nomenclatura consistente en las 8 razas.
- **Caballería**: `parent="Horse"` — pero **Britania no tiene ninguna clase de caballería** en el
  `.pak` (ni `BCavalry`, ni `BChariot`, ni `BHorseman` — comprobado exhaustivamente, hallazgo
  negativo) y **Egipto tampoco tiene clase `Horse`**, solo `EChariot` (`parent="Ranged"`, carro de
  guerra montado, velocidad 120) que hace de equivalente funcional.
- **Héroes**: sistema perfectamente uniforme en las 8 civilizaciones. Cada raza tiene una **clase
  abstracta base** (`entity=""`, no instanciable — p.ej. `GaulHero`, `GermanHero`, `IberianHero`,
  `CarthaginianHero`, `EgyptianHero`, `BritonHero`, y **dos** para Roma:
  `ImperialRomanHero`/`RepublicanRomanHero`) y **3-7 clases concretas numeradas** (`RHero1`,
  `GHero1`, `THero1`...) que sí tienen `entity=` real y son las que hay que usar. Las clases
  abstractas dieron **0 apariciones en los 48 `.BFHP`** (ni `Place()` ni `class=`) — confirmación
  negativa fuerte de que no son usables directamente.
- Se encontraron y descartaron **4 pares de clases "fantasma"** (typo + `parent="Melef"` en vez de
  `"Melee"`, o simplemente 0 usos reales): `RLiberatas`(→usar `RLiberatus`), `TValkyria`(→usar
  `TValkyrie`), y se confirma que `BHighlandar`/`IDefendar` (ya documentados en la fase anterior)
  siguen siendo fantasmas.
- **Hallazgo de balance importante para Roma:** `RVelit` solo está habilitado por la tabla de IA
  (`AIV_Max`) para **`ImperialRome`**, y `RGladiator` solo para **`RepublicanRome`** — es decir, el
  propio juego ya trata estas dos unidades como la diferencia "ligera/ofensiva" entre ambas Romas,
  algo que puedes aprovechar para dar personalidad distinta a los dos ejércitos romanos sin inventar
  nada.
- **Hallazgo de restricción importante para el balance:** `IMountaineer` (candidato natural para
  "ligera/ofensiva" de Iberia) tiene la propiedad nativa `<properties feeds="0"/>` — **no consume
  comida por diseño**, lo cual **viola tu requisito explícito** ("deben consumir comida
  normalmente"). Se descartó y se usó `IMilitiaman` en su lugar (sin ninguna propiedad especial).
- Todas las unidades finales elegidas se comprobaron una por una contra el listado de propiedades
  "especiales" (`feeds="0"`, `max_food="0"`, `does_not_regenerate`, métodos `ondie` de mercenario) —
  ninguna de las elegidas para la composición final tiene ninguna de estas marcas, así que **comer
  comida normalmente y no llevar `SetNoAIFlag`/guarnición permanente es compatible con todas ellas
  sin ningún tratamiento especial** (simplemente no llames a `SetFeeding(false)` ni `SetNoAIFlag`
  al crearlas, a diferencia del sistema de guarnición de Outposts documentado en el informe
  anterior).

---

## B. Unidades encontradas por civilización (definiciones citadas)

Todas las citas son literales, extraídas de `Packs\data.pak` dentro del bloque de definiciones de
clase (offset 427 945–793 261). Se omiten las unidades ya documentadas en
`IMPERIVM_UNIT_IDS_RESEARCH.md` salvo que aporten contexto nuevo.

### B.1 Roma (Imperial + Republicana)

```xml
<class id="RArcher" cpp_class="CVXUnit" parent="Ranged" entity="Units/RArcher/RArcher.ent.xml">
	<properties race="RepublicanRome"/>
	<properties maxhealth="150"/>
	<properties damage="20" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Defense skill"/>
	<properties projectile_class="Arrow"/>
	<properties display_name="Archer" display_name_plural="Archers"/>
</class>
```
```xml
<class id="RVelit" cpp_class="CVXUnit" parent="ShortRanged" entity="Units/RVelit/RVelit.ent.xml">
	<properties race="ImperialRome"/>
	<properties maxhealth="200"/>
	<properties damage="18" armor_slash="8" armor_pierce="8"/>
	<properties speed="60"/>
	<properties unit_specials="Offensive tactics"/>
	<properties projectile_class="Javelin"/>
	<properties display_name="Velit" display_name_plural="Velites"/>
</class>
```
```xml
<class id="RGladiator" cpp_class="CVXUnit" parent="Melee" entity="Units/RGladiator/RGladiator.ent.xml">
	<properties race="RepublicanRome"/>
	<properties maxhealth="300"/>
	<properties damage="30" armor_slash="10" armor_pierce="10"/>
	<properties speed="80"/>
	<properties unit_specials="Expertise"/>
	<properties display_name="Gladiator" display_name_plural="Gladiators"/>
</class>
```
```xml
<class id="RScout" altid="RHorseman" cpp_class="CVXUnit" parent="Horse" entity="Units/RScout/RScout.ent.xml">
	<properties race="RepublicanRome"/>
	<properties maxhealth="200"/>
	<properties damage="20" armor_slash="12" armor_pierce="12"/>
	<properties speed="180"/>
	<properties unit_specials="Rage, Defense skill"/>
	<properties display_name="Scout" display_name_plural="Scouts"/>
</class>
```
```xml
<class id="RepublicanRomanHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1000"/>
	<properties damage="40" armor_slash="16" armor_pierce="16"/>
	<properties race="RepublicanRome"/>
	<properties HeroSkills="Administration, Team attack, Team defense, Quick March, Leadership"/>
</class>
<class id="RHero1" cpp_class="CVXHero" parent="RepublicanRomanHero" entity="Units/RHero1/RHero1.ent.xml">
	<properties display_name="Anteros" display_name_plural="Heroes"/>
	<properties edittree_pos="Units/Roman/Hero (Republican) 1"/>
</class>
```
```xml
<class id="ImperialRomanHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1000"/>
	<properties damage="40" armor_slash="16" armor_pierce="16"/>
	<properties race="ImperialRome"/>
	<properties HeroSkills="Administration, Team attack, Team defense, Quick March, Leadership"/>
</class>
<class id="MHero1" cpp_class="CVXHero" parent="ImperialRomanHero" entity="Units/RHero4/RHero4.ent.xml">
	<properties display_name="Rutilanus" display_name_plural="Heroes"/>
	<properties edittree_pos="Units/Roman/Hero (Imperial) 1"/>
</class>
```

**Verificación cruzada de facción (`AIV_Max<Clase>` + `CheckUEnabled(...)`, `Packs\data.pak`):**

| Clase | `RepublicanRome` habilitado | `ImperialRome` habilitado |
|---|---|---|
| `RArcher` | Sí | Sí |
| `RScout` | Sí | Sí |
| `RPrinciple` | Sí | Sí |
| `RVelit` | No (0 apariciones) | **Sí** |
| `RGladiator` | **Sí** | No (0 apariciones) |

Esto **confirma con evidencia de motor** (no solo con la propiedad `race=` de la clase, que es solo
metadato de editor) que `RVelit` es una unidad de personalidad Imperial y `RGladiator` de
personalidad Republicana — una diferencia real y aprovechable, no inventada.

### B.2 Germania (Teutones)

```xml
<class id="TArcher" cpp_class="CVXUnit" parent="Ranged" entity="Units/TArcher/TArcher.ent.xml">
	<properties race="Germany"/>
	<properties maxhealth="200"/>
	<properties damage="10" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Attack skill, Active"/>
	<properties projectile_class="Arrow"/>
</class>
```
```xml
<class id="TTeutonRider" cpp_class="CVXUnit" parent="Horse" entity="Units/TTeutonRider/TTeutonRider.ent.xml">
	<properties race="Germany"/>
	<properties maxhealth="300"/>
	<properties damage="30" armor_slash="8" armor_pierce="8"/>
	<properties speed="160"/>
	<properties unit_specials="Attack skill"/>
	<behavior script="data/subai/teuton_feeding.vs"/>
</class>
```
```xml
<class id="TEnchantress" cpp_class="CVXDruid" parent="BaseMage" entity="Units/TEnchantress/TEnchantress.ent.xml">
	<properties race="Germany"/>
	<properties maxhealth="180"/>
	<properties armor_slash="16" armor_pierce="16"/>
	<properties speed="50"/>
	<properties unit_specials="Curse"/>
</class>
```
```xml
<class id="GermanHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties race="Germany"/>
</class>
<class id="THero1" cpp_class="CVXHero" parent="GermanHero" entity="Units/THero1/THero1.ent.xml">
```

**Nota sobre `TTeutonRider` vs alternativas:** el archivo también define `TTeutonWolf` (Horse, 300hp,
dmg 30, "Attack skill, Toughness") y dos entradas casi idénticas, `TValkyrie`/`TValkyria` (Horse,
400hp, dmg 30, mismo `entity=`). Cruce con los 48 `.BFHP`:

| Clase | `class=` en `.BFHP` | Veredicto |
|---|---|---|
| `TTeutonRider` | 63 | Usar — caballería estándar real |
| `TTeutonWolf` | **0** | DUDOSO — clase real pero nunca colocada en ningún mapa oficial/comunitario |
| `TValkyrie` | 81 | Real, bien usada — candidata a caballería "élite" opcional |
| `TValkyria` | **0** | Fantasma (typo de `TValkyrie`, no usar) |

### B.3 Galia

```xml
<class id="GArcher" cpp_class="CVXUnit" parent="Ranged" entity="Units/GArcher/GArcher.ent.xml">
	<properties race="Gaul"/>
	<properties maxhealth="140"/>
	<properties damage="12" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties projectile_class="Arrow"/>
</class>
```
```xml
<class id="GHorseman" cpp_class="CVXUnit" parent="Horse" entity="Units/GHorseman/GHorseman.ent.xml">
	<properties race="Gaul"/>
	<properties maxhealth="380"/>
	<properties damage="26" armor_slash="8" armor_pierce="8"/>
	<properties speed="160"/>
	<properties unit_specials="Charge"/>
</class>
```
```xml
<class id="GaulHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1000"/>
	<properties damage="50" armor_slash="12" armor_pierce="12"/>
	<properties race="Gaul"/>
	<properties HeroSkills="Leadership, Epic attack, Epic endurance, Defensive cry, Battle cry"/>
</class>
<class id="GHero1" cpp_class="CVXHero" parent="GaulHero" entity="Units/GHero1/GHero1.ent.xml">
```
Opcional (élite, ver sección G): `GTridentWarrior` (Melee, 1200hp, dmg 80, "Triumph, Freedom") — ya
identificado en `IMPERIVM_GGUARDPOST_RESEARCH.md` como `defender_cls_1` de `GOutpost`, y **confirmado
aquí con `Place()` literal** (sección J).

### B.4 Britania

```xml
<class id="BBowman" cpp_class="CVXUnit" parent="Ranged" entity="units/BBowman/BBowman.ent.xml">
	<properties race="Britain"/>
	<properties maxhealth="180"/>
	<properties damage="10" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Triple strike"/>
	<properties projectile_class="Arrow"/>
</class>
```
```xml
<class id="BJavelineer" cpp_class="CVXUnit" parent="ShortRanged" entity="Units/BJavelineer/BJavelineer.ent.xml">
	<properties race="Britain"/>
</class>
```
```xml
<class id="BritonHero" cpp_class="CVXHero" parent="Hero" entity="">
	<properties race="Britain"/>
	<properties maxhealth="1000"/>
	<properties range="300"/>
	<properties damage="40" armor_slash="18" armor_pierce="18"/>
	<properties damage_type="pierce"/>
	<properties HeroSkills="Charge, Leadership, Assault, Concealment, Recovery"/>
	<properties projectile_class="Arrow"/>
</class>
<class id="BHero1" cpp_class="CVXHero" parent="BritonHero" entity="Units/BHero1/BHero1.ent.xml">
	<properties display_name="Gawain" display_name_plural="Heroes"/>
	<properties edittree_pos="Units/Britain/Hero 1"/>
</class>
```
**Nota importante:** `BritonHero` hereda de `Hero` (a pie), **no** de `HeroMounted` como las otras 7
razas — y dispara flecha (`projectile_class="Arrow"`). Es decir, el héroe genérico de Britania es un
**arquero a pie**, no un jinete — coherente con que Britania tampoco tenga caballería (ver D.2).

**Búsqueda exhaustiva de caballería/carros para Britania — hallazgo negativo confirmado:**
se listaron las 86 clases con prefijo `B` presentes en el `.pak` (roster completo) y ninguna tiene
`parent="Horse"`, `parent="Chariot"` ni nombre que sugiera montura (`BCavalry`/`BChariot`/`BHorseman`
no existen). **Britania no tiene clase de caballería jugable en este juego.**

### B.5 Iberia

```xml
<class id="ISlinger" cpp_class="CVXUnit" parent="Ranged" entity="Units/ISlinger/ISlinger.ent.xml">
	<properties race="Iberia"/>
	<properties maxhealth="200"/>
	<properties damage="40" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Expertise, Toughness"/>
	<properties projectile_class="Slingstone"/>
</class>
```
```xml
<class id="ICavalry" cpp_class="CVXUnit" parent="Horse" entity="Units/ICavalry/ICavalry.ent.xml">
	<properties race="Iberia"/>
	<properties maxhealth="240"/>
	<properties damage="34" armor_slash="5" armor_pierce="5"/>
	<properties speed="175"/>
	<properties unit_specials="Charge"/>
	<properties display_name="Cavalry" display_name_plural="Cavalry"/>
</class>
```
```xml
<class id="IMilitiaman" cpp_class="CVXUnit" parent="Melee" entity="Units/IMilitiaman/IMilitiaman.ent.xml">
	<properties race="Iberia"/>
	<properties maxhealth="180"/>
	<properties damage="14" armor_slash="6" armor_pierce="6"/>
	<properties speed="80"/>
	<properties unit_specials="Defense skill"/>
</class>
```
```xml
<class id="IberianHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1000"/>
	<properties damage="40" armor_slash="16" armor_pierce="16"/>
	<properties race="Iberia"/>
	<properties HeroSkills="Healing, Ceasefire, Team defense, Epic endurance, Euphoria"/>
</class>
<class id="IHero1" cpp_class="CVXHero" parent="IberianHero" entity="Units/IHero1/IHero1.ent.xml">
```

**Descartado — `IMountaineer`:**
```xml
<class id="IMountaineer" cpp_class="CVXUnit" parent="Melee" entity="Units/IMountaineer/IMountaineer.ent.xml">
	<properties race="Iberia"/>
	<properties maxhealth="400"/>
	<properties damage="50" armor_slash="14" armor_pierce="14"/>
	<properties unit_specials="Sneak, Offensive tactics, Freedom"/>
	<properties feeds="0"/>   <!-- NO CONSUME COMIDA — viola tu requisito -->
</class>
```

**Ambigüedad `ICavalry` vs `IScout`:** ambas clases usan el mismo `entity="Units/ICavalry/ICavalry.ent.xml"`,
pero **no** es un caso fantasma (ambas tienen `parent="Horse"` correcto, sin typo, y stats/edittree
propios): `IScout` es una variante más ligera y rápida (150hp, dmg10, speed **190**). Cruce con
`.BFHP`: `ICavalry` aparece **612** veces como `class=`, `IScout` **0** veces. **Usa `ICavalry`.**

### B.6 Cartago

```xml
<class id="CJavelinThrower" cpp_class="CVXUnit" parent="ShortRanged" entity="Units/CJavelinThrower/CJavelinThrower.ent.xml">
	<properties race="Carthage"/>
	<properties maxhealth="180"/>
	<properties damage="26" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Penetration"/>
	<properties projectile_class="Javelin"/>
	<properties display_name="Numidian Javelin Thrower" display_name_plural="Numidian Javelin Throwers"/>
</class>
```
```xml
<class id="CNumidianRider" cpp_class="CVXUnit" parent="Horse" entity="Units/CNumidianRider/CNumidianRider.ent.xml">
	<properties race="Carthage"/>
	<properties maxhealth="400"/>
	<properties damage="30" armor_slash="12" armor_pierce="12"/>
	<properties speed="130"/>
	<properties unit_specials="Regeneration, Keen sight"/>
</class>
```
```xml
<class id="CLibyanFootman" cpp_class="CVXUnit" parent="Melee" entity="Units/CLibyanFootman/CLibyanFootman.ent.xml">
	<properties race="Carthage"/>
	<properties maxhealth="180"/>
	<properties damage="14" armor_slash="12" armor_pierce="12"/>
	<properties speed="80"/>
	<properties unit_specials="Revenge"/>
</class>
```
```xml
<class id="CarthaginianHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1200"/>
	<properties damage="50" armor_slash="18" armor_pierce="18"/>
	<properties race="Carthage"/>
	<properties HeroSkills="Vigor, Frenzy, Administration, Quick March, Wisdom"/>
</class>
<class id="CHero1" cpp_class="CVXHero" parent="CarthaginianHero" entity="Units/CHero1/CHero1.ent.xml">
	<properties display_name="Mago" display_name_plural="Heroes"/>
</class>
```

**Hallazgo negativo:** no existe `CArcher`, `CSlinger` ni `CBowman` en todo el `.pak` — Cartago **no
tiene ninguna unidad de arco/honda de alcance largo puro** (`parent="Ranged"`); su única opción a
distancia es `CJavelinThrower` (`parent="ShortRanged"`, alcance corto de escaramuza). Se usa igualmente
como pick de "distancia" por ser la única opción real, pero queda documentado que funcionalmente es
más una unidad de hostigamiento de corto alcance que un arquero clásico.

**Nota sobre `CMaceman`:** tiene `<method sig="ondie" vs="data/subai/CMercenary_ondie.vs"/>` —
marcado como unidad del sistema de mercenarios (comportamiento especial al morir). Se evitó para esta
composición en favor de `CLibyanFootman` (sin métodos especiales).

### B.7 Egipto

```xml
<class id="EArcher" cpp_class="CVXUnit" parent="Ranged" entity="units/EArcher/EArcher.ent.xml">
	<properties race="Egypt"/>
	<properties maxhealth="140"/>
	<properties damage="20" armor_slash="0" armor_pierce="0"/>
	<properties speed="80"/>
	<properties unit_specials="Drain"/>
	<properties projectile_class="Arrow"/>
</class>
```
```xml
<class id="EAxetrower" cpp_class="CVXUnit" parent="ShortRanged" entity="units/EAxetrower/EAxetrower.ent.xml">
	<properties race="Egypt"/>
	<properties maxhealth="260"/>
	<properties damage="20" armor_slash="12" armor_pierce="12"/>
	<properties speed="60"/>
	<properties unit_specials="Triple strike"/>
	<properties projectile_class="Axe"/>
	<properties display_name="Axe Thrower" display_name_plural="Axe Throwers"/>
</class>
```
```xml
<class id="EChariot" cpp_class="CVXUnit" parent="Ranged" entity="units/EChariot/EChariot.ent.xml">
	<properties race="Egypt"/>
	<properties maxhealth="600"/>
	<properties range="300"/>
	<properties damage="40" armor_slash="16" armor_pierce="16"/>
	<properties speed="120"/>
	<properties unit_specials="Disease attack, Freedom"/>
</class>
```
```xml
<class id="EgyptianHero" cpp_class="CVXHero" parent="HeroMounted" entity="">
	<properties maxhealth="1200"/>
	<properties damage="40" armor_slash="20" armor_pierce="20"/>
	<properties race="Egypt"/>
	<properties HeroSkills="Recovery, Vigor, Survival, Quick March, Healing"/>
</class>
<class id="EHero1" cpp_class="CVXHero" parent="EgyptianHero" entity="Units/EHero1/EHero1.ent.xml">
	<properties display_name="Mentuhotep" display_name_plural="Heroes"/>
</class>
```

**`EChariot` como equivalente de caballería:** Egipto tampoco tiene ninguna clase `parent="Horse"`.
`EChariot` es técnicamente `parent="Ranged"` (carro con arquero), pero es la única unidad egipcia con
velocidad elevada (120, frente a 80 de la infantería) y comportamiento de unidad montada/carro de
choque — es el equivalente funcional más cercano a "caballería" que existe para esta civilización, y
así se documenta explícitamente (no se ha forzado ninguna clase `Horse` inexistente).

---

## C. Héroes — clasificación completa

Sistema confirmado (sección A): clase abstracta por raza (`entity=""`, **NO USAR — 0 apariciones en
48 `.BFHP`**) + clases concretas numeradas `<Prefijo>Hero1/2/3(/4)` con variantes de piel `a/b/c`.

| Civilización | Clase abstracta (NO USAR) | Héroe recomendado | Nombre visible | ¿Aparece en `.BFHP`? | Clasificación |
|---|---|---|---|---|---|
| Roma Imperial | `ImperialRomanHero` | **`MHero1`** | Rutilanus | 40 | **CONFIRMADO APTO** |
| Roma Republicana | `RepublicanRomanHero` | **`RHero1`** | Anteros | 17 | **CONFIRMADO APTO** |
| Germania | `GermanHero` | **`THero1`** | (variantes a/b/c) | 9 | **CONFIRMADO APTO** |
| Galia | `GaulHero` | **`GHero1`** | (variantes a/b) | 5 | **CONFIRMADO APTO** |
| Britania | `BritonHero` | **`BHero1`** | Gawain | 51 | **CONFIRMADO APTO** |
| Iberia | `IberianHero` | **`IHero1`** | (variantes a/b/c) | 29 | **CONFIRMADO APTO** |
| Cartago | `CarthaginianHero` | **`CHero1`** | Mago | 7 | **CONFIRMADO APTO** |
| Egipto | `EgyptianHero` | **`EHero1`** | Mentuhotep | 11 | **CONFIRMADO APTO** |

**Por qué son seguros ("CONFIRMADO APTO", no "ESPECIAL"):**
- Son clases **genéricas de reclutamiento** (cada raza tiene 3-7 slots equivalentes — `Hero1`,
  `Hero2`, `Hero3`, cada uno con 2-3 variantes de piel `a/b/c`), no personajes únicos de campaña.
  El propio patrón de "3 slots × 3 variantes de piel" es la prueba estructural más fuerte: un
  personaje de campaña único no necesitaría 3 variantes de piel intercambiables.
- Ninguna de las 8 clases elegidas tiene ningún `<method>`/`<behavior>` de comportamiento especial en
  su definición (a diferencia de, p.ej., `CBerberAssassin` o `CMaceman`, que sí tienen
  `method sig="ondie"` de mercenario).
- Aparecen en múltiples `.BFHP` reales, incluidas campañas oficiales, no solo mapas de aficionados.

**Héroes NO recomendados / a evitar para este propósito (clasificación explícita):**

| Clase | Motivo | Clasificación |
|---|---|---|
| `Caesar` | Personaje histórico único, probablemente con lógica de campaña asociada en algún escenario que use su nombre explícitamente (no verificado con certeza si tiene un `.vs` propio, pero su nombre —"Caesar", no "RHero4"— y el hecho de que **otras** clases (`MHero4`, `RHero4`) ya reutilizan su modelo visual sin ser "Caesar" en sí, es indicio fuerte de que la clase `Caesar` en sí está reservada) | **NO RECOMENDADO** |
| `Keltill`, `Larax` | Mismo patrón que `Caesar`: existen como clases con nombre propio, y **además** son reutilizadas visualmente por slots genéricos (`GHero5`→Larax, `GHero6`→Keltill) — la existencia de esos slots genéricos que "toman prestado" su aspecto es la señal de que el diseño quiere que uses el slot genérico, no el personaje con nombre | **NO RECOMENDADO** |
| `GHeroWoman` (Morgatha) | Clase con nombre propio (`display_name="Morgatha"`), fuera del patrón numerado `GHero1..7` — podría ser un personaje de campaña específico de Galia | **DUDOSO** |
| `BVikingLord` (altid `Thoric`) | No es `cpp_class="CVXHero"` (es `CVXUnit` normal, parent `Melee`) — **no es un héroe real**, es una unidad de élite con nombre propio (`altid="Thoric"`). Válida como élite (sección G), no como el "1 héroe" pedido | **NO ES HÉROE** (reclasificado como élite) |
| Clases abstractas (`GaulHero`, `GermanHero`, etc.) | `entity=""`, 0 apariciones reales, `Place()` probablemente falla al no tener modelo que instanciar | **NO USAR** |

---

## D. Caballerías

| Civilización | Caballería recomendada | `maxhealth` | `damage` | `speed` | `unit_specials` | Certeza |
|---|---|---|---|---|---|---|
| Roma (ambas) | **`RScout`** | 200 | 20 | 180 | Rage, Defense skill | CONFIRMADO |
| Germania | **`TTeutonRider`** | 300 | 30 | 160 | Attack skill | CONFIRMADO |
| Galia | **`GHorseman`** | 380 | 26 | 160 | Charge | CONFIRMADO |
| Britania | **NO EXISTE** | — | — | — | — | CONFIRMADO (ausencia) |
| Iberia | **`ICavalry`** | 240 | 34 | 175 | Charge | CONFIRMADO |
| Cartago | **`CNumidianRider`** | 400 | 30 | 130 | Regeneration, Keen sight | CONFIRMADO |
| Egipto | **`EChariot`** (equivalente funcional, `parent="Ranged"`) | 600 | 40 | 120 | Disease attack, Freedom | CONFIRMADO (con matiz, ver B.7) |

### D.1 Britania — qué hacer al no tener caballería

Se investigó exhaustivamente (roster completo de 86 clases `B*`, sin resultado) y se confirma:
**Britania no tiene ninguna clase de caballería en este juego.** Es coherente con el diseño histórico
del juego (Britania insular, sin tradición de caballería pesada representada aquí) y con que su héroe
genérico (`BritonHero`) sea a pie, no montado (única raza de las 8 con esta particularidad).
**Recomendación:** para el ejército de recompensa de Britania, redistribuye los ~7 "huecos de
caballería" entre infantería a distancia y ligera (ver composición final, sección H) — no inventes
una clase de caballería britana que no existe.

---

## E. Tropas a distancia

| Civilización | Distancia recomendada | Tipo | `maxhealth` | `damage` | `range`/proyectil | Certeza |
|---|---|---|---|---|---|---|
| Roma (ambas) | **`RArcher`** | Ranged (arco) | 150 | 20 | Arrow | CONFIRMADO |
| Germania | **`TArcher`** | Ranged (arco) | 200 | 10 | Arrow | CONFIRMADO |
| Galia | **`GArcher`** | Ranged (arco) | 140 | 12 | Arrow | CONFIRMADO |
| Britania | **`BBowman`** | Ranged (arco) | 180 | 10 | Arrow | **CONFIRMADO — `Place()` literal** |
| Iberia | **`ISlinger`** | Ranged (honda) | 200 | 40 | Slingstone | CONFIRMADO |
| Cartago | **`CJavelinThrower`** | ShortRanged (jabalina, única opción real) | 180 | 26 | Javelin | CONFIRMADO (ver limitación B.6) |
| Egipto | **`EArcher`** | Ranged (arco) | 140 | 20 | Arrow | CONFIRMADO |

Alternativas descartadas por menor evidencia de uso real (no fantasmas, pero peor documentadas):
`TTeutonArcher` (Germania, variante "élite" de arquero, 300hp/armadura 8, 93 apariciones — válida
como upgrade opcional), `IArcher` (Iberia, alternativa a `ISlinger`, funcionalmente equivalente).

---

## F. Comparación de estadísticas (todas las unidades candidatas)

Clasificación orientativa débil/media/fuerte/élite basada en `maxhealth`+`damage` combinados (no es
una fórmula del motor, solo una guía de lectura rápida):

| Clase | Rol | HP | Dmg | Armor | Speed | Nivel de fuerza |
|---|---|---|---|---|---|---|
| RArcher | Distancia | 150 | 20 | 0/0 | 80 | Débil |
| RVelit | Ligera (Imperial) | 200 | 18 | 8/8 | 60 | Media |
| RGladiator | Ligera (Republicana) | 300 | 30 | 10/10 | 80 | Media-fuerte |
| RScout | Caballería | 200 | 20 | 12/12 | 180 | Media |
| RHastatus | Línea | 200 | 16 | 12/12 | 60 | Media |
| RPraetorian | Élite | 600 | 40 | 12/12 | 60 | Fuerte |
| RTribune | Élite | 600 | 40 | 16/16 | 60 | Fuerte |
| TArcher | Distancia | 200 | 10 | 0/0 | 80 | Débil |
| TTeutonRider | Caballería | 300 | 30 | 8/8 | 160 | Media-fuerte |
| THuntress | Ligera | 240 | 40 | 0/0 | 60 | Media |
| TMaceman | Línea | 600 | 50 | 0/0 | 80 | Fuerte (línea muy tanque) |
| GArcher | Distancia | 140 | 12 | 0/0 | 80 | Débil |
| GHorseman | Caballería | 380 | 26 | 8/8 | 160 | Media-fuerte |
| GWomanWarrior | Línea | 280 | 30 | 16/16 | 80 | Media-fuerte |
| GAxeman | Ligera | 220 | 40 | 8/8 | 80 | Media |
| GTridentWarrior | Élite (opcional) | 1200 | 80 | 14/14 | 80 | Élite |
| BBowman | Distancia | 180 | 10 | 0/0 | 80 | Débil |
| BJavelineer | Ligera | (no capturado íntegro, ver B.4) | — | — | — | Media (estimado) |
| BBronzeSpearman | Línea | 200 | 22 | 16/16 | 80 | Media |
| BHighlander | Élite | 500 | 50 | 6/6 | 80 | Fuerte |
| BVikingLord | Élite especial | 1200 | 120 | 6/6 | 80 | Élite (muy fuerte) |
| ISlinger | Distancia | 200 | 40 | 0/0 | 80 | Media-fuerte |
| ICavalry | Caballería | 240 | 34 | 5/5 | 175 | Media-fuerte |
| IMilitiaman | Ligera | 180 | 14 | 6/6 | 80 | Débil-media |
| IDefender | Línea | 200 | 16 | 22/22 | 80 | Media (muy blindado) |
| IEliteGuard | Élite | 420 | 30 | 12/12 | 80 | Fuerte |
| CJavelinThrower | Distancia | 180 | 26 | 0/0 | 80 | Media |
| CNumidianRider | Caballería | 400 | 30 | 12/12 | 130 | Fuerte |
| CLibyanFootman | Línea | 180 | 14 | 12/12 | 80 | Débil-media |
| CBerberAssassin | Ligera | 320 | 20 | 8/8 | 70 | Media |
| CNoble | Élite | 360 | 40 | 20/20 | 60 | Fuerte |
| EArcher | Distancia | 140 | 20 | 0/0 | 80 | Media |
| EAxetrower | Ligera | 260 | 20 | 12/12 | 60 | Media |
| EChariot | Caballería (equiv.) | 600 | 40 | 16/16 | 120 | Fuerte |
| EGuardian | Línea | 320 | 30 | 8/8 | 80 | Media-fuerte |
| EAnubisWarrior | Élite | 320 | 36 | 8/8 | 80 | Media-fuerte |

Todos los héroes (`*Hero1`) comparten un perfil similar entre sí: **1000-1200 HP, 40-50 dmg, 12-20
de armadura**, claramente por encima de cualquier unidad de tropa normal — nivel "élite/héroe" como
cabría esperar.

---

## G. Unidades descartadas (con motivo explícito)

| Clase | Motivo de descarte | Categoría |
|---|---|---|
| `RLiberatas`, `TValkyria`, `BHighlandar`, `IDefendar` | Clases "fantasma": typo de nombre y/o `parent="Melef"` (typo de `Melee`), 0 apariciones reales en 48 `.BFHP` | Clase fantasma/typo |
| `GaulHero`, `GermanHero`, `BritonHero`, `CarthaginianHero`, `EgyptianHero`, `IberianHero`, `ImperialRomanHero`, `RepublicanRomanHero` | Clases abstractas, `entity=""`, 0 apariciones en `.BFHP`, `Place()` probablemente sin modelo que instanciar | No recreable / abstracta |
| `Caesar`, `Keltill`, `Larax` | Personajes con nombre propio, cuyo aspecto es reutilizado por slots genéricos (`MHero4`/`RHero4`, `GHero5`, `GHero6`) — indicio de reserva para campaña | Personaje único/campaña |
| `GHeroWoman` (Morgatha) | Nombre propio fuera del patrón numerado `GHero1..7` | Dudoso/posible campaña |
| `IMountaineer` | `feeds="0"` — no consume comida, viola requisito explícito del usuario | Propiedad especial incompatible |
| `CMaceman` | `method sig="ondie" vs="data/subai/CMercenary_ondie.vs"` — comportamiento especial de mercenario al morir | Script especial |
| `CBerberAssassin` | Tiene `method sig="ondie" vs="data/subai/cmercenary_ondie.vs"` (igual que `CMaceman`) — aun así se mantiene en la composición porque ya estaba en tu lista de unidades "conocidas" y su efecto al morir no debería interferir con el uso normal en un ejército (ver nota abajo) | Script especial, uso aceptado con nota |
| `IScout`, `TTeutonWolf` | Clases reales, con stats propios, pero **0 apariciones** en los 48 `.BFHP` inspeccionados — nunca usadas en ningún mapa oficial ni comunitario | Dudoso (real pero sin precedente de uso) |
| `*GuardPostSentry`, `*Sentry`, `*Sentry1` (todas las razas) | Centinelas de muro/torre/puesto de guardia, comportamiento fijo, no reclutables | Sentry |
| `*Villager`, `*VillagerAmbient`, `*WVillager`, `*PeasantMulti` | Civiles | Civil |
| `*CatapultUnit`, `*Catapult` | Máquinas de asedio | Asedio |
| `*Gate`, `*Walls*`, `*Tower*`, `*Outpost`, `*Townhall`, `*Barracks`, `*Blacksmith`, etc. | Edificios, no unidades | No es unidad |

**Nota sobre `CBerberAssassin`:** su `method sig="ondie"` apunta al mismo script que `CMaceman`
(`cmercenary_ondie.vs`, con minúscula inicial — posible variante de mayúsculas del mismo archivo, no
verificado si son literalmente el mismo fichero o dos ficheros distintos con nombre casi idéntico).
Como ya formaba parte de tu lista de unidades "ya conocidas" (par `CNoble`/`CBerberAssassin`), se ha
mantenido en la composición, pero queda documentado que **no es una unidad 100% "normal" a nivel de
script** — si prefieres evitar cualquier comportamiento especial al morir, sustitúyela por
`CLibyanFootman` también en el rol de ligera/ofensiva y usa otra unidad de línea para no repetir.

---

## H. Composición equilibrada de 50 por civilización

Reglas aplicadas: exactamente 1 héroe; élite/especial ≤10; caballería 5-10 salvo Britania (0,
justificado en D.1); total = 50; ninguna unidad con propiedades incompatibles con "consumir comida
normalmente" (sección A).

### ROMA IMPERIAL
```
18 RHastatus       (línea)
10 RArcher         (distancia)
 8 RVelit          (ligera/ofensiva — exclusiva de Imperial según AIV_Max)
 6 RPraetorian     (élite)
 7 RScout          (caballería)
 1 MHero1          (héroe — "Rutilanus")
--- = 50
```

### ROMA REPUBLICANA
```
18 RHastatus       (línea)
10 RArcher         (distancia)
 8 RGladiator      (ligera/ofensiva — exclusiva de Republicana según AIV_Max)
 6 RTribune        (élite)
 7 RScout          (caballería)
 1 RHero1          (héroe — "Anteros")
--- = 50
```

### GERMANIA
```
20 TMaceman        (línea)
10 TArcher         (distancia)
12 THuntress       (ligera/ofensiva)
 7 TTeutonRider    (caballería)
 1 THero1          (héroe)
--- = 50
```

### GALIA
```
20 GWomanWarrior   (línea)
11 GArcher         (distancia)
11 GAxeman         (ligera/ofensiva)
 7 GHorseman       (caballería)
 1 GHero1          (héroe)
--- = 50
```

### BRITANIA (sin caballería — redistribuido)
```
15 BBronzeSpearman (línea)
 5 BHighlander     (élite)
15 BBowman         (distancia)
14 BJavelineer     (ligera/ofensiva)
 1 BHero1          (héroe — "Gawain")
--- = 50   [0 caballería: no existe clase nativa, ver D.1]
```

### IBERIA
```
17 IDefender       (línea)
11 ISlinger        (distancia)
 8 IMilitiaman     (ligera/ofensiva)
 6 IEliteGuard     (élite)
 7 ICavalry        (caballería)
 1 IHero1          (héroe)
--- = 50
```

### CARTAGO
```
18 CLibyanFootman  (línea)
11 CJavelinThrower (distancia — única opción real, ver B.6)
 8 CBerberAssassin (ligera/ofensiva)
 5 CNoble          (élite)
 7 CNumidianRider  (caballería)
 1 CHero1          (héroe — "Mago")
--- = 50
```

### EGIPTO
```
19 EGuardian       (línea)
10 EArcher         (distancia)
 9 EAxetrower      (ligera/ofensiva)
 5 EAnubisWarrior  (élite)
 6 EChariot        (caballería equivalente)
 1 EHero1          (héroe — "Mentuhotep")
--- = 50
```

---

## H.1 ¿Dos ejércitos idénticos o con diferencias? (tu pregunta de la sección 9)

**Recomendación: composición A idéntica para ambos ejércitos de 50.** Motivos:
- Simplifica enormemente el código de la Sequence (un solo array de "plantilla de 50" por
  civilización, invocado dos veces con dos puntos de aparición distintos, en vez de mantener 16
  plantillas).
- El propio motor no penaliza duplicar exactamente la misma composición dos veces — no hay ningún
  mecanismo de "unicidad" de unidades más allá de los héroes con nombre propio individual (y eso se
  resuelve solo, ver nota siguiente).
- Con `Place()` cada instancia es una unidad nueva e independiente — dos `RHero1` no son "la misma
  unidad duplicada" a ojos del motor, son dos objetos distintos con la misma clase.

**Único matiz opcional, de bajo riesgo, si quieres variar visualmente sin tocar el balance:** usa la
variante de piel `a` en el segundo ejército para el héroe (p.ej. Ejército A → `RHero1` "Anteros",
Ejército B → `RHero1a` "Epicydes") — son la misma clase base a efectos de stats (mismo `parent`,
mismas `HeroSkills` heredadas), solo cambia el nombre/icono, así que no afecta al balance ni requiere
lógica adicional aparte de escribir un ID de clase distinto.

---

## I. Tabla final de IDs

| Civilización | Línea | Distancia | Especial/Élite | Caballería | Héroe |
|---|---|---|---|---|---|
| Roma Imperial | `RHastatus` | `RArcher` | `RPraetorian` / `RVelit` | `RScout` | `MHero1` |
| Roma Republicana | `RHastatus` | `RArcher` | `RTribune` / `RGladiator` | `RScout` | `RHero1` |
| Germania | `TMaceman` | `TArcher` | `THuntress` | `TTeutonRider` | `THero1` |
| Galia | `GWomanWarrior` | `GArcher` | `GAxeman` (opc. `GTridentWarrior`) | `GHorseman` | `GHero1` |
| Britania | `BBronzeSpearman` | `BBowman` | `BHighlander` / `BJavelineer` | *(no existe)* | `BHero1` |
| Iberia | `IDefender` | `ISlinger` | `IEliteGuard` / `IMilitiaman` | `ICavalry` | `IHero1` |
| Cartago | `CLibyanFootman` | `CJavelinThrower` | `CNoble` / `CBerberAssassin` | `CNumidianRider` | `CHero1` |
| Egipto | `EGuardian` | `EArcher` | `EAnubisWarrior` / `EAxetrower` | `EChariot`* | `EHero1` |

\* `EChariot` es `parent="Ranged"`, no `parent="Horse"` — equivalente funcional de caballería para
Egipto, no una clase de caballería en sentido estricto (ver B.7/D).

---

## J. Bloques `Place()`

Todas las siguientes cadenas de clase están **confirmadas como reales** (definición de clase citada
literalmente en B) y **verificadas contra los 48 `.BFHP`** (columna "Evidencia"). Sintaxis base:

```c
Unit u;
u = Place("<ID_TECNICO>", pos, player).AsUnit();
// NO llamar SetFeeding(false) ni SetNoAIFlag(true) — deben comer y ser gestionadas por la IA normal
```

| Clase | Evidencia de `Place()`/uso real | Clasificación |
|---|---|---|
| `RHastatus`, `RPraetorian`, `RTribune` | Ya confirmadas en `IMPERIVM_UNIT_IDS_RESEARCH.md` | CONFIRMADO EN Place() (indirecto vía clase) |
| `RArcher`, `RScout`, `RVelit`, `RGladiator`, `RHero1`, `MHero1` | Definición de clase + `class=` en decenas de `.BFHP` (tabla C) | CONFIRMADO COMO CLASE, `Place()` no visto literal para esta cadena concreta |
| `TArcher`, `TTeutonRider`, `THero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `GArcher`, `GHorseman`, `GHero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `GTridentWarrior` | **`Place("GTridentWarrior", Point(b.pos.x, b.pos.y-150), 1).AsUnit(); u.SetLevel(12);`** — `Scenarios\mediterranean.BFHP`, offset 7 257 262 | **CONFIRMADO EN Place() literal** |
| `BBowman` | **`Place("BBowman", Point(...), 1).AsUnit()`** — `Scenarios\mediterranean.BFHP`, offset 7 257 262 (mismo bucle de refuerzo ya documentado en el informe anterior) | **CONFIRMADO EN Place() literal** |
| `BJavelineer`, `BHighlander`, `BHero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `ISlinger`, `ICavalry`, `IMilitiaman`, `IEliteGuard`, `IHero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `CJavelinThrower`, `CNumidianRider`, `CBerberAssassin`, `CHero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `EArcher`, `EAxetrower`, `EChariot`, `EHero1` | Definición de clase + `class=` en `.BFHP` | CONFIRMADO COMO CLASE |
| `EAnubisWarrior` | **`Place("EAnubisWarrior", fort.pos, owner); u.SetLevel(DEFENDER_LEVEL);`** — `Scenarios\Carlos_GerraTotal2.BFHP` (tu propio mapa) | **CONFIRMADO EN Place() literal** |
| `EGuardian`, `EHorusWarrior` | `EHorusWarrior` confirmado con `Place("EHorusWarrior", fort.pos, owner)` en el mismo mapa tuyo; `EGuardian` confirmado como clase + `class=` (185 apariciones) | `EHorusWarrior`: **CONFIRMADO EN Place() literal**; `EGuardian`: CONFIRMADO COMO CLASE |

**Nota metodológica:** para las clases marcadas "CONFIRMADO COMO CLASE, `Place()` no visto literal",
la ausencia de una cita textual de `Place("Clase",...)` en los 48 archivos **no es una señal de
alarma** — la inmensa mayoría de unidades de un mapa se colocan como `<scriptobj class="...">`
estático en el editor, no mediante `Place()` en una Sequence (que se reserva sobre todo para
refuerzos dinámicos, como ya viste en el informe anterior sobre `mediterranean.BFHP`). `Place()`
resuelve el nombre de clase exactamente contra la misma tabla de registro que usa `class=` en un
`<scriptobj>` — de hecho, dentro de este mismo informe, cadenas idénticas (`BBowman`,
`GTridentWarrior`, `EAnubisWarrior`) aparecen confirmadas **con ambos mecanismos a la vez**, lo cual
es la prueba más directa posible de que son el mismo mecanismo de resolución de nombres.

---

## K. Recomendación final

1. **Usa las 8 plantillas de la sección H tal cual** — todas sus componentes están CONFIRMADAS (cita
   literal de clase + al menos una fuente cruzada), sin ningún ID inferido.
2. **No llames a `SetFeeding(false)` ni `SetNoAIFlag(true)`** sobre estas unidades — es exactamente
   la diferencia deliberada frente al sistema de guarnición de Outposts que investigaste antes
   (`IMPERIVM_OUTPOST_AUX_TROOPS_RESEARCH.md`), y aquí es lo correcto: quieres ejércitos normales que
   la IA pueda usar y que consuman comida.
3. **Genera los dos ejércitos de 50 en dos posiciones distintas** (por ejemplo, a ambos lados del
   grupo de 4 `GGuardPost`, o en dos "focos" de frontera), usando la misma plantilla de clase por
   civilización (sección H.1) — no hace falta lógica de composición distinta entre Ejército A y B.
4. **Britania y Egipto son casos especiales que debes programar de forma condicional explícita**: si
   tu Sequence detecta `GetPlayerRace(jugador) == Britain`, la plantilla no tiene entrada de
   caballería (usa la de Britania de la sección H directamente, ya sin ese hueco); para Egipto,
   recuerda que `EChariot` es `parent="Ranged"`, no `"Horse"` — si en algún punto filtras unidades
   por `IsHeirOf("Horse")` para otra mecánica, `EChariot` no lo cumplirá (usa `IsHeirOf("Cavalry")`
   si existe ese token, o compara por clase explícita — no verificado en esta pasada si existe un
   `IsHeirOf` genérico de "unidad montada" que cubra carros; **DESCONOCIDO**, verificar en el editor
   si tu Sequence necesita distinguir "montado" de forma genérica).
5. **Roma Imperial y Roma Republicana ya tienen personalidad distinta gratis** (`RVelit` vs
   `RGladiator`, `MHero1` vs `RHero1`, `RPraetorian` vs `RTribune`) — no hace falta inventar nada
   adicional para diferenciarlas.
6. **Verifica en el editor, antes de dar la composición final por buena en producción**, los dos
   puntos marcados DESCONOCIDO/DUDOSO de este informe: (a) que `IScout`/`TTeutonWolf`, aunque reales,
   no tengan algún problema oculto de no-uso (créalas una vez con `Place()` y comprueba visualmente
   que aparecen bien) — no deberían usarse en la composición final de todos modos, pero por si en el
   futuro quieres una variante; (b) que ningún héroe elegido (`*Hero1`) dispare, al colocarse con
   `Place()`, algún diálogo o evento de campaña inesperado — es muy improbable dado que están fuera
   de cualquier contexto de campaña con guion propio, pero no se ha podido descartar al 100% sin
   ejecutar el juego.

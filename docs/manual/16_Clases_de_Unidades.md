# 16. Referencia de clases y unidades

## Outposts

| ID | Referencia |
|---|---|
| `TOutpost` | Outpost germano |
| `GOutpost` | Outpost galo |
| `BOutpost` | Outpost britano |
| `IOutpost` | Outpost íbero |
| `COutpost` | Outpost cartaginés |
| `ROutpost` | Outpost romano |
| `EOutpost` | Outpost egipcio |
| `GGuardPost` | Guard Post |

## Categorías genéricas

| ID | Referencia |
|---|---|
| `Unit` | unidad genérica |
| `Military` | unidad militar |
| `BaseMage` | clase base de unidades mágicas/héroes relacionados |
| `Sentry` | sentinela |
| `Building` | edificio |
| `Catapult` | categoría usada para catapultas/asedio |

## Roma

| ID | Unidad |
|---|---|
| `RHastatus` | Hastatus |
| `RArcher` | Archer |
| `RVelit` | Velit |
| `RGladiator` | Gladiator |
| `RPraetorian` | Praetorian |
| `RTribune` | Tribune |
| `RScout` | Scout |
| `RLiberatus` | Liberati |
| `MHero1` | héroe romano imperial |
| `RHero1` | héroe romano republicano |

## Germania

| ID | Unidad |
|---|---|
| `TMaceman` | Maceman |
| `THuntress` | Huntress |
| `TArcher` | Archer |
| `TTeutonRider` | Teuton Rider |
| `TValkyrie` | Valkyrie |
| `THero1` | héroe germano |

## Galia

| ID | Unidad |
|---|---|
| `GWomanWarrior` | Woman Warrior |
| `GAxeman` | Axeman |
| `GArcher` | Archer |
| `GHorseman` | Horseman |
| `GTridentWarrior` | Trident Warrior / Fand |
| `GHero1` | héroe galo |

## Britania

| ID | Unidad |
|---|---|
| `BBronzeSpearman` | Bronze Spearman |
| `BHighlander` | Highlander |
| `BBowman` | Bowman |
| `BJavelineer` | Javelineer |
| `BHero1` | héroe britano |

No se encontró una clase de caballería britana en la investigación del roster utilizada para los ejércitos de recompensa.

## Iberia

| ID | Unidad |
|---|---|
| `IDefender` | Defender |
| `IEliteGuard` | Elite Guard |
| `ISlinger` | Slinger |
| `IMilitiaman` | Militiaman |
| `ICavalry` | Cavalry |
| `IHero1` | héroe íbero |

## Cartago

| ID | Unidad |
|---|---|
| `CLibyanFootman` | Libyan Footman |
| `CJavelinThrower` | Numidian Javelin Thrower |
| `CBerberAssassin` | Berber Assassin |
| `CNoble` | Noble |
| `CNumidianRider` | Numidian Rider |
| `CMacemen` | guerrero con maza usado por el Outpost |
| `CHero1` | héroe cartaginés |

## Egipto

| ID | Unidad |
|---|---|
| `EGuardian` | Guardian |
| `EArcher` | Archer |
| `EAxetrower` | Axe Thrower |
| `EAnubisWarrior` | Anubis Warrior |
| `EHorusWarrior` | Horus Warrior |
| `EChariot` | Chariot |
| `EHero1` | héroe egipcio |

`EChariot` funciona como unidad móvil equivalente a caballería, aunque su clase base investigada no sea `Horse`.

## Sentinelas de Guard Post

El script nativo construye la clase mediante un prefijo de raza:

```text
<PrefijoRaza>GuardPostSentry
```

Ejemplo:

```text
GGuardPostSentry
```

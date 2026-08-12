# 15. Referencia de funciones y métodos

Esta tabla recopila las funciones y métodos empleados o encontrados durante la investigación.

| Nombre | Receptor/ámbito | Uso |
|---|---|---|
| `Sleep(ms)` | global | pausa la ejecución de la Sequence |
| `Place(class,pos,player)` | global | crea un objeto/unidad |
| `ClassPlayerObjs(class,player)` | global | obtiene objetos de una clase y jugador |
| `EnemyObjs(player,class)` | global | consulta objetos enemigos |
| `ObjsInRange(obj,class,range)` | global | consulta objetos dentro de un radio |
| `Intersect(a,b)` | global/Query | intersección de consultas |
| `Union(a,b)` | global/Query | unión de consultas |
| `Subtract(a,b)` | global/Query | resta de consultas |
| `Group(name)` | global | accede a un Group |
| `EnvReadInt(obj,key)` | global | lee estado entero persistente |
| `EnvWriteInt(obj,key,value)` | global | escribe estado entero persistente |
| `GetPlayerRace(player)` | global | obtiene la raza asociada al jugador |
| `GetRaceStrPref(race)` | global | obtiene prefijo de raza utilizado por scripts nativos |
| `AsUnit()` | `Obj` | convierte referencia a `Unit` |
| `AsBuilding()` | `Obj` | convierte referencia a `Building` |
| `IsHeirOf(class)` | `Obj` | comprueba herencia de clase |
| `AddToGroup(name)` | `Obj` | añade objeto a grupo |
| `RemoveFromGroup(name)` | `Obj` | elimina objeto de grupo |
| `RemoveFromAllGroups()` | `Obj` | elimina objeto de todos sus grupos |
| `SetPlayer(player)` | `Obj`/`Unit`/`Building` | cambia propietario |
| `SetHealth(value)` | `Obj`/`Unit` | modifica salud |
| `Damage(value)` | `Obj`/`Unit` | aplica daño |
| `SetLevel(level)` | `Unit` | fija nivel |
| `SetFood(value)` | `Unit` | fija comida |
| `SetFeeding(bool)` | `Unit` | activa/desactiva alimentación |
| `SetNoAIFlag(bool)` | `Unit` | excluye/incluye de gestión estratégica de IA |
| `SetCommand(cmd,arg)` | `Unit` | asigna orden |
| `GetCommanded()` | `Unit` | detecta estado de orden/intervención usado en scripts |
| `InHolder()` | `Unit` | indica si está dentro de un holder |
| `DistTo(obj)` | `Obj`/`Building` | distancia entre objetos |
| `Units()` | `Settlement` | lista de unidades contenidas |
| `UnitsCount()` | `Settlement` | número de unidades contenidas |
| `ForceAddUnit(unit)` | `Settlement` | fuerza incorporación de una unidad |
| `SetLoyalty(value)` | `Settlement` | modifica lealtad |
| `AllowCapture(bool)` | `Settlement` | habilita/deshabilita captura |
| `AddMaxSentries(n)` | `Settlement` | modifica capacidad de sentinelas del sistema de murallas |
| `AddSentries(n)` | `Settlement` | añade sentinelas en sistema compatible |
| `GetObjList()` | `Query`/`Group` | convierte resultado en `ObjList` |
| `Clear()` | `ObjList` | vacía lista |
| `ClearDead()` | `ObjList` | elimina referencias muertas |
| `Add(obj)` | `ObjList` | añade objeto |
| `AddList(list)` | `ObjList` | añade otra lista |
| `Contains(obj)` | `ObjList` | comprueba pertenencia |

## Comandos de `SetCommand` documentados

| Comando | Uso observado |
|---|---|
| `"advance"` | avanzar hacia un punto combatiendo |
| `"move"` | desplazamiento |
| `"attack"` | ataque a objetivo |
| `"enter_tent"` | entrar en holder/edificio |

La referencia debe ampliarse únicamente con nombres encontrados en archivos reales o verificados en el editor.

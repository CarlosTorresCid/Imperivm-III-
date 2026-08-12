# 4. Obj, Unit, Building y Settlement

## `Obj`

Tipo genérico usado por listas y consultas.

Propiedades/métodos comunes observados:

```cpp
obj.player
obj.pos
obj.IsHeirOf("...")
obj.AddToGroup("...")
obj.RemoveFromGroup("...")
```

## `Unit`

Conversión:

```cpp
Unit u;
u = obj.AsUnit();
```

Operaciones utilizadas:

```cpp
u.SetLevel(20);
u.SetFood(20);
u.SetFeeding(false);
u.SetNoAIFlag(true);
u.SetCommand("move", point);
u.SetCommand("advance", point);
u.SetCommand("enter_tent", building);
u.SetPlayer(player);
u.InHolder();
u.GetCommanded();
```

## `Building`

Conversión:

```cpp
Building fort;
fort = obj.AsBuilding();
```

Datos usados:

```cpp
fort.player
fort.pos
fort.range
fort.settlement
fort.DistTo(unit)
fort.SetPlayer(player)
```

## `Settlement`

Los Outposts disponen de un Settlement asociado.

Operaciones importantes:

```cpp
fort.settlement.Units()
fort.settlement.UnitsCount()
fort.settlement.ForceAddUnit(u)
fort.settlement.SetLoyalty(100)
fort.settlement.AllowCapture(false)
```

`GGuardPost` es una excepción importante porque su clase fija `max_units="0"`, de modo que no debe tratarse como almacén de tropas normal.

# 3. Objetos, clases y herencia

Las entidades del juego se organizan por clases.

Ejemplos:

```text
Unit
Military
Building
Outpost
GOutpost
TOutpost
GGuardPost
```

## `IsHeirOf`

Permite comprobar herencia:

```cpp
if (fort.IsHeirOf("EOutpost"))
{
    // lógica egipcia
}
```

También es útil para clasificar unidades:

```cpp
if (obj.IsHeirOf("Military"))
{
    // unidad militar
}
```

## Conversión de tipo

Un `ObjList` contiene `Obj`.

Según el uso puede ser necesario convertir:

```cpp
Building fort;
fort = objects[i].AsBuilding();
```

o:

```cpp
Unit u;
u = objects[i].AsUnit();
```

## Clases de Outpost usadas

```text
TOutpost  Germania
GOutpost  Galia
BOutpost  Britania
IOutpost  Iberia
COutpost  Cartago
ROutpost  Roma
EOutpost  Egipto
GGuardPost Guard Post especial
```

`GGuardPost` también hereda de `Outpost`, pero sustituye parte importante del comportamiento normal mediante propiedades y scripts propios.

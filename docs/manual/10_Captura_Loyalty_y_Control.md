# 10. Captura, loyalty y control territorial

## `SetLoyalty`

Ejemplo:

```cpp
fort.settlement.SetLoyalty(100);
```

Se utiliza para estabilizar el Settlement cuando la Sequence controla explícitamente el cambio de propietario.

## `SetPlayer`

```cpp
fort.SetPlayer(newOwner);
```

Permite transferir un edificio desde script.

## `AllowCapture`

En Settlements compatibles:

```cpp
fort.settlement.AllowCapture(false);
```

o:

```cpp
fort.settlement.AllowCapture(true);
```

## Posición disputada

El sistema de fortalezas distingue entre destruir la guarnición y controlar el terreno.

Se detectan tropas propias:

```cpp
qFriends =
    Intersect(
        qRange,
        Union(
            ClassPlayerObjs("Military", queryOwner),
            ClassPlayerObjs("BaseMage", queryOwner)
        )
    );
```

Captura:

```cpp
if (
    garrison.count == 0
    &&
    enemies.count > 0
    &&
    friends.count == 0
)
{
    // transferencia
}
```

Esto permite que un ejército de campaña continúe defendiendo un Outpost aunque la guarnición especial haya sido aniquilada.

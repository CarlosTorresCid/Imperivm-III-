# 2. Editor: Sequences y Groups

## Crear una Sequence

En el árbol del editor:

```text
Scenario
└── Map
    └── Sequences
```

1. Crear una nueva Sequence.
2. Asignar un nombre.
3. Abrir `Source`.
4. Pegar el código.
5. Activar `Autorun allowed` si debe ejecutarse automáticamente.
6. Pulsar `Compile`.
7. Guardar el escenario.

## Errores de compilación

El editor muestra en la parte inferior el primer error encontrado.

Es importante distinguir entre el tipo estático de una expresión y el tipo real del objeto.

Ejemplo:

```cpp
ObjList units;
units = fort.settlement.Units();
```

`units[j]` es un `Obj`.

Para llamar a un método específico de `Unit`:

```cpp
units[j].AsUnit().InHolder()
```

## Crear un Group

En:

```text
Scenario
└── Map
    └── Groups
```

un Group permite reunir objetos del mapa bajo un nombre.

Acceso:

```cpp
ObjList objects;

objects =
    Group("MiGrupo")
    .GetObjList();
```

## Groups dinámicos

Un objeto puede añadirse a un grupo desde código:

```cpp
u.AddToGroup("MiGrupoDinamico");
```

El grupo puede recuperarse más tarde:

```cpp
Group("MiGrupoDinamico").GetObjList();
```

Esto permite identificar guarniciones, auxiliares o estados sin crear manualmente cientos de Groups.

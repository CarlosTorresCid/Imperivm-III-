# 1. Introducción a CKS/VS

Imperivm III utiliza scripts `.vs`/CKS para definir comportamientos de unidades, edificios, escenarios y Sequences.

En el editor de escenarios, una Sequence permite ejecutar lógica programada sobre objetos del mapa.

Ejemplo mínimo:

```cpp
while (1)
{
    Sleep(1000);
}
```

La sintaxis recuerda a C/C++, pero no debe asumirse que sea C++ completo. CKS dispone de sus propios tipos, funciones, métodos y restricciones.

## Principio de trabajo

En este proyecto se considera una función o patrón fiable cuando existe al menos una de estas evidencias:

- compilación y prueba directa en el editor;
- uso literal en una Sequence real;
- uso literal en un script nativo `.vs`;
- definición recuperada de los datos del juego.

## Estructura típica

```cpp
ObjList objects;
Building building;
Unit unit;
int i;

objects = ClassPlayerObjs("TOutpost", 15).GetObjList();

for (i = 0; i < objects.count; i += 1)
{
    building = objects[i].AsBuilding();
}
```

## Scripts nativos y Sequences

No son exactamente el mismo contexto.

Una llamada observada en un script nativo demuestra que forma parte del lenguaje/sistema, pero no siempre garantiza que sea invocable de la misma forma desde una Sequence.

Por ello la documentación separa, cuando es necesario:

- uso confirmado en Sequence;
- uso confirmado en scripts nativos;
- comportamiento inferido a partir de archivos de clase.

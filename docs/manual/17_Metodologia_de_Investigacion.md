# 17. Metodología de investigación

La documentación no se construyó únicamente a partir de prueba y error en el editor.

Se combinaron varias fuentes.

## 1. Inspección de `Packs\data.pak`

Se buscaron definiciones de clases y fragmentos de scripts.

Elementos de interés:

```xml
<class id="...">
<properties ...>
<behavior script="...">
<method ...>
```

Esto permite conocer:

- herencia;
- `cpp_class`;
- `entity`;
- propiedades;
- scripts de comportamiento;
- nombres técnicos de unidades;
- relaciones entre edificios y sistemas internos.

## 2. Inspección de mapas `.BFHP`

Se buscaron cadenas literales dentro de escenarios reales.

Ejemplos:

```text
Place(
SetCommand(
ClassPlayerObjs(
AllowCapture(
AddMaxSentries(
EnvReadInt(
EnvWriteInt(
```

El objetivo es comprobar si una función aparece dentro de una Sequence real.

## 3. Comparación de mapas

Se revisaron:

- escenarios;
- aventuras;
- conquistas;
- mapas comunitarios disponibles;
- el escenario en desarrollo.

La repetición de un patrón en distintos BFHP permite aumentar la confianza en su uso.

## 4. Pruebas en editor

Las funciones más importantes se verificaron compilando y probando pequeñas Sequences.

Ejemplos ya empleados en el proyecto:

```cpp
Place(...)
SetFeeding(false)
SetPlayer(...)
SetNoAIFlag(true)
ForceAddUnit(...)
SetCommand(...)
```

## 5. Investigación de scripts nativos

El análisis de `GGuardPost_Sentries.vs` permitió reconstruir el funcionamiento interno del Guard Post:

- 12 sentinelas;
- posiciones fijas;
- regeneración;
- nivel progresivo;
- sustitución al cambiar de propietario.

## 6. Diferenciar evidencia

Una función puede aparecer:

1. en un inventario de nombres;
2. en un script nativo;
3. en una Sequence real;
4. en una prueba directa.

Estas evidencias no son equivalentes.

Para construir código de producción se priorizan:

```text
prueba directa
    ↓
Sequence real
    ↓
script nativo
    ↓
definición/inventario
```

## 7. Búsqueda de nombres técnicos de unidades

Para identificar strings válidos de `Place()` se cruzaron:

- `class id`;
- `display_name`;
- `entity`;
- apariciones `class="..."` en BFHP;
- tablas de IA;
- llamadas literales a `Place()` cuando estaban disponibles.

Este método permitió evitar depender de nombres visibles o traducciones.

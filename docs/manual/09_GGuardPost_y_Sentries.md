# 9. `GGuardPost` y sentinelas

## Definición

La clase recuperada de `data.pak` muestra:

```xml
<class id="GGuardPost" cpp_class="CVXOutpost" parent="Outpost">
```

y propiedades relevantes:

```text
max_units = 0
range = 1000
```

Además utiliza:

```text
data/subai/GGuardPost_Sentries.vs
```

## Sistema propio de 12 sentinelas

El script mantiene:

```text
s0 ... s11
```

con posiciones relativas fijas alrededor del edificio.

Cada sentinela se crea mediante una clase de la forma:

```text
<raza>GuardPostSentry
```

## Regeneración

Si un sentinela deja de ser válido, el script lo vuelve a crear en el siguiente ciclo.

## Cambio de propietario

El script detecta que:

```text
.player() != pNumber
```

y elimina los sentinelas anteriores antes de crear nuevos para el propietario actual.

## Nivel

El script utiliza:

```text
sentriesLevel
```

almacenado con `EnvReadInt`/`EnvWriteInt` y aumenta progresivamente el nivel hasta un máximo observado de 36.

## Diferencia frente al sistema de muros

`GGuardPost` no usa el mismo mecanismo que `AddMaxSentries()` de puertas/murallas.

Sus 12 posiciones están codificadas directamente en su comportamiento propio.

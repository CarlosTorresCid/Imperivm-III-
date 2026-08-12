# 13. Limitaciones estratégicas observadas

Este capítulo recoge limitaciones funcionales que motivaron el desarrollo del proyecto.

## Fortalezas

En mapas grandes, la lógica original ofrece una utilización limitada de los Outposts como red defensiva territorial:

- gestión defensiva poco persistente;
- reducido aprovechamiento estratégico por parte de la IA;
- falta de una lógica avanzada de posición disputada;
- poca coordinación entre tropas almacenadas y defensa del edificio.

Las Sequences del proyecto amplían estos comportamientos sin modificar el ejecutable.

## Agua y navegación

El mapa puede contener:

- grandes masas de agua;
- puertos;
- barcos;
- zonas aptas para transporte naval.

Sin embargo, durante el diseño se ha observado una utilización estratégica muy limitada de estos sistemas por la IA, especialmente comparada con el movimiento terrestre.

Esto restringe el valor práctico de:

- rutas marítimas;
- desembarcos;
- puertos como nodos estratégicos;
- transporte militar por mar.

## `GGuardPost`

Su diseño nativo limita el almacenamiento:

```text
max_units = 0
```

pero ofrece un comportamiento defensivo propio mediante 12 sentinelas.

El proyecto aprovecha esta característica para darle un papel diferenciado como puesto fronterizo.

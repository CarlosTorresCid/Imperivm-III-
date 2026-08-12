# Imperivm III — Guerra Total: scripting y documentación técnica

Este repositorio reúne las **Sequences desarrolladas para ampliar el comportamiento estratégico de Imperivm III / Imperivm: Great Battles of Rome HD** y un manual técnico de referencia sobre el scripting CKS/VS del juego.

El objetivo no es sustituir el juego base, sino aprovechar su editor y su sistema de scripting para cubrir comportamientos que, en mapas grandes, resultan poco explotados por la lógica original.

## Motivación

Durante el desarrollo y las pruebas del escenario se observaron varias limitaciones prácticas del comportamiento del juego:

### Fortalezas y Outposts poco aprovechados

Los Outposts culturales existen y tienen comportamientos propios, pero el juego base no los explota como una red defensiva territorial persistente. En un mapa grande se echaban en falta, entre otras cosas:

- guarniciones persistentes ligadas a cada fortaleza;
- regeneración controlada de defensores;
- defensa automática coherente;
- una lógica de captura que tenga en cuenta si aún quedan tropas del propietario defendiendo la zona;
- diferenciación cultural mantenida después de sucesivas conquistas;
- mayor utilidad de las tropas que el jugador guarda voluntariamente dentro del Outpost.

El proyecto introduce varias Sequences para convertir esas estructuras en posiciones militares más relevantes.

### Escaso aprovechamiento estratégico del agua

Imperivm III dispone de agua, puertos y unidades navales, pero en el escenario se ha encontrado una utilización estratégica muy limitada por parte de la IA:

- poco o nulo aprovechamiento de rutas marítimas;
- ausencia de una gestión naval comparable a la terrestre;
- dificultad para conseguir desembarcos y transportes navales dinámicos;
- puertos y grandes masas de agua con menor importancia estratégica de la esperada.

Este repositorio documenta este problema como una línea de investigación del motor, aunque las cuatro Sequences actuales se centran en defensa terrestre y control territorial.

### Descubrimiento de `GGuardPost`

Durante la investigación apareció una estructura poco habitual: `GGuardPost` (`Guard Post`).

A nivel de motor hereda de `Outpost`, pero tiene un comportamiento específico:

- `max_units="0"`: no admite tropas almacenadas;
- utiliza un script propio, `GGuardPost_Sentries.vs`;
- mantiene 12 posiciones fijas de sentinela;
- los sentinelas se regeneran automáticamente;
- al cambiar de dueño, los sentinelas antiguos son eliminados y se crean nuevos de la raza del nuevo propietario.

En lugar de tratar esta limitación como un problema, se aprovechó para convertir el Guard Post en una estructura defensiva distinta de los Outposts culturales.

---

# Las cuatro Sequences

## 1. `Fortresses_Main`

Sistema universal para los Outposts culturales:

- `TOutpost`
- `GOutpost`
- `BOutpost`
- `IOutpost`
- `COutpost`
- `ROutpost`
- `EOutpost`

Funciones principales:

- detecta automáticamente todos los Outposts del mapa;
- mantiene una guarnición propia por cultura;
- las tropas de la guarnición no consumen comida;
- la IA estratégica no puede llevárselas;
- salen a defender cuando hay enemigos;
- regresan al Outpost cuando termina el peligro;
- regeneran bajas en paz;
- la cultura del edificio determina siempre el tipo de guarnición;
- el `EOutpost` usa una lógica especial para bloquear su captura nativa por proximidad;
- el `COutpost` elimina el bonus inicial de aldeanos en la primera conquista;
- incorpora el estado de **posición disputada**: destruir la guarnición no basta para conquistar el fortín si todavía quedan tropas militares del propietario dentro de su radio.

## 2. `GuardPosts_Main`

Amplía `GGuardPost` sin sustituir sus 12 sentinelas nativos.

Añade una escolta terrestre de 10 unidades:

- 5 de un tipo;
- 5 de un segundo tipo;
- composición distinta según la civilización propietaria.

La escolta:

- no consume comida;
- no puede ser utilizada como ejército estratégico;
- sale a defender;
- regresa al puesto;
- regenera bajas;
- condiciona la captura del Guard Post.

Los 12 sentinelas nativos continúan siendo gestionados por `GGuardPost_Sentries.vs`.

## 3. `OutpostAuxDefense_Main`

Convierte las tropas normales almacenadas por el jugador dentro de un Outpost en una **reserva defensiva temporal**.

En paz:

- el script no las toca;
- el jugador puede introducirlas y retirarlas libremente.

Cuando aparece un enemigo:

- se leen las unidades dentro del Settlement;
- se seleccionan únicamente unidades militares del propietario;
- se excluye la guarnición oficial de `Fortresses_Main`;
- reciben una orden inicial para salir a defender.

Durante el combate no se reescriben sus órdenes continuamente. El jugador puede retirarlas.

Cuando termina el peligro:

- se espera un periodo de seguridad;
- las auxiliares supervivientes reciben una orden de regreso;
- después dejan de estar bajo control del script.

## 4. `GuardPostsFrontierReward_Main`

Crea un objetivo estratégico regional.

Si un mismo jugador controla los cuatro Guard Post definidos en el grupo:

```text
GalGermanFrontier_GuardPosts
```

recibe:

- dos ejércitos;
- 50 unidades por ejército;
- 100 unidades en total;
- composición adaptada a su civilización;
- un héroe por ejército.

La recompensa solo se entrega una vez por jugador durante la partida.

Las tropas son unidades normales: comen, pueden ser utilizadas por la IA y no quedan ligadas a una fortaleza.

---

# Instalación de una Sequence

1. Abre el escenario en el editor.
2. En el árbol izquierdo entra en:
   `Scenario → Map → Sequences`.
3. Crea una nueva Sequence.
4. Ponle el nombre indicado por el archivo `.vs`.
5. Abre la pestaña **Source**.
6. Pega el contenido del archivo.
7. Activa **Autorun allowed** cuando corresponda.
8. Pulsa **Compile**.
9. Corrige cualquier error de compilación.
10. Guarda el escenario.

Ejemplo mínimo:

```cpp
while (1)
{
    Sleep(1000);
}
```

# Creación de un Group

Los Groups permiten reunir objetos del mapa bajo un mismo nombre.

En el editor:

1. `Scenario → Map → Groups`.
2. Crea un nuevo Group.
3. Asigna un nombre.
4. Añade los objetos deseados.

Ejemplo de uso desde una Sequence:

```cpp
ObjList posts;

posts =
    Group(
        "GalGermanFrontier_GuardPosts"
    )
    .GetObjList();
```

También pueden utilizarse grupos dinámicos desde código:

```cpp
u.AddToGroup("MiGrupo");
```

y recuperarse posteriormente con:

```cpp
Group("MiGrupo").GetObjList();
```

---

# Documentación

- [`docs/sequences/`](docs/sequences/) — explicación detallada de las cuatro Sequences.
- [`docs/manual/MANUAL_COMPLETO.md`](docs/manual/MANUAL_COMPLETO.md) — manual técnico unificado.
- [`docs/manual/`](docs/manual/) — manual dividido por capítulos.
- [`docs/research/`](docs/research/) — informes de investigación originales.
- [`examples/`](examples/) — ejemplos pequeños y reutilizables.

# Código

Los archivos `.vs` listos para copiar al editor se encuentran en:

```text
sequences/
```

# Metodología

La documentación se ha construido combinando:

- pruebas directas en el editor;
- inspección de `Packs\data.pak`;
- recuperación de definiciones XML y scripts `.vs`;
- búsqueda de Sequences en mapas `.BFHP`;
- comparación con escenarios oficiales y comunitarios;
- comprobación de clases, propiedades, comandos y funciones mediante compilación y ejecución.

El capítulo de metodología del manual explica este proceso con más detalle.

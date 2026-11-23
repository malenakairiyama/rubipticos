# Convenciones del proyecto

## Stack
- Rails 8.1+, SQLite, Hotwire (Turbo/Stimulus). Sin frameworks JS externos.

## Arquitectura
- La lógica de negocio va en `app/services`. Los controladores quedan delgados.
- El diseño de la BD está en `docs/diseno-base-de-datos.md` y es la fuente de verdad.

## Base de datos
- Validar dos veces: cada CHECK de la migración tiene su validación en el modelo.
- Nombres de tablas y columnas en inglés. Nunca una columna llamada `type`.
- No se usa `default_scope`; se usan scopes explícitos.
- Una migración que ya está en `main` no se edita: los cambios van en una migración nueva.

## Fechas
- Zona horaria America/Argentina/Buenos_Aires.
- Los días y semanas se calculan en Ruby. Nunca `date('now')` de SQLite, que es UTC.

## Seguridad
- La respuesta y la explicación de un críptico nunca llegan al navegador antes de que termine la partida.
- El tiempo y los puntos se calculan siempre en el servidor.
- Los permisos del admin se controlan en cada controlador, no ocultando links.

## Forma de trabajo
- Antes de implementar algo nuevo, se propone el diseño y lo valida el equipo.
- Cada decisión nueva se registra en el diseño (D11, D12…) y se avisa en Discord.
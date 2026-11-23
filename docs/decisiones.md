# Registro de decisiones

> Las decisiones D1 a D12 están en `docs/diseno-base-de-datos.md` (§0. Decisiones tomadas).
> Desde D13, cada decisión nueva se registra acá con el número siguiente y se avisa en Discord.

| # | Fecha | Tema | Decisión | Motivo |
|---|---|---|---|---|
| D13 | 2026-11-23 | Assets | Bootstrap compilado servido con Propshaft, sin Node | Simplificar la instalación del equipo y la corrección |
| D14 | 2026-11-23 | Panel admin | Por ahora cualquier usuario autenticado accede a `/admin`; los permisos por rol se definen más adelante | Tener el panel navegable sin adelantar el diseño de permisos |
| D15 | 2026-11-23 | Usuarios inactivos | Los usuarios con `active = false` no pueden iniciar sesión (mismo error que con contraseña incorrecta), sus sesiones abiertas dejan de valer y no pueden pedir ni usar un reset de contraseña | Desactivar a un usuario tiene que cortarle el acceso al instante, sin borrar su historial (D3) |

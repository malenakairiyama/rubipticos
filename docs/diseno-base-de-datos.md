# Diseño de base de datos — Juego de crípticos (TFI 2026)
 
- **Versión:** 1.0 — 19/11/2026
- **Estado:** diseño aprobado con ajustes. Las migraciones están pendientes.
- **Stack:** Rails 8.1+, SQLite, Hotwire. Lógica en `app/services`. TZ `America/Argentina/Buenos_Aires`.
- **Alcance:** grupo de 3 integrantes. **No** se implementa el críptico del día ni el módulo de estadísticas del backend.
---
 
## 0. Decisiones tomadas
 
| # | Tema | Decisión |
|---|---|---|
| D1 | Idioma | Modelos, tablas y columnas en inglés. Los valores de enums se guardan igual que en la API, en castellano |
| D2 | Enums | Respaldados por string, con clave en inglés y valor de la API. Cada uno tiene un `CHECK ... IN (...)` en SQL |
| D3 | Borrado | Nada con historial se borra. Se desactiva. Las FK quedan en `RESTRICT` |
| D4 | Racha | Solo cuenta un día con **al menos una partida resuelta**. Rendirse o fallar no suma racha |
| D5 | 5 intentos fallidos | La partida pasa a `failed`, suma 0 puntos y se revelan la respuesta y la explicación (igual que al rendirse) |
| D6 | Críptico del día | Fuera de alcance (grupo de 3). No hay `daily_eligible` ni `daily_bonus` |
| D7 | Filtro «origen» | **Supuesto a confirmar con la cátedra:** el origen se filtra por `author` (hoy todo es «Cátedra»; los crípticos propios del fork llevarían otro autor). No se agrega columna nueva |
| D8 | Listas del JSON | Columnas `json`, con `CHECK json_valid AND json_type = 'array'` |
| D9 | Reinicio del ranking | `game_settings.leaderboard_reset_at`, sin borrar partidas |
| D10 | Tipos de críptico | Los 13 tipos presentes en `cryptics.json` (ver §4.2) |
| D11 | NOT NULL explícito | NOT NULL en `attempts.status`/`difficulty`/`guesses_count`/`hints_used`/`points` y `sync_logs.status`/`rejections`, porque un `CHECK` deja pasar NULL |
| D12 | CHECKs adicionales | `CHECK IN` en `attempts.difficulty` (por D2) y `CHECK elapsed_seconds >= 0` en `attempts` |
 
---
 
## 1. DER
 
```
                         ┌──────────────┐
                         │  GameSetting │  (singleton, id = 1, sin FK)
                         └──────────────┘
 
┌──────────┐ 1      N ┌──────────┐
│   User   │──────────│ Session  │   (generador de auth de Rails 8)
│ (backend)│          └──────────┘
│          │ 1      N ┌──────────┐
│          │──────────│ SyncLog  │   user_id NULL = corrida desde db:seed
└──────────┘ (0..1)   └──────────┘
 
┌──────────┐ 1      N ┌──────────┐ N      1 ┌──────────┐
│  Player  │──────────│ Attempt  │──────────│ Cryptic  │
│ (público)│          │ (partida)│          │          │
└──────────┘          └──────────┘          └──────────┘
        UNIQUE (player_id, cryptic_id)  →  Player N:M Cryptic a través de Attempt
```
 
| Relación | Cardinalidad | Notas |
|---|---|---|
| User → SyncLog | 1:N (SyncLog → User N:0..1) | Es opcional porque el seed sincroniza sin admin |
| User → Session | 1:N | Tabla auxiliar del generador de autenticación |
| Player → Attempt | 1:N | |
| Cryptic → Attempt | 1:N | |
| Player ↔ Cryptic | N:M vía Attempt | Cada críptico se juega una sola vez por jugador |
| GameSetting | Aislada | Tiene una sola fila |
 
> `Attempt` representa la **partida completa**. Los hasta 5 intentos de respuesta son un contador (`guesses_count`) dentro de ella.
 
---
 
## 2. Convención de nombres
 
- **Inglés para modelos, tablas y columnas.** En castellano la pluralización se rompe sin avisar (`Jugador` → `jugadors`, `Configuracion` → `configuracions`) y habría que mantener `inflections.rb`.
- **Nombres reservados que se evitan:**
  - `type`: activa STI. Se usa `cryptic_type`.
  - También `hash`, `class`, `attributes`, `errors`, `format`.
- **Mapeo JSON → columna:**
| JSON | Columna |
|---|---|
| `id` | `source_id` |
| `enunciado` | `statement` |
| `enumeracion` | `enumeration` |
| `respuesta` | `answer` |
| `definiciones` | `definitions` |
| `indicadores` | `indicators` |
| `material` | `material` |
| `tipo` | `cryptic_type` |
| `dificultad` | `difficulty` |
| `ayuda` | `hint` |
| `explicacion` | `explanation` |
| `autor` | `author` |
 
---
 
## 3. Políticas de borrado y desactivación
 
| Asociación | `dependent:` | FK `on_delete` | Motivo |
|---|---|---|---|
| `User has_many :sync_logs` | `:restrict_with_error` | restrict | La auditoría conserva quién sincronizó |
| `User has_many :sessions` | `:destroy` | cascade | Una sesión no es historial. Al desactivar un usuario se le borran las sesiones |
| `Cryptic has_many :attempts` | `:restrict_with_error` | restrict | El enunciado prohíbe borrar crípticos con partidas |
| `Player has_many :attempts` | `:restrict_with_error` | restrict | El historial cuenta en el ranking aunque el jugador quede huérfano |
| `SyncLog belongs_to :user, optional: true` | — | restrict | |
 
**Desactivación de cada entidad:**
 
- **Cryptic:**
  - Campos: `active`, `deactivated_at` y `deactivated_by_sync`.
  - Si un críptico vuelve a aparecer en la fuente, la sincronización lo reactiva **solo si lo había desactivado ella misma**. Nunca pisa una desactivación manual del admin.
- **User:**
  - Campo: `active`.
  - El servicio impide que un admin se desactive a sí mismo y que se desactive el último admin activo.
- **Player:**
  - `blocked_at` para nombres ofensivos. Un jugador bloqueado no aparece en el ranking.
  - Al «empezar como otro jugador», el viejo queda en la DB sin cookie.
**Reglas generales:**
 
- **Prohibido usar `default_scope`.** Se usan scopes explícitos (`Cryptic.active`, `Player.visible`). Un default scope haría que `attempt.cryptic` devuelva `nil` para crípticos desactivados.
- **Reinicio del ranking:** solo cuentan las partidas con `finished_at > leaderboard_reset_at`. Es reversible y no destruye datos.
---
 
## 4. Tablas
 
### 4.0 Notas sobre SQLite
 
- **Tipos laxos:** SQLite acepta `'abc'` en una columna integer, así que los `CHECK` son la validación real del lado SQL. Cada `CHECK` tiene su validación AR equivalente (regla de validar dos veces).
- **Fechas:** `datetime` se guarda como texto ISO en UTC y `date` también como texto.
- **Decimales:** `decimal` no es exacto, pero alcanza para los multiplicadores.
- **Zona horaria:**
  - Los días y semanas en hora de BA se calculan en Ruby (`Time.zone.today`, `Time.zone.now.all_week`) y se pasan como rango a la consulta.
  - **Nunca usar `date('now')` de SQLite**, que es UTC. Entre las 21:00 y las 23:59 de BA el día cambiaría antes de tiempo.
- **Escrituras:** Rails 8 abre las transacciones de SQLite como `IMMEDIATE`, así que las escrituras quedan serializadas.
### 4.1 `users`
 
| Campo | Tipo | Restricciones |
|---|---|---|
| email_address | string | NOT NULL, índice único (normalizado a minúsculas) |
| password_digest | string | NOT NULL |
| role | string | NOT NULL, `CHECK IN ('admin','score_editor')` |
| active | boolean | NOT NULL, default true |
 
### 4.2 `cryptics`
 
| Campo | Tipo | Restricciones |
|---|---|---|
| source_id | string | NOT NULL, **índice único**. Es la clave de idempotencia del sync |
| statement | text | NOT NULL, `CHECK length(trim(statement)) > 0` |
| answer | string | NOT NULL, `CHECK length(trim(answer)) > 0`. Se guarda tal cual viene (con tildes) y se compara normalizada |
| enumeration | string | NOT NULL |
| definitions, indicators, material | json | NOT NULL, default `[]`, CHECK de array |
| cryptic_type | string | NOT NULL, `CHECK IN` (13 valores, tabla de abajo) |
| difficulty | string | NOT NULL, `CHECK IN ('facil','medio','avanzado')` |
| hint, explanation | text | NULL permitido |
| author | string | NULL permitido. Se usa como filtro de «origen» (D7) |
| active | boolean | NOT NULL, default true |
| deactivated_at | datetime | |
| deactivated_by_sync | boolean | NOT NULL, default false |
| source_digest | string | SHA256 del payload normalizado. Sirve para saber si cambió y contar bien los «actualizados» |
 
**Índices:**
- `[difficulty, active]`: asignar partida al azar.
- `[cryptic_type]`: filtros del admin.
- `[author]`: filtro de origen.
**Seguridad:** `answer` y `explanation` nunca viajan al cliente antes de que la partida termine. Esto vale para vistas, Turbo Streams y `to_json`.
 
**Tipos (valores reales de `cryptics.json`):**
 
| Clave enum | Valor en DB / API |
|---|---|
| hidden | `oculta` |
| anagram | `anagrama` |
| reversal | `inversion` |
| charade | `charada` |
| double_definition | `doble_definicion` |
| initials | `iniciales` |
| finals | `finales` |
| deletion | `supresion` |
| substitution | `sustitucion` |
| homophone | `homofono` |
| container | `contenedor` |
| symbols | `simbolos` |
| combined | `combinada` |
 
**Dificultades:** `easy`→`facil`, `medium`→`medio`, `hard`→`avanzado`.
 
### 4.3 `players`
 
| Campo | Tipo | Restricciones |
|---|---|---|
| name | string | NOT NULL, `CHECK length(name) BETWEEN 3 AND 20 AND name = trim(name)` |
| name_key | string | NOT NULL, **índice único**. Es `name.downcase` calculado en Ruby (Unicode) |
| token_digest | string | NOT NULL, **índice único** |
| current_streak, best_streak | integer | NOT NULL, default 0, `CHECK >= 0` |
| last_solved_on | date | Fecha en BA de la última partida resuelta (D4) |
| blocked_at | datetime | |
 
- **`name_key` en vez de `COLLATE NOCASE`:** NOCASE solo pasa a minúsculas ASCII, así que no unificaría «Ñ»/«ñ» ni vocales con tilde.
- **Token:**
  - La cookie lleva el token en crudo, `permanent.signed` y `httponly`.
  - La DB guarda solo el digest (SHA256). Si se filtra la base, nadie puede suplantar jugadores.
- **Racha cacheada:**
  - Se actualiza en la misma transacción que resuelve la partida.
  - La racha **efectiva** se evalúa al leerla: si `last_solved_on < ayer (BA)`, vale 0.
  - `best_streak` nunca baja.
### 4.4 `attempts` (partida)
 
| Campo | Tipo | Restricciones |
|---|---|---|
| player_id, cryptic_id | integer FK | NOT NULL, **único `[player_id, cryptic_id]`** |
| status | string | `CHECK IN ('assigned','in_progress','solved','given_up','failed')` |
| difficulty | string | Copia de la dificultad del críptico al crearse la partida |
| started_at | datetime | NULL hasta que el jugador presiona Jugar |
| finished_at | datetime | `CHECK finished_at IS NULL OR finished_at >= started_at` |
| guesses_count | integer | default 0, `CHECK BETWEEN 0 AND 5` |
| hints_used | integer | default 0, `CHECK BETWEEN 0 AND 4` |
| elapsed_seconds | integer | Lo calcula el servidor al cerrar la partida |
| points | integer | default 0, `CHECK (status='solved' AND points >= 10) OR (status<>'solved' AND points = 0)` |
 
**Ciclo de vida:**
 
```
assigned ──Jugar──▶ in_progress ──acierta──────────▶ solved
                         ├──────rendirse───────────▶ given_up
                         └──5.º intento fallido────▶ failed
```
 
- **La partida se crea al asignar el críptico (`assigned`).** Así recargar la página no cambia el críptico asignado.
- **Índice único parcial `[player_id] WHERE status IN ('assigned','in_progress')`:** garantiza una sola partida abierta por jugador, que retoma al volver.
- **Snapshot de `difficulty`:** si el sync cambia la dificultad de un críptico, los filtros del ranking no se alteran hacia atrás.
- **Concurrencia (doble click):**
  - Cada transición se hace con `UPDATE ... WHERE id = ? AND status = 'in_progress'`, verificando cuántas filas cambió, o con `with_lock`.
  - Los puntos, el tiempo y la racha se escriben en la misma transacción.
**Índices:**
- `[status, finished_at]`: Esta semana / Histórico.
- `[cryptic_id, status]`: estadísticas por críptico.
- `[player_id, status]`.
### 4.5 `sync_logs`
 
| Campo | Tipo | Restricciones |
|---|---|---|
| user_id | integer FK | NULL permitido (seed) |
| status | string | `CHECK IN ('success','no_changes','failed')` |
| source_url | string | NOT NULL |
| version | string | NULL si falló antes de parsear |
| created_count, updated_count, deactivated_count, rejected_count | integer | NOT NULL, default 0, `CHECK >= 0` |
| rejections | json | Array de `{source_id, reason}`, CHECK de array |
| error_message | text | |
| created_at | datetime | Fecha de la sincronización |
 
**Índice:** `[status, source_url, created_at]`.
 
**Cómo funciona la sincronización:**
 
- **«Sin cambios»:** se compara `version` **y** `source_url` contra la última sincronización exitosa. Así, cambiar a un fork que tenga la misma versión no da un falso «Sin cambios».
- **Transacción:**
  - El GET (timeout de 10 s) y el parseo van fuera de la transacción.
  - La aplicación de cambios va en una sola transacción. Si el proceso se interrumpe, no queda un catálogo a medias.
- **Concurrencia:** dos admins sincronizando a la vez quedan serializados por el lock de escritura de SQLite, y el índice único de `source_id` evita duplicados.
### 4.6 `game_settings` (singleton)
 
| Campo | Tipo | Restricciones |
|---|---|---|
| id | integer | `CHECK (id = 1)` |
| `<clave_tipo>_points` (13 columnas: `hidden_points`, `anagram_points`, …) | integer | NOT NULL, default 100, `CHECK BETWEEN 10 AND 1000` |
| easy_multiplier, medium_multiplier, hard_multiplier | decimal | NOT NULL, defaults 1/2/3, `CHECK > 0 AND <= 5` |
| source_url | string | NOT NULL |
| welcome_text | text | |
| leaderboard_reset_at | datetime | |
 
- **Trade-off de columnas explícitas vs. JSON:**
  - A favor: los rangos del enunciado se validan en SQL columna por columna.
  - En contra: un tipo nuevo requiere migración. Es aceptable porque el conjunto de tipos es cerrado.
- **Tiempos de referencia:** 60/180/300 s. Los fija el enunciado, así que van como constantes del servicio de puntaje y no en la tabla.
---
 
## 5. Hallazgos en los catálogos (impactan el sincronizador)
 
Revisados `cryptics.json` (versión `2026-11-17.1`, 42 crípticos) y `cryptics_with_errors.json`.
 
1. **`id` duplicado dentro del mismo payload.** En el catálogo con errores, `cr-101` aparece dos veces con contenidos distintos.
   - Propuesta: **rechazar todas las ocurrencias** del id duplicado («id duplicado en el catálogo»), porque no hay forma de saber cuál es la buena.
   - Si ya existía en la DB, queda como estaba: no se actualiza ni se desactiva.
2. **Campo obligatorio ausente.** `cr-104` no trae `respuesta`.
3. **Tipo y dificultad fuera de catálogo.** `cr-105` trae `palindromo` y `experto`.
4. **Enumeración que no coincide.** `cr-102` dice (6) para BANCO.
5. **Definición que no aparece en el enunciado.** `cr-107` trae «una planta».
6. **Anagrama con letras distintas.** `cr-103`: MONJA → JAMÁS.
7. **Validación de `finales` / `iniciales`.**
   - En `cr-021` el material es «álbum, casa y amor» y la respuesta MAR. Si se toma la última letra de *cada* palabra da MAYR. La ayuda aclara que la «y» solo une.
   - El validador tiene que **ignorar los conectores** (y, e, o, u, de…). Si no, rechazaría un críptico válido de la cátedra.
8. **Tildes en las respuestas.** PANTALÓN, JAMÓN y CAFÉ vienen con tilde.
   - La enumeración cuenta letras sin tildes.
   - La comparación y las validaciones normalizan quitando tildes, salvo la Ñ.
9. **Dos lecturas de «aparece textualmente».**
   - Definiciones como «Felino» o «Árbol» coinciden con mayúscula inicial, así que una comparación exacta funciona con el catálogo actual.
   - Si se necesita tolerancia, normalizar mayúsculas y minúsculas en ambos lados.
---
 
## 6. Pendientes
 
- [ ] Confirmar con la cátedra el supuesto D7 (origen = `author`).
- [ ] Aprobar el diseño de migraciones: orden, nombres y `CHECK`s exactos.
- [ ] Diseño del servicio `CrypticSynchronizer` (fases, informe, casos del §5).
- [ ] Diseño del servicio de puntaje y racha.
 
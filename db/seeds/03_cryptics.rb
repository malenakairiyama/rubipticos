# TEMPORAL: lo reemplaza el sincronizador en la H12 (el seed final usará el sincronizador).
# 6 crípticos copiados textualmente de https://ecorrons.github.io/cryptics-api/v1/cryptics.json
# (versión 2026-11-17.1). Este archivo no hace HTTP.
# source_digest queda en nil: lo calcula el sincronizador.
cryptics = [
  {
    source_id: "cr-001",
    statement: "La cama tejida esconde la infusión argentina",
    enumeration: "(4)",
    answer: "MATE",
    definitions: [ "la infusión argentina" ],
    indicators: [ "esconde" ],
    material: [ "cama tejida" ],
    cryptic_type: "oculta",
    difficulty: "facil",
    hint: "Leé de corrido el final de una palabra y el principio de la siguiente.",
    explanation: "ca[MA TE]jida esconde MATE.",
    author: "Cátedra"
  },
  {
    source_id: "cr-003",
    statement: "Amor loco da una fruta del bosque",
    enumeration: "(4)",
    answer: "MORA",
    definitions: [ "una fruta del bosque" ],
    indicators: [ "loco" ],
    material: [ "Amor" ],
    cryptic_type: "anagrama",
    difficulty: "facil",
    hint: "Reordená las letras de la primera palabra.",
    explanation: "AMOR desordenado (loco) da MORA.",
    author: "Cátedra"
  },
  {
    source_id: "cr-013",
    statement: "Mi metido en el hogar da una prenda",
    enumeration: "(6)",
    answer: "CAMISA",
    definitions: [ "una prenda" ],
    indicators: [ "metido en" ],
    material: [ "Mi", "el hogar" ],
    cryptic_type: "contenedor",
    difficulty: "medio",
    hint: "El hogar es una palabra de cuatro letras. Partila al medio y meté MI.",
    explanation: "MI dentro de CASA (el hogar): CA + MI + SA = CAMISA.",
    author: "Cátedra"
  },
  {
    source_id: "cr-015",
    statement: "Ignorante, revuelto, es nacido en este país",
    enumeration: "(9)",
    answer: "ARGENTINO",
    definitions: [ "nacido en este país" ],
    indicators: [ "revuelto" ],
    material: [ "Ignorante" ],
    cryptic_type: "anagrama",
    difficulty: "medio",
    hint: "Nueve letras para reordenar. El país es este.",
    explanation: "IGNORANTE revuelto da ARGENTINO.",
    author: "Cátedra"
  },
  {
    source_id: "cr-026",
    statement: "Calcio y hierro para el desayuno porteño",
    enumeration: "(4)",
    answer: "CAFÉ",
    definitions: [ "el desayuno porteño" ],
    indicators: [ "y" ],
    material: [ "Calcio", "hierro" ],
    cryptic_type: "simbolos",
    difficulty: "avanzado",
    hint: "Pensá en la tabla periódica.",
    explanation: "Ca (calcio) + Fe (hierro) = CAFÉ.",
    author: "Cátedra"
  },
  {
    source_id: "cr-030",
    statement: "Música cubana dentro de la fruta: individuo",
    enumeration: "(7)",
    answer: "PERSONA",
    definitions: [ "individuo" ],
    indicators: [ "dentro de" ],
    material: [ "Música cubana", "la fruta" ],
    cryptic_type: "contenedor",
    difficulty: "avanzado",
    hint: "La música cubana tiene tres letras. La fruta, cuatro.",
    explanation: "SON (música cubana) dentro de PERA (la fruta): PER + SON + A = PERSONA.",
    author: "Cátedra"
  }
]

creados = 0
cryptics.each do |attrs|
  cryptic = Cryptic.find_or_create_by!(source_id: attrs[:source_id]) do |c|
    c.assign_attributes(attrs.except(:source_id).merge(active: true, source_digest: nil))
  end
  creados += 1 if cryptic.previously_new_record?
end

puts "Crípticos: #{creados} creados, #{cryptics.size - creados} existentes"

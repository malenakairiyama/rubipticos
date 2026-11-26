# Configuración del juego (singleton id 1). Si ya existe, no se sobrescribe:
# puede haber sido editada desde el admin.
settings = GameSetting.find_or_create_by!(id: 1) do |s|
  GameSetting::POINT_COLUMNS.each { |column| s[column] = 100 }
  s.easy_multiplier = 1
  s.medium_multiplier = 2
  s.hard_multiplier = 3
  s.source_url = "https://ecorrons.github.io/cryptics-api/v1/cryptics.json"
  s.welcome_text = "¡Te damos la bienvenida a Rubípticos! Resolvé crípticos en castellano, sumá puntos y mantené tu racha jugando todos los días."
end

puts "Configuración: #{settings.previously_new_record? ? 'creada' : 'existente'}"

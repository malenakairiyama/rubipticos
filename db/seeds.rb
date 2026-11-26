# Carga en orden alfabético los archivos de db/seeds/ (01_admin, 02_game_settings,
# 03_cryptics y, más adelante, 04_dev_players) dentro de una sola transacción.
# Cada archivo imprime su propia línea; acá solo va el resumen final.
ActiveRecord::Base.transaction do
  Dir[Rails.root.join("db/seeds/*.rb")].sort.each { |file| load file }
end

por_dificultad = Cryptic.group(:difficulty).count.transform_keys { |key| Cryptic.difficulties[key] }
puts "Crípticos por dificultad: #{por_dificultad.map { |dificultad, cantidad| "#{dificultad} #{cantidad}" }.join(', ')}"

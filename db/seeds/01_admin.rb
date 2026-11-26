# Admin inicial del backend. Si ya existe, no se toca (ni contraseña, ni rol, ni estado).
if Rails.env.local? # development o test
  email = ENV.fetch("ADMIN_EMAIL", "admin@test.com")
  password = ENV.fetch("ADMIN_PASSWORD", "admin123")
else # production: si falta alguna variable, KeyError con su nombre
  email = ENV.fetch("ADMIN_EMAIL")
  password = ENV.fetch("ADMIN_PASSWORD")
end

admin = User.find_or_create_by!(email_address: email) do |user|
  user.password = password
  user.role = "admin"
  user.active = true
end

puts "Admin #{admin.email_address}: #{admin.previously_new_record? ? 'creado' : 'existente'}"

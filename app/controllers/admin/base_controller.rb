# Base del panel de administración. Exige sesión iniciada, porque no declara
# allow_unauthenticated_access. Por ahora no distingue roles (D14).
class Admin::BaseController < ApplicationController
  layout "admin"
end

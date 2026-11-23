# Pantalla de inicio pública: el juego lo usan jugadores sin cuenta.
class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
  end
end

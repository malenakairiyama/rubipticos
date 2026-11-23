require "test_helper"

class AdminLayoutTest < ActionView::TestCase
  setup { render inline: "<p>contenido</p>", layout: "layouts/admin" }

  test "se distingue del sitio público" do
    assert_select "body.admin"
    assert_select "nav.navbar.bg-dark[data-bs-theme=dark]"
    assert_select ".badge", "Admin"
    assert_select "title", "Rubípticos · Admin"
  end

  test "tiene la navegación del backend" do
    assert_select "#admin-nav.collapse" do
      %w[Crípticos Configuración Sincronización Jugadores Usuarios].each do |label|
        assert_select "a.nav-link[href='#']", text: label
      end
    end
  end

  test "cierra sesión con DELETE a la sesión del generador de auth" do
    assert_select "form[action=?][method=post]", session_path do
      assert_select "input[name=_method][value=delete]"
      assert_select "button", "Cerrar sesión"
    end
  end

  test "renderiza el contenido" do
    assert_select "main p", "contenido"
  end
end

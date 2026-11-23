require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "la pantalla de inicio es pública y usa el layout del sitio" do
    get root_path

    assert_response :success
    assert_select "html[lang=es]"
    assert_select "title", "Rubípticos"
    assert_select "h1", "Rubípticos"
  end

  test "la home pública no usa el layout admin" do
    get root_path

    assert_select "body.admin", count: 0
    assert_select ".badge", text: "Admin", count: 0
  end

  test "el navbar público colapsa y tiene los cuatro links" do
    get root_path

    assert_select "button.navbar-toggler[data-bs-target='#public-nav']"
    assert_select "#public-nav.collapse.navbar-collapse" do
      assert_select "a.nav-link", text: "Jugar"
      assert_select "a.nav-link", text: "Mi racha"
      assert_select "a.nav-link", text: "Tabla de posiciones"
      assert_select "a.nav-link[href=?]", how_to_play_path, text: "Cómo se juega"
    end
  end

  test "carga Bootstrap desde Propshaft e importmap" do
    get root_path

    assert_select "link[rel=stylesheet][href*='bootstrap.min']"
    assert_select "script[type=importmap]", /"bootstrap"/
  end
end

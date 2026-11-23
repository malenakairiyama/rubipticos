require "test_helper"

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  test "sin sesión, /admin redirige al login" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "un admin entra al panel con el layout admin" do
    sign_in_as users(:one)
    get admin_root_path

    assert_response :success
    assert_admin_home_for users(:one)
  end

  test "un score_editor también entra al panel (D14)" do
    sign_in_as users(:two)
    get admin_root_path

    assert_response :success
    assert_admin_home_for users(:two)
  end

  test "la sesión de un usuario desactivado deja de valer (D15)" do
    sign_in_as users(:one)
    users(:one).update!(active: false)

    get admin_root_path

    assert_redirected_to new_session_path
  end

  private
    def assert_admin_home_for(user)
      assert_select "body.admin"
      assert_select ".badge", "Admin"
      assert_select "a.navbar-brand[href=?]", admin_root_path
      assert_select "h1", "Panel de administración"
      assert_select "main p", /#{Regexp.escape(user.email_address)}/
    end
end

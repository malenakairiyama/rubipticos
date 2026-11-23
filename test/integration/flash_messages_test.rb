require "test_helper"

class FlashMessagesTest < ActionDispatch::IntegrationTest
  test "el alert de login fallido se muestra una sola vez, como alerta de Bootstrap" do
    post session_path, params: { email_address: "nadie@example.com", password: "incorrecta" }
    follow_redirect!

    assert_select ".alert", count: 1
    assert_select ".alert.alert-danger.alert-dismissible .btn-close[data-bs-dismiss=alert]"
  end

  test "el notice se muestra como alerta de éxito" do
    post passwords_path, params: { email_address: "nadie@example.com" }
    follow_redirect!

    assert_select ".alert", count: 1
    assert_select ".alert.alert-success"
  end
end

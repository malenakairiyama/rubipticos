require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "cómo se juega es pública" do
    get how_to_play_path

    assert_response :success
    assert_equal "/como-se-juega", how_to_play_path
    assert_select "h1", "Cómo se juega"
  end
end

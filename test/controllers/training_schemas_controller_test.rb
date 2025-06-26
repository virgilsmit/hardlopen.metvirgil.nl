require "test_helper"

class TrainingSchemasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get training_schemas_index_url
    assert_response :success
  end

  test "should get show" do
    get training_schemas_show_url
    assert_response :success
  end
end

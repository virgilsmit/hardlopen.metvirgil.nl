require "test_helper"

class ImportHistoryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get import_history_index_url
    assert_response :success
  end
end

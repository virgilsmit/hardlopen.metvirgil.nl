require "test_helper"

class Admin::LoginLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_login_logs_index_url
    assert_response :success
  end
end

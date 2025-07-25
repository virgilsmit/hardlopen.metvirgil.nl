require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @session = sessions(:one)
  end

  test "should get index" do
    get sessions_url
    assert_response :success
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session" do
    assert_difference("Session.count") do
      post sessions_url, params: { session: { description: @session.description, end_time: @session.end_time, group_id: @session.group_id, start_time: @session.start_time, title: @session.title, trainer_name: @session.trainer_name } }
    end

    assert_redirected_to session_url(Session.last)
  end

  test "should show session" do
    get session_url(@session)
    assert_response :success
  end

  test "should get edit" do
    get edit_session_url(@session)
    assert_response :success
  end

  test "should update session" do
    patch session_url(@session), params: { session: { description: @session.description, end_time: @session.end_time, group_id: @session.group_id, start_time: @session.start_time, title: @session.title, trainer_name: @session.trainer_name } }
    assert_redirected_to session_url(@session)
  end

  test "should destroy session" do
    assert_difference("Session.count", -1) do
      delete session_url(@session)
    end

    assert_redirected_to sessions_url
  end
end

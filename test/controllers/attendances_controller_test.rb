require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendance = attendances(:one)
    post login_path, params: { email: 'virgil@virgilhomemade.nl', password: 'muffel2406' }
  end

  test "should get index" do
    get attendances_url
    assert_response :success
  end

  test "should get new" do
    get new_attendance_url
    assert_response :success
  end

  test "should create attendance" do
    assert_difference("Attendance.count") do
      post attendances_url, params: { attendance: { user_id: @attendance.user_id, training_session_id: @attendance.training_session_id, status: @attendance.status } }
    end
    assert_redirected_to schema_week_path
  end

  test "should show attendance" do
    get attendance_url(@attendance)
    assert_response :success
  end

  test "should get edit" do
    get edit_attendance_url(@attendance)
    assert_response :success
  end

  test "should update attendance" do
    patch attendance_url(@attendance), params: { attendance: { user_id: @attendance.user_id, training_session_id: @attendance.training_session_id, status: @attendance.status } }
    assert_redirected_to trainings_path
  end

  test "should destroy attendance" do
    assert_difference("Attendance.count", -1) do
      delete attendance_url(@attendance)
    end

    assert_redirected_to attendances_url
  end
end

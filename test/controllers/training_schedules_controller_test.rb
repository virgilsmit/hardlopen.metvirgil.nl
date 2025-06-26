require "test_helper"

class TrainingSchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training_schedule = training_schedules(:one)
  end

  test "should get index" do
    get training_schedules_url
    assert_response :success
  end

  test "should get new" do
    get new_training_schedule_url
    assert_response :success
  end

  test "should create training_schedule" do
    assert_difference("TrainingSchedule.count") do
      post training_schedules_url, params: { training_schedule: { active: @training_schedule.active, end_time: @training_schedule.end_time, group_id: @training_schedule.group_id, location: @training_schedule.location, start_time: @training_schedule.start_time, weekday: @training_schedule.weekday } }
    end

    assert_redirected_to training_schedule_url(TrainingSchedule.last)
  end

  test "should show training_schedule" do
    get training_schedule_url(@training_schedule)
    assert_response :success
  end

  test "should get edit" do
    get edit_training_schedule_url(@training_schedule)
    assert_response :success
  end

  test "should update training_schedule" do
    patch training_schedule_url(@training_schedule), params: { training_schedule: { active: @training_schedule.active, end_time: @training_schedule.end_time, group_id: @training_schedule.group_id, location: @training_schedule.location, start_time: @training_schedule.start_time, weekday: @training_schedule.weekday } }
    assert_redirected_to training_schedule_url(@training_schedule)
  end

  test "should destroy training_schedule" do
    assert_difference("TrainingSchedule.count", -1) do
      delete training_schedule_url(@training_schedule)
    end

    assert_redirected_to training_schedules_url
  end
end

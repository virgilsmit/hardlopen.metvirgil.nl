require "application_system_test_case"

class TrainingSchedulesTest < ApplicationSystemTestCase
  setup do
    @training_schedule = training_schedules(:one)
  end

  test "visiting the index" do
    visit training_schedules_url
    assert_selector "h1", text: "Training schedules"
  end

  test "should create training schedule" do
    visit training_schedules_url
    click_on "New training schedule"

    check "Active" if @training_schedule.active
    fill_in "End time", with: @training_schedule.end_time
    fill_in "Group", with: @training_schedule.group_id
    fill_in "Location", with: @training_schedule.location
    fill_in "Start time", with: @training_schedule.start_time
    fill_in "Weekday", with: @training_schedule.weekday
    click_on "Create Training schedule"

    assert_text "Training schedule was successfully created"
    click_on "Back"
  end

  test "should update Training schedule" do
    visit training_schedule_url(@training_schedule)
    click_on "Edit this training schedule", match: :first

    check "Active" if @training_schedule.active
    fill_in "End time", with: @training_schedule.end_time
    fill_in "Group", with: @training_schedule.group_id
    fill_in "Location", with: @training_schedule.location
    fill_in "Start time", with: @training_schedule.start_time
    fill_in "Weekday", with: @training_schedule.weekday
    click_on "Update Training schedule"

    assert_text "Training schedule was successfully updated"
    click_on "Back"
  end

  test "should destroy Training schedule" do
    visit training_schedule_url(@training_schedule)
    click_on "Destroy this training schedule", match: :first

    assert_text "Training schedule was successfully destroyed"
  end
end

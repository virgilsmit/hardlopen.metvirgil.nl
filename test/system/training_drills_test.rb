require "application_system_test_case"

class TrainingDrillsTest < ApplicationSystemTestCase
  setup do
    @training_drill = training_drills(:one)
    # Ensure related objects exist or are mocked if necessary
    # @training_session = training_sessions(:one)
    # @training_drill.training_session = @training_session
    # @training_drill.save
  end

  test "visiting the index" do
    visit training_drills_url
    assert_selector "h1", text: "Training drills"
  end

  test "should create training drill" do
    visit training_drills_url
    click_on "New training drill"

    fill_in "Drill", with: @training_drill.drill_id
    # fill_in "Training session", with: @training_drill.training_session_id # Assuming you have a way to select/input this
    # If training_session_id is selected from a dropdown for an existing TrainingSession:
    # select training_sessions(:one).id, from: "Training session" 
    # Or if it's a direct input and you have a known ID:
    # fill_in "Training session", with: training_sessions(:one).id
    click_on "Create Training drill"

    assert_text "Training drill was successfully created"
    click_on "Back"
  end

  test "should update Training drill" do
    visit training_drill_url(@training_drill)
    click_on "Edit this training drill", match: :first

    fill_in "Drill", with: @training_drill.drill_id
    # fill_in "Training session", with: @training_drill.training_session_id # Adjust as per your form
    click_on "Update Training drill"

    assert_text "Training drill was successfully updated"
    click_on "Back"
  end

  test "should destroy Training drill" do
    visit training_drill_url(@training_drill)
    click_on "Destroy this training drill", match: :first

    assert_text "Training drill was successfully destroyed"
  end
end

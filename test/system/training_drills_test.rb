require "application_system_test_case"

class TrainingDrillsTest < ApplicationSystemTestCase
  setup do
    @training_drill = training_drills(:one)
  end

  test "visiting the index" do
    visit training_drills_url
    assert_selector "h1", text: "Training drills"
  end

  test "should create training drill" do
    visit training_drills_url
    click_on "New training drill"

    fill_in "Drill", with: @training_drill.drill_id
    fill_in "Training", with: @training_drill.training_id
    click_on "Create Training drill"

    assert_text "Training drill was successfully created"
    click_on "Back"
  end

  test "should update Training drill" do
    visit training_drill_url(@training_drill)
    click_on "Edit this training drill", match: :first

    fill_in "Drill", with: @training_drill.drill_id
    fill_in "Training", with: @training_drill.training_id
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

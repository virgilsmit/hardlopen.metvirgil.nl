require "application_system_test_case"

class DrillsTest < ApplicationSystemTestCase
  setup do
    @drill = drills(:one)
  end

  test "visiting the index" do
    visit drills_url
    assert_selector "h1", text: "Drills"
  end

  test "should create drill" do
    visit drills_url
    click_on "New drill"

    fill_in "Description", with: @drill.description
    fill_in "Name", with: @drill.name
    fill_in "Video url", with: @drill.video_url
    click_on "Create Drill"

    assert_text "Drill was successfully created"
    click_on "Back"
  end

  test "should update Drill" do
    visit drill_url(@drill)
    click_on "Edit this drill", match: :first

    fill_in "Description", with: @drill.description
    fill_in "Name", with: @drill.name
    fill_in "Video url", with: @drill.video_url
    click_on "Update Drill"

    assert_text "Drill was successfully updated"
    click_on "Back"
  end

  test "should destroy Drill" do
    visit drill_url(@drill)
    click_on "Destroy this drill", match: :first

    assert_text "Drill was successfully destroyed"
  end
end

require "application_system_test_case"

class PresencesTest < ApplicationSystemTestCase
  setup do
    @presence = presences(:one)
  end

  test "visiting the index" do
    visit presences_url
    assert_selector "h1", text: "Presences"
  end

  test "should create presence" do
    visit presences_url
    click_on "New presence"

    fill_in "Name", with: @presence.name
    fill_in "Session", with: @presence.session_id
    check "Status" if @presence.status
    fill_in "User", with: @presence.user_id
    click_on "Create Presence"

    assert_text "Presence was successfully created"
    click_on "Back"
  end

  test "should update Presence" do
    visit presence_url(@presence)
    click_on "Edit this presence", match: :first

    fill_in "Name", with: @presence.name
    fill_in "Session", with: @presence.session_id
    check "Status" if @presence.status
    fill_in "User", with: @presence.user_id
    click_on "Update Presence"

    assert_text "Presence was successfully updated"
    click_on "Back"
  end

  test "should destroy Presence" do
    visit presence_url(@presence)
    click_on "Destroy this presence", match: :first

    assert_text "Presence was successfully destroyed"
  end
end

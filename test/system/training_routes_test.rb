require "application_system_test_case"

class TrainingRoutesTest < ApplicationSystemTestCase
  setup do
    @training_route = training_routes(:one)
  end

  test "visiting the index" do
    visit training_routes_url
    assert_selector "h1", text: "Training routes"
  end

  test "should create training route" do
    visit training_routes_url
    click_on "New training route"

    fill_in "Route", with: @training_route.route_id
    fill_in "Training", with: @training_route.training_id
    click_on "Create Training route"

    assert_text "Training route was successfully created"
    click_on "Back"
  end

  test "should update Training route" do
    visit training_route_url(@training_route)
    click_on "Edit this training route", match: :first

    fill_in "Route", with: @training_route.route_id
    fill_in "Training", with: @training_route.training_id
    click_on "Update Training route"

    assert_text "Training route was successfully updated"
    click_on "Back"
  end

  test "should destroy Training route" do
    visit training_route_url(@training_route)
    click_on "Destroy this training route", match: :first

    assert_text "Training route was successfully destroyed"
  end
end

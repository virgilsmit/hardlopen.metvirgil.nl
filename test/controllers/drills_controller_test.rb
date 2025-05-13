require "test_helper"

class DrillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @drill = drills(:one)
  end

  test "should get index" do
    get drills_url
    assert_response :success
  end

  test "should get new" do
    get new_drill_url
    assert_response :success
  end

  test "should create drill" do
    assert_difference("Drill.count") do
      post drills_url, params: { drill: { description: @drill.description, name: @drill.name, video_url: @drill.video_url } }
    end

    assert_redirected_to drill_url(Drill.last)
  end

  test "should show drill" do
    get drill_url(@drill)
    assert_response :success
  end

  test "should get edit" do
    get edit_drill_url(@drill)
    assert_response :success
  end

  test "should update drill" do
    patch drill_url(@drill), params: { drill: { description: @drill.description, name: @drill.name, video_url: @drill.video_url } }
    assert_redirected_to drill_url(@drill)
  end

  test "should destroy drill" do
    assert_difference("Drill.count", -1) do
      delete drill_url(@drill)
    end

    assert_redirected_to drills_url
  end
end

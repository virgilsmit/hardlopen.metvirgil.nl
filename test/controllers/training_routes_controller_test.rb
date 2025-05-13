require "test_helper"

class TrainingRoutesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training_route = training_routes(:one)
  end

  test "should get index" do
    get training_routes_url
    assert_response :success
  end

  test "should get new" do
    get new_training_route_url
    assert_response :success
  end

  test "should create training_route" do
    assert_difference("TrainingRoute.count") do
      post training_routes_url, params: { training_route: { route_id: @training_route.route_id, training_id: @training_route.training_id } }
    end

    assert_redirected_to training_route_url(TrainingRoute.last)
  end

  test "should show training_route" do
    get training_route_url(@training_route)
    assert_response :success
  end

  test "should get edit" do
    get edit_training_route_url(@training_route)
    assert_response :success
  end

  test "should update training_route" do
    patch training_route_url(@training_route), params: { training_route: { route_id: @training_route.route_id, training_id: @training_route.training_id } }
    assert_redirected_to training_route_url(@training_route)
  end

  test "should destroy training_route" do
    assert_difference("TrainingRoute.count", -1) do
      delete training_route_url(@training_route)
    end

    assert_redirected_to training_routes_url
  end
end

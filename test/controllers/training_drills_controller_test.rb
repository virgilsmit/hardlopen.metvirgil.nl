require "test_helper"

class TrainingDrillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training_drill = training_drills(:one)
  end

  test "should get index" do
    get training_drills_url
    assert_response :success
  end

  test "should get new" do
    get new_training_drill_url
    assert_response :success
  end

  test "should create training_drill" do
    assert_difference("TrainingDrill.count") do
      post training_drills_url, params: { training_drill: { drill_id: @training_drill.drill_id, training_id: @training_drill.training_id } }
    end

    assert_redirected_to training_drill_url(TrainingDrill.last)
  end

  test "should show training_drill" do
    get training_drill_url(@training_drill)
    assert_response :success
  end

  test "should get edit" do
    get edit_training_drill_url(@training_drill)
    assert_response :success
  end

  test "should update training_drill" do
    patch training_drill_url(@training_drill), params: { training_drill: { drill_id: @training_drill.drill_id, training_id: @training_drill.training_id } }
    assert_redirected_to training_drill_url(@training_drill)
  end

  test "should destroy training_drill" do
    assert_difference("TrainingDrill.count", -1) do
      delete training_drill_url(@training_drill)
    end

    assert_redirected_to training_drills_url
  end
end

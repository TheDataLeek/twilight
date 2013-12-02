require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get logout" do
    get :logout
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end

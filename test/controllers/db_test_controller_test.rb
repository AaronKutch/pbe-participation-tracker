require 'test_helper'

class DbTestControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get db_test_index_url
    assert_response :success
  end

end

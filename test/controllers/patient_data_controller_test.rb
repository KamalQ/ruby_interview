require 'test_helper'

class PatientDataControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get patient_data_index_url
    assert_response :success
  end

end

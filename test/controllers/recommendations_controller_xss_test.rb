require "test_helper"

class RecommendationsControllerXssTest < ActionDispatch::IntegrationTest
  test "escapes XSS in script tags" do
    get recommendations_path, params: { vibe: "&lt;script&gt;alert('XSS')&lt;/script&gt;" }
    
    assert_response :success
    # Verify the script is escaped in the HTML response
    assert_select "input[value*='&lt;script&gt;']", true
    # Ensure no actual script tag exists
    assert_not response.body.include?("<script>alert('XSS')</script>")
  end

  test "escapes XSS in image tags" do
    get recommendations_path, params: { vibe: "&lt;img src=x onerror=alert('XSS')&gt;" }
    
    assert_response :success
    # Verify the tag is escaped
    assert_not response.body.include?("<img src=x onerror")
  end

  test "escapes javascript protocol" do
    get recommendations_path, params: { vibe: "javascript:alert('XSS')" }
    
    assert_response :success
    # Verify it's treated as text, not executed
    assert_not response.body.include?("alert('XSS')")
  end

  test "rejects excessively long input" do
    long_vibe = "a" * (MAX_VIBE_INPUT_LENGTH + 1)
    get recommendations_path, params: { vibe: long_vibe }
    
    assert_response :success
    assert_match /Invalid input.*too long/, flash[:alert]
  end

  test "handles null bytes safely" do
    get recommendations_path, params: { vibe: "test\u0000input" }
    
    assert_response :success
    assert_match /Invalid input/, flash[:alert]
  end

  test "accepts valid vibe input" do
    get recommendations_path, params: { vibe: "Happy music" }
    
    assert_response :success
    # Should not show any validation errors
    assert_not flash[:alert]&.include?("Invalid input")
  end
end

require "test_helper"

module Gemini
  class InterpreterServiceTest < ActiveSupport::TestCase
    test "validates input before processing" do
      # Should return nil for invalid input (too long)
      long_input = "a" * (MAX_VIBE_INPUT_LENGTH + 1)
      result = InterpreterService.call(long_input)
      
      assert_nil result
    end

    test "validates response structure" do
      service = InterpreterService.new("test")
      
      # Valid response
      assert service.send(:valid_response?, { 'genres' => ['pop'] })
      assert service.send(:valid_response?, { 'search_terms' => 'test' })
      assert service.send(:valid_response?, { 'genres' => ['pop'], 'search_terms' => 'test' })
      
      # Invalid responses
      assert_not service.send(:valid_response?, {})
      assert_not service.send(:valid_response?, nil)
      assert_not service.send(:valid_response?, "string")
      assert_not service.send(:valid_response?, [])
    end

    test "sanitizes input before caching" do
      # Skip if no API key (for CI/local testing without API)
      skip "No Gemini API key" unless ENV['GEMINI_API_KEY'].present?
      
      input = "  Happy   music  "
      sanitized = "Happy music"
      
      # Clear any existing cache
      VibeCache.where(prompt: [input, sanitized]).destroy_all
      
      # First call should sanitize and cache
      InterpreterService.call(input)
      
      # Check cache uses sanitized version
      cached = VibeCache.find_by(prompt: sanitized)
      assert_not_nil cached
    end

    test "returns nil for blank input" do
      assert_nil InterpreterService.call(nil)
      assert_nil InterpreterService.call("")
      assert_nil InterpreterService.call("   ")
    end

    test "handles null bytes in input" do
      result = InterpreterService.call("test\u0000input")
      assert_nil result
    end
  end
end

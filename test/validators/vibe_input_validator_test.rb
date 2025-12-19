require "test_helper"

class VibeInputValidatorTest < ActiveSupport::TestCase
  test "accepts valid inputs" do
    assert_equal "Happy upbeat music", VibeInputValidator.validate!("Happy upbeat music")
    assert_equal "Chill studying vibes 📚", VibeInputValidator.validate!("Chill studying vibes 📚")
    assert_equal "Metallica", VibeInputValidator.validate!("Metallica")
    assert_equal "90s hip-hop", VibeInputValidator.validate!("90s hip-hop")
  end

  test "strips and normalizes whitespace" do
    assert_equal "Test input", VibeInputValidator.validate!("  Test   input  ")
    assert_equal "Multiple spaces", VibeInputValidator.validate!("Multiple    spaces")
  end

  test "rejects inputs over max length" do
    long_input = "a" * (MAX_VIBE_INPUT_LENGTH + 1)
    error = assert_raises(VibeInputValidator::ValidationError) do
      VibeInputValidator.validate!(long_input)
    end
    assert_match /too long/, error.message
  end

  test "rejects inputs with null bytes" do
    error = assert_raises(VibeInputValidator::ValidationError) do
      VibeInputValidator.validate!("test\u0000input")
    end
    assert_match /Invalid characters/, error.message
  end

  test "rejects invalid UTF-8 encoding" do
    invalid_input = "test".dup.force_encoding('ASCII-8BIT')
    invalid_input += "\xFF\xFE"
    
    error = assert_raises(VibeInputValidator::ValidationError) do
      VibeInputValidator.validate!(invalid_input)
    end
    assert_match /encoding/, error.message
  end

  test "returns nil for blank input" do
    assert_nil VibeInputValidator.validate!(nil)
    assert_nil VibeInputValidator.validate!("")
    assert_nil VibeInputValidator.validate!("   ")
  end

  test "accepts emoji and special characters" do
    assert_equal "🎵 Music! 🎶", VibeInputValidator.validate!("🎵 Music! 🎶")
    assert_equal "Rock & Roll", VibeInputValidator.validate!("Rock & Roll")
    assert_equal "90's R&B", VibeInputValidator.validate!("90's R&B")
  end

  test "accepts maximum length input" do
    max_input = "a" * MAX_VIBE_INPUT_LENGTH
    result = VibeInputValidator.validate!(max_input)
    assert_equal MAX_VIBE_INPUT_LENGTH, result.length
  end
end

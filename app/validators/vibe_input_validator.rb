# Validates and sanitizes user vibe inputs to prevent malicious data
class VibeInputValidator
  class ValidationError < StandardError; end

  class << self
    def validate!(input)
      return nil if input.blank?

      input = input.to_s.strip

      # Check length
      if input.length > MAX_VIBE_INPUT_LENGTH
        raise ValidationError, "Input too long (max #{MAX_VIBE_INPUT_LENGTH} characters)"
      end

      # Check for null bytes
      if input.include?("\u0000")
        raise ValidationError, "Invalid characters detected"
      end

      # Ensure valid UTF-8 encoding
      unless input.valid_encoding?
        raise ValidationError, "Invalid character encoding"
      end

      # Check for valid characters (allow emoji, punctuation, letters, numbers)
      # This is permissive to allow creative inputs
      unless input.match?(VIBE_INPUT_PATTERN)
        raise ValidationError, "Input contains unsupported characters"
      end

      # Return sanitized input
      sanitize(input)
    end

    private

    def sanitize(input)
      # Strip leading/trailing whitespace
      # Normalize multiple spaces to single space
      input.strip.gsub(/\s+/, ' ')
    end
  end
end

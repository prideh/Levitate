# Security Configuration

# Maximum allowed length for user vibe inputs
MAX_VIBE_INPUT_LENGTH = 500

# Allowed character pattern for vibe inputs
# Allows: letters (all languages), numbers, spaces, common punctuation, emoji
VIBE_INPUT_PATTERN = /\A[\p{L}\p{N}\p{P}\p{Zs}\p{Emoji}\s]+\z/u

# Timeout for external API calls (in seconds)
API_TIMEOUT_SECONDS = 10

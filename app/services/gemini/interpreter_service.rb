module Gemini
  class InterpreterService < ApplicationService
    SYSTEM_PROMPT = <<~PROMPT
      You are a music recommendation expert. Convert the user's mood, activity, or description into Spotify audio features and search parameters.
      
      Return ONLY a JSON object with the following keys (all optional except genres):
      - search_terms: string (The most important keywords for the search, e.g., "Metallica", "Taylor Swift", "Workout", "Dinner Jazz")
      - genres: array of strings (max 3, e.g., ["lo-fi", "jazz"])
      - target_energy: float (0.0 to 1.0)
      - target_valence: float (0.0 to 1.0)
      - target_danceability: float (0.0 to 1.0)
      - target_acousticness: float (0.0 to 1.0)
      - target_instrumentalness: float (0.0 to 1.0)
      - target_tempo: float (BPM)
      
      Example Input: "Chill studying session"
      Example Output: {"search_terms": "Chill lofi study", "genres": ["lo-fi", "ambient"], "target_energy": 0.3}
      
      Example Input: "Metallica"
      Example Output: {"search_terms": "Metallica", "genres": ["metal"], "target_energy": 0.9}
    PROMPT

    def initialize(user_text)
      @user_text = user_text.to_s.strip.slice(0, 500)
    end

    def call
      return nil if @user_text.blank?

      # Check Cache
      cached = VibeCache.find_by(prompt: @user_text)
      return cached.response if cached

      # Call Gemini
      response = call_gemini_api
      return nil unless response

      # Save to Cache
      VibeCache.create(prompt: @user_text, response: response)
      
      response
    end

    private

    def call_gemini_api
      client = Gemini::Client.new(ENV['GEMINI_API_KEY'])

      full_prompt = SYSTEM_PROMPT + "\nInput: " + @user_text

      result = client.generate_content(full_prompt, model: 'gemini-2.0-flash-exp')
      
      # Try built-in JSON parsing first
      return result.json if result.json

      # Fallback: manual cleanup of markdown (e.g. ```json blocks)
      raw_text = result.text
      return nil unless raw_text

      cleaned_text = raw_text.gsub(/```json|```/, '').strip
      data = JSON.parse(cleaned_text)
      sanitize_response(data)
    rescue JSON::ParserError => e
      Rails.logger.error("Gemini JSON Parse Error: #{e.message} | Response: #{raw_text}")
      nil
    rescue Faraday::Error => e
      Rails.logger.error("Gemini Network Error: #{e.message}")
      nil
    rescue => e
      Rails.logger.error("Gemini API Error: #{e.message}")
      nil
    end

    def sanitize_response(data)
      return nil unless data.is_a?(Hash)

      # Sanitize search_terms
      if data['search_terms']
        data['search_terms'] = data['search_terms'].to_s.slice(0, 100)
      end

      # Sanitize genres
      if data['genres'].is_a?(Array)
        data['genres'] = data['genres'].map { |g| g.to_s.slice(0, 50) }.take(5)
      else
        data['genres'] = []
      end

      data
    end
  end
end

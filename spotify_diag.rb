require 'rspotify'

puts "--- Spotify Diagnostics ---"
client_id = ENV['SPOTIFY_CLIENT_ID']
client_secret = ENV['SPOTIFY_CLIENT_SECRET']

puts "Client ID present: #{client_id.present?}"
puts "Client Secret present: #{client_secret.present?}"

begin
  puts "Authenticating..."
  RSpotify.authenticate(client_id, client_secret)
  puts "Authentication successful."
  
  # Check if we have a token (RSpotify specific check if possible, or just proceed)
  # RSpotify stores class-level state.

  puts "Testing Recommendations (seed_genres: ['metal'])..."
  rec = RSpotify::Recommendations.generate(limit: 5, seed_genres: ['metal'])
  puts "Success! Found #{rec.tracks.size} tracks."
  puts "Example: #{rec.tracks.first.name} by #{rec.tracks.first.artists.first.name}"

rescue RestClient::Exception => e
  puts "API Error: #{e.message}"
  puts "Response body: #{e.response.body rescue 'N/A'}"
rescue => e
  puts "General Error: #{e.message}"
end
puts "--- End Diagnostics ---"

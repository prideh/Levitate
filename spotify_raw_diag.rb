require 'net/http'
require 'uri'
require 'json'
require 'base64'

client_id = ENV['SPOTIFY_CLIENT_ID']
client_secret = ENV['SPOTIFY_CLIENT_SECRET']

# 1. Get Token
puts "1. Getting Token..."
auth_uri = URI('https://accounts.spotify.com/api/token')
req = Net::HTTP::Post.new(auth_uri)
req.basic_auth(client_id, client_secret)
req.set_form_data('grant_type' => 'client_credentials')

res = Net::HTTP.start(auth_uri.hostname, auth_uri.port, use_ssl: true) do |http|
  http.request(req)
end

if res.code != '200'
  puts "Auth Failed: #{res.code} #{res.body}"
  exit
end

token = JSON.parse(res.body)['access_token']
puts "Token received."

# 2. Get Genres
puts "2. Fetching Genres..."
genres_uri = URI('https://api.spotify.com/v1/recommendations/available-genre-seeds')
req = Net::HTTP::Get.new(genres_uri)
req['Authorization'] = "Bearer #{token}"

res = Net::HTTP.start(genres_uri.hostname, genres_uri.port, use_ssl: true) do |http|
  http.request(req)
end

puts "Response Code: #{res.code}"
puts "Response Body: #{res.body}"
puts "Response Headers: #{res.to_hash.inspect}"

# 3. Get A Known Track (Basic Check)
puts "3. Fetching Track (Rick Astley)..."
track_uri = URI('https://api.spotify.com/v1/tracks/4cOdK2wGLETKBW3PvgPWqT')
req = Net::HTTP::Get.new(track_uri)
req['Authorization'] = "Bearer #{token}"

res = Net::HTTP.start(track_uri.hostname, track_uri.port, use_ssl: true) do |http|
  http.request(req)
end

puts "Track Response Code: #{res.code}"

# 4. Search (Alternative Strategy)
puts "4. Testing Search API..."
search_uri = URI('https://api.spotify.com/v1/search?q=genre:metal&type=track&limit=5')
req = Net::HTTP::Get.new(search_uri)
req['Authorization'] = "Bearer #{token}"

res = Net::HTTP.start(search_uri.hostname, search_uri.port, use_ssl: true) do |http|
  http.request(req)
end

puts "Search Response Code: #{res.code}"
if res.code == '200'
  tracks = JSON.parse(res.body)['tracks']['items']
  puts "Search found: #{tracks.size} tracks"
  puts "First: #{tracks.first['name']} - #{tracks.first['artists'].first['name']}"
else
  puts "Search Body: #{res.body}"
end

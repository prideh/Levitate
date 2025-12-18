require 'rspotify'
require 'gemini'

# RSpotify Setup
if ENV['SPOTIFY_CLIENT_ID'] && ENV['SPOTIFY_CLIENT_SECRET']
  RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
end

# Gemini Setup is handled per request in service for now, but general config could go here.

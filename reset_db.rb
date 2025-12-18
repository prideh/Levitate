puts "Clearing VibeCaches..."
VibeCache.delete_all
puts "VibeCaches cleared."

puts "Clearing Tracks..."
Track.delete_all
puts "Tracks cleared."

puts "Clearing Sessions..."
ActiveRecord::SessionStore::Session.delete_all
puts "Sessions cleared."

puts "Database clean!"

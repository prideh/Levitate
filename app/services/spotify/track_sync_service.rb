module Spotify
  class TrackSyncService < ApplicationService
    def initialize(spotify_id)
      @spotify_id = spotify_id
    end

    def call
      track = Track.find_by(spotify_id: @spotify_id)
      return track if track.present?

      sync_track_from_spotify
    end

    private

    def sync_track_from_spotify
      # RSpotify Authentication should be handled in initializer or initial call
      # For now assuming RSpotify.authenticate is called elsewhere or we call it here if needed
      # but ideally in an initializer.

      spotify_track = RSpotify::Track.find(@spotify_id)
      
      return nil unless spotify_track

      # Audio features are deprecated/403, skipping fetch.
      audio_features = nil
      
      Track.create!(
        spotify_id: spotify_track.id,
        name: spotify_track.name,
        artist: spotify_track.artists.first.name,
        album: spotify_track.album.name,
        image_url: spotify_track.album.images.first&.dig("url"),
        preview_url: spotify_track.preview_url,
        features: {}
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Track Validation Error for #{spotify_track.id}: #{e.record.errors.full_messages.join(', ')}")
      nil
    rescue RestClient::NotFound
      nil
    rescue => e
      Rails.logger.error("Track Sync Error: #{e.message}")
      nil
    end
  end
end

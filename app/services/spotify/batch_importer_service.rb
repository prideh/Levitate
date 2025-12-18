module Spotify
  class BatchImporterService < ApplicationService
    def initialize(rspotify_tracks)
      @rspotify_tracks = rspotify_tracks
    end

    def call
      return [] if @rspotify_tracks.empty?

      # Filter out tracks we already have
      existing_ids = Track.where(spotify_id: @rspotify_tracks.map(&:id)).pluck(:spotify_id).to_set
      new_tracks = @rspotify_tracks.reject { |t| existing_ids.include?(t.id) }

      return Track.where(spotify_id: @rspotify_tracks.map(&:id)).to_a if new_tracks.empty?

      # Create Tracks (Bulk Insert for Speed)
      if new_tracks.any?
        current_time = Time.current
        
        attributes_list = new_tracks.map do |t|
          {
            spotify_id: t.id,
            name: t.name,
            artist: t.artists.first.name,
            album: t.album.name,
            image_url: t.album.images.first&.dig("url"),
            preview_url: t.preview_url,
            features: "{}", # Audio features are deprecated
            created_at: current_time,
            updated_at: current_time
          }
        end
        
        # Insert all at once
        # Note: MySQL adapter in this version doesn't support explicit :unique_by, 
        # so we rely on the DB's unique index and 'INSERT IGNORE' behavior of insert_all.
        Track.insert_all(attributes_list)
      end

      # Return all requested tracks (newly created + existing)
      Track.where(spotify_id: @rspotify_tracks.map(&:id)).in_order_of(:spotify_id, @rspotify_tracks.map(&:id))
    end
  end
end

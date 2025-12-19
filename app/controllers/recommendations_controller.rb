class RecommendationsController < ApplicationController
  def index
    @vibe = params[:vibe]
    @page = (params[:page] || 0).to_i
    
    # Existing History
    @history_tracks = Track.where(spotify_id: recommendation_history).index_by(&:spotify_id).values_at(*recommendation_history).compact

    if @vibe.present?
      set_last_vibe(@vibe)
      add_to_search_history(@vibe)
      
      # Interpret vibe (Cached)
      begin
        interpretation = Gemini::InterpreterService.call(@vibe)
        unless interpretation
           flash.now[:alert] = "Could not interpret vibe."
           @tracks = []
           return
        end
      rescue => e
        flash.now[:alert] = "Interpreter Error: #{e.message}"
        @tracks = []
        return
      end

      # Construct search parameters
      seed_genres = interpretation['genres']&.take(5)
      
      # Use Gemini's suggested search terms, or fallback to the raw vibe
      keywords = interpretation['search_terms'].presence || @vibe
      
      # Combine with genre if available for better filtering
      query = if seed_genres.present?
        "#{keywords} genre:\"#{seed_genres.first}\""
      else
        keywords
      end
      
      # Search & Batch Import
      begin
        # ... search logic ...

        max_songs = 50
        per_page = 20
        offset = @page * per_page
        remaining = max_songs - offset
        limit = [per_page, remaining].min

        if limit <= 0
          @tracks = []
        else
        if limit <= 0
          @tracks = []
        else
          raw_tracks = RSpotify::Track.search(query, limit: limit, offset: offset)
          
          # Fallback: If strict search (Keyword + Genre) yields no results, try broader search (Keyword only)
          if raw_tracks.empty? && seed_genres.present?
             raw_tracks = RSpotify::Track.search(keywords, limit: limit, offset: offset)
          end
  
          
          # Batch Import
          @tracks = Spotify::BatchImporterService.call(raw_tracks)
          
          # Only show next page if we haven't hit the max and we got a full page
          @next_page = @page + 1 if (@tracks.size >= limit) && (offset + @tracks.size < max_songs)
        end
        
        end
        
        # Responses for Turbo
        respond_to do |format|
          format.html # Normal render
          format.turbo_stream
        end
      rescue => e
        Rails.logger.error("Search Error: #{e.message}\n#{e.backtrace.join("\n")}")
        flash.now[:alert] = "Trouble finding tracks."
        @tracks = []
      end
    end
  end

  # Create is no longer used for search, redirect to index
  def create
    redirect_to recommendations_path(vibe: params[:vibe])
  end

  def click
    @track = Track.find_by(spotify_id: params[:id])
    
    if @track
      add_to_history(@track)
      
      respond_to do |format|
        format.html { redirect_to "https://open.spotify.com/track/#{@track.spotify_id}", allow_other_host: true }
        format.turbo_stream do
          render turbo_stream: [
             turbo_stream.remove("no_recent_discoveries"),
             turbo_stream.prepend("recent_discoveries_list", partial: "history_item", locals: { track: @track })
          ]
        end
      end
    else
      redirect_to "https://open.spotify.com/track/#{params[:id]}", allow_other_host: true
    end
  end
end

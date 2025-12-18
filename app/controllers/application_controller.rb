class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  helper_method :recommendation_history, :last_vibe, :search_history

  private

  def recommendation_history
    session[:recommendation_history] ||= []
  end

  def add_to_history(track)
    history = recommendation_history
    unless history.include?(track.spotify_id)
      history.unshift(track.spotify_id)
      session[:recommendation_history] = history.first(20) # Keep last 20
    end
  end

  def search_history
    session[:search_history] ||= []
  end

  def add_to_search_history(query)
    return if query.blank?
    history = search_history
    # Remove if exists (to move to top)
    history.delete(query)
    history.unshift(query)
    session[:search_history] = history.first(5) # Keep last 5
  end

  def last_vibe
    session[:last_vibe]
  end

  def set_last_vibe(vibe_text)
    session[:last_vibe] = vibe_text
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end

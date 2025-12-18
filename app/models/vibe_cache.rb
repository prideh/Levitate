class VibeCache < ApplicationRecord
  serialize :response, coder: JSON
end

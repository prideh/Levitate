class CreateTracks < ActiveRecord::Migration[8.1]
  def change
    create_table :tracks do |t|
      t.string :spotify_id
      t.string :name
      t.string :artist
      t.string :album
      t.string :image_url
      t.string :preview_url
      t.json :features

      t.timestamps
    end
    add_index :tracks, :spotify_id
  end
end

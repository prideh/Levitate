class CreateVibeCaches < ActiveRecord::Migration[8.1]
  def change
    create_table :vibe_caches do |t|
      t.text :prompt
      t.json :response

      t.timestamps
    end
    add_index :vibe_caches, :prompt
  end
end

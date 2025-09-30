class CreateSources < ActiveRecord::Migration[8.0]
  def change
    create_table :sources do |t|
      # 'citext' activé dans la première migration -> create_people
      t.citext :slug, null: false
      t.string :title
      t.text :url, null: false
      t.string :kind
      t.string :checksum
      t.datetime :fetched_at
      t.jsonb :extra, null: false, default: {}
      t.references :sourceable, polymorphic: true, null: false, index: true

      t.timestamps
    end

    add_index :sources, :slug, unique: true
    add_index :sources, :url
    add_index :sources, :checksum
  end
end

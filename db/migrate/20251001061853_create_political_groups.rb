class CreatePoliticalGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :political_groups do |t|
      # 'citext' activé dans la première migration -> create_people
      t.citext :slug, null: false
      t.string :name, null: false
      t.string :short_name
      t.string :color_hex
      t.references :institution, null: false, foreign_key: true, index: true

      t.timestamps
    end
    add_index :political_groups, :slug, unique: true
    add_index :political_groups, :name
    add_index :political_groups, :short_name
    # Permet d'interdire deux groupes de même nom dans la même institution
    add_index :political_groups, [ :name, :institution_id ], unique: true
  end
end

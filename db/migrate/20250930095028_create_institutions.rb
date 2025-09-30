class CreateInstitutions < ActiveRecord::Migration[8.0]
  def change
    create_table :institutions do |t|
      # 'citext' activé dans la première migration -> create_people
      t.citext :slug, null: false
      t.string :name, null: false
      t.string :kind, null: false

      t.timestamps
    end

    add_index :institutions, :slug, unique: true
    add_index :institutions, :name
    add_index :institutions, :kind
  end
end

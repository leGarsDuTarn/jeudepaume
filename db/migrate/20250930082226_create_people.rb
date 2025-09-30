class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    # 'citext' est une extension de postgreSQL qui permet de rendre la case-isensitive
    # exemple macron = MACRON = MaCron
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :people do |t|
      t.citext :slug, null: false
      t.string :first_name
      t.string :last_name
      t.string :birth_name
      t.string :full_name
      t.string :gender
      t.date :birth_date
      t.string :birth_place
      t.string :birth_postal_code
      t.string :nationality
      t.text :image_url
      t.text :image_meta
      t.text :socials
      t.text :website
      t.text :bio
      t.text :external_ids

      t.timestamps
    end
    # unique: true -> Permet ici de n'avoir aucune duplication de slug
    # exemple : /people/emmanuel-macron correspondra toujours à une seule et même personne
    add_index :people, :slug, unique: true
  end
end

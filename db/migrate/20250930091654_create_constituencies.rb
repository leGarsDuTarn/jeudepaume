class CreateConstituencies < ActiveRecord::Migration[8.0]
  def change
    create_table :constituencies do |t|
      # 'citext' activé dans la première migration -> create_people
      t.citext :slug, null: false
      t.string :name, null: false
      # Ici on parle de level pour : 'région', 'département', 'commune'
      t.string :level, null: false
      t.string :insee_code

      t.timestamps
    end

    add_index :constituencies, :slug, unique: true
    add_index :constituencies, :insee_code, unique: true
    # Ici index composite permet de chercher beaucoup plus rapidement
    # donc évite les doublons (Paris+city ≠ Paris+region)
    # accélère les recherches combinées
    add_index :constituencies, [ :name, :level ], unique: true
  end
end

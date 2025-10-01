class CreateAssetsStatements < ActiveRecord::Migration[8.0]
  def change
    create_table :assets_statements do |t|
      t.date :filed_on, null: false
      t.string :kind, null: false
      t.integer :total_assets_cents
      t.text :document_url
      t.text :document_meta
      t.references :person, null: false, foreign_key: true, index: true

      t.timestamps
    end
    add_index :assets_statements, :filed_on
    add_index :assets_statements, [ :person_id, :filed_on, :kind ], unique: true
    # Contraintes
    add_check_constraint :assets_statements,
      "total_assets_cents IS NULL OR total_assets_cents >= 0",
      name: "chk_assets_total_nonneg"
  end
end

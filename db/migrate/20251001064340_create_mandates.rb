class CreateMandates < ActiveRecord::Migration[8.0]
  def change
    create_table :mandates do |t|
      t.string :role, null: false
      t.string :status
      t.date :started_on, null: false
      t.date :ended_on
      t.string :seat_label
      t.string :source
      t.references :person, null: false, foreign_key: true, index: true
      t.references :political_group, null: true, foreign_key: true, index: true
      t.references :institution, null: false, foreign_key: true, index: true
      t.references :constituency, null: true, foreign_key: true, index: true

      t.timestamps
    end
    add_index :mandates, [ :person_id, :institution_id, :started_on ]

    # Ici permet de respecter la chronologie: la fin ne peut pas être avant le début
    add_check_constraint :mandates,
      "ended_on IS NULL OR ended_on >= started_on",
      name: "chk_mandates_chronology"
  end
end

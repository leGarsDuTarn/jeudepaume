class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      # Exemple : 'séance', 'commission'...
      t.string :scope, null: false
      # Identifiant de la 'séance', 'commission'...
      t.string :scope_ref
      t.integer :presence_count, null: false, default: 0
      t.integer :absence_count, null: false, default: 0
      # precision = nombre total de chiffre avant + après la virgule
      # scale =  nombre de chiffres après la virgule
      t.decimal :vote_participation_rate, precision: 5, scale: 2
      t.string :source
      t.references :mandate, null: false, foreign_key: true, index: true

      t.timestamps
    end
    # Amélioration requêtes
    add_index :attendances, :scope
    add_index :attendances, [ :mandate_id, :scope, :scope_ref ]
    # Contraintes
    add_check_constraint :attendances, "presence_count >= 0", name: "chk_attendance_presence_nonneg"
    add_check_constraint :attendances, "absence_count  >= 0", name: "chk_attendance_absence_nonneg"
    add_check_constraint :attendances,
      "vote_participation_rate IS NULL OR (vote_participation_rate >= 0 AND vote_participation_rate <= 100)",
      name: "chk_attendance_vote_rate_range"
  end
end

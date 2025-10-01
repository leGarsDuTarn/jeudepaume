class CreateCompensations < ActiveRecord::Migration[8.0]
  def change
    create_table :compensations do |t|
      # exemple : 'indemnité','prime'...
      t.string :kind, null: false
      # exemple : 'Logement de fonction'
      t.string :label
      # Montants en centimes
      t.integer :amount_gross_cents, null: false, default: 0
      # 'avantage par mois', 'à l'année', 'à vie'
      t.string :period
      # Période de validité -> date de début
      t.date :effective_from, null: false
      # Période de validité -> date de fin
      t.date :effective_to
      t.string :source
      t.references :mandate, null: false, foreign_key: true, index: true

      t.timestamps
    end
    # Améliore la vitesse de recherche par mandat + période de début
    add_index :compensations, [ :mandate_id, :effective_from ]
    # Permet d'éviter les doublons exacts de revenus pour un même mandat
    # Rajout d'un name ici : "uniq_comp_mand_kind_label_from"
    # -> dépasse la limite de 63 caractères de PostgreSQL
    # -> Rails applique une troncature
    # -> Risque de collisions si autre index aux noms proches présent
    add_index :compensations, [ :mandate_id, :kind, :label, :effective_from ],
          unique: true,
          name: "uniq_comp_mand_kind_label_from"
    # Permet d'éviter les valeurs négative
    add_check_constraint :compensations,
      "amount_gross_cents >= 0",
      name: "chk_compensations_amount_non_negative"
    # Ici permet de respecter la chronologie: la fin ne peut pas être avant le début
    add_check_constraint :compensations,
      "effective_to IS NULL OR effective_to >= effective_from",
      name: "chk_compensations_chronology"
  end
end

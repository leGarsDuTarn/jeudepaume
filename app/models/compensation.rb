class Compensation < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :mandate

  KINDS = [
    # Traitement - indemnité de base
    "base_salary",
    # Indemnités diverses (logement, déplacement ...)
    "allowance",
    # Prime diverses
    "bonus",
    # Avantages en nature
    "benefit_in_kind"
].freeze

  PERIODS = [
    "montly",
    "yearly",
    # Versement unique
    "one_off"
  ]

end

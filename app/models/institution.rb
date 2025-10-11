class Institution < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  KINDS = [
    "Assemblée nationale",
    "Sénat",
    "Gouvernement",
    "Présidence de la République",
    "Conseil constitutionnel",
    "Collectivité territoriale"
  ].freeze

  before_validation :normalize_fields

  validates :name, presence: true, length: { maximum: 120 }, uniqueness: { case_sensitive: false }
  validates :kind, presence: true, inclusion: { in: KINDS }

  # régénère le slug si le nom change
  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_name?
  end

  # Préparation des requêtes de recherche
  scope :parlementaires, -> { where(kind: [ "Assemblée nationale", "Sénat" ]) }
  scope :executif,       -> { where(kind: [ "Gouvernement", "Présidence de la République" ]) }
  scope :constit,        -> { where(kind: "Conseil constitutionnel") }
  scope :collectivites,  -> { where(kind: "Collectivité territoriale") }
  scope :recentes,       -> { order(created_at: :desc) }

  private

  def normalize_fields
    self.name = name.to_s.strip.presence
    self.kind = kind.to_s.strip.presence
  end
end

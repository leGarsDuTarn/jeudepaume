class Constituency < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  has_many :mandates, dependent: :nullify
  has_many :people, through: :mandates

  before_validation :normalize_fields

  LEVELS = [
    "circonscription législative",
    "circonscription sénatoriale",
    "circonscription européenne",
    "département",
    "région",
    "commune",
    "arrondissement municipal"
  ].freeze

  # Règles Métier
  validates :name,
            presence: true,
            length: { maximum: 120 },
            uniqueness: { scope: :level, case_sensitive: false }

  validates :level,
            presence: true,
            inclusion: { in: LEVELS }

  scope :ordered, -> { order(level: :asc, name: :asc) }

  # Slug regen si le nom change
  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_name?
  end

  def label
    name
  end

  private

  def normalize_fields
    self.name = name.to_s.squish.presence
    self.level = level.to_s.squish.presence
    self.insee_code = insee_code.to_s.strip.upcase.presence
  end
end

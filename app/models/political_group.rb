class PoliticalGroup < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :history ]

  belongs_to :institution
  has_many :people, through: :mandates
  # Ici ':restrict_with_error' => Interdis la destruction du parent s’il a encore des enfants,
  # et ajoute une erreur sur l’objet au lieu de supprimer quoi que ce soit
  has_many :mandates, dependent: :restrict_with_error

  # Normalisation
  before_validation :normalize_fields

  # Règles métier
  validates :name,
            presence: true,
            length: { maximum: 120 },
            uniqueness: { scope: :institution_id, case_sensitive: false }

  validates :short_name,
            length: { maximum: 30 },
            allow_blank: true

  # Ici mise au format hex CSS : #RRGGBB ou #RGB, insensible à la casse
  validates :color_hex,
           format: { with: /\A#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/,
                     message: "doit être une couleur hex valide (ex: #1a2b3c)" },
           allow_blank: true


  scope :ordered, -> { order(name: :asc) }
  # Ici permet de renvoyer tous les groupes politiques rattachés à l’institution indiquée
  scope :for_institution, ->(inst) { where(institution: inst) }

  # Régénère le slug si le nom change
  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_name?
  end

  # Ici -> affichage court : "Renaissance" ou fallback sur name
  def label
    short_name.presence || name
  end

  private

  def normalize_fields
    self.name = name.to_s.squish.presence
    self.short_name = short_name.to_s.squish.presence
    self.color_hex = color_hex.to_s.squish.presence
  end
end

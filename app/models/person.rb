class Person < ApplicationRecord
  extend FriendlyId
  # ':computed_full_name' = c'est la méthode qui renvoie le texte à slugifier
  # 'use: :slugged' = active le module de génération de slug de FriendlyId
  friendly_id :computed_full_name, use: [ :slugged, :history ]

  has_many :mandates, dependent: :destroy
  has_many :institutions, through: :mandates
  has_many :assets_statements, dependent: :destroy

  # Mode manuel -> si l'admin doit rentrer les infos à la main
  attr_accessor :manual_entry # ⚠️ le passer à true dans le controller -> @person.manual_entry = true
  # Ici en mode manuel les prénom/nom ou full_name est exigé
  # Et la saisie admin doit être en JSON
  # Voir section private
  with_options if: :manual_entry? do
    validate :require_some_name
    validate :json_text_fields_valid
  end
  # Normalisation avec .squish
  before_validation :squish_names!
  before_validation :normalize_text_fields

  validates :slug, presence: true, uniqueness: true

  # Ici travail des régles métier de l'API.
  # Si l'API est vide 'allow_blank: true ou allow_nil: true' alors pas de blocage
  # souplesse ++++++
  validates :gender,
           inclusion: { in: %w[male female other unknown],
                        message: "valeur non reconnue" },
           allow_blank: true

  validates :birth_date,
           comparison: { less_than_or_equal_to: ->(_) { Time.zone.today } },
           allow_nil: true

  validates :birth_place,
          length: { maximum: 120 },
          format: { with: /\A[\p{L}\p{M}\s\-\'’.]+\z/u, message: "caractères non valides" },
          allow_blank: true

  # Code Postal en FR (ex: "81000")
  validates :birth_postal_code,
           format: { with: /\A\d{5}\z/, message: "doit être 5 chiffres" },
           allow_blank: true

  # URL de site perso si présent
  validates :website,
           format: { with: /\Ahttps?:\/\/.+\z/i, message: "URL invalide" },
           allow_blank: true

  # Nationalité (libre mais bornée)
  validates :nationality,
           length: { maximum: 80 },
           format: { with: /\A[\p{L}\p{M}\s\-\'’]+\z/u, message: "caractères non valides" },
           allow_blank: true

  # URL d'image si présente
  validates :image_url,
           format: { with: /\Ahttps?:\/\/.+\z/i, message: "URL invalide" },
           allow_blank: true

  # Bio libre mais bornée
  validates :bio, length: { maximum: 10_000 }, allow_blank: true

  # Helpers d'accès propre aux champs JSON texte
  def socials_hash
    parse_json_text(self.socials)
  end

  def external_ids_hash
    parse_json_text(self.external_ids)
  end

  # Source du slug : full_name prioritaire, sinon prénom + nom
  def computed_full_name
    full_name.presence || [ first_name, last_name ].compact.join(" ").squish
  end

  # Regénère le slug si le nom change
  def should_generate_new_friendly_id?
    slug.blank? || will_save_change_to_full_name? || will_save_change_to_first_name? || will_save_change_to_last_name?
  end

  private

  def manual_entry?
    manual_entry == true
  end

  def require_some_name
    if computed_full_name.blank?
      errors.add(:base, "Renseigner au moins full_name ou first_name + last_name")
    end
  end

  def squish_names!
    self.first_name = first_name&.squish
    self.last_name  = last_name&.squish
    self.full_name  = full_name&.squish
  end

  def normalize_text_fields
    self.gender        = gender.to_s.downcase.squish.presence
    self.nationality   = nationality.to_s.squish.presence
    self.image_url     = image_url.to_s.squish.presence
    self.image_meta    = image_meta.to_s.strip.presence
    self.socials       = socials.to_s.strip.presence
    self.external_ids  = external_ids.to_s.strip.presence
    self.website       = website.to_s.squish.presence
    self.bio           = bio.to_s.strip.presence
    self.birth_place   = birth_place.to_s.squish.presence
  end

  # Convertit un champ texte (censé contenir du JSON) en Hash Ruby,
  # sans jamais faire planter l'app si la valeur est vide ou invalide.
  def parse_json_text(text)
    # Si nil ou chaîne vide → on renvoie un Hash vide
    return {} if text.blank?
    # Ici on essaye de parser le JSON
    JSON.parse(text)
  # Si le contenu n'est pas un JSON valide, on intercepte l'erreur
  # et on renvoie un Hash vide pour éviter un crash.
  rescue JSON::ParserError, TypeError
    {}
  end

  # Valide que certains champs texte (si RENSEIGNÉS) contiennent bien du JSON valide.
  # Ne bloque pas si le champ est vide (allow_blank implicite ici).
  def json_text_fields_valid
    # Les attributs à vérifier (colonnes TEXT censées contenir du JSON)
    %i[image_meta socials external_ids].each do |attr|
      # Récupère dynamiquement la valeur de l'attribut (équivaut à self.image_meta, etc.)
      value = self.public_send(attr)
      # Si vide → on ne valide pas le JSON mais on laisse passer
      next if value.blank?
      begin
        # On essaie juste de parser pour vérifier la validité
        JSON.parse(value)
      rescue JSON::ParserError, TypeError
        # Si ce n'est pas du JSON valide → on ajoute une erreur de validation
        errors.add(attr, "doit être un JSON valide")
      end
    end
  end
end

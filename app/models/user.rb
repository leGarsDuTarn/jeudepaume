class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { citoyen: 0, admin: 1 }
  # Callback -> voir section private
  # will_save_change_to_user_name? && user_name.present? => évite de rentrer dans la méthode
  # -> gain de performance, évite des requêtes inutiles
  # idem pour normalize_names
  before_validation :normalize_user_name, if: -> { will_save_change_to_user_name? && user_name.present? }
  before_validation :normalize_names, if: -> { will_save_change_to_first_name? || will_save_change_to_last_name? }

  validates :user_name,
    presence: { message: "Veuillez renseigner un nom d'utilisateur" },
    uniqueness: true, # Citext gère déjà la casse côté DB
    length: { minimum: 3, maximum: 20, message: "Caractères : min 3 - max 20" },
    format: { with: /\A[a-z0-9_]+\z/, message: "seulement lettres, chiffres et _" },
    exclusion: { in: %w[admin support root www api system jeudepaume], message: "n'est pas disponible" }

  # Cette REGEX autorise uniquement des prénoms/noms composés de lettres Unicode,
  # avec des espaces, des points, des apostrophes ou bien des tirets entre les mots.
  # Exemples valides : "Jean", "Jean-Luc", "O'Connor", "J. R. R. Tolkien", "Élodie"
  # Exemples invalides : "Jean3", "Jean_", "Jean-", " Jean "
  NAME_REGEX = /\A\p{L}+(?:[ .'-]\p{L}+)*\z/u.freeze
  validates :first_name,
    presence: { message: "Veuillez renseigner un prénom" },
    length: { minimum: 1, maximum: 50 },
    format: { with: NAME_REGEX }
  validates :last_name,
    presence: { message: "Veuillez renseigner un nom" },
    length: { minimum: 1, maximum: 50 },
    format: { with: NAME_REGEX }

  private

  def normalize_user_name
    s = user_name.to_s.unicode_normalize(:nfc).strip.downcase
    s = (I18n.transliterate(s) rescue s) # accents -> ASCII si dispo
    # espaces -> "_"
    s = s.gsub(/\s+/, "_")
      # Remplace tout sauf [A-Za-z0-9_] par "_"
      .gsub(/[^\w]/, "_")
      # Ici ça compresse "___" en "_"
      .gsub(/_+/, "_")
      # enlève les underscores '_' au début et à la fin
      .gsub(/^_+|_+$/, "")
    self.user_name = s.presence
  end

  def normalize_names
    self.first_name = normalize_person_name(first_name)
    self.last_name = normalize_person_name(last_name)
  end

  def normalize_person_name(value)
    s = value.to_s.unicode_normalize(:nfc).strip
    # apostrophes typographiques -> apostrophe simple
    s = s.tr("’`´", "'")
      # variantes de tirets -> "-"
      .gsub(/[‐-–—]/, "-")
      # espaces multiples -> simple espace
      .gsub(/\s+/, " ")
      # pas d’espace autour des "-"
      .gsub(/\s*-\s*/, "-")
      # pas d’espace autour des "'"
      .gsub(/\s*'\s*/, "'")
      # pas de séparateur en bord
      .gsub(/\A[.'-]+|[.'-]+\z/, "")
    return nil if s.blank?
    # Ici ça découpe par espaces
    s.split(" ").map { |w|
      # Puis pour chaque mot, ça découpe par tirets
      w.split("-").map { |h|
        # Puis pour chaque sous-mot, ça découpee par apostrophes
        # mb_chars.capitalize permet de capitaliser chaque segment
        h.split("'").map { |p| p.mb_chars.capitalize.to_s }.join("'")
      }.join("-")
      # Enfin ça rassemble successivement avec ', puis -, puis l’espace.
    }.join(" ")
  end
end

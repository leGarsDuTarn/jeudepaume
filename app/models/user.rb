class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { citoyen: 0, admin: 1 }
  # Callback -> voir section private
  before_validation :normalize_user_name

  validates :user_name,
    presence: { message: "Veuillez renseigner un nom d'utilisateur" },
    uniqueness: true, # Citext gére déjà la casse côté DB
    length: { minimum: 3, maximum: 20, message: "Caractères : mini 3 - max 20" },
    format: { with: /\A[a-z0-9_]+\z/, message: "seulement lettres, chiffres et _" },
    exclusion: { in: %w[admin support root www api system jeudepaume], message: "n'est pas disponible" }

  # Cette REGEX autorise uniquement des prénoms/noms composés de lettres Unicode,
  # avec des espaces, des points, des apostrophes ou bien des tirets entre les mots.
  # Exemple valides : "Jean", "Jean-Luc", "O'Connor", "J. R. R. Tolkien", "Élodie"
  # Exemple invalides : "Jean3", "Jean_", "Jean-", " Jean "
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
      # Valide tout sauf [A-Za-z0-9_] sinon "_"
      .gsub(/[^\w]/, "_")
      # Ici ça compresse "___" en "_"
      .gsub(/_+/, "_")
      # enlève les espaces au début et à la fin
      .gsub(/^_+|_+$/, "")
    self.user_name = s
  end

  def normalize_names
    self.first_name = normalize_persson_name(first_name)
    self.last_name = normalize_persson_name(last_name)
  end

  def normalize_persson_name(value)
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
      # Puis pour chaque mot,ça découpe par tirets
      w.split("-").map { |h|
        # Puis pour chaque sous-mot, ça découpee par apostrophes
        # mb_chars.capitalize permet de capitaliser chaque segment
        h.split("'").map { |p| p.mb_chars.capitalize.to_s }.join("'")
      }.join("-")
      # Enfin ça rassemble successivement avec ', puis -, puis l’espace.
    }.join(" ")
  end
end

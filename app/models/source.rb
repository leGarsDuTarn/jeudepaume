class Source < ApplicationRecord
  belongs_to :sourceable, polymorphic: true

  # Normalisation + valeurs par défaut
  before_validation :normalize_fields
  before_validation :ensure_slug, on: :create
  before_validation :compute_checksum, if: -> { url_changed? && url.present? }

  # Règles métier
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 120 }
  validates :url,  presence: true, format: { with: /\Ahttps?:\/\/\S+\z/i, message: "URL invalide" }
  validates :kind, length: { maximum: 80 }, allow_blank: true
  validate  :extra_is_hash

  # Ici permet de faire des recherches en fonction des sources
  scope :recent,    -> { order(fetched_at: :desc, created_at: :desc) }
  scope :by_kind,   ->(k) { where(kind: k) }
  scope :for_url,   ->(u) { where(url: u) }
  scope :for,       ->(record) { where(sourceable: record) }
  scope :checksum,  ->(c) { where(checksum: c) }

  # Ici permet d'extraire le nom d domaine depuis l'URL de la source
  def domain
    URI.parse(url).host rescue nil
  end
  # Ici c'est un helper d'affichage
  def label
    # Si title non nil alors renvoie le titre
    # sinon le domaine
    # sinon l'URL brute
    title.presence || domain || url
  end

  private

  def normalize_fields
    self.title = title.to_s.squish.presence
    self.kind  = kind.to_s.squish.presence
    self.url   = url.to_s.strip.presence
    self.slug  = slug.to_s.squish.presence
  end

  # Ici permet de fournir un slug auto si non fourni : basé sur le titre, ou le domaine de l'URL
  # ou en dernier recoure => "source"
  def ensure_slug
    return if slug.present?
    # La methode '.parameterize' transforme une chaîne en slug URL-friendly
    base = (title.presence || (URI.parse(url).host rescue nil) || "source").to_s.parameterize
    self.slug = unique_slug(base)
  end

  # Ici permet de garder l’unicité => sert à garantir un slug unique
  def unique_slug(base)
    candidate = base.presence || "source"
    i = 2
    while self.class.where(slug: candidate).exists?
      candidate = "#{base}-#{i}"
      i += 1
    end
    candidate
  end

  # Ici le Checksum basé sur l’URL permet de détecter les doublons potentiels
  def compute_checksum
    # Ici 'Digest::SHA256' à une taille fixe et produit toujours 64 caractéres hex(256 bits)
    # quelle que soit la longueur de l'URL
    # Probabilité de collision quasi nulle
    self.checksum = Digest::SHA256.hexdigest(url)
  end

  # Ici permet de s’assurer qu’on manipule un Hash Ruby
  def extra_is_hash
    self.extra ||= {}
    errors.add(:extra, "doit être un objet JSON") unless extra.is_a?(Hash)
  end
end

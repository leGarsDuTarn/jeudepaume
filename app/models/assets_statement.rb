class AssetsStatement < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable

  belongs_to :person

  # Callback
  before_validation :normalize_fields

  # Règles métier
  validates :filed_on, presence: true
  validates :kind,     presence: true, length: { maximum: 80 }
  validates :total_assets_cents,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true
  # Unicité conforme à l’index unique
  validates :filed_on, uniqueness: { scope: %i[person_id kind] }
  validates :document_url,
            length: { maximum: 2_000 },
            allow_blank: true,
            format: {
              with: /\Ahttps?:\/\/[^\s]+\z/i,
              message: "doit être une URL http(s) valide"
            }, if: -> { document_url.present? }

  scope :ordered, -> { order(person_id: :asc, filed_on: :desc, kind: :asc) }
  scope :for_person, ->(p) { where(person_id: p) }
  scope :for_kind, ->(k) { where(kind: k) }
  scope :on_date, ->(d) { where(filed_on: d) }
  scope :before_or_on, ->(d) { where(arel_table[:filed_on].lteq(d)) }
  scope :latest_first, -> { order(filed_on: :desc) }

  # Getter: renvoie BigDecimal en euros (ou nil si inconnu)
  def total_assets_eur
    return nil if total_assets_cents.nil?
    (total_assets_cents.to_d / 100)
  end

  # Setter: accepte "1234.56", "1 234,56", etc. → stocke en centimes (entier)
  # Choix: valeur vide → nil (car la colonne est nullable en DB)
  def total_assets_eur=(val)
    self.total_assets_cents =
      case val
      when nil, "" then nil
      else
        normalized = val.to_s.tr(" ", "").tr(",", ".")
        (BigDecimal(normalized) * 100).round(0).to_i
      end
  end

  # Affichage sympa si besoin
  def display_title
    [ kind.presence, filed_on&.strftime("%Y-%m-%d") ].compact.join(" – ")
  end

  private

  def normalize_fields
    self.kind         = kind.to_s.strip
    self.document_url = document_url.to_s.strip.presence
    self.document_meta = document_meta.to_s.strip.presence
    self.source       = source.to_s.squish.presence if respond_to?(:source)
  end
end

class Compensation < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable

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
    "monthly",
    "yearly",
    # Versement unique
    "one_off"
].freeze

  before_validation :normalize_fields

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :effective_from, presence: true
  validates :amount_gross_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :period, inclusion: { in: PERIODS }, allow_nil: true
  # Unicité conforme à l’index unique : mandate_id, kind, label, effective_from
  validates :effective_from, uniqueness: { scope: %i[mandate_id kind label] }

  # Voir section privée
  # Contrainte SQL (chronologie)
  validate :effective_to_not_before_from
  # Anti-chevauchement pour un même triplet (mandate/kind/label)
  validate :no_overlapping_ranges, if: -> { effective_from.present? }

  scope :ordered, -> { order(mandate_id: :asc, kind: :asc, label: :asc, effective_from: :desc) }
  scope :for_kind, ->(k) { where(kind: k) }
  scope :for_label, ->(lab) { where(lablel: lab) }
  scope :current_on, ->(date = Date.current) {
    where(arel_table[:effective_from].lteq(date))
      .where(arel_table[:effective_to].eq(nil).or(arel_table[:effective_to].gteq(date)))
  }
  scope :current, -> { current_on(Date.current) }

  # Helpers
  # Ici permet d'utiliser amount_gross_eur (BigDecimal/String) côté formulaires/seed
  def amount_gross_eur
    return nil if amount_gross_cents.nil?

    (amount_gross_cents.to_d / 100)
  end

  def amount_gross_eur=(val)
    self.amount_gross_cents =
      case val
      when nil, "" then 0
      else
        # accepte "1234.56", "1 234,56", etc.
        normalized = val.to_s.tr(" ", "").tr(",", ".")
        (BigDecimal(normalized) * 100).round(0).to_i
      end
  end

  # Couverture d’une date donnée par la plage effective_from..effective_to
  def covers?(date)
    return false unless date.is_a?(Date)
    start_ok = effective_from <= date
    end_ok   = effective_to.nil? || effective_to >= date
    start_ok && end_ok
  end

  private

  def normalize_fields
    self.kind  = kind.to_s.strip
    self.label = label.to_s.squish.presence
    self.period = period.to_s.strip.presence
  end

  def effective_to_not_before_from
    return if effective_to.blank? || effective_from.blank?
    if effective_to < effective_from
      errors.add(:effective_to, "ne peut pas être antérieure à effective_from")
    end
  end

  # Empêche deux lignes pour le même (mandate, kind, label) d’avoir des périodes qui se chevauchent
  # Ici on autorise plusieurs enregistrements si les périodes sont disjointes.
  def no_overlapping_ranges
    rel = self.class.where(mandate_id: mandate_id, kind: kind, label: label)
    rel = rel.where.not(id: id) if persisted?

    # Stratégie d'intersection de périodes (NULL = ouvert)
    # Overlap si:
    # other.effective_from <= self.effective_to (ou self.effective_to NULL)
    # ET
    # self.effective_from <= other.effective_to (ou other.effective_to NULL)
    rel = rel.where(
      self.class.sanitize_sql_array(
        [
          "(effective_from <= ? OR ? IS NULL) AND (? <= effective_to OR effective_to IS NULL)",
          effective_to, effective_to, effective_from
        ]
      )
    )

    if rel.exists?
      errors.add(:base, "chevauche une compensation existante pour le même mandat/kind/label")
    end
  end
end

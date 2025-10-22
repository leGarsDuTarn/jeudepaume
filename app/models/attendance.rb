class Attendance < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable

  belongs_to :mandate

  # Callback
  before_validation :normalize_fields
  before_validation :compute_rate_if_possible

  # Règles métier
  validates :scope, presence: true, length: { maximum: 80 }
  validates :scope_ref, length: { maximum: 120 }, allow_blank: true

  validates :presence_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :absence_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :vote_participation_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true

  scope :ordered,      -> { order(mandate_id: :asc, scope: :asc, scope_ref: :asc) }
  scope :for_scope,    ->(sc)  { where(scope: sc) }
  scope :for_ref,      ->(ref) { where(scope_ref: ref) }
  scope :with_rates,   ->      { where.not(vote_participation_rate: nil) }
  scope :missing_rates,->      { where(vote_participation_rate: nil) }

  # Helpers
  def total_sessions
    presence_count.to_i + absence_count.to_i
  end

  # Ici permet de calculer le taux de participation
  def computed_rate
    total = total_sessions
    return nil if total.zero?
    # pour rester cohérent => precision: 5, scale: 2
    # precision: 5 => 5 chiffres en tout avant et après la virgule
    # scale: 2 => deux chiffres après la virgule
    (presence_count.to_d * 100 / total).round(2)
  end

  private

  def normalize_fields
    # Attention: la colonne s'appelle "scope"
    self.scope     = self[:scope].to_s.strip
    self.scope_ref = scope_ref.to_s.squish.presence
    self.source    = source.to_s.squish.presence
  end

  # Si l’API ne fournit pas le taux mais donne les compteurs, on le calcule.
  def compute_rate_if_possible
    return unless vote_participation_rate.nil?
    rate = computed_rate
    self.vote_participation_rate = rate if rate
  end
end

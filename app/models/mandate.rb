class Mandate < ApplicationRecord
  # Voir concern sourceable.rb
  include Sourceable

  belongs_to :person
  belongs_to :institution
  belongs_to :political_group, optional: true
  belongs_to :constituency, optional: true

  has_many :attendances, dependent: :destroy
  has_many :compensations, dependent: :destroy

  before_validation :normalize_fields

  validates :role, presence: true
  validates :status, length: { maximum: 80 }, allow_blank: true
  validates :seat_label, length: { maximum: 80 }, allow_blank: true
  validates :started_on, presence: true
  # Voir section private
  validate :chronology

  scope :ordered, -> { order(started_on: :desc, id: :desc) }
  # Ici permet de faire une recherche en cours de mandat
  scope :current, ->(on = Date.current) {
    where("started_on <= ? AND (ended_on IS NULL OR ended_on >= ?)", on, on)
  }
  # Ici permet de faire une recherche sur des mandats terminés à une date donnée
  scope :past, ->(on = Date.current) {
    where("ended_on IS NOT NULL AND ended_on < ?", on)
  }

  scope :for_institution, ->(institution) { where(institution:) }
  scope :for_person,      ->(person)      { where(person:) }
  scope :for_group,       ->(group)       { where(political_group: group) }
  scope :for_constituency, ->(c)          { where(constituency: c) }

  # Ici ce helper répond à : Ce mandat est-il en cours à la date X ?
  def in_office?(on = Date.current)
    started_on <= on && (ended_on.nil? || ended_on >= on)
  end

  # Ici helper de durée -> donne le nombre de jours qu'a duré(ou dure encore) un mandat
  def duration_in_days(until_date = Date.current)
    return nil unless started_on

    to = ended_on || until_date
    # Ici return nil si pas encore commencé à cette date
    return nil if to < started_on
    # Ici c'est inclusif
    # => 2024-01-01 -> 2024-01-01 : 1 jour (inclusif).
    (to - started_on).to_i + 1
  end

  # Ici helper d'affichage ex: Député · Renaissance · Haute-Garonne
  def label
    parts = [ role ]
    parts << political_group&.short_name if political_group&.short_name.present?
    parts << constituency&.name if constituency&.name.present?
    parts.compact.join(" - ")
  end

  private

  def normalize_fields
    self.role = role.to_s.squish.presence
    self.status     = status.to_s.squish.presence
    self.seat_label = seat_label.to_s.squish.presence
    self.source     = source.to_s.squish.presence
  end

  def chronology
    return if ended_on.blank? || started_on.blank?

    if ended_on < started_on
      errors.add(:ended_on, "ne peut pas être antérieure à la date de début")
    end
  end
end

# Catalog of trackable part categories (brake pad, battery, ...) and how
# long each is expected to last. Reference/lookup data — seeded once, not
# meant to churn.
class PartTypeReference < ApplicationRecord
  has_many :parts, dependent: :restrict_with_error

  PART_TYPES = %w[
    brake_pad brake_rotor battery alternator spark_plug
    air_filter oil_filter tire water_pump shock_absorber
  ].freeze

  validates :part_type, presence: true, uniqueness: true, inclusion: { in: PART_TYPES }
  validates :typical_lifespan_days, presence: true, numericality: { greater_than: 0, only_integer: true }
end

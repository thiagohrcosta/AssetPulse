# A single physical, serialized part tracked through its lifecycle. `status`
# is a denormalized cache of where the part currently stands — the actual
# history lives in `lifecycle_events`.
#
# `host_unit` is nil whenever the part isn't installed on anything right now
# (in transit, at a repair shop, or scrapped); `company` always points at
# whoever currently has custody of it, so it stays set even then.
class Part < ApplicationRecord
  belongs_to :part_type_reference
  belongs_to :host_unit, optional: true
  belongs_to :company
  has_many :lifecycle_events, dependent: :destroy

  enum :status, {
    installed: "installed",
    in_repair: "in_repair",
    removed: "removed",
    scrapped: "scrapped"
  }, default: "installed"

  delegate :part_type, :typical_lifespan_days, to: :part_type_reference

  validates :serial_number, presence: true, uniqueness: true
  validates :manufacturer, presence: true
  validates :model, presence: true

  scope :by_manufacturer_model, ->(manufacturer, model) { where(manufacturer: manufacturer, model: model) }
end

# One entry in a part's history: installed, serviced, replaced, reassigned
# to another host unit, or scrapped. `host_unit`/`company` capture custody
# *as of this event* — a part's current custody (on `Part`) moves over time,
# but its history shouldn't.
#
# `age_at_event_days` tracks continuous time-in-service since the part's
# current life cycle started. It does not reset across installed ->
# maintenance -> replaced_wear/replaced_defect (same continuous use) — only
# a `reassigned` event starts a new cycle, since the part is being put back
# into service after being idle.
class LifecycleEvent < ApplicationRecord
  belongs_to :part
  belongs_to :host_unit, optional: true
  belongs_to :company

  enum :event_type, {
    installed: "installed",
    maintenance: "maintenance",
    replaced_wear: "replaced_wear",
    replaced_defect: "replaced_defect",
    reassigned: "reassigned",
    scrapped: "scrapped"
  }

  enum :installation_type, {
    factory_original: "factory_original",
    aftermarket_new: "aftermarket_new",
    aftermarket_refurbished: "aftermarket_refurbished"
  }

  validates :event_type, presence: true
  validates :occurred_at, presence: true
  validates :age_at_event_days, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :chronological, -> { order(:occurred_at) }
end

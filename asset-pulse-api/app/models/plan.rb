# A subscription tier offered to companies. Rows here are metadata/cache —
# the Product + Price actually live in Stripe and are the source of truth;
# `rails stripe:sync_plans` (see StripePlanSync) creates/updates both and
# keeps stripe_product_id / stripe_price_id in sync.
class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :currency, presence: true
  validates :interval, presence: true

  scope :active, -> { where(active: true) }

  def amount
    amount_cents / 100.0
  end
end

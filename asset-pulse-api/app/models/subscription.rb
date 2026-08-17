# One subscription per company. Tracks either the card-less 7-day trial
# (status "trialing", trial_ends_at set, no Stripe subscription at all) or a
# real Stripe subscription kept in sync via webhooks
# (Api::V1::Stripe::WebhooksController / Subscriptions::WebhookHandler).
class Subscription < ApplicationRecord
  TRIAL_PERIOD = 7.days

  belongs_to :company
  belongs_to :plan, optional: true

  enum :status, {
    trialing: "trialing",
    active: "active",
    past_due: "past_due",
    unpaid: "unpaid",
    canceled: "canceled",
    incomplete: "incomplete",
    incomplete_expired: "incomplete_expired"
  }, default: "trialing"

  validates :status, presence: true
  validates :company_id, uniqueness: true
  validates :stripe_customer_id, uniqueness: true, allow_nil: true
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  # True while the company should be able to use the platform: an
  # unexpired trial, an active paid subscription, or a paid subscription
  # Stripe is still retrying (past_due) rather than having given up on
  # (canceled/unpaid/incomplete_expired).
  def access_granted?
    return trial_active? if trialing?

    active? || past_due?
  end

  def trial_active?
    trial_ends_at.present? && trial_ends_at.future?
  end

  def trial_expired?
    trialing? && trial_ends_at.present? && !trial_ends_at.future?
  end
end

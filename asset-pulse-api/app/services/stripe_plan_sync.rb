class StripePlanSync
  CURRENCY = "usd"
  INTERVAL = "month"

  PLAN_DEFINITIONS = [
    {
      slug: "basic",
      name: "Basic",
      description: "Asset management for a single company.",
      amount_cents: 4_999,
      ai_enabled: false
    },
    {
      slug: "premium",
      name: "Premium with AI",
      description: "Everything in Basic, plus AI-powered features.",
      amount_cents: 8_999,
      ai_enabled: true
    }
  ].freeze

  def self.call
    new.call
  end

  def call
    PLAN_DEFINITIONS.map { |definition| sync_plan(definition) }
  end

  private

  def sync_plan(definition)
    price = find_or_create_price(definition)
    product_id = price.product.is_a?(String) ? price.product : price.product.id

    plan = Plan.find_or_initialize_by(slug: definition[:slug])
    plan.update!(
      name: definition[:name],
      amount_cents: definition[:amount_cents],
      currency: CURRENCY,
      interval: INTERVAL,
      ai_enabled: definition[:ai_enabled],
      active: true,
      stripe_product_id: product_id,
      stripe_price_id: price.id
    )

    Rails.logger.info(
      "[stripe_plan_sync] #{plan.slug}: product=#{product_id} price=#{price.id}"
    )
    plan
  end

  def find_or_create_price(definition)
    lookup_key = lookup_key_for(definition)

    existing = Stripe::Price.list(
      lookup_keys: [lookup_key],
      expand: ["data.product"],
      limit: 1
    ).data.first
    return existing if existing

    product = Stripe::Product.create(
      name: definition[:name],
      description: definition[:description],
      metadata: { slug: definition[:slug], ai_enabled: definition[:ai_enabled] }
    )

    Stripe::Price.create(
      product: product.id,
      unit_amount: definition[:amount_cents],
      currency: CURRENCY,
      recurring: { interval: INTERVAL },
      lookup_key: lookup_key,
      metadata: { slug: definition[:slug] }
    )
  end

  def lookup_key_for(definition)
    "asset_pulse_#{definition[:slug]}_#{INTERVAL}ly"
  end
end

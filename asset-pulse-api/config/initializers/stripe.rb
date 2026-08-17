# Billing (subscription plans, checkout, webhooks) is handled by Stripe.
#
# STRIPE_SECRET_KEY / STRIPE_WEBHOOK_SECRET are read from the environment
# (see docker-compose.yml / .env.example). They're intentionally left blank
# until a real key is provided — the app boots fine without one, but any
# call that hits the Stripe API (checkout, `rails stripe:sync_plans`, the
# webhook endpoint) will fail until STRIPE_SECRET_KEY is set.
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# Identifies this integration to Stripe support/logs.
Stripe.set_app_info(
  "AssetPulse",
  version: "1.0.0",
  url: "https://github.com/thiagohrcosta/AssetPulse"
)

Stripe.log_level = Rails.env.development? ? Stripe::LEVEL_INFO : nil

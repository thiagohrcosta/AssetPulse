namespace :stripe do
  desc "Create/update the Stripe Products & Prices for AssetPulse's plans and sync the local Plan cache"
  task sync_plans: :environment do
    if ENV["STRIPE_SECRET_KEY"].blank?
      abort "STRIPE_SECRET_KEY is not set. Add it to .env and re-run (see .env.example)."
    end

    plans = StripePlanSync.call
    plans.each do |plan|
      puts "#{plan.slug.ljust(8)} #{plan.name.ljust(20)} $#{'%.2f' % plan.amount} / #{plan.interval} -> #{plan.stripe_price_id}"
    end
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'

# SimpleCov must start before any application code is loaded so it can
# track every file as it's required.
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "app/channels/application_cable"
  # Unused Rails scaffolding — no ActiveJob/ActionMailer classes exist yet.
  add_filter "app/jobs/application_job.rb"
  add_filter "app/mailers/application_mailer.rb"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"
  add_group "Lib", "app/lib"

  minimum_coverage 90
end

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

# Sensible test-only defaults for env vars the app fetches at request time
# (Stripe checkout/webhook URLs & secret) so specs don't need a real .env.
ENV["STRIPE_WEBHOOK_SECRET"] ||= "whsec_test_secret"
ENV["STRIPE_CHECKOUT_SUCCESS_URL"] ||= "http://localhost:3001/billing/success"
ENV["STRIPE_CHECKOUT_CANCEL_URL"] ||= "http://localhost:3001/billing/cancel"

require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "devise"
require "factory_bot_rails"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories.
Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }

# Ensures that the test database schema matches the current schema file.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include RequestSpecHelper, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

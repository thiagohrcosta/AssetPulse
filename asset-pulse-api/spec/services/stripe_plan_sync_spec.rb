require "rails_helper"

RSpec.describe StripePlanSync do
  # StripePlanSync syncs every entry in PLAN_DEFINITIONS (basic, premium) in
  # one #call, so stubs must key off the lookup_key/args to return a distinct
  # price per plan — a single fixed double would collide on the unique
  # stripe_price_id index.
  def stub_price_list(existing_by_lookup_key: {})
    allow(Stripe::Price).to receive(:list) do |args|
      double(data: Array(existing_by_lookup_key[args[:lookup_keys].first]))
    end
  end

  def stub_price_and_product_create(product_id_for: ->(name) { "prod_#{name}" })
    allow(Stripe::Product).to receive(:create) do |args|
      double("Stripe::Product", id: product_id_for.call(args[:metadata][:slug]))
    end
    allow(Stripe::Price).to receive(:create) do |args|
      double("Stripe::Price", id: "price_#{args[:metadata][:slug]}", product: double(id: args[:product]))
    end
  end

  describe ".call" do
    it "creates a Plan for each definition when no Stripe price exists yet" do
      stub_price_list
      stub_price_and_product_create

      plans = described_class.call

      expect(plans.map(&:slug)).to contain_exactly("basic", "premium")
      expect(Plan.count).to eq(2)
      basic = Plan.find_by(slug: "basic")
      expect(basic.stripe_product_id).to eq("prod_basic")
      expect(basic.stripe_price_id).to eq("price_basic")
      expect(basic.active).to be true
    end

    it "reuses an existing price when one is found by lookup_key, without creating a new one" do
      existing_product = double("Stripe::Product", id: "prod_existing")
      existing_price = double("Stripe::Price", id: "price_existing", product: existing_product)
      stub_price_list(existing_by_lookup_key: { "asset_pulse_basic_monthly" => existing_price })
      # premium still has no existing price, so it goes through create.
      stub_price_and_product_create

      described_class.call

      expect(Plan.find_by(slug: "basic").stripe_price_id).to eq("price_existing")
      expect(Plan.find_by(slug: "basic").stripe_product_id).to eq("prod_existing")
      expect(Plan.find_by(slug: "premium").stripe_price_id).to eq("price_premium")
    end

    it "handles a price whose product is returned as a bare string id" do
      stub_price_list
      allow(Stripe::Product).to receive(:create) do |args|
        double("Stripe::Product", id: "prod_#{args[:metadata][:slug]}")
      end
      allow(Stripe::Price).to receive(:create) do |args|
        # `product` here is a bare string id, not an object with #id.
        double("Stripe::Price", id: "price_#{args[:metadata][:slug]}", product: args[:product])
      end

      described_class.call

      expect(Plan.find_by(slug: "basic").stripe_product_id).to eq("prod_basic")
    end

    it "updates an existing plan on re-sync instead of duplicating it" do
      existing = create(:plan, slug: "basic")
      stub_price_list
      stub_price_and_product_create

      # "basic" already exists (updated in place) — only "premium" is new.
      expect { described_class.call }.to change { Plan.count }.by(1)
      expect(existing.reload.stripe_price_id).to eq("price_basic")
    end
  end
end

class CreatePlans < ActiveRecord::Migration[7.2]
  def change
    create_table :plans do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "usd"
      t.string :interval, null: false, default: "month"
      t.boolean :ai_enabled, null: false, default: false
      t.boolean :active, null: false, default: true

      # Populated by `rails stripe:sync_plans` (app/services/stripe_plan_sync.rb),
      # which creates/updates the matching Product + Price in Stripe.
      t.string :stripe_product_id
      t.string :stripe_price_id

      t.timestamps
    end

    add_index :plans, :slug, unique: true
    add_index :plans, :stripe_price_id, unique: true
  end
end

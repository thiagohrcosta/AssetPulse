class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :company, null: false, foreign_key: true, index: { unique: true }
      t.references :plan, foreign_key: true

      # Mirrors a Stripe subscription's lifecycle. "trialing" also covers the
      # card-less 7-day trial, which never gets a stripe_subscription_id.
      t.string :status, null: false, default: "trialing"

      t.string :stripe_customer_id
      t.string :stripe_subscription_id

      t.datetime :trial_ends_at
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, null: false, default: false

      t.timestamps
    end

    add_index :subscriptions, :stripe_customer_id, unique: true
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :status
  end
end

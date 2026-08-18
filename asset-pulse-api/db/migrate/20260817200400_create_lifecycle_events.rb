class CreateLifecycleEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :lifecycle_events do |t|
      t.references :part, null: false, foreign_key: true
      # Host unit and company as of this event, not the part's current one —
      # a part's custody moves over time (installed, reassigned, ...).
      t.references :host_unit, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :installation_type
      t.datetime :occurred_at, null: false
      t.integer :age_at_event_days, null: false
      t.text :notes

      t.timestamps
    end

    add_index :lifecycle_events, :event_type
    add_index :lifecycle_events, [ :part_id, :occurred_at ]
  end
end

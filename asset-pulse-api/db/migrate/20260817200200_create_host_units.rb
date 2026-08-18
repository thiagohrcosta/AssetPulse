class CreateHostUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :host_units do |t|
      t.references :company, null: false, foreign_key: true
      t.string :vin, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :host_units, :vin, unique: true
  end
end

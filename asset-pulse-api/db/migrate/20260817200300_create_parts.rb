class CreateParts < ActiveRecord::Migration[7.2]
  def change
    create_table :parts do |t|
      t.references :part_type_reference, null: false, foreign_key: true
      # Nil while the part is off any vehicle: at a repair shop, or scrapped.
      t.references :host_unit, foreign_key: true
      # Denormalized current owner — needed because a part can sit between
      # host units (e.g. at a repair shop) with no host_unit at all.
      t.references :company, null: false, foreign_key: true
      t.string :serial_number, null: false
      t.string :manufacturer, null: false
      t.string :model, null: false
      t.string :status, null: false, default: "installed"

      t.timestamps
    end

    add_index :parts, :serial_number, unique: true
    add_index :parts, [ :part_type_reference_id, :manufacturer, :model ],
      name: "index_parts_on_type_manufacturer_model"
  end
end

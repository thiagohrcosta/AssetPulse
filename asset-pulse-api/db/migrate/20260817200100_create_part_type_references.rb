class CreatePartTypeReferences < ActiveRecord::Migration[7.2]
  def change
    create_table :part_type_references do |t|
      t.string :part_type, null: false
      t.integer :typical_lifespan_days, null: false

      t.timestamps
    end

    add_index :part_type_references, :part_type, unique: true
  end
end

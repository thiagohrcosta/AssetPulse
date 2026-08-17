class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|

      t.string :name, null:false
      t.string :registration_number, null: false
      t.integer :address_zip_code, null: false
      t.string :address_street, null: false
      t.integer :address_number, null: false
      t.string :address_city, null: false
      t.string :address_complement
      t.string :address_state, null: false

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

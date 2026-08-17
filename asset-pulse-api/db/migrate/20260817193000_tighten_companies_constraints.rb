class TightenCompaniesConstraints < ActiveRecord::Migration[7.2]
  def change
    change_column_null :companies, :user_id, false
    add_index :companies, :registration_number, unique: true
  end
end

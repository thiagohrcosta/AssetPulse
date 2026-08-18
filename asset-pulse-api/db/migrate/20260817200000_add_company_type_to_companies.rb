class AddCompanyTypeToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :company_type, :string, null: false, default: "fleet_operator"
    add_index :companies, :company_type
  end
end

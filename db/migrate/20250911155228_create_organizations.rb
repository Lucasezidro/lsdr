class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :company_name
      t.string :document_number
      t.date :founding_date
      t.string :email
      t.string :phone
      t.string :website_url
      t.string :description

      t.timestamps
    end
  end
end

class AddSalaryFieldToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :salary, :string
  end
end

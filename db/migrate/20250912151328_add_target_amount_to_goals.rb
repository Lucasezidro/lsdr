class AddTargetAmountToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :target_amount, :decimal
  end
end

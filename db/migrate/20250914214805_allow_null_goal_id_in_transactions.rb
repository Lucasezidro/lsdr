class AllowNullGoalIdInTransactions < ActiveRecord::Migration[7.1]
  def change
    change_column_null :transactions, :goal_id, true
  end
end
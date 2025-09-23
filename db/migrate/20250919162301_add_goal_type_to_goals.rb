class AddGoalTypeToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :goal_type, :string
    add_reference :goals, :user, foreign_key: true
  end
end
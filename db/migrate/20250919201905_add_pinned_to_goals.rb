class AddPinnedToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :pinned, :boolean, default: false
  end
end

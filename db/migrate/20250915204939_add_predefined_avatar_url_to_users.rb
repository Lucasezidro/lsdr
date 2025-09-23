class AddPredefinedAvatarUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :predefined_avatar_url, :string
  end
end

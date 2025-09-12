class AddInvitationStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :invitation_status, :string
  end
end

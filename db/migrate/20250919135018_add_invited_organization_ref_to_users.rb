class AddInvitedOrganizationRefToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :invited_organization, foreign_key: { to_table: :organizations }
  end
end
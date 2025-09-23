class Organization < ApplicationRecord
  class InviteErorr < StandardError; end
  
  has_many :users
  has_many :goals
  has_many :transactions

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id', optional: true

  validates :user_id, uniqueness: { message: "já é dono de uma organização." }, on: :create

  class << self
    def invite(current_user, email_to_invite)
      unless current_user.management_organization.present?
        raise InviteErorr, 'Você não tem permissão para convidar membros para esta organização.'
      end

      user = User.find_by(email: email_to_invite)

      raise 'Usuário não encontrado' if user.nil?
      raise 'Usuário já pertence a uma organização' if user.organization.present?
      raise 'Apenas ADMIN ou MANAGER podem convidar usuários' unless current_user.manage_organization?

      user.update_attributes(role: 'EMPLOYEE', 
                             invitation_status: 'pending_invitation', 
                             organization: current_user.management_organization) 
      user
    end
  end


  def total_balance
    total_income - total_expenses
  end

  def total_income
    transactions.where(transaction_type: 'income').sum(:amount) || 0
  end

  def total_expenses
    transactions.where(transaction_type: 'expense').sum(:amount) || 0
  end
end

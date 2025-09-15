class Organization < ApplicationRecord
  has_many :users
  has_many :goals
  has_many :transactions

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  validates :user_id, uniqueness: { message: "já é dono de uma organização." }

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

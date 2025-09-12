class Organization < ApplicationRecord
  has_many :users
  has_many :goals
  has_many :transactions
end

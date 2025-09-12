class Transaction < ApplicationRecord
  belongs_to :organization
  belongs_to :goal
end

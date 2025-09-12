class Goal < ApplicationRecord
  belongs_to :organization
  has_many :transactions

  validates :status, inclusion: { in: %w(in_progress finished cancelled paused) }
end

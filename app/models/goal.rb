class Goal < ApplicationRecord
  belongs_to :organization

  validates :status, inclusion: { in: %w(in_progress finished cancelled paused) }
end

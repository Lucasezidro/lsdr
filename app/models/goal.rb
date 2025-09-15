class Goal < ApplicationRecord
  belongs_to :organization
  has_many :transactions

  validates :status, inclusion: { in: %w(in_progress finished cancelled paused) }

  def progress_amount
    transactions.sum(:amount) || 0
  end

  def progress_percentage
    return 0 if target_amount.nil? || target_amount.zero?
    (progress_amount.to_f / target_amount.to_f) * 100
  end

  def progress_status_message
    if progress_amount >= target_amount
      "Meta alcançada!"
    elsif due_date.past?
      "Prazo expirado. Meta não alcançada."
    elsif due_date < 7.days.from_now
      "Atenção: o prazo final da meta está se aproximando."
    else
      "Em progresso."
    end
  end
end
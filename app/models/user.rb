class User < ApplicationRecord
  has_secure_password validations: false
  belongs_to :organization, optional: true

  validates :password, presence: true, on: :create
  validates :role, presence: true, inclusion: { in: %w[ADMIN MANAGER EMPLOYEE] }
  validate :one_admin_per_organization, if: -> { role == "ADMIN" && organization.present? }

  validates :invitation_status, inclusion: { in: %w[pending_invitation accepted] }

  after_initialize :set_default_status, if: :new_record?

  after_initialize :set_default_role, if: :new_record?

  def as_json(options = {})
    super(options.merge({ only: [:id, :name, :email, :created_at, :updated_at, :role, :organization_id, :invitation_status] }))
  end

  has_one :address
  accepts_nested_attributes_for :address, allow_destroy: true

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64
    self.invitation_sent_at = Time.now.utc
    save!
  end

  def invitation_token_valid?
    invitation_sent_at.present? && invitation_sent_at > 24.hours.ago
  end

  private
  def set_default_role
    self.role ||= "EMPLOYEE"
  end

  def set_default_status
    self.invitation_status ||= "pending_invitation"
  end

  def one_admin_per_organization
    admin_count = organization.users.where(role: "ADMIN").where.not(id: id).count
    if admin_count >= 1
      errors.add(:role, "There can be only one ADMIN per organization")
    end
  end
end
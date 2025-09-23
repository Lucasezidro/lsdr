include Rails.application.routes.url_helpers

class User < ApplicationRecord
  belongs_to :organization, optional: true
  has_one :address
  accepts_nested_attributes_for :address, allow_destroy: true

  has_many :employees, class_name: 'User', foreign_key: 'manager_id'
  belongs_to :manager, class_name: 'User', foreign_key: 'manager_id', optional: true

  has_secure_password
  
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :role, presence: true, inclusion: { in: %w[ADMIN MANAGER EMPLOYEE] }
  validates :invitation_status, inclusion: { in: %w[pending_invitation accepted revoked], allow_nil: true }
  
  validate :one_admin_per_organization, if: -> { role == "ADMIN" && organization.present? }

  MANAGER_ROLES = %w[ADMIN MANAGER].freeze

  def manage_organization?
    MANAGER_ROLES.include?(role) && organization.present?
  end

  def management_organization
    manage_organization? ? organization : nil
  end
  
  def as_json(options = {})
    super(options.merge({
      except: [:password_digest, :invitation_token, :invitation_sent_at, :password_reset_token, :password_reset_sent_at],
      methods: [:avatar_url],
      include: {
        address: {
          only: [:id, :street, :number, :complement, :neighborhood, :city, :state, :zip_code]
        },
        organization: {
          only: [:id, :company_name]
        }
      }
    }))
  end

  def avatar_url
    if predefined_avatar_url.present?
      predefined_avatar_url
    else
      'URL_PADRAO_PARA_AVATAR.png'
    end
  end

  def invitation_token_valid?
    invitation_sent_at.present? && invitation_sent_at > 24.hours.ago
  end

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64
    self.invitation_sent_at = Time.now.utc
    save!
  end

  def generate_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.zone.now
    save!
  end

  private

  def one_admin_per_organization
    admin_count = organization.users.where(role: "ADMIN").where.not(id: id).count
    if admin_count >= 1
      errors.add(:role, "There can be only one ADMIN per organization")
    end
  end

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= "EMPLOYEE"
  end
end
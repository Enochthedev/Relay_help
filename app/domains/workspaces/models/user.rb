class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  # workspace_id on User table functions as the "current" workspace context
  belongs_to :workspace
  
  has_many :workspace_memberships, dependent: :destroy
  has_many :workspaces, through: :workspace_memberships

  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assigned_to_id", dependent: :nullify
  has_many :messages, dependent: :nullify
  has_many :refresh_tokens, dependent: :delete_all

  # Delegated role methods (based on current workspace context)
  delegate :role, to: :current_membership, allow_nil: true

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :discord_user_id, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 8 }, if: :password_required?, allow_blank: false

  # Scopes
  scope :platform_admins, -> { where(platform_admin: true) }
  scope :with_discord, -> { where.not(discord_user_id: nil) }
  scope :pending_invitations, -> { where(invitation_status: "pending") }
  scope :accepted_invitations, -> { where(invitation_status: "accepted") }
  
  # Instance methods
  def current_membership
    return nil unless workspace_id
    workspace_memberships.find_by(workspace_id: workspace_id)
  end

  # Role checks based on current workspace context
  def owner?
    current_membership&.owner?
  end

  def admin?
    current_membership&.admin?
  end

  def member?
    current_membership&.member?
  end

  def workspace_admin?
    admin? || owner?
  end

  def platform_admin?
    platform_admin == true
  end

  def discord_connected?
    discord_user_id.present?
  end

  def display_name
    name.presence || email.split("@").first
  end

  # Invitation methods
  def pending_invitation?
    invitation_status == "pending"
  end
  
  def accepted_invitation?
    invitation_status == "accepted"
  end

  def generate_invitation_token!
    self.invitation_token = SecureRandom.urlsafe_base64(32)
    self.invitation_sent_at = Time.current
    self.invitation_status = "pending"
    save!
  end

  def accept_invitation!(discord_user_id:, discord_username:)
    update!(
      invitation_status: "accepted",
      invitation_accepted_at: Time.current,
      discord_user_id: discord_user_id,
      discord_username: discord_username,
      discord_connected_at: Time.current,
      two_factor_verified: true
    )
  end
   
  def decline_invitation!
    update!(invitation_status: "declined")
  end
  
  def resend_invitation!
    return false if accepted_invitation? # Don't resend accepted invitations
    generate_invitation_token!
  end
  
  def invitation_expired?
    return false unless pending_invitation?
    invitation_sent_at && invitation_sent_at < 7.days.ago
  end

  # Override Devise methods
  def password_required?
    # Only owners need passwords (for web dashboard access)
    return false unless owner?
    
    # If owner and creating new record, require password
    # If owner and updating, only require if password is being changed
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  
  def email_required?
    true
  end
  def can_login?
    encrypted_password.present?
  end

  def needs_password?
    owner? && !can_login?
  end

  def discord_only?
    discord_connected? && !can_login?
  end
end
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  belongs_to :workspace
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assigned_to_id", dependent: :nullify

  enum role: {
    member: "member",
    admin: "admin",
    owner: "owner"
  }

  # Validations
  validates :role, presence: true
  validates :discord_user_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :platform_admins, -> { where(platform_admin: true) }
  scope :workspace_admins, -> { where(role: ["admin", "owner"]) }
  scope :with_discord, -> { where.not(discord_user_id: nil) }
  # Instance methods
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
end
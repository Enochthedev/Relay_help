class WidgetKey < ApplicationRecord
  belongs_to :workspace

  before_validation :generate_keys, on: :create
  
  validates :public_key, presence: true, uniqueness: true, format: { with: /\A(wk_|rh_)[a-f0-9]{32}\z/ }
  validates :secret_key, presence: true
  validates :label, presence: true
  
  scope :active, -> { where(status: "active") }
  
  def active?
    status == "active"
  end
  
  def revoke!
    update!(status: "revoked")
  end
  
  def used!
    increment!(:requests_count)
    touch(:last_used_at)
  end
  
  def domain_allowed?(domain)
    return true if allowed_domains.blank?
    allowed_domains.any? { |d| domain.include?(d) }
  end
  
  private
  
  def generate_keys
    self.public_key ||= "wk_#{SecureRandom.hex(16)}"
    self.secret_key ||= SecureRandom.hex(32)
  end
end

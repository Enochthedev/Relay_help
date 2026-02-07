class ApiKey < ApplicationRecord
  belongs_to :workspace
  belongs_to :created_by, class_name: "User", optional: true
  
  before_create :generate_key
  
  validates :name, presence: true
  
  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }
  
  def revoke!
    update!(revoked_at: Time.current)
  end
  
  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end
  
  private
  
  def generate_key
    raw_key = SecureRandom.hex(32)
    self.key_prefix = "rh_#{SecureRandom.hex(4)}"
    self.key_hash = Digest::SHA256.hexdigest(raw_key)
    
    # Return the raw key (only shown once!)
    @raw_key = "#{key_prefix}_#{raw_key}"
  end
  
  def raw_key
    @raw_key
  end
end
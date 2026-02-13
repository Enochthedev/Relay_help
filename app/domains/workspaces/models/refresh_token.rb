# frozen_string_literal: true

class RefreshToken < ApplicationRecord
  belongs_to :user

  # Token is stored as digest, not plaintext
  attr_accessor :token

  before_create :set_token_digest

  # Scopes
  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  # Generate a new token and return the plaintext (only available on create)
  def self.generate_for(user, request: nil, expires_in: nil)
    expires_in ||= ENV.fetch('REFRESH_TOKEN_EXPIRY_DAYS', 7).to_i.days
    
    token_record = new(
      user: user,
      expires_at: Time.current + expires_in,
      user_agent: request&.user_agent&.truncate(255),
      ip_address: request&.remote_ip
    )
    
    # Generate random token
    token_record.token = SecureRandom.urlsafe_base64(32)
    token_record.save!
    
    token_record
  end

  # Find token by plaintext value
  def self.find_by_token(plaintext_token)
    return nil if plaintext_token.blank?
    
    digest = Digest::SHA256.hexdigest(plaintext_token)
    active.find_by(token_digest: digest)
  end

  # Revoke this token
  def revoke!
    update!(revoked_at: Time.current)
  end

  # Revoke all tokens for a user (logout everywhere)
  def self.revoke_all_for_user(user)
    where(user: user, revoked_at: nil).update_all(revoked_at: Time.current)
  end

  # Check if token is valid
  def valid_token?
    revoked_at.nil? && expires_at > Time.current
  end

  private

  def set_token_digest
    self.token_digest = Digest::SHA256.hexdigest(token) if token.present?
  end
end

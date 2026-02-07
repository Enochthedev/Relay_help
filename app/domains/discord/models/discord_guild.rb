class DiscordGuild < ApplicationRecord
  belongs_to :workspace
  
  validates :guild_id, presence: true, uniqueness: true
  
  def connected?
    guild_id.present?
  end
  
  def support_channel_configured?
    support_channel_id.present?
  end
end
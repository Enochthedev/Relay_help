class WidgetKeySerializer
  include JSONAPI::Serializer

  attributes :id, :public_key, :label, :allowed_domains, :last_used_at, :requests_count, :status, :created_at

  attribute :secret_key do |object|
    # Only show secret key on creation? For now, show always to simplify testing.
    object.secret_key
  end
end

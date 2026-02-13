# frozen_string_literal: true

# Middleware to transform incoming request keys from camelCase to snake_case
# Handles: JSON body params, query string params, and form-urlencoded params
# Pairs with CamelCaseResponseMiddleware for full bidirectional conversion
#
# Request flow:  JS sends { "apiKey": "abc" }  →  Rails sees params[:api_key]
# Response flow: Rails renders { api_key: "abc" }  →  JS receives { "apiKey": "abc" }
class SnakeCaseParamsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Transform query string params (GET, DELETE, any request with query params)
    transform_query_string!(env)

    # Transform request body params (POST, PUT, PATCH with JSON body)
    transform_json_body!(env)

    @app.call(env)
  end

  private

  def transform_query_string!(env)
    query = env['QUERY_STRING']
    return if query.nil? || query.empty?

    params = Rack::Utils.parse_query(query)
    transformed = deep_transform_keys(params)
    env['QUERY_STRING'] = Rack::Utils.build_query(transformed)
  end

  def transform_json_body!(env)
    content_type = env['CONTENT_TYPE'] || env['HTTP_CONTENT_TYPE']
    return unless content_type&.include?('application/json')

    body = env['rack.input']&.read
    env['rack.input']&.rewind
    return if body.nil? || body.empty?

    begin
      json = JSON.parse(body)
      transformed = deep_transform_keys(json)
      new_body = JSON.generate(transformed)

      env['rack.input'] = StringIO.new(new_body)
      env['CONTENT_LENGTH'] = new_body.bytesize.to_s
    rescue JSON::ParserError
      # Not valid JSON, continue with original body
    end
  end

  def deep_transform_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(k, v), result|
        result[k.to_s.underscore] = deep_transform_keys(v)
      end
    when Array
      value.map { |v| deep_transform_keys(v) }
    else
      value
    end
  end
end

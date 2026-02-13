# frozen_string_literal: true

# Middleware to transform JSON response keys from snake_case to camelCase
# Pairs with SnakeCaseParamsMiddleware for full bidirectional conversion
#
# Request flow:  JS sends { "apiKey": "abc" }  →  Rails sees params[:api_key]
# Response flow: Rails renders { api_key: "abc" }  →  JS receives { "apiKey": "abc" }
class CamelCaseResponseMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    # Only transform JSON responses
    # Check both string-key and symbol-key variants for content type
    content_type = headers['Content-Type'] || headers['content-type'] || ''
    if content_type.include?('application/json')
      body = +''
      response.each { |part| body << part }
      response.close if response.respond_to?(:close)

      # Don't transform empty bodies
      return [status, headers, [body]] if body.empty?

      begin
        json = JSON.parse(body)
        transformed = deep_transform_keys(json)
        new_body = JSON.generate(transformed)
        headers['Content-Length'] = new_body.bytesize.to_s
        return [status, headers, [new_body]]
      rescue JSON::ParserError
        # Not valid JSON, return original
        return [status, headers, [body]]
      end
    end

    [status, headers, response]
  end

  private

  def deep_transform_keys(value)
    case value
    when Hash
      value.each_with_object({}) do |(k, v), result|
        result[k.to_s.camelize(:lower)] = deep_transform_keys(v)
      end
    when Array
      value.map { |v| deep_transform_keys(v) }
    else
      value
    end
  end
end

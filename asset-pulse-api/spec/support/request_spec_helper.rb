module RequestSpecHelper
  # Parses the last JSON response body into a Hash/Array with indifferent
  # access to symbol/string keys.
  def json
    JSON.parse(response.body, symbolize_names: true)
  end

  # Bearer-token header for a given user, built the same way the real
  # AuthController issues tokens.
  def auth_headers(user)
    { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
  end
end

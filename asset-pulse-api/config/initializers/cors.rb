# Allow the frontend (asset-pulse-web, served from a different origin) to
# call this JSON API, including the JWT Authorization header and multipart
# uploads (company logo).
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # .strip + .chomp("/") guard against copy-paste mistakes in the env var
    # (trailing slash, stray newline/whitespace) that would otherwise make
    # the exact-string match in rack-cors silently reject every origin.
    allowed_origins = ENV.fetch("CORS_ORIGINS", "http://localhost:3001")
      .split(",")
      .map { |origin| origin.strip.chomp("/") }
      .reject(&:empty?)

    origins allowed_origins

    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

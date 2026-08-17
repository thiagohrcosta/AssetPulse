# Allow the frontend (asset-pulse-web, served from a different origin) to
# call this JSON API, including the JWT Authorization header and multipart
# uploads (company logo).
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:3001").split(",")

    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

# The `cloudinary` gem ships an Active Storage service
# (ActiveStorage::Service::CloudinaryService, used by the `cloudinary:` entry
# in config/storage.yml) but doesn't require it automatically — only its
# ActionView/ActionController/CarrierWave integrations autoload on boot. Wire
# it in explicitly so `config.active_storage.service = :cloudinary` works.
#
# This has to work around a boot-order chicken-and-egg problem: the first
# reference to ActiveStorage::Blob anywhere in the app runs Active Storage's
# `active_storage.services` initializer, which immediately resolves whatever
# service config.active_storage.service points to (here, :cloudinary) — but
# ActiveStorage::Service::CloudinaryService doesn't exist yet at that point,
# since the very first line of the file that defines it *also* references
# ActiveStorage::Blob. We sidestep it by hiding the configured service name
# while requiring the file, then wiring it up ourselves once it's defined.
Rails.application.config.after_initialize do
  next unless defined?(ActiveStorage::Blob)

  configured_service = Rails.configuration.active_storage.service
  Rails.configuration.active_storage.service = nil

  require "active_storage/service/cloudinary_service"

  Rails.configuration.active_storage.service = configured_service
  if configured_service
    ActiveStorage::Blob.service = ActiveStorage::Blob.services.fetch(configured_service)
  end
end

# Credentials are read by the gem itself from the CLOUDINARY_URL env var
# (format: cloudinary://<api_key>:<api_secret>@<cloud_name>), set via
# docker-compose.yml / .env. See https://cloudinary.com/console for the
# account's own URL.

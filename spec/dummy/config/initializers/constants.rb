module App
  PERMITTED_IMAGE_TYPES = Rails.configuration.active_storage.web_image_content_types
  PERMITTED_IMAGE_SIZE = 5.megabytes
end

require 'active_support/core_ext/numeric/bytes'

module Koi
  module KoiAsset
    class << self
      # Image to use when no icon cannot be found
      attr_accessor :unknown_image

      # Default file upload size limit
      attr_accessor :size_limit

      # Back end file storage provider for images and documents.
      # one of :dragonfly, :active_storage, :dragonfly_active_storage (used for migrating)
      attr_accessor :storage_backend

      def use_dragonfly?
        %i[dragonfly dragonfly_active_storage].include?(storage_backend)
      end

      def use_active_storage?
        %i[active_storage dragonfly_active_storage].include?(storage_backend)
      end
    end

    @unknown_image   = 'koi/application/icon-file-unknown.png'
    @size_limit      = 5.megabytes
    @storage_backend = defined?(Dragonfly::Model) ? :dragonfly : :active_storage
  end
end

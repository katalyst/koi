# frozen_string_literal: true

require "active_support/core_ext/numeric"

module Koi
  class Config
    attr_accessor :admin_name,
                  :authenticate_local_admins,
                  :resource_name_candidates,
                  :admin_stylesheet,
                  :admin_javascript_entry_point,
                  :document_mime_types,
                  :document_size_limit,
                  :image_mime_types,
                  :image_size_limit,
                  :site_name

    def initialize
      @admin_name = "Koi"
      @authenticate_local_admins = Rails.env.development?
      @resource_name_candidates = %i[title name]
      @admin_stylesheet = "admin"
      @admin_javascript_entry_point = "@katalyst/koi"
      @document_mime_types = %w[image/png image/gif image/jpeg image/webp application/pdf audio/*].freeze
      @document_size_limit = 10.megabytes
      @image_mime_types = %w[image/png image/gif image/jpeg image/webp].freeze
      @image_size_limit = 10.megabytes
    end
  end
end

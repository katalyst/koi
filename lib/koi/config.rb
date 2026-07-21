# frozen_string_literal: true

require "active_support/core_ext/hash/deep_merge"
require "active_support/core_ext/numeric"
require "active_support/ordered_options"

module Koi
  class Config
    attr_accessor :action_text_editor,
                  :admin_name,
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
      @action_text_editor           = nil
      @admin_name                   = "Koi"
      @authenticate_local_admins    = Rails.env.development?
      @resource_name_candidates     = %i[title name]
      @admin_stylesheet             = "admin"
      @admin_javascript_entry_point = "@katalyst/koi"
      @document_mime_types          = %w[image/png image/gif image/jpeg image/webp application/pdf audio/*].freeze
      @document_size_limit          = 10.megabytes
      @image_mime_types             = %w[image/png image/gif image/jpeg image/webp].freeze
      @image_size_limit             = 10.megabytes
    end

    # Identity & access settings for OIDC authentication.
    def identity
      @identity ||= ActiveSupport::OrderedOptions.new.merge!(providers: {}, members: {})
    end

    def identity=(options)
      identity.deep_merge!(options.to_h)
    end

    # Load config/koi.yml, if present
    def load(app)
      app.config_for(:koi).each do |attribute, value|
        public_send("#{attribute}=", value)
      end

      self
    rescue RuntimeError => e
      raise unless e.message.start_with?("Could not load configuration")

      self
    end

    private

    def method_missing(name, *) # rubocop:disable Style/MissingRespondToMissing
      return super unless name.to_s.end_with?("=")

      raise ArgumentError, "Unknown Koi config setting: #{name.to_s.chomp('=')}"
    end
  end
end

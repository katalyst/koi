# frozen_string_literal: true

module Koi
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def action_text_editor
      return config.action_text_editor if config.action_text_editor.present?

      defined?(::Lexxy) && defined?(::Flipper) && Flipper.enabled?(:lexxy, Koi::Current.admin_user) ? :lexxy : :trix
    end
  end
end

require "koi/engine"

# frozen_string_literal: true

require "active_support"
require "active_support/rails"

module Koi
  extend ActiveSupport::Autoload

  autoload :Config

  extend self

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end
end

require "koi/engine"

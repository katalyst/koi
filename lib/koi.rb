# frozen_string_literal: true

module Koi
  extend self

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end
end

require "koi/engine"

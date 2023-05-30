# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("dummy/spec/rails_helper", __dir__)

Dir[Koi::Engine.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

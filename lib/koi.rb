# frozen_string_literal: true

require "importmap-rails"
require "katalyst/govuk/formbuilder"
require "govuk_design_system_formbuilder/concerns/file_element"
require "govuk_design_system_formbuilder/elements/document"
require "govuk_design_system_formbuilder/elements/image"
require "katalyst/tables"
require "pagy"
require "stimulus-rails"
require "turbo-rails"
require "webauthn"

require "koi/form_builder"
require "koi/menu"
require "koi/caching"
require "koi/collection"
require "koi/config"
require "koi/engine"
require "koi/extensions"
require "koi/release"

require "katalyst/content"
require "katalyst/kpop"
require "katalyst/navigation"

require "view_component"

module Koi
  extend self

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end
end

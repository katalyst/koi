# frozen_string_literal: true

require "importmap-rails"
require "jquery-rails"
require "katalyst/govuk/formbuilder"
require "govuk_design_system_formbuilder/concerns/file_element"
require "govuk_design_system_formbuilder/elements/document"
require "govuk_design_system_formbuilder/elements/image"
require "katalyst/tables"
require "pagy"
require "stimulus-rails"
require "turbo-rails"

require "koi/config"
require "koi/form_builder"
require "koi/menu"
require "koi/caching"
require "koi/engine"

require "katalyst/content"
require "katalyst/navigation"

module Koi
end

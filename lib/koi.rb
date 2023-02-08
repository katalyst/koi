# frozen_string_literal: true

require "acts-as-taggable-on"
require "cocoon"
require "csv"
require "devise"
require "dragonfly"
require "has_scope"
require "importmap-rails"
require "inherited_resources"
require "jquery-rails"
require "jquery-ui-rails"
require "kaminari"
require "katalyst/govuk/formbuilder"
require "govuk_design_system_formbuilder/concerns/file_element"
require "govuk_design_system_formbuilder/elements/document"
require "govuk_design_system_formbuilder/elements/image"
require "katalyst/tables"
require "pagy"
require "scoped_search"
require "select2-rails"
require "stimulus-rails"
require "turbo-rails"

require "koi/config"
require "koi/form_builder"
require "koi/menu"
require "koi/priority_menu"
require "koi/caching"
require "koi/engine"

require "katalyst/content"
require "katalyst/navigation"

module Koi
end

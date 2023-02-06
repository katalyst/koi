# frozen_string_literal: true

require "acts-as-taggable-on"
require "awesome_nested_set"
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
require "scoped_search"
require "select2-rails"
require "simple_form"
require "stimulus-rails"
require "turbo-rails"

require "koi/config"
require "has_crud/has_crud"
require "exportable/exportable"
require "koi/form_builder"
require "koi/menu"
require "koi/priority_menu"
require "koi/caching"
require "koi/engine"

require "katalyst/content"
require "katalyst/navigation"

module Koi
end

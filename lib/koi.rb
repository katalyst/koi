# frozen_string_literal: true

require "acts-as-taggable-on"
require "awesome_nested_set"
require "cocoon"
require "csv"
require "devise"
require "dragonfly"
require "friendly_id"
require "has_scope"
require "importmap-rails"
require "inherited_resources"
require "jquery-rails"
require "jquery-ui-rails"
require "kaminari"
require "katalyst/govuk/formbuilder"
require "govuk_design_system_formbuilder/elements/image"
require "katalyst/tables"
require "scoped_search"
require "select2-rails"
require "simple_form"
require "simple_navigation"
require "stimulus-rails"
require "turbo-rails"

require "koi/config"
require "has_crud/has_crud"
require "has_navigation/has_navigation"
require "has_settings/has_settings"
require "exportable/exportable"
require "koi/menu"
require "koi/priority_menu"
require "koi/koi_asset"
require "koi/koi_assets/image"
require "koi/koi_assets/document"
require "koi/navigation"
require "koi/settings"
require "koi/sitemap"
require "koi/caching"
require "koi/engine"

require "katalyst/content"
require "katalyst/navigation"

module Koi
end

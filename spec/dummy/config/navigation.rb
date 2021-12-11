# frozen_string_literal: true

# Configures your navigation
SimpleNavigation.register_renderer sf_menu: SfMenuRenderer
SimpleNavigation.register_renderer active_items: ActiveItemsRenderer
SimpleNavigation::Configuration.run do |navigation|
end

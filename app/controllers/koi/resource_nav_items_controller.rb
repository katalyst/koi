# frozen_string_literal: true

module Koi
  class ResourceNavItemsController < NavItemsController
    defaults resource_class: ResourceNavItem
  end
end

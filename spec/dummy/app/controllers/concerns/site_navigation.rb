# frozen_string_literal: true

module SiteNavigation
  extend ActiveSupport::Concern

  module NavigationHelper
    def navigation_for(slug)
      @navigation_menus[slug.to_s]
    end
  end

  included do
    helper Katalyst::Navigation::FrontendHelper
    helper NavigationHelper

    before_action :set_site_navigation
  end

  protected

  def set_site_navigation
    @navigation_menus ||= Katalyst::Navigation::Menu.includes(:published_version).index_by(&:slug) # rubocop:disable Naming/MemoizedInstanceVariableName
  end
end

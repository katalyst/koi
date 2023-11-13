# frozen_string_literal: true

module HasNavigation
  extend ActiveSupport::Concern

  #
  # TO USE:
  #
  # In your model:
  #
  #   has_crud navigation: true
  #
  # It should now show up in the dropdown list when trying to add items in
  # the sitemap.
  #
  # This assumes you have an admin resources route for the model in your routes
  # and that it's not a nested resource. If it's nested, or there's something
  # else out-of-the-ordinary with this resource, you may have to override the
  # below methods `self.get_new_admin_url` and `get_edit_admin_url` in the model to return
  # the correct paths for edit/new, perhaps based on some default parent resource.
  # (Another option would be to have the parent resource selectable in the
  # child resource form rather than it being a nested resource.)
  #
  # Similarly, it assumes that your front end route is not nested. You may need to
  # override the `get_url` method to return the correct route based on the parent if so.
  #
  # Be sure to implement `to_s` in your model so that it correctly generates nav item titles
  #

  class_methods do
    def has_navigation(_options = {})
      # Include class & instance methods.
      include HasNavigation::Model

      has_one :resource_nav_item, as: :navigable, dependent: :destroy
    end
  end

  class UrlHelpers
    include ActionDispatch::Routing::PolymorphicRoutes

    def polymorphic_url(subject, options = {})
      # handle explicit routes defined in the main routing table first
      super
    rescue NoMethodError
      # if an admin route was requested, fall back to koi engine
      (subject = koi_route(subject)) ? super(subject, options) : raise
    end

    def polymorphic_path(subject, options = {})
      # handle explicit routes defined in the main routing table first
      super
    rescue NoMethodError
      # if an admin route was requested, fall back to koi engine
      (subject = koi_route(subject)) ? super(subject, options) : raise
    end

    private

    def koi_route(subject)
      [koi_engine, *subject.slice(1)] if subject.instance_of?(Array) && subject.first == :admin
    end
  end

  class << self
    def url_helpers
      @url_helpers ||= begin
                         # delayed initialization to ensure Rails application has loaded, Rails 5 has better options
                         UrlHelpers.include Rails.application.routes.url_helpers
                         UrlHelpers.include Rails.application.routes.mounted_helpers
                         UrlHelpers.new
                       end
    end
  end

  module Model
    extend ActiveSupport::Concern

    class_methods do
      def get_new_admin_url(options = {})
        HasNavigation.url_helpers.new_polymorphic_path [:admin, self], options
      end
    end

    def get_edit_admin_url(options = {})
      HasNavigation.url_helpers.edit_polymorphic_path [:admin, self], options
    end

    def get_url
      HasNavigation.url_helpers.polymorphic_path(self)
    end

    def get_title
      if respond_to? :title
        title
      elsif respond_to? :name
        name
      else
        to_s
      end
    end

    def get_setting_prefix
      respond_to?(:settings_prefix) ? settings_prefix : nil
    end

    def get_nav_item
      resource_nav_item.presence || ResourceNavItem.new
    end

    def new_title
      get_nav_item.title.presence || get_title
    end

    def to_navigator(options = {})
      resource_nav_item = get_nav_item

      options.reverse_merge!(title: new_title, url: get_url,
                             admin_url: get_edit_admin_url,
                             setting_prefix: get_setting_prefix,
                             navigable: self)

      options.each_key do |key|
        resource_nav_item.send("#{key}=", options[key]) if resource_nav_item.respond_to?(key)
      end

      resource_nav_item
    end

    def to_navigator!(options = {})
      navigator = to_navigator(options)

      if navigator.parent_id.blank?
        true
      elsif navigator.save
        navigator
      else
        false
      end
    end
  end
end

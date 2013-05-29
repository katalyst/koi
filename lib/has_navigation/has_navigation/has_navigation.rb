module HasNavigation
  
  def has_navigation options = {}
    # Include url helpers to generate default path.
    send :include, Rails.application.routes.url_helpers
    # Include class & instance methods.
    send :include, HasNavigation::Model

    has_one :resource_nav_item, as: :navigable, dependent: :destroy
  end

  module Model
    extend ActiveSupport::Concern

    module ClassMethods
    end

    def to_navigator options = {}
      title           = respond_to?(:title) ? title : "#{ self.class.name } - #{ self.id }"
      url             = polymorphic_path self
      admin_url       = begin
                          edit_polymorphic_path [:admin, self]
                        rescue
                          Koi::Engine.routes.url_helpers.send :"edit_#{ self.class.name.singularize.parameterize '_' }_path", self
                        end
      settings_prefix = settings_prefix if respond_to? :settings_prefix

      resource_nav_item = self.resource_nav_item.blank? ? ResourceNavItem.new : self.resource_nav_item
      resource_nav_item.attributes = options.merge navigable: self, title: title, url: url, admin_url: admin_url, setting_prefix: settings_prefix
      resource_nav_item
    end

    def to_navigator! options = {}
      navigator = to_navigator options
      return true      if navigator.parent_id.blank?
      return navigator if navigator.save
      return false
    end
  end

end

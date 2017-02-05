module HasNavigation
  def has_navigation(options={})
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

    def get_admin_url
      begin
      edit_polymorphic_path [:admin, self]
      rescue
        Koi::Engine.routes.url_helpers.send :"edit_#{ self.class.name.singularize.underscore }_path", self
      end
    end

    def get_url
      polymorphic_path(self)
    end

    def get_title
      respond_to?(:title) ? title : "#{self.class} - #{self.id}"
    end

    def get_setting_prefix
      respond_to?(:settings_prefix) ? settings_prefix : nil
    end

    def get_nav_item
      self.resource_nav_item.blank? ? ResourceNavItem.new : self.resource_nav_item
    end

    def new_title
      get_nav_item.title.blank? ? get_title : get_nav_item.title
    end

    def to_navigator(options={})
      resource_nav_item = get_nav_item

      options.reverse_merge!(title: new_title, url: get_url,
                             admin_url: get_admin_url,
                             setting_prefix: get_setting_prefix,
                             navigable: self)

      options.keys.each do |key|
        resource_nav_item.send("#{key}=", options[key]) if resource_nav_item.respond_to?(key)
      end

      resource_nav_item
    end

    def to_navigator!(options={})
      navigator = to_navigator(options)

      if navigator.parent_id.blank?
        return true
      elsif navigator.save
        navigator
      else
        false
      end
    end

  end
end

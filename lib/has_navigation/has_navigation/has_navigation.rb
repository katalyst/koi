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

    def to_navigator(options={})
      options.merge!(:navigable => self)
      resource_nav_item = self.resource_nav_item.blank? ? ResourceNavItem.new : self.resource_nav_item
      resource_nav_item.attributes = options.merge(title: (self.try(:title) || "#{self.class} - #{self.id}"),
                                                   url: polymorphic_path(self),
                                                   admin_url: "/admin#{edit_polymorphic_path(self)}",
                                                   setting_prefix: respond_to?(:settings_prefix) ? settings_prefix : nil)
      resource_nav_item
    end

    def to_navigator!(options={})
      navigator = to_navigator(options)
      return true if navigator.parent_id.blank?
      navigator.save ? navigator : false
    end
  end
end

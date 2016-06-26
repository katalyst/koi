module HasNavigation

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

  def has_navigation(options={})
    # Include url helpers to generate default path.
    send :include, Rails.application.routes.url_helpers
    # Include class & instance methods.
    send :include, HasNavigation::Model

    has_one :resource_nav_item, as: :navigable, dependent: :destroy
  end

  module Model
    extend ActiveSupport::Concern

    class_methods do
      def get_new_admin_url(options={})
        begin
          new_polymorphic_path [:admin, self], options
        rescue
          Rails.application.routes.url_helpers.send :"new_admin_#{ self.name.singularize.parameterize '_' }_path", options
        end
      end
    end

    def get_edit_admin_url(options={})
      begin
      edit_polymorphic_path [:admin, self]
      rescue
        Koi::Engine.routes.url_helpers.send :"edit_admin_#{ self.class.name.singularize.parameterize '_' }_path", self, options
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
                             admin_url: get_edit_admin_url,
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

module Koi::ApplicationHelper
  def kt(args={})
    interpolation = (params[:controller] + "/" + params[:action]).gsub("/", ".")
    args.merge!(resource.attributes.symbolize_keys) if params[:id].present? && respond_to?(:resource)
    args.merge!(klass: resource_class.name) if respond_to? :resource_class
    raw(t(interpolation, args))
  end

  def sortable(column, title = column.titleize, link_opt = {})
    link_params = params.merge sort: column, direction: "asc", page: nil
    link_opt.merge! data: { get_script: true }
    if column == sort_column
      link_params.merge! direction: (sort_direction == "asc" ? "desc" : "asc")
      link_opt.merge_html! class: "sort icon pad-r-15px #{ sort_direction }"
    end
    link_to title, link_params, link_opt
  end

  def is_settable?
    defined?(resource_class) && resource_class.options[:settings]
  end

  def settings
    return [] unless is_settable?
    return @settings if @settings

    begin
      @settings = resource.settings
    rescue ::ActiveRecord::RecordNotFound
      @settings = resource_class.settings
    end
  end

  # Example:
  #
  #   placeholder_image("No Image", width: 100, height: 100) # => <Image>
  #
  def placeholder_image(text, args={})
    image = Dragonfly::App[:images].generate(:text, text, { color: "#fff", background_color: "#ccc", padding: '200' })
    image.process(:crop, { width: 100, height: 100, gravity: "c" }.merge(args))
  end

  # Example:
  #
  #   placeholder_image_tag("No Image", width: 100, height: 100) # => "<img src='/example.png' width='100' height='100' />"
  #
  def placeholder_image_tag(text, args={})
    image_tag('koi/application/placeholder-image-none.png', args)
#    image_tag(placeholder_image(text, args).url, args)
  end

  def new_uuid
    UUIDTools::UUID.timestamp_create().to_s
  end

  def is_koi_core_class?(klass)
    ["Admin", "Page", "Setting", "Translation", "NavItem", "AliasNavItem",
     "ModuleNavItem", "ResourceNavItem", "FolderNavItem", "RootNavItem",
     "FriendlyIdSlug", "UrlRewrite"].include? klass.name
  end

  def ancestor_controllers
    controller.class.ancestors.select { |klass| klass < ActionController::Base }
  end

  def ancestor_controller_names
    ancestor_controllers.map(&:controller_name)
  end

  def ancestor_controller_paths
    ancestor_controllers.map(&:name).map(&:underscore)
  end

  def ancestor_paths
    ancestor_controller_paths.map { |path| path.match(/(.*)_controller/).to_a[1] }
  end
end

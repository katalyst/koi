# frozen_string_literal: true

module Koi
  module ApplicationHelper
    include Katalyst::Tables::Frontend

    def kt(args = {})
      args.merge!(resource.attributes.symbolize_keys) if params[:id].present? && respond_to?(:resource)

      args[:klass] = resource_class.name if respond_to?(:resource_class)

      t(current_url, **args)
    end

    def sortable(column, title = column.titleize, link_opt = {})
      if resource_class.column_names.include?(column)
        link_params = params.merge sort: column, direction: "asc", page: nil
        link_opt[:data] = { get_script: true }
        if column == sort_column.to_s
          link_params[:direction] = (sort_direction.to_s == "asc" ? "desc" : "asc")
          link_opt[:class] = "sort icon pad-r-15px #{sort_direction}"
        end
        link_to title, link_params, link_opt
      else
        content_tag(:span, title)
      end
    end

    # Example:
    #
    #   placeholder_image("No Image", width: 100, height: 100) # => <Image>
    #
    def placeholder_image(text, args = {})
      image = Dragonfly::App[:images].generate(:text, text, { color: "#fff", background_color: "#ccc", padding: "200" })
      image.process(:crop, { width: 100, height: 100, gravity: "c" }.merge(args))
    end

    # Example:
    #
    #   placeholder_image_tag("No Image", width: 100, height: 100)
    #   => "<img src='/example.png' width='100' height='100' />"
    #
    def placeholder_image_tag(_text, args = {})
      image_tag(path_to_image("koi/application/placeholder-image-none.png"), args)
    end

    def new_uuid
      SecureRandom.uuid
    end

    def is_koi_core_class?(klass)
      %w[AdminUser NavItem AliasNavItem
         ModuleNavItem ResourceNavItem FolderNavItem RootNavItem
         FriendlyIdSlug UrlRewrite].include? klass.name
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

    private

    def current_url
      "#{params[:controller]}/#{params[:action]}".gsub("/", ".")
    end

    def single_content_for(name, content = nil, &block)
      @view_flow.set(name, ActiveSupport::SafeBuffer.new)
      content_for(name, content, &block)
    end

    # Icon Helper
    # <%= icon("close", width: 24, height: 24, stroke: "#BADA55", fill: "purple") %>
    def icon(icon_path, options = {})
      options[:width] = 24 if options[:width].blank?
      options[:height] = 24 if options[:height].blank?
      options[:stroke] = "#000000" if options[:stroke].blank?
      options[:fill] = "#000000" if options[:fill].blank?
      options[:class] = "" if options[:class].blank?
      render("koi/shared/icons/#{icon_path}", options: options)
    end

    # SVG Image Helper
    # Converts a dragonfly-stored SVG image to inline SVG with a missing
    # asset fallback.
    def svg_image(image)
      raw image.data # rubocop:disable Rails/OutputSafety
    rescue Dragonfly::Job::Fetch::NotFound
      "Image missing"
    end

    def partial_with_wrapper(&block)
      capture(&block)
    rescue ActionView::MissingTemplate
      nil
    end

    # Navigation helper to mark list item as active
    def navigation_helper(label, link_path, link_opts = {})
      li_opts = request.path.eql?(link_path) ? { class: "selected" } : {}
      content_tag(:li, link_to(label, link_path, link_opts), li_opts)
    end
  end
end

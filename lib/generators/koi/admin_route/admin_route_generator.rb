# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

require_relative "../helpers/attribute_helpers"
require_relative "../helpers/resource_helpers"

module Koi
  class AdminRouteGenerator < Rails::Generators::NamedBase
    include Helpers::AttributeHelpers
    include Helpers::ResourceHelpers

    source_root File.expand_path("templates", __dir__)

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def create_routes
      return if Pathname.new(destination_root).join("config/routes/admin.rb").exist?

      template("routes.rb", "config/routes/admin.rb")
    end

    def add_route
      route "resources :#{file_name.pluralize}"

      if orderable?
        resource_route "patch :order, on: :collection"
      end

      if archivable?
        resource_route "put :restore, on: :collection"
        resource_route "put :archive, on: :collection"
        resource_route "get :archived, on: :collection"
      end
    end

    def create_navigation
      return if Pathname.new(destination_root).join("config/initializers/koi.rb").exist?

      template("initializer.rb", "config/initializers/koi.rb")
    end

    def add_navigation
      gsub_file("config/initializers/koi.rb", /Koi::Menu.modules = ({}|{\n(?:\s+.*\n)*})\n/) do |match|
        # Safe because we know that this only called during code generation
        config        = eval(match) # rubocop:disable Security/Eval
        label         = [*regular_class_path.map(&:humanize), human_name.pluralize].join(" ")
        path          = route_url
        config[label] = path
        config        = config.sort.to_h
        StringIO.new.tap do |io|
          io.puts "Koi::Menu.modules = {"
          config.each do |k, v|
            if v.is_a?(Hash)
              io.puts "  #{k.inspect} => {"
              v.each do |kk, vv|
                io.puts "    #{kk.inspect} => #{vv.inspect},"
              end
              io.puts "  },"
            else
              io.puts "  #{k.inspect} => #{v.inspect},"
            end
          end
          io.puts "}"
        end.string
      end
    end

    private

    # See Rails::Generators::Actions
    # Replaces hard-coded route with admin route file
    def route(routing_code, namespace: regular_class_path)
      namespace         = Array(namespace)
      namespace_pattern = route_namespace_pattern(namespace)
      routing_code      = namespace.reverse.reduce(routing_code) do |code, name|
        "namespace :#{name} do\n#{rebase_indentation(code, 2)}end"
      end

      log :route, routing_code

      in_root do
        if (namespace_match = match_file(route_file, namespace_pattern))
          base_indent, *, existing_block_indent = namespace_match.captures.compact.map(&:length)
          existing_line_pattern                 = /^ {,#{existing_block_indent}}\S.+\n?/
          routing_code = rebase_indentation(routing_code, base_indent + 2).gsub(existing_line_pattern, "")
          namespace_pattern = /#{Regexp.escape namespace_match.to_s}/
        end

        inject_into_file route_file, routing_code, after: namespace_pattern, verbose: true, force: false
      end
    end

    def resource_route(routing_code, namespace: regular_class_path, resource: "resources :#{file_name.pluralize}")
      namespace        = Array(namespace)
      resource_pattern = route_namespace_pattern(namespace, resource)
      block_pattern    = /#{resource_pattern}( do)?\n/

      log :route, routing_code

      in_root do
        resource_match = match_file(route_file, block_pattern)

        if resource_match.captures.last.nil?
          *, current_indent = resource_match.captures.compact.map(&:length)
          inject_into_file route_file, " do\n#{' ' * current_indent}end",
                           after:   resource_pattern,
                           verbose: false,
                           force:   false
        end

        resource_match = match_file(route_file, block_pattern)

        *, existing_block_indent, _ = resource_match.captures.compact.map(&:length)
        routing_code = rebase_indentation(routing_code, existing_block_indent + 2)

        inject_into_file route_file, routing_code, after: block_pattern, verbose: true, force: false
      end
    end

    # See Rails::Generators::Actions
    # Replaces Routes.draw with namespace :admin as the search term
    def route_namespace_pattern(namespace, resource = nil)
      seed = resource ? route_resource_pattern(namespace, resource) : nil

      namespace.each_with_index.reverse_each.reduce(seed) do |pattern, (name, i)|
        cummulative_margin     = "\\#{i + 1}[ ]{2}"
        blank_or_indented_line = "^[ ]*\n|^#{cummulative_margin}.*\n"
        "(?:(?:#{blank_or_indented_line})*?^(#{cummulative_margin})namespace :#{name} do\n#{pattern})?"
      end.then do |pattern|
        /^( *)namespace :admin do\n#{pattern}/
      end
    end

    # Generate a regex for the resource block at the appropriate level of nesting
    def route_resource_pattern(namespace, resource)
      cummulative_margin     = "\\#{namespace.count + 1}[ ]{2}"
      blank_or_indented_line = "^[ ]*\n|^#{cummulative_margin}.*\n"
      "(?:(?:#{blank_or_indented_line})*?^(#{cummulative_margin})#{resource})"
    end

    def route_file
      "config/routes/admin.rb"
    end
  end
end

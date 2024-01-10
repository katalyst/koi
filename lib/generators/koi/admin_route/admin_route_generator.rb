# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Koi
  class AdminRouteGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("templates", __dir__)

    def create_routes
      return if Pathname.new(destination_root).join("config/routes/admin.rb").exist?

      template("routes.rb", "config/routes/admin.rb")
    end

    def add_route
      route "resources :#{file_name.pluralize}", namespace: regular_class_path
    end

    def create_navigation
      return if Pathname.new(destination_root).join("config/initializers/koi.rb").exist?

      template("initializer.rb", "config/initializers/koi.rb")
    end

    def add_navigation
      insert_into_file("config/initializers/koi.rb",
                       "  \"#{[*regular_class_path.map(&:humanize),
                               human_name.pluralize].join(' ')}\" => \"/admin#{route_url}\",\n",
                       after: "Koi::Menu.modules = {\n")
    end

    private

    # See Rails::Generators::Actions
    # Replaces hard-coded route with admin route file
    def route(routing_code, namespace: nil)
      namespace = Array(namespace)
      namespace_pattern = route_namespace_pattern(namespace)
      routing_code = namespace.reverse.reduce(routing_code) do |code, name|
        "namespace :#{name} do\n#{rebase_indentation(code, 2)}end"
      end

      log :route, routing_code

      in_root do
        if (namespace_match = match_file(route_file, namespace_pattern))
          base_indent, *, existing_block_indent = namespace_match.captures.compact.map(&:length)
          existing_line_pattern = /^ {,#{existing_block_indent}}\S.+\n?/
          routing_code = rebase_indentation(routing_code, base_indent + 2).gsub(existing_line_pattern, "")
          namespace_pattern = /#{Regexp.escape namespace_match.to_s}/
        end

        inject_into_file route_file, routing_code, after: namespace_pattern, verbose: true, force: false
      end
    end

    # See Rails::Generators::Actions
    # Replaces Routes.draw with namespace :admin as the search term
    def route_namespace_pattern(namespace)
      namespace.each_with_index.reverse_each.reduce(nil) do |pattern, (name, i)|
        cummulative_margin = "\\#{i + 1}[ ]{2}"
        blank_or_indented_line = "^[ ]*\n|^#{cummulative_margin}.*\n"
        "(?:(?:#{blank_or_indented_line})*?^(#{cummulative_margin})namespace :#{name} do\n#{pattern})?"
      end.then do |pattern|
        /^( *)namespace :admin do\n#{pattern}/
      end
    end

    def route_file
      "config/routes/admin.rb"
    end
  end
end

# frozen_string_literal: true

require "koi/menu/builder"

module Koi
  module Menu
    mattr_accessor :priority
    @@priority = {}

    mattr_accessor :modules
    @@modules = {}

    mattr_accessor :advanced
    @@advanced = {}

    def admin_menu(context)
      builder = Builder.new
      builder.add_menu(title: "Priority") do |b|
        b.add_link(title: "View site", url: "/", target: "_blank")
        b.add_link(title: "Dashboard", url: context.main_app.admin_dashboard_path)
        b.add_items(priority)
        b.add_button(title: "Logout", url: context.main_app.admin_session_path, http_method: :delete)
      end
      builder.add_menu(title: "Modules") do |b|
        b.add_items(modules)
      end
      builder.add_menu(title: "Advanced") do |b|
        b.add_items(advanced)

        if Object.const_defined?("Flipper::UI")
          b.add_link(title:  "Flipper", url: context.main_app.admin_root_path.concat("/flipper"),
                     target: "_blank")
        end
        if Object.const_defined?("Sidekiq::Web")
          b.add_link(title:  "Sidekiq", url: context.main_app.admin_root_path.concat("sidekiq"),
                     target: "_blank")
        end
        b.add_button(title:       "Clear cache", url: context.main_app.admin_cache_path,
                     http_method: :delete)
      end
      builder.render
    end

    module_function(:admin_menu)
  end
end

# frozen_string_literal: true

module Koi
  module Menu
    mattr_accessor :quick_links
    @@quick_links = {}

    mattr_accessor :priority
    @@priority = {}

    mattr_accessor :modules
    @@modules = {}

    mattr_accessor :advanced
    @@advanced = {}

    def admin_menu(context)
      builder = Builder.new
      builder.add_menu(title: "Priority") do |b|
        b.add_link(title: "View website", url: "/", target: :blank)
        b.add_link(title: "Dashboard", url: context.main_app.admin_dashboard_path)
        b.add_items(priority)
      end
      builder.add_menu(title: "Modules") do |b|
        b.add_items(modules)
      end
      builder.add_menu(title: "Advanced") do |b|
        b.add_items(advanced)

        if Object.const_defined?("Flipper::UI")
          b.add_link(title:  "Flipper", url: context.main_app.admin_root_path.concat("/flipper"),
                     target: :blank)
        end
        if Object.const_defined?("Sidekiq::Web")
          b.add_link(title:  "Sidekiq", url: context.main_app.admin_root_path.concat("sidekiq"),
                     target: :blank)
        end
        b.add_button(title:       "Clear cache", url: context.main_app.admin_cache_path,
                     http_method: :delete)
      end
      builder.render
    end

    def dashboard_menu
      builder = Builder.new
      builder.add_menu(title: "Quick links") do |b|
        b.add_link(title: "View website", url: "/", target: :blank)
        b.add_items(quick_links)
      end
      builder.render
    end

    module_function(:admin_menu)
    module_function(:dashboard_menu)
  end
end

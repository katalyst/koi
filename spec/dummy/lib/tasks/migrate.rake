# frozen_string_literal: true

require "optparse"

class NavImporter
  attr_reader :menu

  def self.call(**options)
    new.call(**options)
  end

  def initialize
    @items = []
  end

  def call(slug:, title: slug.humanize.titleize)
    @menu = Katalyst::Navigation::Menu.find_or_initialize_by(slug: slug)
    menu.update!(title: title)

    NavItem.find_by!(key: slug).children.each { |child| add_link(child) }

    menu.update!(items_attributes: @items)
    menu.publish!

    self
  end

  def add_link(nav_item, depth = 0)
    link = Katalyst::Navigation::Link.create!({ menu:    menu,
                                                title:   nav_item.title,
                                                url:     nav_item.url || "#",
                                                visible: !nav_item.is_hidden })
    @items << { id: link.id, depth: depth }
    nav_item.children.each do |child_item|
      add_link(child_item, depth + 1)
    end
  end
end

namespace :migrate do |args|
  desc "Export NavItem menu to NavigationLinks"
  task menu: :environment do
    options = {}
    OptionParser.new(args) do |opts|
      opts.banner = "Usage: rake migrate:menu -- [options]"
      opts.on("-s", "--slug {slug}", "NavItems's key, to use as slug", String) do |slug|
        options[:slug] = slug
      end
      opts.on("-t", "--title {title}", "Title for new menu, defaults to humanized slug", String) do |title|
        options[:title] = title
      end
      args = opts.order!(ARGV) {} #=> this line is required, return `ARGV` with the intended arguments
    end.parse!

    importer = NavImporter.call(**options)
    puts "Menu created (#{importer.menu.id})"
    exit 0
  end
end

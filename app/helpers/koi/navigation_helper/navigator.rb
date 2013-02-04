require 'ostruct'
require Koi::Engine.root.join 'app/helpers/koi/navigation_helper'

module Koi::NavigationHelper

  class Navigator < OpenStruct

    def to_s
      title
    end

    def to_str
      title
    end

    def to_string
      title
    end

    def initialize *etc, &filter
      super etc.extract_options! while Hash === etc.last
      filter_if       = Proc === self.if     ? self.if     : proc { |arg| true  }
      filter_unless   = Proc === self.unless ? self.unless : proc { |arg| false }
      self.filter   ||= proc { |arg| filter_if[arg] && ! filter_unless[arg] } # doesn't work for some reason...
      self.template ||= etc.shift
    end

    def request
      template.request
    end

    def root
      ancestors.first
    end

    def children
      @children ||= case super
      when Array
        super.map do |child|
          case child
          when Navigator
            child
          when Hash
            nav = Navigator.new template, child, &filter
            nav.parent = self
            nav
          end
        end.select &:is_navigable?
      else
        []
      end
    end

    def self_and_children
      @self_and_children ||= [self] + children
    end

    def ancestors
      @ancestors ||= (parent ? parent.ancestors + [parent] : []).drop_while(&:isnt_navigable?)
    end

    def self_and_ancestors
      @self_and_ancestors ||= ancestors + [self]
    end

    def self_and_descendants
      @self_and_descendants ||= [self] + descendants
    end

    def descendants
      @descendants ||= children + children.map(&:descendants).flatten
    end

    def highlight
      @highlight ||= highlight!
    end

    def highlight!
      @highlight  = 00000
      @highlight += 10000 if instance_exec url, &highlights_on if Proc === highlights_on
      @highlight += 00100 if url == request.fullpath
      @highlight += 00001 if url == request.path
      @highlight *= level
      @highlight
    end

    def path_highlight
      @path_highlight ||= ([highlight] + children.map(&:path_highlight)).max
    end

    def negative_highlight
      - highlight
    end

    def is_highlighted?
      @is_highlighted ||= highlight > 0
    end

    def is_path_highlighted?
      @is_path_highlighted ||= path_highlight > 0
    end

    alias_method :on?, :is_path_highlighted?

    def is_mobile?
      @is_mobile
    end

    def is_path_mobile?
      @is_path_mobile = is_mobile? || parent && parent.is_path_mobile? if @is_path_mobile.nil?
      @is_path_mobile
    end

    def is_hidden?
      !! is_hidden
    end

    def is_visible?
      ! is_hidden?
    end

    def is_navigable?
      is_visible? && instance_exec(&filter)
    end

    def isnt_navigable?
      ! is_navigable?
    end

    def level
      @level ||= parent ? parent.level + 1 : 0
    end

    def depth
      @depth ||= - level
    end

    def you_are_elle
      return url unless url.blank? || url == "#"
      return children.first.you_are_elle unless children.empty?
    end

    def link_to *sig
      opt = sig.extract_options!
      opt.keys.grep(/\!$/).each { |key| o = opt.delete(key) and send key.to_s.gsub /!$/, "?" and opt.merge! o }
      opt.keys.grep(/\?$/).each { |key| o = opt.delete(key) and send key and opt.merge_html! o }      
      template.link_to title, you_are_elle, opt
    end

    def content_tag *sig, &blk
      opt = sig.extract_options!
      opt.keys.grep(/\!$/).each { |key| o = opt.delete(key) and send key.to_s.gsub /!$/, "?" and opt.merge! o }
      opt.keys.grep(/\?$/).each { |key| o = opt.delete(key) and send key and opt.merge_html! o }      
      template.content_tag *sig, opt, &blk
    end

  end
end


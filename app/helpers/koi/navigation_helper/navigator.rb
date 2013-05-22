require 'ostruct'
require Koi::Engine.root.join 'app/helpers/koi/navigation_helper'

module Koi::NavigationHelper

  class Navigator < OpenStruct

    class Settings < OpenStruct

      def initialize navigator, *properties
        super properties.pop until properties.empty?
        @navigator = navigator
      end

      attr_accessor :navigator

      def parent
        navigator.parent.settings if navigator.parent
      end

      def method_missing key, *sig, &blk
        return super if /=$/ === key
        return send :"#{ key }=", parent.send(key, *sig, &blk) if parent
      end

    end

    def to_s
      title
    end

    def to_str
      title
    end

    def to_string
      title
    end

    def initialize template, *properties
      super properties.pop until properties.empty? # shift (which is more desirable) doesn't work for some reason...
      @template ||= template
    end

    attr_accessor :template

    def settings
      @settings ||= Settings.new self, super
    end

    def request
      template.request
    end

    def root
      ancestors.first
    end

    def root?
      parent.nil?
    end

    def children
       @children ||= case super
       
       when Array
         super.map do |child|
           case child
           when Navigator then child
           when Hash then Navigator.new template, child.merge(parent: self)
           end
         end
       
       else []
       end
    end

    def visible_children
      @visible_children ||= children.select &:is_visible?
    end

    def self_and_children
      @self_and_children ||= [self] + children
    end

    def self_and_visible_children
      @self_and_visible_children ||= [self] + visible_children
    end

    def ancestors
      @ancestors ||= parent ? parent.ancestors + [parent] : []
    end

    def visible_ancestors
      @visible_ancestors ||= ancestors.drop_while &:is_hidden?
    end

    def ancestors_and_self
      @ancestors_and_self ||= ancestors + [self]
    end

    def visible_ancestors_and_self
      @self_and_visible_ancestors ||= visible_ancestors + [self]
    end

    def descendants
      @descendants ||= children + children.map(&:descendants).flatten
    end

    def visible_descendants
      @visible_descendants ||= visible_children + visible_children.map(&:descendants).flatten
    end

    def self_and_descendants
      @self_and_descendants ||= [self] + descendants
    end

    def self_and_visible_descendants
      @self_and_visible_descendants ||= [self] + visible_descendants
    end

    def negative_highlight
      @negative_highlight ||= -highlight
    end

    def highlight
      @highlight ||= begin
        score  =                   0
        score += 1000000000000000000 if template.instance_exec url, &highlights_on if Proc === highlights_on
        score +=       1000000000000 if url == request.fullpath
        score +=             1000000 if url == request.path
        score += url.length if request.path.start_with? url
        score *= level
        score
      end
    end

    def is_highlighted?
      highlight > 0
    end

    def path_highlight
      @path_highlight ||= ([highlight] + children.map(&:path_highlight)).max
    end

    def is_path_highlighted?
      path_highlight > 0 && (root? || path_highlight == root.path_highlight)
    end

    alias_method :on?, :is_path_highlighted?

    def is_mobile?
      !!@is_mobile
    end

    def is_path_mobile?
      is_mobile? || children.any?(&:is_path_mobile?)
    end

    def is_hidden?
      !is_visible?
    end

    def is_visible?
      !is_hidden && if? && !unless? && (!template.is_mobile_agent? || is_path_mobile?)
    end

    def if?
      Proc === self.if ? template.instance_eval(&self.if) : true
    end

    def unless?
      Proc === self.unless ? template.instance_eval(&self.unless) : false
    end

    def level
      @level ||= parent ? parent.level + 1 : 0
    end

    def depth
      @depth ||= -level
    end

    def path_url
      return url unless url.blank? || url == "#"
      return children.first.path_url unless children.empty?
    end

    def link_to *sig
      opt = sig.extract_options!
      opt.keys.grep(/\!$/).each { |key| o = opt.delete(key) and send key.to_s.gsub /!$/, "?" and opt.merge! o }
      opt.keys.grep(/\?$/).each { |key| o = opt.delete(key) and send key and opt.merge_html! o }      
      template.link_to title, path_url, opt
    end

    def content_tag *sig, &blk
      opt = sig.extract_options!
      opt.keys.grep(/\!$/).each { |key| o = opt.delete(key) and send key.to_s.gsub /!$/, "?" and opt.merge! o }
      opt.keys.grep(/\?$/).each { |key| o = opt.delete(key) and send key and opt.merge_html! o }      
      template.content_tag *sig, opt, &blk
    end

  end
end

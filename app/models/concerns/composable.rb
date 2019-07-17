module Composable
  extend ActiveSupport::Concern

  included do
    class_attribute :_composable, instance_writer: false, default: Hash.new { |h, k| h[k] = {} }
  end

  class_methods do
    DEFAULT_COMPONENTS = [:section, :heading, :text].freeze

    def composable?(field)
      _composable.include?(field)
    end

    def composable_components(field)
      return nil unless composable?(field)
      _composable.dig(field, :components) || DEFAULT_COMPONENTS
    end

    # @deprecated
    def composable_crud_config
      _composable.map { |attr, options| [attr, composable_components(attr)] }.to_h
    end

    # Defines accessors and configuration for a composable field
    def composable(field, opts = {})
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{field}=(value)
          # Deserialise JSON form data
          value = JSON.parse(value) if value.is_a?(String)
          # Strip react-composable-content default group
          value = value["data"] if value.is_a?(Hash)
          self[:#{field}] = value
        end
      RUBY

      _composable[field].merge!(opts)
    end
  end

  def composable?(field)
    self.class.composable?(field) && public_send(field).present?
  end

  # Get formatted composable content grouped in to sections for a specific field
  # * `include_drafts`: true if draft content should be rendered
  def composable_sections(field, opts = {})
    renderer = ::Composable::SectionRenderer.new(opts)
    if (data = self[field])
      data.map(&:with_indifferent_access).reduce(renderer, &:render).result
    end
  end

  # Same as composable_sections but includes drafts
  # @deprecated use composable_sections directly
  def composable_sections_with_drafts(field, opts = {})
    composable_sections(field, opts.merge(include_drafts: true))
  end

  class SectionRenderer
    attr_reader :include_drafts
    alias_method :include_drafts?, :include_drafts

    def initialize(include_drafts: false)
      @include_drafts  = include_drafts
      @current_section = nil
      @result          = []
    end

    # Visits a datum, adding it to the result and returning the renderer
    def render(datum)
      case datum[:component_type]
      when "section"
        @current_section = render_section(datum)
      else
        @current_section ||= new_section(datum[:component_type])
        render_child(@current_section, datum)
      end

      self
    end

    # Creates a new section, adds it to the result, and returns it
    def render_section(datum)
      section = {
        section_type:  datum.fetch(:data, {}).fetch(:section_type, default_section_type),
        section_data:  [],
        section_draft: datum.fetch(:component_draft, false),
        advanced:      datum.fetch(:advanced, {}),
      }
      # Add section to output, unless it's a draft
      @result << section if keep?(datum)
      section
    end

    # Creates a new section to wrap a top-level datum
    def new_section(type)
      section = {
        section_type: default_section_type(type),
        section_data: []
      }
      # No check for draft here because the next item may not be a draft
      # Empty sections will be removed by `result`
      @result << section
      section
    end

    # Creates a new child, adds it to the section, and returns it
    def render_child(section, datum)
      # Mark as draft if section is a draft
      if Koi::ComposableContent.section_drafting_for_children
        datum[:component_draft] = true if section[:section_draft]
      end

      # Remove section-only attributes
      datum.except!("component_collapsed")

      section[:section_data] << datum if keep?(datum)
    end

    # Returns the rendered result
    def result
      @result.reject { |section| section[:section_data].empty? }.as_json
    end

    private

    def keep?(datum)
      include_drafts? || !datum.fetch(:component_draft, false)
    end

    def default_section_type(component_type = nil)
      case component_type.to_s
      when "video"
        "fullwidth"
      when "full_banner"
        "fullwidth"
      else
        Koi::ComposableContent.fallback_section_type
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  class TableComponent < ViewComponent::Base
    include Katalyst::Tables::Frontend
    include Pagy::Frontend
    include Turbo::StreamsHelper

    attr_reader :collection, :id, :partial, :selection

    delegate :paginated?, to: :collection

    renders_one(:filters)
    renders_many(:selected_actions)
    renders_many(:unselected_actions)

    def initialize(collection, id: "table", partial: "table", **html_options)
      @collection   = collection
      @id           = id
      @partial      = partial
      @html_options = html_options

      @selection = SelectionComponent.new(parent: self)
    end

    def call
      table = render(partial:, locals: { component: self, collection:, sort: collection.sorting, selection: }, formats: :html)

      content = tag.div(id:, class: @html_options.delete(:class) || "stack", data: { controller: "selected" }, **@html_options) do
        actions + table + pagination
      end

      view_context.controller.respond_to do |format|
        format.html { filters.to_s + render(selection) + content }
        format.turbo_stream { turbo_stream.replace(id, content) }
      end
    end

    def actions
      tag.div do
        concat(tag.div(class: "actions", data: { selected_target: "selectedActions" }) do
          "<span data-selected-target='number'></span> selected".html_safe +
          selected_actions.map(&:to_s).sum("".html_safe)
        end) if selected_actions?
        concat(tag.div(class: "actions", data: { selected_target: "unselectedActions" }) do
          unselected_actions.map(&:to_s).sum("".html_safe)
        end) if unselected_actions?
      end
    end

    def pagination
      pagy_nav(collection.pagination).html_safe if paginated?
    end

    def url
      url_for
    end

    def url_for(**params)
      view_context.url_for(**collection.attributes.compact_blank, **params)
    end

    class SelectionComponent < ViewComponent::Base

      delegate_missing_to :@form

      def initialize(parent:)
        super

        @parent = parent
      end

      def id
        "#{@parent.id}_selection"
      end

      def call
        form_with(id:,
                  class: "hidden",
                  data: {
                    controller: "selection",
                    action: "selection#submit",
                    selection_selected_outlet: "##{@parent.id}",
                  }) do |form|
          @form = form
          content
        end
      end
    end
  end
end

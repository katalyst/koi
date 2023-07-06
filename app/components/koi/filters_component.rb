# frozen_string_literal: true

module Koi
  class FiltersComponent < ViewComponent::Base

    attr_reader :form

    renders_many :secondaries

    def initialize(collection:)
      @collection = collection
    end

    def call
      tag.nav class: "index-actions", data: { controller: "index-actions", action: actions } do
        form_with(model:  @collection,
                  url:    request.path,
                  method: :get,
                  scope:  "",
                  data:   { controller:   "search",
                            turbo_stream: "",
                            action:       <<~ACTIONS,
                              input->index-actions#update
                              change->index-actions#update
                            ACTIONS
                  }) do |form|
          @form = form

          form.submit("Filter", hidden: "") +
            filters_tag +
            secondary_filters_tag
        end
      end
    end

    def nav_tag(&)
      actions = [
        # TODO these should be on the table component not the filters
        "shortcut:page-prev@document->index-actions#prevPage",
        "shortcut:page-next@document->index-actions#nextPage",
      ].compact.join(" ")
      tag.nav(class: "index-actions", data: { controller: "index-actions", action: actions }, &)
    end

    def filters_tag
      tag.div(content, class: "actions-group")
    end

    def secondary_filters_tag
      tag.div(secondaries.map(&:to_s).sum("".html_safe), class: "actions-group") if secondaries?
    end

    def actions

    end
  end
end

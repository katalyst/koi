# frozen_string_literal: true

module Koi
  module IndexActionsHelper
    def koi_index_actions(search: false, create: false, &)
      IndexActionsBuilder.new(self, search:, create:).render(&)
    end
  end

  class IndexActionsBuilder
    delegate_missing_to :@context

    def initialize(context, search:, create:)
      @context = context
      @search  = search
      @create  = create
    end

    def search?
      !!@search
    end

    def create?
      !!@create
    end

    def render(&)
      tag.nav class: "index-actions", data: { controller: "index-actions", action: actions } do
        form_with(**search_options,
                  data: { controller:   "search",
                          turbo_action: "replace",
                          action:       <<~ACTIONS,
                            input->index-actions#update
                            change->index-actions#update
                            submit->index-actions#submit
                          ACTIONS
                  }) do |form|
          concat(links(form, &))
          concat(sort_input(form))
          concat(search(form)) if create? || search?
        end
      end
    end

    def search(form)
      tag.div class: "actions-group" do
        concat(search_button(form)) if search?
        concat(create_button(form)) if create?
        concat(search_input(form)) if search?
      end
    end

    def sort_input(form)
      form.hidden_field(:sort, value: params[:sort], data: { index_actions_target: "sort" })
    end

    # Hidden button to trigger search, avoids triggering create instead.
    def search_button(form)
      form.submit("Search", hidden: "")
    end

    def create_button(_form)
      tag.button(t("koi.labels.new", default: "New"),
                 type:       :submit,
                 formaction: @create == true ? url_for(action: :new) : new_polymorphic_path(@create),
                 class:      "button--primary",
                 data:       { index_actions_target: "create" })
    end

    def search_input(form)
      form.search_field(:search,
                        placeholder: t("koi.labels.search", default: "Search"),
                        value:       params[:search],
                        data:        { index_actions_target: "search" })
    end

    def links(form, &)
      tag.div(class: "actions-group") do
        yield(form) if block_given?
      end
    end

    def actions
      [
        ("shortcut:cancel@document->index-actions#clear" if search?),
        ("shortcut:create@document->index-actions#create" if create?),
        ("shortcut:search@document->index-actions#search" if search?),
      ].compact.join(" ")
    end

    def search_options
      options = { url: request.path, method: :get, scope: "" }
      options.merge!(@search) if @search.is_a?(Hash)
      options
    end
  end
end

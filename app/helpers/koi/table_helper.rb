# frozen_string_literal: true

module Koi
  module TableHelper
    def koi_table_actions(path:, **options)
      TableActionsBuilder.new(self, path:, **options).render
    end
  end

  class TableActionsBuilder
    delegate_missing_to :@context

    def initialize(context, path:, search: true, create: true)
      @context = context
      @path    = path
      @search  = search
      @create  = create
    end

    def search?
      @search
    end

    def create?
      @create
    end

    def render(&)
      tag.nav class: "index-table-actions ornament-form", data: { controller: "table-actions", action: actions } do
        concat search if search?
        concat links(&)
      end
    end

    def search
      form_with url: @path, method: :get, class: "form-search form-inline" do |form|
        concat(tag.div(class: "form-inline--input") do
          form.search_field(:search,
                            placeholder: "Search",
                            value:       params[:search],
                            class:       "form-inline--input",
                            data:        { table_actions_target: "search" })
        end)
        concat(form.submit("Go", class: "button button__primary form-inline--button"))
        concat(tag.div(class: "form-inline--button") do
          link_to("Reset", @path,
                  class: "button button--secondary",
                  data:  { table_actions_target: "reset" })
        end)
      end
    end

    def links(&block)
      content = block ? capture(&block) : ""

      return "" unless create? || content.present?

      tag.div(class: "item-actions") do
        concat create_link if create?
        concat content if content.present?
      end
    end

    def create_link
      link_to("Add", new_polymorphic_path(@path),
              class: "button button--primary",
              data:  { table_actions_target: "create" })
    end

    def actions
      [
        ("shortcut:cancel@document->table-actions#clear" if search?),
        ("shortcut:create@document->table-actions#create" if create?),
        ("shortcut:search@document->table-actions#search" if search?),
      ].compact.join(" ")
    end
  end
end

# frozen_string_literal: true

module Koi
  module HeaderHelper
    # This helper generates an accessible breadcrumb navigation structure with
    # proper ARIA attributes for screen readers. The breadcrumb items should be
    # provided as content within the block.
    #
    # @param ** Additional HTML attributes to merge with the default breadcrumb attributes
    # @yield [Block] The block should contain the breadcrumb items (typically `<li>` elements)
    # @return [String, nil] Returns the HTML `<nav>` element with breadcrumbs if content is present, nil otherwise
    #
    # @example Basic usage with list items
    #   <%= breadcrumb_list do %>
    #     <li><%= link_to "Home", root_path %></li>
    #     <li><%= link_to "Products", products_path %></li>
    #   <% end %>
    #
    # @see https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/ ARIA breadcrumb pattern
    def breadcrumb_list(**, &)
      return if (content = capture(&)).blank?

      tag.nav(**_koi_breadcrumbs_attributes(**)) do
        tag.ol(content, class: "breadcrumbs-list", role: "list")
      end
    end

    # This helper generates an accessible actions navigation structure with
    # proper ARIA attributes for screen readers. The action items should be
    # provided as content within the block.
    #
    # @param ** Additional HTML attributes to merge with the default actions attributes
    # @yield [Block] The block should contain the action items (typically `<li>` elements)
    # @return [String, nil] Returns the HTML `<nav>` element with actions if content is present, nil otherwise
    #
    # @example Basic usage with CRUD and contextual actions
    #   <%= actions_list do %>
    #     <li><%= link_to "Edit", edit_article_path(article) %></li>
    #     <li><%= link_to_archive_or_delete(article) %></li>
    #     <li><%= link_to "Config", articles_config_path(article) %></li>
    #   <% end %>
    #
    # @see https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/ ARIA naming and descriptions
    def actions_list(**, &)
      return if (content = capture(&)).blank?

      tag.nav(**_koi_actions_attributes(**)) do
        tag.ul(content, class: "actions-list", role: "list")
      end
    end

    # Creates a delete link with confirmation.
    #
    # @param model [ActiveRecord::Base] The record to create a delete link for
    # @param text [String] Text to display for delete link (default: "Delete")
    # @param confirm [String] Confirmation message for delete action (default: "Are you sure?")
    # @param url [String] Target url for delete actions (defaults to admin_<record>_path)
    # @param ** Additional HTML attributes to pass to the link
    # @return [String, nil] Returns the HTML link element, or nil if record is not persisted
    #
    # @example Basic usage
    #   <%= link_to_delete(user) %>
    def link_to_delete(model,
                       text = "Delete",
                       confirm: "Are you sure?",
                       url: polymorphic_path([:admin, model]),
                       **)
      return unless model.persisted?

      link_to(text, url, data: { turbo_method: :delete, turbo_confirm: confirm }, **)
    end

    # Conditionally creates an archive or delete link based on the record's status.
    #
    # @param model [ActiveRecord::Base] The record to create an archive/delete link for
    # @param archive_text [String] Text to display for archive link (default: "Archive")
    # @param delete_text [String] Text to display for delete link (default: "Delete")
    # @param confirm [String] Confirmation message for delete action (default: "Are you sure?")
    # @param url [String] Target url for delete actions (defaults to admin_<record>_path)
    # @param ** Additional HTML attributes to pass to the link
    # @return [String, nil] Returns the HTML link element, or nil if record is not persisted
    #
    # @example Basic usage
    #   <%= link_to_archive_or_delete(user) %>
    #
    # @see Koi::Model::Archivable For more information about the archivable concern
    def link_to_archive_or_delete(model,
                                  archive_text: "Archive",
                                  delete_text: "Delete",
                                  confirm: "Are you sure?",
                                  url: polymorphic_path([:admin, model]),
                                  **)
      raise ArgumentError unless model.respond_to?(:archived?)

      return unless model.persisted?

      if model.archived?
        link_to(delete_text, url, data: { turbo_method: :delete, turbo_confirm: confirm }, **)
      else
        link_to(archive_text, url, data: { turbo_method: :delete }, **)
      end
    end

    private

    using Katalyst::HtmlAttributes::HasHtmlAttributes

    def _koi_breadcrumbs_attributes(**attributes)
      {
        aria:  { label: "Breadcrumb" },
        class: "breadcrumb",
      }.merge_html(attributes)
    end

    def _koi_actions_attributes(**attributes)
      {
        aria:  { label: "Actions" },
        class: "actions",
      }.merge_html(attributes)
    end
  end
end

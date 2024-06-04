# frozen_string_literal: true

module Koi
  module Tables
    module Cells
      # Generates a column that links to the record's show page (by default).
      #
      # @param column [Symbol] the column's name, called as a method on the record
      # @param label [String|nil] the label to use for the column header
      # @param heading [boolean] if true, data cells will use `th` tags
      # @param url [Symbol|String|Proc] arguments for url_for, defaults to the record
      # @param link [Hash] options to be passed to the link_to helper
      # @param ** [Hash] HTML attributes to be added to column cells
      # @param & [Proc] optional block to alter the cell content
      #
      # If a block is provided, it will be called with the link cell component as an argument.
      # @yieldparam cell [Katalyst::Tables::Cells::LinkComponent] the cell component
      #
      # @return [void]
      #
      # @example Render a column containing the record's title, linked to its show page
      #   <% row.link :title %> # => <td><a href="/admin/post/15">About us</a></td>
      # @example Render a column containing the record's title, linked to its edit page
      #   <% row.link :title, url: :edit_admin_post_path do |cell| %>
      #      Edit <%= cell %>
      #   <% end %>
      #   # => <td><a href="/admin/post/15/edit">Edit About us</a></td>
      def link(column, label: nil, heading: false, url: (default_url = true), link: {}, **, &)
        with_cell(Tables::Cells::LinkComponent.new(
                    collection:, row:, column:, record:, label:, heading:, url:, default_url:, link:, **,
                  ), &)
      end

      # Generates a column that renders an ActiveStorage attachment as a downloadable link.
      #
      # @param column [Symbol] the column's name, called as a method on the record
      # @param label [String|nil] the label to use for the column header
      # @param heading [boolean] if true, data cells will use `th` tags
      # @param variant [Symbol] the variant to use when rendering the image (default :thumb)
      # @param ** [Hash] HTML attributes to be added to column cells
      # @param & [Proc] optional block to alter the cell content
      #
      # If a block is provided, it will be called with the attachment cell component as an argument.
      # @yieldparam cell [Katalyst::Tables::Cells::AttachmentComponent] the cell component
      #
      # @return [void]
      #
      # @example Render a column containing a download link to the record's background image
      #   <% row.attachment :background %> # => <td><a href="...">background.png</a></td>
      def attachment(column, label: nil, heading: false, variant: :thumb, **, &)
        with_cell(Tables::Cells::AttachmentComponent.new(
                    collection:, row:, column:, record:, label:, heading:, variant:, **,
                  ), &)
      end
    end
  end
end

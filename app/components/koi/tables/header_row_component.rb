# frozen_string_literal: true

module Koi
  module Tables
    # Custom header row component, in order to override the default header cell component
    # for number columns, we add a class to the header cell to allow for custom styling
    class HeaderRowComponent < Katalyst::Tables::HeaderRowComponent
      # Renders a boolean column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (:xs) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a boolean column header
      #  <% row.boolean :active %> # => <th>Active</th>
      #
      # @example Render a boolean column header with a custom label
      #  <% row.boolean :active, label: "Published" %> # => <th>Published</th>
      #
      # @example Render a boolean column header with medium width
      #  <% row.boolean :active, width: :m %>
      #  # => <th class="width-s">Active</th>
      #
      # @see Koi::Tables::BodyRowComponent#boolean
      def boolean(method, **attributes, &block)
        header_cell(method, component: Header::BooleanComponent, **attributes, &block)
      end

      # Renders a date column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (:s) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a date column header
      #  <% row.date :published_on %> # => <th>Published on</th>
      #
      # @example Render a date column header with a custom label
      #  <% row.date :published_on, label: "Date" %> # => <th>Date</th>
      #
      # @example Render a date column header with small width
      #  <% row.date :published_on, width: :s %>
      #  # => <th class="width-s">Published on</th>
      #
      # @see Koi::Tables::BodyRowComponent#date
      def date(method, **attributes, &block)
        header_cell(method, component: Header::DateComponent, **attributes, &block)
      end

      # Renders a datetime column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (:m) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a datetime column header
      #  <% row.datetime :created_at %> # => <th>Created at</th>
      #
      # @example Render a datetime column header with a custom label
      #  <% row.datetime :created_at, label: "Published at" %> # => <th>Published at</th>
      #
      # @example Render a datetime column header with small width
      #  <% row.datetime :created_at, width: :s %>
      #  # => <th class="width-s">Created at</th>
      #
      # @see Koi::Tables::BodyRowComponent#datetime
      def datetime(method, **attributes, &block)
        header_cell(method, component: Header::DateTimeComponent, **attributes, &block)
      end

      # Renders a number column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (:xs) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a number column header
      #  <% row.number :comment_count %> # => <th>Comments</th>
      #
      # @example Render a number column header with a custom label
      #  <% row.number :comment_count, label: "Comments" %> # => <th>Comments</th>
      #
      # @example Render a number column header with medium width
      #  <% row.number :comment_count, width: :m %>
      #  # => <th class="width-m">Comment Count</th>
      #
      # @see Koi::Tables::BodyRowComponent#number
      def number(method, **attributes, &block)
        header_cell(method, component: Header::NumberComponent, **attributes, &block)
      end

      # Renders a currency column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (:s) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a currency column header
      #  <% row.currency :price %> # => <th>Price</th>
      #
      # @example Render a currency column header with a custom label
      #  <% row.currency :price, label: "Amount($)" %> # => <th>Amount($)</th>
      #
      # @example Render a currency column header with medium width
      #  <% row.currency :price, width: :m %>
      #  # => <th class="width-m">Price</th>
      #
      # @see Koi::Tables::BodyRowComponent#currency
      def currency(method, **attributes, &block)
        header_cell(method, component: Header::CurrencyComponent, **attributes, &block)
      end

      # Renders a rich text column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (nil) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a rich text column header
      #  <% row.rich_text :content %> # => <th>Content</th>
      #
      # @example Render a rich text column header with a custom label
      #  <% row.rich_text :content, label: "Post content" %> # => <th>Post content</th>
      #
      # @example Render a rich text column header with large width
      #  <% row.rich_text :content, width: :l %>
      #  # => <th class="width-l">Content</th>
      #
      # @see Koi::Tables::BodyRowComponent#rich_text
      def rich_text(method, **attributes, &block)
        header_cell(method, component: Header::TextComponent, **attributes, &block)
      end

      # Renders a link column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (nil) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a link column header
      #  <% row.link :link %> # => <th>Link</th>
      #
      # @example Render a link column header with a custom label
      #  <% row.link :link, label: "Post" %> # => <th>Post</th>
      #
      # @example Render a link column header with small width
      #  <% row.link :content, width: :s %>
      #  # => <th class="width-s">Content</th>
      #
      # @see Koi::Tables::BodyRowComponent#link
      def link(method, **attributes, &block)
        header_cell(method, component: Header::LinkComponent, **attributes, &block)
      end

      # Renders a text column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (nil) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a text column header
      #  <% row.text :content %> # => <th>Content</th>
      #
      # @example Render a text column header with a custom label
      #  <% row.text :content, label: "Description" %> # => <th>Description</th>
      #
      # @example Render a text column header with large width
      #  <% row.text :content, width: :l %>
      #  # => <th class="width-l">Content</th>
      #
      # @see Koi::Tables::BodyRowComponent#text
      def text(method, **attributes, &block)
        header_cell(method, component: Header::TextComponent, **attributes, &block)
      end

      # Renders a attachment column header
      # @param method [Symbol] the method to call on the record to get the value
      # @param attributes [Hash] additional arguments are applied as html attributes to the th element
      # @option attributes [String] :label (nil) The label options to display in the header
      # @option attributes [Hash] :link ({}) The link options for the sorting link
      # @option attributes [String] :width (nil) The width of the column, can be +:xs+, +:s+, +:m+, +:l+ or nil
      #
      # @example Render a attachment column header
      #  <% row.attachment :attachment %> # => <th>Attachment</th>
      #
      # @example Render a attachment column header with a custom label
      #  <% row.attachment :attachment, label: "Document" %> # => <th>Document</th>
      #
      # @example Render a attachment column header with small width
      #  <% row.attachment :attachment, width: :s %>
      #  # => <th class="width-s">Attachment</th>
      #
      # @see Koi::Tables::BodyRowComponent#attachment
      def attachment(method, **attributes, &block)
        header_cell(method, component: Header::AttachmentComponent, **attributes, &block)
      end

      private

      def header_cell(method, component: HeaderCellComponent, **attributes, &block)
        with_column(component.new(@table, method, link: @link_attributes, **attributes), &block)
      end
    end
  end
end

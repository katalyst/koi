# frozen_string_literal: true

module Koi
  module Tables
    module Cells
      # Displays a link to the record
      # The link text is the value of the attribute
      class LinkComponent < Katalyst::Tables::CellComponent
        def initialize(url:, default_url:, link:, **)
          super(**)

          with_content_wrapper(WrapperComponent.new(cell: self, url:, default_url:, **link))
        end

        private

        def default_html_attributes
          { class: "type-link" }
        end

        class WrapperComponent < ViewComponent::Base
          include Katalyst::HtmlAttributes

          delegate :record, :column, :value, :row, to: :@cell

          def initialize(cell:, url:, default_url:, **)
            super(**)

            @cell = cell
            @url = url
            @default_url = default_url
          end

          def call
            if row.header?
              content
            else
              link_to(content, @default_url ? default_url : url, **html_attributes)
            end
          end

          def url
            case @url
            when Symbol
              # helpers are not available until the component is rendered
              @url = helpers.public_send(@url, record)
            when Proc
              @url = @url.call(record)
            else
              @url
            end
          end

          def default_url
            if value.is_a?(ApplicationRecord)
              [:admin, value]
            else
              [:admin, record]
            end
          end
        end
      end
    end
  end
end

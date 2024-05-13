# frozen_string_literal: true

module Koi
  module Tables
    module Cells
      # Displays a link to the record
      # The link text is the value of the attribute
      class LinkComponent < Katalyst::Tables::CellComponent
        define_html_attribute_methods :link_attributes

        def initialize(url:, link:, **)
          super(**)

          @url = url

          self.link_attributes = link
        end

        def rendered_value
          link_to(value, url, **link_attributes)
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

        private

        def default_html_attributes
          { class: "type-link" }
        end
      end
    end
  end
end

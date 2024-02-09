# frozen_string_literal: true

module Koi
  module Tables
    # Custom body cell component, in order to override the content
    class BodyCellComponent < Katalyst::Tables::BodyCellComponent
      def before_render
        # fallback if no content block is given
        with_content(rendered_value) unless content?
      end

      def rendered_value
        value.to_s
      end

      def inspect
        "#<#{self.class.name} #{@attribute.inspect}>"
      end
    end
  end
end

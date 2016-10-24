module Koi
  module Components
    class IndexAsTable < Arbre::Context
      include ActionView::Helpers

      def initialize(collection, &block)
        @columns = []
        instance_eval(&block)

        super(collection: collection, columns: @columns) do
          table class: 'table' do
            thead do
              tr do
                columns.each { |attr_name, _| th attr_name.to_s.titleize }
                th "Actions"
              end
            end

            collection.each do |resource|
              tr do
                columns.each do |attribute_name, block|
                  column = block.call(resource) if block
                  column ||= resource.send(attribute_name)
                  td column
                end

                td do
                  # span link_to "Show", "#edit"
                  # span link_to "Edit", "#edit"
                  # Rails.application.routes.url_helpers
                  binding.pry
                  span link_to("Delete", url_for(resource), confirm: 'Are you sure?', method: :delete)
                end
              end
            end
          end
        end
      end

      def column(attribute, &block)
        @columns << [attribute, block]
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  module Extensions
    module ObjectRendering
      # Workaround for de-duplicating nested module paths for admin controllers
      # See https://github.com/rails/rails/issues/50916
      def merge_prefix_into_object_path(prefix, object_path)
        if prefix.include?(?/) && object_path.include?(?/)
          prefixes     = []
          prefix_array = File.dirname(prefix).split("/")

          prefix_array.each_with_index do |dir, index|
            break if object_path.start_with?(prefix_array[index..].join("/"))

            prefixes << dir
          end

          (prefixes << object_path).join("/")
        else
          object_path
        end
      end
    end
  end
end

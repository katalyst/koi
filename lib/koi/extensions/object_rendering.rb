# frozen_string_literal: true

module Koi
  module Extensions
    module ObjectRendering
      # Workaround for de-duplicating nested module paths for admin controllers
      # See https://github.com/rails/rails/issues/50916
      def merge_prefix_into_object_path(prefix, object_path)
        return object_path unless prefix.include?(?/) && object_path.include?(?/)

        prefixes         = File.dirname(prefix).split("/")
        object_namespace = object_path.split("/")

        # Drop the longest run of trailing prefix segments that also appears at
        # the head of the object namespace, merging overlapping namespaces
        # rather than repeating them.
        max_overlap = [prefixes.length, object_namespace.length].min
        overlap     = max_overlap.downto(0).find do |length|
          prefixes.last(length) == object_namespace.first(length)
        end

        (prefixes.first(prefixes.length - overlap) << object_path).join("/")
      end
    end
  end
end

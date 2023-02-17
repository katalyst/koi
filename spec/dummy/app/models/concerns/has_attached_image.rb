# frozen_string_literal: true

module HasAttachedImage
  extend ActiveSupport::Concern

  class_methods do
    def has_one_attached_image(name, alt_text = nil, &) # rubocop:disable Naming/PredicateName
      has_one_attached(name, &)
      accepts_nested_attributes_for :"#{name}_attachment", allow_destroy: true

      validates name,
                content_type: App::PERMITTED_IMAGE_TYPES,
                size:         { less_than: App::PERMITTED_IMAGE_SIZE }

      if alt_text.present?
        if attribute_names.include?("title")
          before_validation :"set_default_#{alt_text}"

          define_method "set_default_#{alt_text}" do
            self[alt_text] ||= title
          end
        end

        validates alt_text,
                  presence: true,
                  if:       -> { send(name).attached? && !send(name).marked_for_destruction? }
      end
    end
  end
end

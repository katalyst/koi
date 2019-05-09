module HasManagedAssets
  extend ActiveSupport::Concern

  class_methods do
    def managed_image(attr, options={})
      belongs_to :"#{attr}_association", foreign_key: :"#{attr}_asset_id", class_name: "Image"
      define_method attr do
        send("#{attr}_association").try(:data)
      end
    end

    def managed_document(attr, options={})
      belongs_to :"#{attr}_association", foreign_key: :"#{attr}_asset_id", class_name: "Document"
      define_method attr do
        send("#{attr}_association").try(:data)
      end
    end
  end

end

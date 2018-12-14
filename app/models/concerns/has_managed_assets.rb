module HasManagedAssets
  extend ActiveSupport::Concern

  class_methods do
    def managed_image(attr, options={})
      define_method attr do
        id = send("#{attr}_asset_id")
        Image.find_by(id: id).data if id
      end
    end

    def managed_document(attr, options={})
      define_method attr do
        id = send("#{attr}_asset_id")
        Document.find_by(id: id).data if id
      end
    end
  end

end

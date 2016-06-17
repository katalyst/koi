class PageContentSerializer < ActiveModel::Serializer
  attributes :id, :title, :text, :file_uid, :file_name, :file_id, :file_ids, :module_limit, :module_ordered_by, :module_paginated, :module_category, :active
end

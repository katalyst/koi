class <%= class_name.delete('::') %>Serializer < ActiveModel::Serializer
  attributes :id, <%= model_attributes.collect { |a| ":#{a.name}" }.join(', ') %>
end

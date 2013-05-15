ActiveRecord::Relation.class_eval do

  def to_key
    [table_name]
  end

end
class << ActiveRecord::Relation

  def model_name
    @model_name ||= ActiveModel::Name.new ActiveRecord::Relation, nil, 'class'
  end

end

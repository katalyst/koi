Koi::Resource.register Car do
  permit_params :name, :engine_size, :description, :classic

  index as: :table do
    column :name
    column :description
    column :engine_size do |car|
      car.engine_size.to_s + ' litres'
    end
    column :classic do |car|
      car.classic ? "Classic" : "Modern"
    end
  end

  form do |f|
    f.input :name
    f.input :engine_size
    f.input :description
    f.input :classic,
            hint: 'Built before 1975',
            as: :select, collection: [['Yes', true], ['No', false]]

    f.actions
  end
end

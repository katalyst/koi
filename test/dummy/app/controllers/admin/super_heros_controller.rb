class Admin::SuperHerosController < Koi::AdminCrudController

  # Name search
  # This is an example of just autocompleting and saving
  # strings, no id or record associations
  def name_search
    render json: SuperHero.all.map { |hero| hero.name }
  end

  # 
  def search_id
    
  end

  def content_id

  end

  def search_association

  end

  def content_association
  end

end

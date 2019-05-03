class Admin::SuperHerosController < Koi::AdminCrudController

  # Name search
  # This is an example of just autocompleting and saving
  # strings, no id or record associations
  def name_search
    render json: SuperHero.all.map { |hero| hero.name }
  end

  # ID search
  # This is an example of search for an ID associated with
  # a keyword search
  def search_id
    render json: SuperHero.all.map { |hero| { label: hero.name, value: hero.id } }
  end

  # ID content
  # Returning hero based on existing value
  # in this case it's an ID so we can just .find it
  def content_id
    @hero = SuperHero.find(params[:value])
    render json: [{ label: @hero.name, value: @hero.id }]
  end

  # Association search
  # This is an example of taking a keyword and returning back
  # various record types
  def search_association
    render json: SuperHero.all.map { |hero| { label: hero.name, value: { type: "SuperHero", id: hero.id } } }
  end

  # Association content
  # Returning a hero based on the ID param
  # A real-life example would need to consider the record type
  # aswell and find the id of the appropriate record type
  def content_association
    @hero = SuperHero.find(params[:id])
    render json: [{ label: @hero.name, value: { type: @hero.class.name, value: @hero.id }}]
  end

end

class SuperHerosController < Koi::CrudController
  def per_page
    SuperHero.setting(:per_page, 20)
  end
end

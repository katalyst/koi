class PagesController < CrudController

  # Stop accidental leakage of unwanted actions to frontend

  def index
    redirect_to '/'
  end

  alias :index :create
  alias :index :destroy
  alias :index :update
  alias :index :edit
  alias :index :new

end

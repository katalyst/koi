# frozen_string_literal: true

class LegacyPagesController < CrudController
  # Stop accidental leakage of unwanted actions to frontend

  def index
    redirect_to "/"
  end

  alias create index
  alias destroy index
  alias update index
  alias edit index
  alias new index
end

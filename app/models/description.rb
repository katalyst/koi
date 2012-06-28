class Description < Section
  def to_s
    description
  end

  crud.config do
    config :admin do
      form fields: [:description]
    end
  end
end

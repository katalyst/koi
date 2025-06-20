# frozen_string_literal: true

module Koi
  class PagyNavComponent < Katalyst::Tables::PagyNavComponent
    include Koi::Pagy::Frontend
  end
end

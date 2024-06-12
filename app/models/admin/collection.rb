# frozen_string_literal: true

module Admin
  class Collection < Katalyst::Tables::Collection::Base
    include Katalyst::Tables::Collection::Query

    attribute :search, :search, scope: :admin_search
  end
end

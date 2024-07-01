# frozen_string_literal: true

require "koi/collection/type/archivable"

module Koi
  module Collection
    class << self
      Katalyst::Tables::Collection::Type.register(:archivable, Koi::Collection::Type::Archivable)
    end
  end
end

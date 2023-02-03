# frozen_string_literal: true

class Article < ApplicationRecord
  include Katalyst::Content::Container

  class Version < ApplicationRecord
    include Katalyst::Content::Version
  end
end

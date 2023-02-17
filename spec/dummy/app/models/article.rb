# frozen_string_literal: true

class Article < ApplicationRecord
  include Katalyst::Content::Container
  include HasAttachedImage

  has_one_attached_image :image

  class Version < ApplicationRecord
    include Katalyst::Content::Version
  end
end

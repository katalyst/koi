require 'test_helper'

class SuperHeroTest < ActiveSupport::TestCase
  setup do
    @super_hero = Factory(:super_hero)
  end
end

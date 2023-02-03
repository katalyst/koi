# frozen_string_literal: true

Katalyst::Content.configure do |config|
  config.backgrounds << "pink"
  config.items = %w[
    Katalyst::Content::Section
    Katalyst::Content::Group
    Katalyst::Content::Column
    Katalyst::Content::Aside
    Katalyst::Content::Content
    Katalyst::Content::Figure
  ]
end

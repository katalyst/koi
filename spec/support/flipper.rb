# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
  end

  config.before do
    allow(Flipper).to receive(:enabled?).and_return(true)
  end
end

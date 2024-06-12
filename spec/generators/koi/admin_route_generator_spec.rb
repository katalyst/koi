# frozen_string_literal: true

require "rails_helper"

require "generators/koi/admin_route/admin_route_generator"

RSpec.describe Koi::AdminRouteGenerator do
  subject(:output) do
    Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
  end

  let(:gen) { generator(%w(test)) }

  it "updates routes" do
    expect(output.lines.grep(/insert/).map { |l| l.split.last }).to include("config/routes/admin.rb")
  end

  it "updates menus" do
    expect(output.lines.grep(/gsub/).map { |l| l.split.last }).to include("config/initializers/koi.rb")
  end

  describe "menu changes" do
    subject(:admin_menu) { file("config/initializers/koi.rb") }

    let(:stubs) { nil }

    before do
      stubs
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    it { is_expected.to contain('"Tests" => "/admin/tests",') }
  end

  describe "routes changes" do
    subject(:admin_routes) { file("config/routes/admin.rb") }

    let(:stubs) { nil }

    before do
      stubs
      Ammeter::OutputCapturer.capture(:stdout) { gen.invoke_all }
    end

    it { is_expected.to contain("resources :tests") }

    context "when admin routes file exists" do
      let(:stubs) do
        RSpec::Support::DirectoryMaker.mkdir_p(file("config/routes").to_s)
        File.write(file("config/routes/admin.rb"), <<~RUBY)
          namespace :admin do
          end
        RUBY

        set_shell_prompt_responses(gen, ask: "y")
      end

      it { is_expected.to contain(<<~RUBY) }
        namespace :admin do
          resources :tests
        end
      RUBY
    end

    context "when the module is nested" do
      let(:gen) { generator(%w(nested/test)) }

      it { is_expected.to contain(<<-RUBY) }
  namespace :nested do
    resources :tests
  end
      RUBY
    end

    context "when the module is nested and the namespace already exists" do
      let(:gen) { generator(%w(nested/test)) }
      let(:stubs) do
        RSpec::Support::DirectoryMaker.mkdir_p(file("config/routes").to_s)
        File.write(file("config/routes/admin.rb"), <<~RUBY)
          namespace :admin do
            namespace :nested do
              resources :other
            end
          end
        RUBY

        set_shell_prompt_responses(gen, ask: "y")
      end

      it { is_expected.to contain(<<-RUBY) }
  namespace :nested do
    resources :tests
    resources :other
  end
      RUBY
    end
  end
end

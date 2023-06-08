# frozen_string_literal: true

require "rails_helper"
require "rails/generators"

# rubocop:disable RSpec/InstanceVariable, RSpec/BeforeAfterAll
RSpec.describe "Koi::AdminGenerator" do
  before(:all) do
    @tmpdir = Dir.mktmpdir
    FileUtils.cp_r "spec/dummy/", "#{@tmpdir}/"
    @dummy = "#{@tmpdir}/dummy"
    Dir.chdir(@dummy) do
      `bin/rails g koi:admin test`
    end
  end

  after(:all) do
    FileUtils.remove_entry(@tmpdir)
  end

  it { expect(Pathname.new("#{@dummy}/app/models/test.rb")).to exist }
  it { expect(Pathname.new("#{@dummy}/app/controllers/admin/tests_controller.rb")).to exist }
  it { expect(Pathname.new("#{@dummy}/app/views/admin/tests/index.html.erb")).to exist }
  it { expect(Pathname.new("#{@dummy}/app/views/admin/tests/new.html.erb")).to exist }
  it { expect(Pathname.new("#{@dummy}/app/views/admin/tests/show.html.erb")).to exist }
  it { expect(File.read("#{@dummy}/config/routes/admin.rb")).to include "resources :tests" }
end
# rubocop:enable RSpec/InstanceVariable, RSpec/BeforeAfterAll

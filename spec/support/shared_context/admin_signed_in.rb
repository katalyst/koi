RSpec.shared_context 'admin_signed_in', :shared_context => :metadata do
  let(:admin) { create(:admin) }

  before(:each) do
    login_as(admin, scope: :admin)
  end
end

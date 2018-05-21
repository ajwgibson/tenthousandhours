module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:default_user)
      sign_in user
    end
  end
  def login_volunteer
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:volunteer]
      volunteer = FactoryBot.create(:default_volunteer)
      volunteer.confirm
      sign_in volunteer
    end
  end
  def login_basic
    before(:each) do
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('username','password')
    end
  end
end

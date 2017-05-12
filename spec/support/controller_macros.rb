module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:default_user)
      sign_in user
    end
  end
  def login_volunteer
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:volunteer]
      volunteer = FactoryGirl.create(:default_volunteer)
      volunteer.confirm
      sign_in volunteer
    end
  end
end

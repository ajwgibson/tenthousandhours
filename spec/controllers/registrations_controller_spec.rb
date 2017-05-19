require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do

  login_volunteer

  describe "GET #confirm_mobile" do
    it "returns http success" do
      get :confirm_mobile
      expect(response).to have_http_status(:success)
    end
    it "renders the :confirm_mobile view" do
      get :confirm_mobile
      expect(response).to render_template :confirm_mobile
    end
  end


  describe "POST #do_confirm_mobile" do
    let(:volunteer) { Volunteer.first }
    let(:code) { volunteer.mobile_confirmation_code }
    context "when the code matches the volunteer's mobile_confirmation_code" do
      before(:each) do
        post :do_confirm_mobile, { code: code }
        volunteer.reload
      end
      it "set the volunteer mobile_confirmation_code to nil" do
        expect(volunteer.mobile_confirmation_code).to eq(nil)
      end
      it "redirects to the my projects page" do
        expect(response).to redirect_to(my_projects_url)
      end
      it "sets a flash message" do
        expect(flash[:notice]).to eq('Mobile number confirmed')
      end
    end
    context "when the code does not match the volunteer's mobile_confirmation_code" do
      before(:each) do
        post :do_confirm_mobile, { code: 'abcd' }
        volunteer.reload
      end
      it "does not set the volunteer mobile_confirmation_code to nil" do
        expect(volunteer.mobile_confirmation_code).to eq(code)
      end
      it "re-renders the form" do
        expect(response).to render_template(:confirm_mobile)
      end
      it "remembers the code supplied by the user" do
        expect(assigns(:code)).to eq('abcd')
      end
      it "sets a flash message" do
        expect(flash[:error]).to eq('Failed to match code')
      end
      it "returns an error message" do
        expect(assigns(:error)).to eq('Failed to match code - please try again')
      end
    end
  end

end

require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  login_user


  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
    it "populates an array of users" do
      # Note: the login_user method creates a user!
      get :index
      expect(assigns(:users)).to eq([User.first])
    end
    it "orders the users by email address" do
      # Note: the login_user method creates a user!
      default_user = User.first
      user_z = FactoryGirl.create(:default_user, :email => 'z@z.com')
      user_y = FactoryGirl.create(:default_user, :email => 'y@y.com')
      get :index
      expect(assigns(:users)).to eq([default_user, user_y, user_z])
    end
  end


  describe "GET #show" do

    let(:user) { FactoryGirl.create(:default_user, :email => 'a@a.com') }

    it "shows a record" do
      get :show, { id: user.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:user).id).to eq(user.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, { id: 99 }
      end
    end
  end


  describe "GET #new" do
    it "renders a blank form" do
      get :new
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:user).id).to be_nil
    end
  end


  describe "POST #create" do

    context "with valid data" do

      let(:user) { User.order(:id).last }

      def post_create
        attrs = {
          email:                 'a@b.com',
          first_name:            'John',
          last_name:             'Smith',
          role:                  'Organiser',
          password:              'Pa$$w0rd',
          password_confirmation: 'Pa$$w0rd',
        }
        post :create, { user: attrs }
      end

      before(:each) do
        post_create
      end

      it "creates a new record" do
        expect {
          post :create, { user: FactoryGirl.attributes_for(:default_user) }
        }.to change(User, :count).by(1)
      end
      it "redirects to the index action" do
        expect(response).to redirect_to(users_path())
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('User was created successfully')
      end
      it "stores the email" do expect(user.email).to eq('a@b.com') end
      it "stores the first_name" do expect(user.first_name).to eq('John') end
      it "stores the last_name" do expect(user.last_name).to eq('Smith') end
      it "stores the role" do expect(user.role).to eq('Organiser') end
    end

    context "with invalid data" do
      def post_create
        attrs = FactoryGirl.attributes_for(:user, :first_name => 'A')
        post :create, { user: attrs }
      end
      it "does not create a new record" do
        expect {
          post_create
        }.to_not change(User, :count)
      end
      it "re-renders the form with the posted data" do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:user).first_name).to eq('A')
      end
    end
  end


  describe "GET #edit" do

    let(:user) { FactoryGirl.create(:default_user) }

    it "shows a record for editing" do
      get :edit, { id: user.id }
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:user).id).to eq(user.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, { id: 99 }
      end
    end
  end


  describe "PUT #update" do

    context "with valid data" do

      let(:user) { FactoryGirl.create(:default_user, :first_name => 'Original') }

      def post_update
        put :update,
            :id => user.id,
            :user => {
              :first_name => 'Changed',
              :last_name  => user.last_name,
              :email      => user.email,
              :role       => user.role,
            }
        user.reload
      end

      before(:each) do
        post_update
      end

      it "updates the user details" do
        expect(user.first_name).to eq('Changed')
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(user_path(assigns(:user)))
      end
      it "sets a flash message" do
        expect(flash[:notice]).to eq('User was updated successfully')
      end
    end

    context "with invalid data" do

      let(:user) { FactoryGirl.create(:default_user, :first_name => 'Original') }

      def post_update
        put :update, :id => user.id, :user => { :first_name => nil }
        user.reload
      end

      before(:each) do
        post_update
      end

      it "does not update the user details" do
        expect(user.first_name).to eq('Original')
      end
      it "re-renders the form with the posted data" do
        expect(response).to render_template(:edit)
        expect(assigns(:user).first_name).to be_nil
      end
    end
  end


  describe "DELETE #destroy" do

    let!(:user) { FactoryGirl.create(:default_user) }

    it "deletes the record" do
      expect {
        delete :destroy, :id => user.id
      }.to change(User, :count).by(-1)
    end
    it "redirects to #index" do
      delete :destroy, :id => user.id
      expect(response).to redirect_to(:users)
    end
  end


end

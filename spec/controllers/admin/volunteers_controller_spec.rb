require 'rails_helper'

RSpec.describe Admin::VolunteersController, type: :controller do

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
    it "populates an array of volunteers" do
      v = FactoryBot.create(:default_volunteer)
      get :index
      expect(assigns(:volunteers)).to eq([v])
    end
    it "orders volunteers by name by default" do
      ba = FactoryBot.create(:default_volunteer, first_name: 'b', last_name: 'a')
      ca = FactoryBot.create(:default_volunteer, first_name: 'c', last_name: 'a')
      ab = FactoryBot.create(:default_volunteer, first_name: 'a', last_name: 'b')
      aa = FactoryBot.create(:default_volunteer, first_name: 'a', last_name: 'a')
      get :index
      expect(assigns(:volunteers)).to eq([aa,ab,ba,ca])
    end
    it "stores filters to the session" do
      get :index, params: { with_first_name: 'abc' }
      expect(session[:filter_admin_volunteers]).to eq({'with_first_name' => 'abc'})
    end
    it "removes blank filter values" do
      get :index, params: { with_first_name: nil }
      expect(assigns(:filter)).to eq({})
    end
    it "retrieves filters from the session if none have been supplied" do
      a = FactoryBot.create(:default_volunteer, first_name: 'a', last_name: 'zzz')
      b = FactoryBot.create(:default_volunteer, first_name: 'b', last_name: 'zzz')
      get :index, session: { :filter_admin_volunteers => {'with_first_name' => 'a'} }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'with_first_name' filter if supplied" do
      a = FactoryBot.create(:default_volunteer, first_name: 'a')
      b = FactoryBot.create(:default_volunteer, first_name: 'b')
      get :index, params: { with_first_name: 'a' }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'with_last_name' filter if supplied" do
      a = FactoryBot.create(:default_volunteer, last_name: 'a')
      b = FactoryBot.create(:default_volunteer, last_name: 'b')
      get :index, params: { with_last_name: 'a' }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'with_email' filter if supplied" do
      a = FactoryBot.create(:default_volunteer, email: 'a@x.y')
      b = FactoryBot.create(:default_volunteer, email: 'b@x.y')
      get :index, params: { with_email: 'a' }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'with_mobile' filter if supplied" do
      a = FactoryBot.create(:default_volunteer, mobile: 'a')
      b = FactoryBot.create(:default_volunteer, mobile: 'b')
      get :index, params: { with_mobile: 'a' }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'in_age_category' filter if supplied" do
      a = FactoryBot.create(:default_volunteer)
      b = FactoryBot.create(:youth_volunteer)
      get :index, params: { in_age_category: 'youth' }
      expect(assigns(:volunteers)).to eq([b])
    end
    it "applies the 'with_skill' filter if supplied" do
      a = FactoryBot.create(:default_volunteer, skills: ['a','x'])
      b = FactoryBot.create(:default_volunteer, skills: ['b','x'])
      get :index, params: { with_skill: 'a' }
      expect(assigns(:volunteers)).to eq([a])
    end
    it "applies the 'without_projects' filter if supplied" do
      slot = FactoryBot.create(:default_project_slot)
      a    = FactoryBot.create(:default_volunteer, first_name: 'a')
      b    = FactoryBot.create(:default_volunteer, first_name: 'b')
      slot.volunteers << a
      get :index, params: { without_projects: true }
      expect(assigns(:volunteers)).to eq([b])
    end
    it "applies the 'needs_activity_consent' filter if supplied" do
      a    = FactoryBot.create(:default_volunteer)
      b    = FactoryBot.create(:youth_volunteer)
      get :index, params: { needs_activity_consent: true }
      expect(assigns(:volunteers)).to eq([b])
    end
    it "applies the 'with_can_contact_future' filter if supplied" do
      a    = FactoryBot.create(:default_volunteer)
      b    = FactoryBot.create(:default_volunteer, can_contact_future: true)
      get :index, params: { with_can_contact_future: true }
      expect(assigns(:volunteers)).to eq([b])
    end
    context "with no explicit page value" do
      it "returns the first page of volunteers" do
        30.times do |i|
          FactoryBot.create(:default_volunteer, first_name: "Person_#{i}", last_name: 'xxx')
        end
        get :index
        expect(assigns(:volunteers).count).to eq(25)
      end
    end
    context "with an explicit page value" do
      it "returns the requested page of volunteers" do
        30.times do |i|
          FactoryBot.create(:default_volunteer, first_name: "Person_#{i}", last_name: 'xxx')
        end
        get :index, params: { page: 2 }
        expect(assigns(:volunteers).count).to eq(5)
      end
    end
  end


  describe "GET #clear_filter" do
    it "redirects to #index" do
      get :clear_filter
      expect(response).to redirect_to([:admin, :volunteers])
    end
    it "clears the session entry" do
      session[:filter_admin_volunteers] = {'with_first_name' => 'abc'}
      get :clear_filter
      expect(session.key?(:filter_admin_volunteers)).to be false
    end
  end


  describe "GET #show" do

    let(:volunteer) { FactoryBot.create(:default_volunteer, :email => 'a@a.com') }

    it "shows a record" do
      get :show, params: { id: volunteer.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:volunteer).id).to eq(volunteer.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 99 }
      end
    end
  end


  describe "GET #new" do
    it "renders a blank form" do
      get :new
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:volunteer).id).to be_nil
    end
  end


  describe "POST #create" do

    context "with valid data" do

      let(:volunteer) { Volunteer.first }

      def post_create(email='a@b.c')
        attrs = {
          email:          email,
          first_name:     'John',
          last_name:      'Smith',
          mobile:         '12345',
          age_category:   'adult',
          family:         '[{"name":"John","age_category":"adult"}]',
          skills:         ["a", "b", "c"],
          guardian_name:  'The grown up',
          guardian_contact_number: '999'
        }
        post :create, params: { volunteer: attrs }
      end

      before(:each) do
        post_create
      end

      it "creates a new record" do
        expect {
          post_create 'z@y.x'
        }.to change(Volunteer, :count).by(1)
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(admin_volunteer_path(volunteer))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Volunteer was created successfully')
      end
      it "stores email" do
        expect(volunteer.email).to eq('a@b.c')
      end
      it "stores first_name" do
        expect(volunteer.first_name).to eq('John')
      end
      it "stores last_name" do
        expect(volunteer.last_name).to eq('Smith')
      end
      it "stores mobile" do
        expect(volunteer.mobile).to eq('12345')
      end
      it "stores age_category" do
        expect(volunteer.adult?).to eq(true)
      end
      it "stores family" do
        expect(volunteer.family).to eq('[{"name":"John","age_category":"adult"}]')
      end
      it "stores skills" do
        expect(volunteer.skills).to eq(["a", "b", "c"])
      end
      it "stores guardian_name" do
        expect(volunteer.guardian_name).to eq('The grown up')
      end
      it "stores guardian_contact_number" do
        expect(volunteer.guardian_contact_number).to eq('999')
      end
      it "sets confirmed_at" do
        expect(volunteer.confirmed_at).not_to eq(nil)
      end
    end

    context "without an email address" do

      let(:volunteer) { Volunteer.first }

      def post_create
        attrs = {
          first_name:     'John',
          last_name:      'Smith',
          mobile:         '12345',
          age_category:   'adult'
        }
        post :create, params: { volunteer: attrs }
      end

      before(:each) do
        post_create
      end

      it "creates a new record" do
        expect {
          post_create
        }.to change(Volunteer, :count).by(1)
      end
      it "sets a dummy email" do
        expect(volunteer.email).not_to eq(nil)
      end
    end

    context "with an empty email address" do

      let(:volunteer) { Volunteer.first }

      def post_create
        attrs = {
          email:          '',
          first_name:     'John',
          last_name:      'Smith',
          mobile:         '12345',
          age_category:   'adult'
        }
        post :create, params: { volunteer: attrs }
      end

      before(:each) do
        post_create
      end

      it "creates a new record" do
        expect {
          post_create
        }.to change(Volunteer, :count).by(1)
      end
      it "sets a dummy email" do
        expect(volunteer.email).not_to eq(nil)
      end
    end

    context "with invalid data" do

      let(:volunteer) { Volunteer.first }

      def post_create
        attrs = { first_name: 'A' }
        post :create, params: { volunteer: attrs }
      end

      before(:each) do
        post_create
      end

      it "does not create a new record" do
        expect {
          post_create
        }.to_not change(Volunteer, :count)
      end
      it "re-renders the form with the posted data" do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:volunteer).first_name).to eq('A')
      end
    end
  end


  describe "GET #edit" do

    let(:volunteer) { FactoryBot.create(:default_volunteer) }

    it "shows a record for editing" do
      get :edit, params: { id: volunteer.id }
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:volunteer).id).to eq(volunteer.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, params: { id: 99 }
      end
    end

  end


  describe "PUT #update" do

    context "with valid data" do

      let(:volunteer) { FactoryBot.create(:default_volunteer, :first_name => 'Original') }

      def post_update
        put :update, params: { :id => volunteer.id, :volunteer => { :first_name => 'Changed' } }
        volunteer.reload
      end

      before(:each) do
        post_update
      end

      it "updates the volunteer details" do
        expect(volunteer.first_name).to eq('Changed')
      end

      it "redirects to the show action" do
        expect(response).to redirect_to(admin_volunteer_path(assigns(:volunteer)))
      end

      it "set a flash message" do
        expect(flash[:notice]).to eq('Volunteer was updated successfully')
      end

    end

    context "with invalid data" do

      let(:volunteer) { FactoryBot.create(:default_volunteer, :first_name => 'Original') }

      def post_update
        put :update, params: { :id => volunteer.id, :volunteer => { :first_name => nil } }
        volunteer.reload
      end

      before(:each) do
        post_update
      end

      it "does not update the volunteer details" do
        expect(volunteer.first_name).to eq('Original')
      end

      it "re-renders the form with the posted data" do
        expect(response).to render_template(:edit)
        expect(assigns(:volunteer).first_name).to be_empty
      end

    end

  end


  describe "POST #activity_consent_received" do
    let(:volunteer) { FactoryBot.create(:youth_volunteer) }
    def post_update
      post :activity_consent_received, params: { :id => volunteer.id }
      volunteer.reload
    end
    before(:each) do
      post_update
    end
    it "updates the volunteer details" do
      expect(volunteer.activity_consent_recorded_by).to eq(subject.current_user.name)
    end
    it "redirects to the show action" do
      expect(response).to redirect_to(admin_volunteer_path(assigns(:volunteer)))
    end
    it "set a flash message" do
      expect(flash[:notice]).to eq('Volunteer was updated successfully')
    end
  end


  describe "GET #compose_one" do

    context "with a valid volunteer id" do
      let(:volunteer) { FactoryBot.create(:default_volunteer) }

      before(:each) do
        get :compose_one, params: { id: volunteer.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
      it "renders the :compose_one view" do
        expect(response).to render_template :compose_one
      end
      it "populates the volunteer" do
        expect(assigns(:volunteer)).to eq(volunteer)
      end
      it "populates an empty model" do
        expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
      end
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :compose_one, params: { id: 99 }
      end
    end

  end


  describe "POST #send_one" do

    let(:volunteer) { FactoryBot.create(:default_volunteer, mobile: '1234') }

    context "with an invalid message" do
      def send_message
        post :send_one, params: { id: volunteer.id, compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form with the posted data" do
        send_message
        expect(response).to render_template(:compose_one)
      end
    end

    context "with a valid message" do
      def send_message
        post :send_one, params: { id: volunteer.id, compose_message: { message_text: 'Hello world' } }
      end

      before(:each) do
        send_message
      end

      it "sends a message" do
        expect {
          send_message
        }.to change(TextMessage, :count).by(1)
      end
      it "uses the message text provided" do
        expect(TextMessage.first.message).to eq('Hello world')
      end
      it "sends the message to the volunteer using the international mobile format" do
        expect(TextMessage.first.recipients).to eq('441234')
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the show volunteer view" do
        expect(response).to redirect_to admin_volunteer_url(volunteer)
      end
    end
  end


  describe "GET #compose_all" do
    before do
      FactoryBot.create(:default_volunteer)
      FactoryBot.create(:default_volunteer)
    end

    before(:each) do
      get :compose_all
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "renders the :compose_all view" do
      expect(response).to render_template :compose_all
    end
    it "populates the volunteer count" do
      expect(assigns(:volunteer_count)).to eq(Volunteer.count)
    end
    it "populates an empty model" do
      expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
    end
  end


  describe "POST #send_all" do

    context "with an invalid message" do
      def send_message
        post :send_all, params: { compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form with the posted data" do
        send_message
        expect(response).to render_template(:compose_all)
      end
    end

    context "with a valid message" do
      def send_message
        post :send_all, params: { compose_message: { message_text: 'Hello world' } }
      end

      before do
        FactoryBot.create(:default_volunteer, mobile: '1111')
        FactoryBot.create(:default_volunteer, mobile: '2222')
        FactoryBot.create(:default_volunteer, mobile: '3333')
      end

      before(:each) do
        send_message
      end

      it "sends a message" do
        expect {
          send_message
        }.to change(TextMessage, :count).by(1)
      end
      it "uses the message text provided" do
        expect(TextMessage.first.message).to eq('Hello world')
      end
      it "sends the message to all volunteers using the international mobile format" do
        expect(TextMessage.first.recipients).to eq('441111,442222,443333')
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the volunteers view" do
        expect(response).to redirect_to admin_volunteers_url
      end
    end
  end


  describe "GET #new_sign_up" do
    let(:volunteer) { FactoryBot.create(:default_volunteer) }

    let(:published_project)   { FactoryBot.create(:published_project) }
    let(:unpublished_project) { FactoryBot.create(:default_project) }

    it "renders a blank form" do
      get :new_sign_up, params: { id: volunteer.id }
      expect(response).to render_template :new_sign_up
      expect(response).to have_http_status(:success)
      expect(assigns(:volunteer).id).to eq(volunteer.id)
      expect(assigns(:manual_sign_up).slot_id).to be_nil
      expect(assigns(:projects)).to eq([published_project])
    end
  end

end

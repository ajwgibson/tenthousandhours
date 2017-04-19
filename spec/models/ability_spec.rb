require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  subject(:ability) { Ability.new(user) }
  let(:user)        { nil }

  context "organisers" do
    let(:user)    { FactoryGirl.build(:default_user, role: :Organiser) }
    it { is_expected.to have_abilities([:manage], :all) }
  end

  context "overseers" do
    let(:user)    { FactoryGirl.build(:default_user, role: :Overseer) }

    it { is_expected.to have_abilities([:read, :review, :do_review],   Project) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy, :import], Project) }

    it { is_expected.to have_abilities([:read], User) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], User) }

    it { is_expected.to not_have_abilities([:manage], ProjectSlot) }

    it { is_expected.to have_abilities([:read], Volunteer) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], Volunteer) }
  end

  context "coordinators" do
    let(:user)    { FactoryGirl.build(:default_user, role: :Coordinator) }

    it { is_expected.to have_abilities([:read, :create, :update],   Project) }
    it { is_expected.to not_have_abilities([:destroy, :import], Project) }

    it { is_expected.to have_abilities([:read], User) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], User) }

    it { is_expected.to not_have_abilities([:manage], ProjectSlot) }

    it { is_expected.to have_abilities([:read], Volunteer) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], Volunteer) }
  end

  context "leaders" do
    let(:user)    { FactoryGirl.build(:default_user, role: :Leader) }

    it { is_expected.to have_abilities([:read],   Project) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy, :import], Project) }

    it { is_expected.to have_abilities([:read], User) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], User) }

    it { is_expected.to not_have_abilities([:manage], ProjectSlot) }

    it { is_expected.to have_abilities([:read], Volunteer) }
    it { is_expected.to not_have_abilities([:create, :update, :destroy], Volunteer) }
  end

end

require 'rails_helper'

RSpec.describe CreateProjectSlot, type: :model do

  it 'has a valid factory' do
    s = FactoryBot.build(:default_create_project_slot)
    expect(s).to be_valid
  end

  # VALIDATION

  it "is not valid without a start_date" do
    expect(FactoryBot.build(:default_create_project_slot, start_date: nil)).not_to be_valid
  end
  it "is not valid with a badly formatted start_date" do
    expect(FactoryBot.build(:default_create_project_slot, start_date: 'rubbish')).not_to be_valid
  end
  it "is not valid with a badly formatted end_date" do
    expect(FactoryBot.build(:default_create_project_slot, end_date: 'rubbish')).not_to be_valid
  end
  it "is not valid when the end_date is before the start_date" do
    expect(
      FactoryBot.build(
        :default_create_project_slot,
        start_date: 2.days.from_now.to_s,
      end_date: 1.days.from_now.to_s)).not_to be_valid
  end
  it "is not valid without at least one slot type" do
    expect(FactoryBot.build(
      :default_create_project_slot,
      morning_slot: nil,
      afternoon_slot: '0',
      evening_slot: nil)).not_to be_valid
  end


  # METHODS

  describe "#create_slots" do

    let(:project) { FactoryBot.create(:default_project) }

    context "with no end_date" do

      context "for a morning slot" do
        it "creates a single slot for the morning of the start_date" do
          m = FactoryBot.build(
            :default_create_project_slot,
            start_date: 1.day.from_now.to_s, end_date: nil,
            morning_slot: '1', afternoon_slot: '0', evening_slot: '0' )

          expect {
            m.create_slots(project)
          }.to change(ProjectSlot, :count).by(1)

          expect(ProjectSlot.first.slot_date).to eq(1.day.from_now.to_date)
          expect(ProjectSlot.first.morning?).to be_truthy
        end
      end

      context "for an afternoon slot" do
        it "creates a single slot for the afternoon of the start_date" do
          m = FactoryBot.build(
            :default_create_project_slot,
            start_date: 1.day.from_now.to_s, end_date: nil,
            morning_slot: '0', afternoon_slot: '1', evening_slot: '0' )

          expect {
            m.create_slots(project)
          }.to change(ProjectSlot, :count).by(1)

          expect(ProjectSlot.first.afternoon?).to be_truthy
        end
      end

      context "for an evening slot" do
        it "creates a single slot for the evening of the start_date" do
          m = FactoryBot.build(
            :default_create_project_slot,
            start_date: 1.day.from_now.to_s, end_date: nil,
            morning_slot: '0', afternoon_slot: '0', evening_slot: '1' )

          expect {
            m.create_slots(project)
          }.to change(ProjectSlot, :count).by(1)

          expect(ProjectSlot.first.evening?).to be_truthy
        end
      end

      context "for multiple slots" do
        it "creates a slot for each slot type" do
          m = FactoryBot.build(
            :default_create_project_slot,
            start_date: 1.day.from_now.to_s, end_date: nil,
            morning_slot: '1', afternoon_slot: '1', evening_slot: '1' )

          expect {
            m.create_slots(project)
          }.to change(ProjectSlot, :count).by(3)

          expect(ProjectSlot.order(:slot_type).map{ |ps| ps.slot_type }).to eq(['morning','afternoon','evening'])
        end
      end

      context "for a slot that already exists" do
        it "does not create a duplicate slot" do

          FactoryBot.create(:project_slot, project: project, slot_date: 1.day.from_now.to_s, slot_type: :morning)

          m = FactoryBot.build(
            :create_project_slot,
            start_date: 1.day.from_now.to_s, end_date: nil,
            morning_slot: '1', afternoon_slot: '0', evening_slot: '0' )

          expect {
            m.create_slots(project)
          }.to change(ProjectSlot, :count).by(0)

        end
      end

    end

    context "with an end_date" do
      it "creates a slot for each date in the range" do
        m = FactoryBot.build(
          :default_create_project_slot,
          start_date: 1.day.from_now.to_s, end_date: 3.days.from_now.to_s,
          morning_slot: '0', afternoon_slot: '0', evening_slot: '1' )

        expect {
          m.create_slots(project)
        }.to change(ProjectSlot, :count).by(3)
      end
      it "returns the number of slots created" do
        m = FactoryBot.build(
          :default_create_project_slot,
          start_date: 1.day.from_now.to_s, end_date: 3.days.from_now.to_s,
          morning_slot: '1', afternoon_slot: '1', evening_slot: '1' )

        total = m.create_slots(project)
        expect(total).to eq(9)
      end
    end

  end

end

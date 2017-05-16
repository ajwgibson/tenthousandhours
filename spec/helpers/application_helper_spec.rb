require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe "yes_no_icon" do
    it "when the value is true" do
      output = helper.yes_no_icon(true)
      expect(output).to include('<span class="fa fa-check text-success"> </span>')
    end
    it "when the value is false" do
      output = helper.yes_no_icon(false)
      expect(output).to include('<span class="fa fa-times text-danger"> </span>')
    end
  end


  describe "markdown" do
    it "converts the text to html" do
      output = helper.markdown('__bold__')
      expect(output).to include('<strong>bold</strong>')
    end
    it "can accept nil" do
      output = helper.markdown(nil)
      expect(output).to_not eq(nil)
    end
  end


  describe "filter" do
    it "returns nil if the filter has no values" do
      output = helper.filter Hash.new
      expect(output).to eq(nil)
    end
    it "humanizes the map keys" do
      output = helper.filter({ something_a_bit_different: 'A value' })
      expect(output).to include('<dt>Something a bit different</dt>')
    end
    it "outputs boolean values as yes or no" do
      output = helper.filter({ a_boolean: 'true' })
      expect(output).to include('<dd>Yes</dd>')
    end
  end


  describe "mobile_phone_number" do
    context "when the value is nil" do
      it "returns nil" do
        output = helper.mobile_phone_number(nil)
        expect(output).to eq(nil)
      end
    end
    context "when the value is 1234567890" do
      it "returns '+44 (0) 1234 567890'" do
        output = helper.mobile_phone_number('1234567890')
        expect(output).to eq('+44 (0) 1234 567890')
      end
    end
  end

end

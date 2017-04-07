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

end

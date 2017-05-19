class AddMobileConfirmationCodeToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :mobile_confirmation_code, :string
  end
end

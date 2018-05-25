class AddMobileConfirmationCodeToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :mobile_confirmation_code, :string
  end
end

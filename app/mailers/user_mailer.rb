class UserMailer < ApplicationMailer

  def welcome_email(user)

    @user = user
    @url  = admin_root_url

    email_with_name = %("#{@user.name}" <#{@user.email}>)

    mail(
      to:      email_with_name,
      subject: 'Welcome to 10,000 hours'
    )
  end

end

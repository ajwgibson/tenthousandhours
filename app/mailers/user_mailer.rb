class UserMailer < ApplicationMailer

  def welcome_email(user)

    @user = user
    @url  = 'http://tenthousandhours.grumpygibson.com/'

    email_with_name = %("#{@user.name}" <#{@user.email}>)

    mail(
      to:      email_with_name,
      subject: 'Welcome to 10,000 hours'
    )
  end

end

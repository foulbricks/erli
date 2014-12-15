class UserMailer < ActionMailer::Base
  
  def forgot_password(member)
    mail(
      :to     => member.email,
      :from   => "noreply@erli.com",
      :subject => "Account Password Reset",
      :template_path => "/mailers/user_mailer"
    )
  end
  
  def new_user(member)
    mail(
      :to     => member.email,
      :from   => "noreply@erli.com",
      :subject => "A New Account Has Been Created",
      :template_path => "/mailers/user_mailer"
    )
  end
  
  def welcome(member)
    mail(
      :to     => member.email,
      :from   => "noreply@erli.com",
      :subject => "Please activate your account",
      :template_path => "/mailers/user_mailer"
    )
  end
    
end
class UserMailer < ActionMailer::Base
  
  def forgot_password(member)
    @building = user.lease.apartment.building
    @user = user
    @company = Company.first
    @setup = Setup.first
    if Rails.env.development?
      @domain = "http://localhost:3000/"
    else
      @domain = ""
    end  
    
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
  
  def welcome(user)
    @building = user.lease.apartment.building
    @user = user
    @company = Company.first
    @setup = Setup.first
    if Rails.env.development?
      @domain = "http://localhost:3000/"
    else
      @domain = ""
    end  
    
    mail(
      :to     => user.email,
      :from   => "noreply@erli.com",
      :subject => "Si prega di attivare il tuo account per #{@building.name}",
      :template_path => "/mailers/user_mailer/welcome"
    )
  end
    
end
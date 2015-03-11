class UserMailer < ActionMailer::Base
  
  def forgot_password(user)
    @building = user.try(:lease).try(:apartment).try(:building)
    @user = user
    @company = Company.first
    @setup = Setup.where("building_id = ?", @building.id).first if @building
    if Rails.env.development?
      @domain = "http://localhost:3000"
    else
      @domain = "http://erli-env-ptdjt3gwkb.elasticbeanstalk.com"
    end  
    
    mail(
      :to     => user.email,
      :from   => "noreply@erli.com",
      :subject => "Reimpostazione Password Dell'Account",
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
    @setup = Setup.where("building_id = ?", @building.id).first
    if Rails.env.development?
      @domain = "http://localhost:3000"
    else
      @domain = "http://erli-env-ptdjt3gwkb.elasticbeanstalk.com"
    end  
    
    mail(
      :to     => user.email,
      :from   => "noreply@erli.com",
      :subject => "Si prega di attivare il tuo account per #{@building.name}",
      :template_path => "/mailers/user_mailer"
    )
  end
    
end
class UserMailer < ActionMailer::Base
  
  def forgot_password(user)
    @building = user.try(:lease).try(:apartment).try(:building)
    @user = user
    @company = Company.first
    @setup = Setup.where("building_id = ?", @building.id).first if @building
    if Rails.env.development?
      @domain = "http://localhost:3000"
    else
      @domain = "http://5.249.150.11"
    end  
    
    mail(
      :to     => user.escaped_email,
      :from   => "ERLIimmobiliare@gmail.com",
      :subject => "Reimpostazione Password Dell'Account",
      :template_path => "/mailers/user_mailer"
    )
  end
  
  def unpaid_mav(mav, unpaid_email)
    unpaid_email.unpaid_email_attachments.each do |a|
      f = a.document
      attachments[f.file.filename] = File.read(f.file.path)
    end
    
    mail(
      :to     => mav.user.escaped_email,
      :from   => "ERLIimmobiliare@gmail.com",
      :subject => "MAV Scaduto " + mav.expiration_value_it,
      :body => unpaid_email.body,
      :content_type => "text/html"
    ) # do |format|
#       format.text { render text: unpaid_email.body }
#     end
  end
  
  def welcome(user)
    @building = user.lease.apartment.building
    @user = user
    @company = Company.first
    @setup = Setup.where("building_id = ?", @building.id).first
    if Rails.env.development?
      @domain = "http://localhost:3000"
    else
      @domain = "http://5.249.150.11"
    end  
    
    mail(
      :to     => user.escaped_email,
      :from   => "ERLIimmobiliare@gmail.com",
      :subject => "Si prega di attivare il tuo account per #{@building.name}",
      :template_path => "/mailers/user_mailer"
    )
  end
    
end
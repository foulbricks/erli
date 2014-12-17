require "bcrypt"
require "digest/sha1"

class User < ActiveRecord::Base
  attr_accessor :passwd
  
  before_save :encrypt_password
  
  validates_presence_of :first_name, :last_name, :email
  validates_presence_of :passwd, :on => :create
  validates_confirmation_of :passwd, :on => :create
  validates_uniqueness_of :email
  
  def self.authenticate(email, pass)
    user = find_by_email(email)
    if user && user.password == BCrypt::Engine.hash_secret(pass, user.salt)
      user
    else
      nil
    end
  end
  
  def name
    [first_name, last_name].join(" ")
  end
  
  def encrypt_password
    if passwd.present?
      self.salt = BCrypt::Engine.generate_salt
      self.password = BCrypt::Engine.hash_secret(self.passwd, self.salt)
    end
  end
  
  def activate!
    unless within_activation_time?
      errors.add :activation, "The time allotment to activate your account has expired. Please request another activation code"
      return
    end
    self.activation_code = self.activation_code_set_at = nil
    save
  end
  
  def active?
    active && self.activation_code.nil?
  end
  
  def inactive?
    !active?
  end
  
  def send_signup_notification!
    self.activation_code = make_token
    save && UserMailer.welcome(self).deliver
  end
  
  def forgot_password!
    make_pw_reset_code!
    save(:validate => false)
    UserMailer.forgot_password(self).deliver
  end
  
  def reset_pw!(pw)
    self.passwd = pw
    self.pw_code = self.pw_code_set_at = nil
  end
  
  def within_activation_time?
    Time.now - activation_code_set_at < 2.days
  end
  
  def withing_pw_reset_time?
    Time.now - pw_code_set_at < 2.days
  end
  
  def make_activation_code!
    self.activation_code = make_token
    self.activation_code_set_at = Time.now
  end
  
  def make_pw_reset_code!
    self.pw_code = make_token
    self.pw_code_set_at = Time.now
  end
  
  private
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join("--"))
    end
    
    def make_token
      secure_digest(Time.now, (1..10).map { rand.to_s })
    end
  
end

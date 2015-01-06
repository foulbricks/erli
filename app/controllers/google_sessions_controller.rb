class GoogleSessionsController < ApplicationController
  skip_before_filter :authorize
  layout false
  
  def new
    
  end
  
  def create
    @auth = request.env["omniauth.auth"]["credentials"]
    GoogleToken.create(
      access_token: @auth["token"],
      refresh_token: @auth["refresh_token"],
      expires_at: Time.at(@auth["expires_at"])
    )
  end
end
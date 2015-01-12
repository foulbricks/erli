class UsersController < ApplicationController
  before_filter :check_admin, :clear_building
  
  def index
    @users = User.where(["admin = ?", true]).order("email DESC").all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.admin = true
    
    respond_to do |format|
      if @user.save
        format.html { 
          flash[:notice] = "User successfully saved"
          redirect_to users_path
        }
      else
        format.html {
          render "new"
        }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html {
          flash[:notice] = "User successfully updated"
          redirect_to users_path
        }
      else
        format.html {
          render "edit"
        }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if User.count > 1
      @user.destroy
      flash[:notice] = "User successfully deleted"
    else
      flash[:alert] = "Could not delete administrator because there would be none left!"
    end
    
    respond_to do |format|
      format.html {
        redirect_to users_path
      }
    end
  end 
  
  def forgot_password
    
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :passwd, :email, :passwd_confirmation, :active)
  end
      
end
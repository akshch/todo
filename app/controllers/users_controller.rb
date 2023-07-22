class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    password = Devise.friendly_token.first(10)
    @user.password = password
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :role)
  end

end
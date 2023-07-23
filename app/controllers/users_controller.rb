class UsersController < ApplicationController

  before_action :authenticate_user!, :check_admin

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
      UserMailer.with(user: @user, password: password).password_email.deliver_later
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

  def check_admin
    return if current_user.admin?

    redirect_to root_path, notice: "You don't have access to this page"
  end

end
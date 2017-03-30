class UsersController < ApplicationController

  before_action :set_user, only: [:show, :edit, :update, :destroy]


  def index
    @users = User.order(:email)
  end


  def show
  end


  def new
    @user = User.new
    render :edit
  end


  def create
    @user = User.new user_params
    if @user.save
      redirect_to( { action: 'index' }, notice: 'User was created successfully' )
    else
      render :edit
    end
  end


  def edit
  end


  def update
    if @user.update_without_password user_params
      redirect_to @user, notice: 'User was updated successfully'
    else
      render :edit
    end
  end


  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was deleted'
  end


  private
    def set_user
      @user = User.find(params[:id])
    end

    # Parameter white list
    def user_params
      params
        .require(:user)
        .permit(
          :email,
          :first_name,
          :last_name,
          :role,
          :password,
          :password_confirmation
        )
    end

end

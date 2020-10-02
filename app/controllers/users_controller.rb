# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = Customer.order('last_name')
  end
  
  def show
    @user = Customer.find(params[:id])
    @user_events = @user.events.order('date')
  end
  
  def edit
  end
  
  def update
  end

  def create; end

  def dashboard; end
  
  def delete
    @user = Customer.find(params[:id])
  end
  
  def destroy
    @user = Customer.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
  
end

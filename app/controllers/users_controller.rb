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
    @user = Customer.find(params[:id])
  end
  
  def update
    @user_info = params['customer']
    @user = Customer.find(params[:id])
    @user.update_attribute(:role, @user_info['role'])
    redirect_to users_path
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

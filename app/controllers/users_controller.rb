# frozen_string_literal: true

class UsersController < ApplicationController

  before_action :check_admin

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

  def check_admin
    unless Customer.find(session[:user_id]).role == 'admin'
      flash[:notice] = 'Non-admins are not authorized to view this page.'
      redirect_to(events_path)
    end
  end
  
end

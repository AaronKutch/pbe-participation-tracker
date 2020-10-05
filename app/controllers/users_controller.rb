# frozen_string_literal: true

class UsersController < ApplicationController

  before_action :check_admin

  def index
    @users = Customer.order('last_name')
  end
  
  def show
    begin
      @user = Customer.find(params[:id])
      if (@user == nil)
        raise 'error'
      end
      @user_events = @user.events.order('date')
    rescue
      flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
      redirect_to(users_path)
    end
  end
  
  def edit
    begin
      @user = Customer.find(params[:id])
      if (@user == nil)
        raise 'error'
      end
    rescue
      flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
      redirect_to(users_path)
    end
  end
  
  def update
    begin
      @user_info = params['customer']
      @user = Customer.find(params[:id])
      if (@user == nil)
        raise 'error'
      end
      @user.update_attribute(:role, @user_info['role'])
      redirect_to(users_path)
    rescue
      flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
      redirect_to(users_path)
    end
  end

  def create; end

  def dashboard; end
  
  def delete
    begin
      @user = Customer.find(params[:id])
      if (@user == nil)
        raise 'error'
      end
    rescue
      flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
      redirect_to(users_path)
    end
  end
  
  def destroy
    begin
      @user = Customer.find(params[:id])
      if (@user == nil)
        raise 'error'
      end
      @user.destroy
      redirect_to(users_path)
    rescue
      flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
      redirect_to(users_path)
    end
  end

  def check_admin
    unless Customer.find(session[:user_id]).role == 'admin'
      flash[:notice] = 'Non-admins are not authorized to view this page.'
      redirect_to(events_path)
    end
  end
  
end

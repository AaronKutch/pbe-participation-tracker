# frozen_string_literal: true

# Users CRUD controller
class UsersController < ApplicationController
  before_action :confirm_logged_in

  def index
    @users = Customer.order('last_name')

    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end

    # conditionally renders admin or user index view
    case @user_role
    when 'admin'
      render('index_admin')
    when 'user'
      render('index_user')
    end
  end

  def show
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user_events = @user.events.order('date')
  rescue StandardError
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end

  def edit
    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end
    unless @user_role == 'admin'
      flash[:notice] = 'You do not have admin permissions.'
      return redirect_to(users_path)
    end
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end

  def update
    @user_info = params['customer']
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.update_attribute(:role, @user_info['role'])
    redirect_to(users_path)
  rescue StandardError
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end

  def delete
    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end
    unless @user_role == 'admin'
      flash[:notice] = 'You do not have admin permissions.'
      return redirect_to(users_path)
    end
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end

  def destroy
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.destroy
    redirect_to(users_path)
  rescue StandardError
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end
end

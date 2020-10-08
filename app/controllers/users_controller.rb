class UsersController < ApplicationController
  # before_action :check_admin

  def index
    @users = Customer.order('last_name')

    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end

    # conditionally renders admin or user index view
    if @user_role == 'admin'
      render('index_admin')
    elsif @user_role == 'user'
      render('index_user')
    end
  end

  def show
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user_events = @user.events.order('date')
  rescue StandardError
    flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
    redirect_to(users_path)
  end

  def edit
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
    redirect_to(users_path)
  end

  def update
    @user_info = params['customer']
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.update_attribute(:role, @user_info['role'])
    redirect_to(users_path)
  rescue StandardError
    flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
    redirect_to(users_path)
  end

  def create; end

  def dashboard; end

  def delete
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
    redirect_to(users_path)
  end

  def destroy
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.destroy
    redirect_to(users_path)
  rescue StandardError
    flash[:notice] = 'No customer found with ID ' + params[:id].to_s + '.'
    redirect_to(users_path)
  end

  # def check_admin
  #   unless Customer.find(session[:user_id]).role == 'admin'
  #     flash[:notice] = 'Non-admins are not authorized to view this page.'
  #     redirect_to(events_path)
  #   end
  # end
end

# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = Customer.order('last_name')
  end
  
  def show
    @user = Customer.find(params[:id])
    @user_events = @user.events.order('date')
  end

  def create; end

  def update; end

  def dashboard; end
end

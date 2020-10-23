# frozen_string_literal: true

require 'csv'

# Users CRUD controller
class UsersController < ApplicationController
  before_action :confirm_logged_in
  before_action :confirm_permissions, except: %i[index show]

  def index
    @users = Customer.order('last_name')
    @user_role = Customer.where(id: session[:user_id]).first.role

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

  def export_attendance_csv
    # NOTE csv files are a bad idea for big data larger than this anyway, if the scale of this
    # program is ever increased beyond this point, there needs to be some kind of filtering
    users = Customer.order('last_name').take(10_000)
    events = Event.order('date').take(10_000)

    # create csv string
    csv_string = CSV.generate do |csv|
      # set the header row first
      header = ['Last name', 'First name', 'total attendances']

      # push a column for every meeting
      event_index = header.length
      # this hashmap is for keeping track of which column corresponds to an event id,
      # because we have a manual query that would be clumsy to sort
      id_map = {}
      events.each do |event|
        header.push(event.title)
        id_map[event.id] = event_index
        event_index += 1
      end
      csv << header

      # fill out table rows according to every user
      users.each do |user|
        row = [user.last_name, user.first_name, '']
        # start the row empty
        (0..id_map.size).each do
          row.push('')
        end
        # manual query instead of needing to have an existence query for every combination of
        # customer and event
        query = ActiveRecord::Base.connection.execute(
          "SELECT customers_events.event_id FROM customers_events WHERE customers_events.customer_id = #{user.id};"
        )
        num_attended = 0
        query.each_row do |id|
          # modify the corresponding cell to have a '1'
          row[id_map[id.first]] = '1'
          num_attended += 1
        end
        row[2] = num_attended.to_s
        csv << row
      end
    end

    # send the data for download by admin
    d = Date.today
    send_data(
      csv_string,
      filename: "attendance-#{d.day}-#{d.month}-#{d.year}.csv",
      type: 'text/csv; charset=utf-8; header=present'
    )
  end
end

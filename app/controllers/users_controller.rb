# frozen_string_literal: true

require 'csv'

# Users CRUD controller
class UsersController < ApplicationController
  before_action :confirm_logged_in
  before_action :confirm_permissions, except: %i[index show change_password]

  def index
    order = if params[:sort].nil?
              'last_name'
            else
              ActiveRecord::Base.sanitize_sql_for_order(params[:sort])
            end
    @users = Customer.order(order)
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

    @password_change = PasswordChange.new
    @session_user = Customer.find_by(id: session[:user_id])
    raise 'error' if @session_user.nil?

    order = if params[:sort].nil?
              'date'
            else
              ActiveRecord::Base.sanitize_sql_for_order(params[:sort])
            end
    @user_events = @user.events.order(order)
  rescue StandardError
    on_user_not_found
  end

  def edit
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    on_user_not_found
  end

  def update
    @user_info = params['customer']
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.update_attribute(:role, @user_info['role'])
    redirect_to(users_path)
  rescue StandardError
    on_user_not_found
  end

  def delete
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?
  rescue StandardError
    on_user_not_found
  end

  def destroy
    @user = Customer.find_by(id: params[:id])
    raise 'error' if @user.nil?

    @user.destroy
    redirect_to(users_path)
  rescue StandardError
    on_user_not_found
  end

  def on_user_not_found
    flash[:notice] = "No user found with ID #{params[:id]}."
    redirect_to(users_path)
  end

  def change_password
    @session_user = Customer.find_by(id: session[:user_id])

    # Make sure that the user exists.
    @found_user = Customer.find_by(id: params[:user_id])
    unless @found_user
      flash[:notice] = 'Could not find user with given ID.'
      return redirect_to(users_path)
    end

    # If the user is a non-admin, authenticate their old password.
    unless @session_user.role == 'admin'
      @authorized_user = @found_user.authenticate(params[:password_change][:old_password])
      unless @authorized_user
        flash[:notice] = 'Invalid password.'
        return redirect_to(user_path(@found_user.id))
      end
    end

    # Save the new password.
    @found_user.password = params[:password_change][:new_password]
    @found_user.password_confirmation = params[:password_change][:new_password]
    @found_user.save

    # Reload user page.
    flash[:notice] = 'Password successfully updated.'
    redirect_to(user_path(@found_user.id))
  end

  def export_attendance_csv
    # NOTE: csv files are a bad idea for big data larger than this anyway, if the scale of this
    # program is ever increased beyond this point, there needs to be some kind of filtering
    events = Event.order('date').take(10_000)
    users = Customer.order('last_name').take(10_000)
    # a single manual query instead of needing to have an existence query for every combination of
    # customer and event
    query = ActiveRecord::Base.connection.execute(
      "SELECT * FROM customers_events LIMIT #{events.length * users.length};"
    )

    # first row for the CSV, which contains event names
    row0 = ["users: #{users.length}", '', '', "events: #{events.length}"]
    # per event marginals for CSV
    marginal_event_attendance = []
    # this hashmap is for keeping track of which column corresponds to an event id,
    # because we have an unsorted bulk manual query that needs to be sorted for the table
    event_id_map = {}
    i = 0
    events.each do |event|
      row0.push(event.title)
      marginal_event_attendance.push(0)
      event_id_map[event.id] = i
      i += 1
    end

    # for keeping track of which row corresponds to a user id
    user_id_map = {}
    i = 0
    users.each do |user|
      user_id_map[user.id] = i
      i += 1
    end

    table = Array.new(users.length) { Array.new(events.length) { false } }

    # set cells based on query
    query.each do |pair|
      user_indx = user_id_map[pair['customer_id']]
      event_indx = event_id_map[pair['event_id']]
      table[user_indx][event_indx] = true
    end

    # fill out second row with user attribute headers and event attendance marginals
    row1 = ['Last name', 'First name', 'Email', '']
    corner_marginal = 0
    (0...events.length).each do |event_i|
      column_marginal = 0
      (0...users.length).each do |user_i|
        column_marginal += 1 if table[user_i][event_i]
      end
      corner_marginal += column_marginal
      row1.push(column_marginal)
    end
    row1[3] = "marginals total: #{corner_marginal}"

    # create csv string
    csv_string = CSV.generate do |csv|
      csv << row0
      csv << row1

      # fill out table rows according to every user
      i = 0
      users.each do |user|
        row_marginal = 0
        row = [user.last_name, user.first_name, user.email, '']
        table_row = table[i]
        (0...events.length).each do |j|
          if table_row[j]
            row_marginal += 1
            row.push('1')
          else
            row.push('')
          end
        end
        row[3] = row_marginal
        csv << row
        i += 1
      end
    end

    # send the data for download by admin
    d = Date.today
    send_data(
      csv_string,
      filename: "attendance-#{d.day}-#{d.month}-#{d.year}.csv",
      type: 'text/csv; charset=utf-8'
    )
  end
end

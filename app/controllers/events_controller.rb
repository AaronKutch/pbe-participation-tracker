# frozen_string_literal: true

# Controller for Events CRU
class EventsController < ApplicationController
  before_action :confirm_logged_in
  before_action :confirm_permissions, except: %i[index show mark_attendance]

  def add_user
    @event = Event.find_by(id: params['id'])
    redirect_to(events_path) if @event.nil?
    # get every customer that is not already registered for this event
    s = 'SELECT * FROM customers WHERE customers.id NOT IN('
    s += 'SELECT customers_events.customer_id FROM customers_events '
    s += "WHERE customers_events.event_id = #{@event.id}"
    s += ') ORDER BY customers.last_name;'
    @query = ActiveRecord::Base.connection.execute(s)
  end

  def manual_add
    # Check that event exists.
    @event = Event.find_by(id: params['event_id'])
    if @event.nil?
      flash[:notice] = 'Could not find given event.'
      return redirect_to(events_path)
    end

    # Check that user exists.
    @user = Customer.find_by(id: params['user_id'])
    if @user.nil?
      flash[:notice] = 'Could not find given user.'
      return redirect_to(event_path(params['event_id']))
    end

    # Add event to list of users.
    @user.events << @event
  end

  def index
    order = if params[:sort].nil?
              'date'
            else
              ActiveRecord::Base.sanitize_sql_for_order(params[:sort])
            end
    @events = Event.order(order)
    @user_role = session[:user_id] ? Customer.where(id: session[:user_id]).first.role : 'not_logged_in'
    s = 'SELECT events.id FROM events WHERE events.id IN('
    s += 'SELECT customers_events.event_id FROM customers_events '
    s += "WHERE customers_events.customer_id = #{session[:user_id].to_i}"
    s += ') ORDER BY events.date;'
    @user_events = ActiveRecord::Base.connection.execute(s).values
    Time.use_zone('Central Time (US & Canada)') do
      @utc_offset = Time.zone.parse(Date.current.to_s).dst? ? 5.hours : 6.hours
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
    begin
      @event_record = Event.find_by(id: params[:id])
      if @event_record.nil?
        flash[:notice] = 'This event does not exist.'
        raise StandardError, 'error'
      end
    rescue StandardError
      return redirect_to(events_path)
    end
    @user_role = session[:user_id] ? Customer.where(id: session[:user_id]).first.role : 'not_logged_in'
    Time.use_zone('Central Time (US & Canada)') do
      @utc_offset = Time.zone.parse(Date.current.to_s).dst? ? 5.hours : 6.hours
    end

    order = if params[:sort].nil?
              'last_name'
            else
              ActiveRecord::Base.sanitize_sql_for_order(params[:sort])
            end
    @attendees = @user_role == 'admin' ? @event_record.customers.order(order) : []
    @attended = Customer.where(id: session[:user_id]).first.events.exists?(id: params[:id])

    # conditionally renders admin or user index view
    case @user_role
    when 'admin'
      render('show_admin')
    when 'user'
      render('show_user')
    end
  end

  def new
    @new_event = Event.new
  end

  def create
    @event_info = params['event']
    raise 'error' if @event_info['title'].length > 50

    date_time = construct_time(DATE_TIME_FIELD)
    end_time = construct_time(END_TIME_FIELD)

    if date_time <= end_time
      Event.create(title: @event_info['title'], description: @event_info['description'], date: date_time,
                   end_time: end_time, location: @event_info['location'], mandatory: @event_info['mandatory'])
      redirect_to events_path
    elsif date_time > end_time
      flash[:notice] = "\'Date'\ must be before \'End Time'\."
      redirect_to('/events/new')
    end
  rescue StandardError
    redirect_to new_event_path
  end

  def edit
    @event = Event.find_by(id: params[:id])
    raise StandardError, 'error' if @event.nil?
  rescue StandardError
    redirect_to(events_path)
  end

  def update
    @event_info = params['event']
    @event = Event.find_by(id: params[:id])
    raise 'error' if @event.nil?

    date_time = construct_time(DATE_TIME_FIELD)
    end_time = construct_time(END_TIME_FIELD)

    if date_time <= end_time
      @event.update(title: @event_info['title'], description: @event_info['description'], date: date_time,
                    end_time: end_time, location: @event_info['location'], mandatory: @event_info['mandatory'])
      redirect_to events_path
    elsif date_time > end_time
      flash[:notice] = "\'Date'\ must be before \'End Time'\."
      redirect_to("/events/#{params[:id]}/edit")
    end
  rescue StandardError
    redirect_to events_path
  end

  def delete
    @event_record = Event.find_by(id: params[:id])
    raise StandardError, 'error' if @event_record.nil?
  rescue StandardError
    redirect_to events_path
  end

  def destroy
    @event_record = Event.find_by(id: params[:id])
    raise StandardError, 'error' if @event_record.nil?

    @event_record.destroy
    redirect_to(events_path)
  rescue StandardError
    redirect_to(events_path)
  end

  def mark_attendance
    @user = Customer.where(id: session[:user_id]).first
    @user.events << Event.where(id: Integer(params[:event])).first
    redirect_to(events_path)
  rescue StandardError
    flash[:notice] = 'You have already registered for this event.'
    redirect_to(events_path)
  end

  def revoke_attendence
    @user = Customer.find(params[:customer])
    @event = Event.find(params[:event])
    raise 'error' if @user.nil? || @event.nil?

    @event.customers.delete(@user)
    redirect_to("/events/#{params[:event]}")
  rescue StandardError
    flash[:notice] = 'Student has not signed in yet.'
    redirect_to(events_path)
  end

  def generate_qr_code
    @event_title = params[:event_title]
    @event_id = params[:event_id]
    raise 'error' if Event.find_by(id: params[:event_id]).nil?

    @qr = RQRCode::QRCode.new(params[:url])
    render('qr')
  rescue StandardError
    flash[:notice] = 'Unable to create QR Code for this event'
    redirect_to(events_path)
  end

  private

  DATE_TIME_FIELD = 'date'
  END_TIME_FIELD = 'end_time'

  def construct_time(field)
    s = "#{@event_info["#{field}(1i)"]}-#{@event_info["#{field}(2i)"]}-#{@event_info["#{field}(3i)"]}"
    s += "T#{@event_info["#{field}(4i)"]}:#{@event_info["#{field}(5i)"]}:00+00:00"
    DateTime.parse(s)
  end
end

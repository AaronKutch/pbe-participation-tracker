# frozen_string_literal: true

# Controller for Events CRU
class EventsController < ApplicationController
  before_action :confirm_logged_in, except: %i[index show]
  before_action :confirm_permissions, except: %i[index show mark_attendance]

  def index
    @events = Event.order('date')
    @user_role = session[:user_id] ? Customer.where(id: session[:user_id]).first.role : 'not_logged_in'
    Time.use_zone('Central Time (US & Canada)') do
      @utc_offset = Time.zone.parse(Date.current.to_s).dst? ? 5.hours : 6.hours
    end

    # conditionally renders admin or user index view
    case @user_role
    when 'admin'
      render('index_admin')
    when 'user'
      render('index_user')
    else
      redirect_to(access_login_path)
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

    @attendees = @user_role == 'admin' ? @event_record.customers : []

    # conditionally renders admin or user index view
    case @user_role
    when 'admin'
      render('show_admin')
    when 'user'
      render('show_user')
    else
      redirect_to(access_login_path)
    end

  end

  def new
    @new_event = Event.new
  end

  def create
    @event_info = params['event']
    Event.create(title: @event_info['title'], description: @event_info['description'], date: construct_date_time,
                 end_time: construct_end_time, location: @event_info['location'], mandatory: @event_info['mandatory'])
    redirect_to events_path
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
    @event = Event.find(params[:id])
    @event.update(title: @event_info['title'], description: @event_info['description'], date: construct_date_time,
                  end_time: construct_end_time, location: @event_info['location'], mandatory: @event_info['mandatory'])
    redirect_to events_path
  rescue StandardError
    redirect_to edit_event_path
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
  rescue StandardError
    flash[:notice] = 'You have already registered for this event.'
    redirect_to(events_path)
  end

  def revoke_attendence
    @user = Customer.find(params[:customer])
    @event = Event.find(params[:event])
    @event.customers.delete(@user)
    redirect_to("/events/#{params[:event]}")
  rescue StandardError
    flash[:notice] = 'Student has no signed in.'
  end

  def generate_qr_code
    @event_title = params[:event]
    @qr = RQRCode::QRCode.new(params[:url])
    render('qr')
  rescue StandardError
    flash[:notice] = "Unable to create QR Code for this event"
    redirect_to(events_path)
  end

  private

  def construct_date_time
    s = "#{@event_info['date(1i)']}-#{@event_info['date(2i)']}-#{@event_info['date(3i)']}"
    s += "T#{@event_info['date(4i)']}:#{@event_info['date(5i)']}:00+00:00"
    DateTime.parse(s)
  end

  def construct_end_time
    s = "#{@event_info['end_time(1i)']}-#{@event_info['end_time(2i)']}-#{@event_info['end_time(3i)']}"
    s += "T#{@event_info['end_time(4i)']}:#{@event_info['end_time(5i)']}:00+00:00"
    DateTime.parse(s)
  end
end

# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :confirm_logged_in, except: %i[index show]
  before_action :confirm_permissions, except: %i[index show mark_attendance]
  @time_zone = 6

  def index
    @events = Event.order('date')

    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end
  end

  def show
    begin
      @event_record = Event.find(params[:id])
    rescue StandardError
      redirect_to events_path
    end

    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end

    @attendees = []
    @attendees = @event_record.customers if @user_role == 'admin'
  end

  def new
    @new_event = Event.new
  end

  def create
    @event_info = params['event']
    Event.create(
      title: @event_info['title'],
      description: @event_info['description'],
      date: construct_date_time,
      end_time: construct_end_time,
      location: @event_info['location'],
      mandatory: @event_info['mandatory']
    )
    redirect_to events_path
  rescue StandardError
    redirect_to new_event_path
  end

  def edit
    @event = Event.find(params[:id])
  rescue StandardError
    redirect_to events_path
  end

  def update
    @event_info = params['event']
    @event = Event.find(params[:id])
    @event.update(
      title: @event_info['title'],
      description: @event_info['description'],
      date: construct_date_time,
      end_time: construct_end_time,
      location: @event_info['location'],
      mandatory: @event_info['mandatory']
    )
    redirect_to events_path
  rescue StandardError
    redirect_to edit_event_path
  end

  def delete
    @event_record = Event.find(params[:id])
  rescue StandardError
    redirect_to events_path
  end

  def destroy
    begin
      @event_record = Event.find(params[:id])
      @event_record.destroy
    rescue StandardError
      # TODO: recover from failure to destroy
    end
    redirect_to events_path
  end

  def mark_attendance
    @user = Customer.where(id: session[:user_id]).first
    @user.events << Event.where(id: Integer(params[:event])).first
  rescue StandardError
    flash[:notice] = 'You have already registered for this event.'
    redirect_to(events_path)
  end

  private

  def confirm_permissions
    if Customer.where(id: session[:user_id]).first.role == 'admin'
      nil
    else
      flash[:notice] = "You don't have permission to do that"
      redirect_to(events_path)
    end
  end

  def construct_date_time
    s = "#{@event_info['date(1i)']}-#{@event_info['date(2i)']}-#{@event_info['date(3i)']}"
    s += "T#{@event_info['date(4i)']}:#{@event_info['date(5i)']}+0#{@time_zone}:00"
    DateTime.parse(s)
  end

  def construct_end_time
    s = "#{@event_info['end_time(1i)']}-#{@event_info['end_time(2i)']}-#{@event_info['end_time(3i)']}"
    s += "T#{@event_info['end_time(4i)']}:#{@event_info['end_time(5i)']}+#{@time_zone}"
    DateTime.parse(s)
  end
end

class EventsController < ApplicationController
  before_action :confirm_logged_in, except: [:index, :show]
  before_action :confirm_permissions, except: [:index, :show, :mark_attendance]
	@time_zone = 6

  def index
    @events = Event.order("date")

    @user_role = "guest"
    if session[:user_id]
      @user_role = Customer.where(:id => session[:user_id]).first.role
    end
  end

  def show
    begin
      @event_record = Event.find(params[:id])
    rescue
      redirect_to events_path
    end

    @user_role = "guest"
    if session[:user_id]
      @user_role = Customer.where(:id => session[:user_id]).first.role
    end

    @attendees = []
    if @user_role == "admin"
      @attendees = @event_record.customers
    end
  end

  def new
    @new_event = Event.new
  end

  def create
    begin
      @event_info = params["event"]
      puts "Date — " + @event_info["date"].to_s
      dt = DateTime.parse(@event_info["date(1i)"].to_s + "-" + @event_info["date(2i)"].to_s + "-" + @event_info["date(3i)"].to_s + "T" + @event_info["date(4i)"].to_s + ":" + @event_info["date(5i)"].to_s + "+0" + @time_zone.to_s + ":00")
      Event.create(:title => @event_info["title"], :description => @event_info["description"], :date => dt, :location => @event_info["location"], :mandatory => @event_info["mandatory"])
      redirect_to events_path
    rescue
      redirect_to new_event_path
    end
  end

  def edit
    begin
      @event = Event.find(params[:id])
    rescue
      redirect_to events_path
    end
  end

  def update
    begin
      @event_info = params["event"]
      @event = Event.find(params[:id])
      puts "DATE --  " + @event_info["date"].to_s
      dt = DateTime.parse(@event_info["date(1i)"].to_s + "-" + @event_info["date(2i)"].to_s + "-" + @event_info["date(3i)"].to_s + "T" + @event_info["date(4i)"].to_s + ":" + @event_info["date(5i)"].to_s + "+0" + @time_zone.to_s + ":00")
      @event.update_attributes(:title => @event_info["title"], :description => @event_info["description"], :date => dt, :location => @event_info["location"], :mandatory => @event_info["mandatory"])
      redirect_to events_path
    rescue
      redirect_to edit_event_path
    end
  end

  def delete
    begin
      @event_record = Event.find(params[:id])
    rescue
      redirect_to events_path
    end
  end

  def destroy
    begin
      @event_record = Event.find(params[:id])
      @event_record.destroy
    rescue
    end
    redirect_to events_path
  end

  def mark_attendance
    @user = Customer.where(:id => session[:user_id]).first
    @user.events << Event.where(:id => Integer(params[:event])).first
  end

  private 
    def confirm_permissions
      if Customer.where(:id => session[:user_id]).first.role != 'admin'
        flash[:notice] = "You don't have permission to do that"
        redirect_to(events_path)
      end
    end
end

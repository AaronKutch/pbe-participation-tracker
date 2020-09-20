class EventsController < ApplicationController

	@time_zone = 6

  def index
	@events = Event.order("date")
  end

  def show
  	begin
		@event_record = Event.find(params[:id])
	rescue
		redirect_to events_path
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
end

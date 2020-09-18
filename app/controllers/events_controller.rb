class EventsController < ApplicationController
  def index
	@events = Event.order("date")
  end

  def show
	@event_record = Event.find(params[:id])
  end

  def new
	@new_event = Event.new
	@time = ""
  end

  def create
	@event_info = params["event"]	
	Event.create(:title => @event_info["title"], :description => @event_info["description"], :date => @event_info["date"], :location => @event_info["location"], :mandatory => @event_info["mandatory"])
	redirect_to events_path
  end

  def edit
  	@event = Event.find(params[:id])
  end

  def update
  	@event_info = params["event"]
  	@event = Event.find(params[:id])
  	@event.update_attributes(:title => @event_info["title"], :description => @event_info["description"], :date => @event_info["date"], :location => @event_info["location"], :mandatory => @event_info["mandatory"])
  	redirect_to events_path
  end

  def delete
	@event_record = Event.find(params[:id])
  end

  def destroy
	@event_record = Event.find(params[:id])
	@event_record.destroy
	redirect_to events_path
  end
end

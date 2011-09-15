class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :authorize_admin, :only => [:new, :create, :edit, :update]
  
  def index
    @events = Event.order("begins DESC") # TODO: paginate
  end
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(params[:event])
    
    if @event.save
      redirect_to @event, :notice => "Event added succesfully."
    else
      render :action => :new
    end
  end
  
  def show
    @event = Event.find(params[:id])
    @replays = Replay.public.processed.includes(:event, :plays, :players).order("replays.saved_at DESC").where(:event_id => @event.id).paginate(:per_page => 10, :page => params[:page])
    @replays_count = @event.replays.count
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was succesfully updated.'
      redirect_to @event
    else
      render :action => :edit
    end
  end
end
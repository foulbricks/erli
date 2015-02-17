class EventsController < ApplicationController
  before_filter :check_admin
  
  def index
    active = params[:active] || true
    if params[:building_id]
      @events = Event.where(:building_id => params[:building_id], :active => active).order("start ASC, created_at ASC").all
    elsif params[:apartment_id]
      @events = Event.where(:apartment_id => params[:apartment_id], :active => active).order("start ASC, created_at ASC").all
    elsif params[:user_id]
      @events = Event.where(:user_id => params[:user_id], :active => active).order("start ASC, created_at ASC").all
    else
      @events = Event.where(:active => active).order("start ASC, created_at ASC").all
    end
    
    events = {}

    if active != "false"
      @events.each do |event|
        (event.start.to_date..event.finish.to_date).each do |date|
          events[date.to_s] ||= []
          coll = events[date.to_s].select {|e| e[event.color].present? }.first
          if coll
            coll[event.color] << event.to_json
          else
            events[date.to_s] << { event.color => [event.to_json] }
          end
        end
      end
    else
      events = @events
    end

    render :json => events
  end
  
  def new
    @event = Event.new
    render :layout => false
  end
  
  def create
    @event = Event.new(event_params)
    @event.active = true
    
    if @event.save
      render :json => {:success => @event.start.strftime("%Y-%m-%d") }
    else
      render :json => {:error => @event.errors.full_messages.join(", ") }
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    render :layout => false
  end
  
  def update
    @event = Event.find(params[:id])
    
    if @event.update(event_params)
      render :json => {:success => @event.start.strftime("%Y-%m-%d") }
    else
      render :json => {:error => @event.errors.full_messages.join(", ") }
    end
  end
  
  def show
    @event = Event.find(params[:id])
    render :layout => false
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    render :json => {:success => true }
  end
  
  def clear
    @event = Event.find(params[:id])
    @event.update_column(:active, false)
    render :json => {:success => true }
  end
  
  def reinstate
    @event = Event.find(params[:id])
    @event.update_column(:active, true)
    render :json => {:success => true }
  end
  
  private
  
  def event_params
    params.require(:event).permit(:title, :description, :start, :finish, :color, :building_id, :apartment_id,
                                  :user_id, :lease_id, :kind, :active)
  end
  
end
class EventsController < ApplicationController
  before_filter :check_admin
  
  def index
    active = params[:active] || true
    
    if params[:building_id]
      @events = Event.where({:building_id => params[:building_id], :active => active}).
                order("start ASC, created_at ASC")
    elsif params[:apartment_id]
      @events = Event.where({:apartment_id => params[:apartment_id], :active => active}).
                order("start ASC, created_at ASC")
    elsif params[:user_id]
      @events = Event.where({:user_id => params[:user_id], :active => active}).
                order("start ASC, created_at ASC")
    else
      @events = Event.where({:active => active}).order("start ASC, created_at ASC")
    end
    
    @events = @events.where("label ~ ?", ",? ?#{params[:label]},?") if params[:label].present?
    @events = @events.all
    
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
    
    if @event.repeat
      if @event.valid? && @event.frequency_number.to_i > 0
        events = Event.make_events(@event, event_params)
        if events.any?
          render :json => {:success => events[0].start.strftime("%Y-%m-%d") }
        else
          render :json => {:error => "No events were created" }
        end
      else
        render :json => {:error => "Frequency is not a number" }
      end
    else
      if @event.save
        render :json => {:success => @event.start.strftime("%Y-%m-%d") }
      else
        render :json => {:error => @event.errors.full_messages.join(", ") }
      end
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    render :layout => false
  end
  
  def update
    @event = Event.find(params[:id])
    @event = Event.find(@event.parent) if @event.parent.present? and params[:modify] == "all"
    
    if @event.update(event_params)
      if @event.repeat? && @event.parent.present? and params[:modify] == "all"
         events = Event.where("parent = ? and id <> ?", @event.parent, @event.id).all
         events.each {|e| e.destroy }
         events = Event.make_events(@event, event_params)
         @event.destroy
         @event = events[0]
      end
      if @event.present?
        render :json => {:success => @event.start.strftime("%Y-%m-%d") }
      else
        render :json => {:error => "No events were saved" }
      end
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
    if @event.parent.present?
      Event.where("parent = ?", @event.parent).all.each do |e|
        e.destroy
      end
    else
      event.destroy
    end
    render :json => {:success => true }
  end
  
  def clear
    @event = Event.find(params[:id])
    if @event.parent.present?
      Event.where("parent = ?", @event.parent).all.each do |e|
        e.update_column(:active, false)
      end
    else
      @event.update_column(:active, false)
    end
    render :json => {:success => true }
  end
  
  def reinstate
    @event = Event.find(params[:id])
    if @event.parent.present?
      Event.where("parent = ?", @event.parent).all.each do |e|
        e.update_column(:active, true)
      end
    else
      @event.update_column(:active, true)
    end
    render :json => {:success => true }
  end
  
  private
  
  def event_params
    params.require(:event).permit(:title, :description, :start, :finish, :color, :building_id, :apartment_id,
                                  :user_id, :lease_id, :kind, :active, :label, :repeat, :frequency, 
                                  :frequency_number, :frequency_weekdays)
  end
  
end
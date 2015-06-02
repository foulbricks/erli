class Event < ActiveRecord::Base
  belongs_to :building
  belongs_to :apartment
  belongs_to :user
  belongs_to :lease
  
  validates :start, :finish, :title, :presence => true
  
  before_save do |event|
    event.label = event.label.strip.downcase if event.label.present?
  end
  
  def self.create_events(event, event_params, time_frame)
    events = []
    if event.start.is_a?(Date) and event.finish.is_a?(Date) and event.frequency_number.is_a?(Integer)
      days = event.frequency_weekdays.present? ? event.frequency_weekdays.split(",") : []
      from = event.start
      while from < event.finish
        if time_frame == "weeks" and days.any? and (!days.include?((from.wday + 1).to_s))
          from = from + 1.day
          next
        end
        e = Event.new(event_params)
        e.start, e.finish = from
        e.active = true
        e.parent = events[0].try(:id)
        e.save
        events << e
        if time_frame == "weeks" and days.any?
          from = from + 1.day
        else
          from = from + event.frequency_number.to_i.send("#{time_frame}")
        end
      end
    end
    events[0].update_attribute(:parent, events[0].id) if events.any?
    events
  end
  
  def self.make_events(event, event_params)
    if event.frequency == "daily"
      events = self.create_events(@event, event_params, "days")
    elsif event.frequency == "weekly"
      events = self.create_events(@event, event_params, "weeks")
    elsif event.frequency == "monthly"
      events = self.create_events(@event, event_params, "months")
    elsif event.frequency == "yearly"
      events = self.create_events(@event, event_params, "years")
    end
    return events
  end
  
end

namespace :event do
  desc 'schedule events'
  task schedule_events: :environment do
    Event.where(scheduled_at: nil).update_all(scheduled_at: DateTime.now)
  end
end
require './config/boot'
require './app/models/speech_schedule'

module Clockwork
  Clockwork.manager = DatabaseEvents::Manager.new

  sync_database_events :model => ::SpeechSchedule, :every => 1.minute do |speech_schedule|
    `say #{speech_schedule.speech_text}`
  end
end

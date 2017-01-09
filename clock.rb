require File.expand_path('../config/boot', __FILE__)

require 'models/speech_schedule'
require 'modules/speakable_module'

module Clockwork
  Clockwork.manager = DatabaseEvents::Manager.new

  sync_database_events :model => SpeechSchedule, :every => 1.minute do |speech_schedule|
    speech_schedule.speech
    speech_schedule.destroy if speech_schedule.once_only?
  end
end

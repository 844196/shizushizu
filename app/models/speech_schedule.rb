require 'modules/speakable_module'

class SpeechSchedule < ActiveRecord::Base
  include SpeakableModule

  serialize :wday

  enum :wdays => {
    :sunday => 0,
    :monday => 1,
    :tuesday => 2,
    :wednesday => 3,
    :thursday => 4,
    :friday => 5,
    :saturday => 6,
  }

  validate :wday_check

  def self.save_by(hash)
    entity = self.new do |me|
      me.name = hash['name']
      me.frequency = hash['frequency']
      me.at = hash['at']
      me.wday = hash['wday']
      me.speech_text = hash['speech_text']
      me.once_only = hash['once_only']
    end
    entity.tap(&:save)
  end

  def self.update_by(hash)
    entity = self.find(hash['id']).tap do |me|
      me.name = hash['name']
      me.frequency = hash['frequency']
      me.at = hash['at']
      me.wday = hash['wday']
      me.speech_text = hash['speech_text']
      me.once_only = hash['once_only']
    end
    entity.tap(&:save)
  end

  def if?(time)
    self.wday.include?(time.wday)
  end

  def wday_check
    expected = SpeechSchedule.wdays.values
    actual = self.wday

    errors.add(:day_of_weeks, '曜日が重複しています') unless actual.size === actual.uniq.size
    errors.add(:day_of_weeks, '不正な曜日指定です') unless ((expected | actual) - expected).size.zero?
  end
end

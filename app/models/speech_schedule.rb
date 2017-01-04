class SpeechSchedule < ActiveRecord::Base
  def self.save_by(hash)
    entity = self.new do |me|
      me.name = hash['name']
      me.frequency = hash['frequency'] if hash.has_key?('frequency')
      me.at = hash['at']
      me.speech_text = hash['speech_text']
    end
    entity.tap(&:save)
  end

  def self.update_by(hash)
    entity = self.find(hash['id']).tap do |me|
      me.name = hash['name']
      me.frequency = hash['frequency']
      me.at = hash['at']
      me.speech_text = hash['speech_text']
    end
    entity.tap(&:save)
  end
end

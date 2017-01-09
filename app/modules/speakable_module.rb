module SpeakableModule
  class << self
    def speech(speech_text)
      `say #{speech_text}`
    end
  end

  def speech
    SpeakableModule.speech(self.speech_text)
  end
end

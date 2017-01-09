require 'models/speech_schedule'
require 'modules/json_api_module'
require 'modules/speakable_module'

class ApiV1Controller < Sinatra::Base
  register Sinatra::Namespace
  register Sinatra::Reloader
  register JsonApiModule

  set :contracts, PROJECT_ROOT + '/contracts'

  namespace '/api/v1' do
    error ActiveRecord::RecordNotFound do
      response_json :status => status(404), :reason => 'Requested data was not found'
    end

    post '/speech' do
      SpeakableModule.speech(@payload['speech_text'])
    end

    get '/speech/schedules' do
      response_json SpeechSchedule.all.map(&:attributes)
    end

    post '/speech/schedules' do
      schedule = SpeechSchedule.save_by(@payload)
      headers['Location'] = "/api/v1/speech/schedules/#{schedule.id}"
      status 201
      response_json schedule.attributes
    end

    get '/speech/schedules/:id' do
      response_json SpeechSchedule.find(params['id']).attributes
    end

    put '/speech/schedules/:id' do
      schedule = SpeechSchedule.update_by(@payload)
      headers['Location'] = "/api/v1/speech/schedules/#{schedule.id}"
      status 204
    end

    delete '/speech/schedules/:id' do
      SpeechSchedule.find(params['id']).destroy
      status 204
    end
  end
end

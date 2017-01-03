require './config/boot'
require './app/models/speech_schedule'

class App < Sinatra::Base
  set :views, settings.root + '/app/views'
  set :method do |*methods|
    condition { methods.map {|m| m.to_s.upcase }.include?(request.request_method) }
  end

  register Sinatra::Namespace

  get '/' do
    haml :index
  end

  get '/schedules' do
    haml :schedules
  end

  namespace '/api/v1' do
    helpers do
      def contract(api_path, method, type)
        JSON.parse(File.read("#{settings.root}/contracts#{api_path.gsub(/(?<=schedules\/).+/, 'schedule')}/#{method}/#{type}.json"))
      end
    end

    before :method => [:post, :put] do
      begin
        JSON::Validator.validate!(
          contract(request.path, request.request_method, 'request'),
          @payload = JSON.parse(request.body.read)
        )
      rescue JSON::ParserError => e
        content_type :json
        halt 400, {:status => status(400), :reason => 'Request data was not JSON object' }.to_json
      rescue JSON::Schema::ValidationError => e
        content_type :json
        halt 400, {:status => status(400), :reason => e.message }.to_json
      end
    end

    error ActiveRecord::RecordNotFound do
      content_type :json
      {:status => status(404), :reason => 'Requested data was not found'}.to_json
    end

    error do
      content_type :json
      {:status => status(500), :reason => (settings.development? ? env['sinatra.error'].message : 'Internal server error') }.to_json
    end

    post '/speech' do
      `say #{@payload['speech_text']}`
    end

    get '/speech/schedules' do
      schedules = SpeechSchedule.all
      content_type :json
      schedules.to_json
    end

    post '/speech/schedules' do
      schedule = SpeechSchedule.new(@payload)
      schedule.save
      content_type :json
      status 201
      headers['Location'] = "/api/v1/speech/schedules/#{schedule.id}"
      schedule.to_json
    end

    put '/speech/schedules/:id' do
      schedule = SpeechSchedule.find(params['id'])
      schedule.update(@payload)
      status 204
      headers['Location'] = "/api/v1/speech/schedules/#{params['id']}"
    end

    delete '/speech/schedules/:id' do
      schedule = SpeechSchedule.find(params['id'])
      schedule.destroy
      status 204
    end
  end
end

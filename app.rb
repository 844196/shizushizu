require './config/boot'
require './app/models/speech_schedule'

class App < Sinatra::Base
  set :views, settings.root + '/app/views'
  set :method do |*methods|
    condition { methods.map {|m| m.to_s.upcase }.include?(request.request_method) }
  end
  set :show_exceptions, :after_handler

  register Sinatra::Namespace
  register Sinatra::Reloader if settings.development?

  get '/' do
    haml :index
  end

  get '/schedules' do
    haml :schedules
  end

  namespace '/api/v1' do
    helpers do
      def contract_(api_path, method, type)
        JSON.parse(File.read("#{settings.root}/contracts#{api_path.gsub(/(?<=schedules\/).+/, 'schedule')}/#{method}/#{type.to_s}.json"))
      end
    end

    before :method => [:post, :put] do
      begin
        JSON::Validator.validate!(
          contract(request.path, request.request_method, :request),
          @payload = JSON.parse(request.body.read)
        )
      rescue JSON::ParserError => e
        env['sinatra.error'] = e
        halt :status => status(400), :reason => 'Request data was not JSON object'
      rescue JSON::Schema::ValidationError => e
        env['sinatra.error'] = e
        halt :status => status(400), :reason => e.message
      end
    end

    after do
      case
      when response.status === 204 then
      when response.body === Hash, Array then
        begin
          unless env['sinatra.error']
            JSON::Validator.validate!(
              contract(request.path, request.request_method, :response),
              response.body
            )
          end
        rescue => e
          response.body = {:status => status(500), :reason => (settings.development? ? e.message : 'Internal server error')}
        ensure
          content_type :json
          response.body = response.body.to_json
        end
      end
    end

    error ActiveRecord::RecordNotFound do
      {:status => status(404), :reason => 'Requested data was not found'}
    end

    error do
      {:status => status(500), :reason => (settings.development? ? env['sinatra.error'].message : 'Internal server error') }
    end

    post '/speech' do
      `say #{@payload['speech_text']}`
    end

    get '/speech/schedules' do
      SpeechSchedule.all.map{|s| s.attributes }
    end

    post '/speech/schedules' do
      schedule = SpeechSchedule.save_by(@payload)
      status 201
      headers['Location'] = "/api/v1/speech/schedules/#{schedule.id}"
      schedule.attributes
    end

    put '/speech/schedules/:id' do
      SpeechSchedule.update_by(@payload)
      headers['Location'] = "/api/v1/speech/schedules/#{params['id']}"
      status 204
    end

    delete '/speech/schedules/:id' do
      SpeechSchedule.find(params['id']).destroy
      status 204
    end
  end
end

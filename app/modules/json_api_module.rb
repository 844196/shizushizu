module JsonApiModule
  extend Sinatra::Extension

  set :show_exceptions, false
  set :method do |*methods|
    condition { methods.map {|m| m.to_s.upcase }.include?(request.request_method) }
  end

  helpers do
    def contract(type)
      route = settings.routes[request.request_method]
        .find {|pattern,keys,conditions,block| pattern.match(request.path_info) }
        .at(3)
        .instance_variable_get(:@route_name)
        .gsub(/\A#{request.request_method}\s/, '')
        .gsub(/:([^\/]+)/, '__\1__')
      path = "#{settings.contracts}#{route}/#{request.request_method}/#{type}.json"
      JSON.parse(File.read(path))
    end

    def response_json(data)
      JSON::Validator.validate!(contract(:response), data) unless env['sinatra.error']
      content_type :json
      halt data.to_json
    end
  end

  options '*' do
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With,Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,DELETE,OPTIONS'
    halt 200
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  before :method => [:post, :put] do
    begin
      request.body.rewind
      @payload = JSON.parse(request.body.read)
      JSON::Validator.validate!(contract(:request), @payload)
    rescue JSON::ParserError => parser_error
      env['sinatra.error'] = parser_error
      response_json :status => status(400), :reason => 'Request data was not JSON object'
    rescue JSON::Schema::ValidationError => validation_error
      env['sinatra.error'] = validation_error
      response_json :status => status(406), :reason => validation_error.message
    end
  end

  error do
    message = settings.development? ? env['sinatra.error'].message : 'Internal server error'
    response_json :status => status(500), :reason => message
  end
end

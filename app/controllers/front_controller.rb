class FrontController < Sinatra::Base
  set :views, PROJECT_ROOT + '/app/views'
  set :public_folder, PROJECT_ROOT + '/public'

  get '/' do
    haml :index
  end

  get '/schedules' do
    haml :schedules
  end

  get '/test' do
    haml :test, :layout => false
  end

  get '/test2' do
    haml :test2, :layout => false
  end
end

require File.expand_path('../boot', __FILE__)

require 'controllers/api_v1_controller'
require 'controllers/front_controller'

class Application < Sinatra::Base
  use ApiV1Controller
  use FrontController if settings.development?
end

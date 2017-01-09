require 'yaml'
require 'json'
require 'bundler/setup'

Bundler.require()

PROJECT_ROOT = File.dirname(File.expand_path('../', __FILE__))

config = YAML.load_file(PROJECT_ROOT + '/config/database.yml')
ActiveRecord::Base.establish_connection(config)
ActiveRecord::Base.logger = Logger.new(STDOUT)

$:.unshift(PROJECT_ROOT + '/app')

require 'yaml'
require 'json'
require 'bundler/setup'
Bundler.require()

config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(config)

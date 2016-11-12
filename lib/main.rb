# Dashboard specific
require 'application'

configure :development do
  Sinatra::Application.reset!
  use Rack::Reloader
end

# If we could not find Chef configuration file then demo mode
if ChefNetworkViewerSettings.chef[:client].nil?
  puts 'Demo: Using Chef Zero server'
  require 'demo/chef_zero_server'
else
  puts "Loading config from #{ChefNetworkViewerSettings.chef[:client]}"
end

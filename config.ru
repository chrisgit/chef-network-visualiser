# Pin to Gems; Bundler.setup http://bundler.io/v1.7/bundler_setup.html
#require 'bundler/setup'

lib = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'main'

run ChefNetworkViewer::App.new

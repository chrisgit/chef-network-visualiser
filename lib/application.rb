require 'chefapi'
require 'helpers'
require 'tilt/erubis'
require 'sinatra'
require 'chefservice'

# The Sinatra application
module ChefNetworkViewer
  # Sinatra modular application
  class App < Sinatra::Base
  
    set :chef_api, ChefNetworkViewer::ChefAPI.new
#  set :chefservice, EnvironmentNetwork.new(settings.chef_api)       # View by Environment
#  set :chefservice, RoleNetwork.new(settings.chef_api)              # View by Role
    set :chefservice, EnvironmentNetwork.new(settings.chef_api)

    ## -----
    ## Sinatra Settings
    ## -----

    set :erb, escape_html: true
    set :root, ApplicationHelper.app_root
    set :protection, :except => :frame_options
    enable :static
  
    ## -----
    ## Views
    ## -----

    get '/?' do
      redirect '/index.html'
    end
  
    get '/node_stats' do
      settings.chefservice.node_stats.to_json
    end

    get '/environment_stats' do
      settings.chefservice.environment_stats.to_json
    end

    get '/role_stats' do
      settings.chefservice.role_stats.to_json
    end

    # View by Role or Environment
    get '/network_views' do
      headers 'Access-Control-Allow-Origin' => '*'
      content_type :json
      settings.chefservice.network_views.to_json
    end
  
    # Show all nodes for selected Role or Environment
    get '/network_nodes/:view_id' do
      headers 'Access-Control-Allow-Origin' => '*'
      content_type :json
      settings.chefservice.network_nodes(params[:view_id]).to_json
    end

    # Home in on a specific node	 
    get '/node_detail/:node_id' do
      headers 'Access-Control-Allow-Origin' => '*'
      content_type :json
      chef_node = settings.chef_api.node.find(params[:node_id])
      chef_version = chef_node.chef_attributes['chef_packages']['chef']['version']
      ohai_version = chef_node.chef_attributes['chef_packages']['ohai']['version']
      {name: chef_node.name, environment: chef_node.chef_environment, ipaddress: chef_node.public_ipv4, chef_version: chef_version, ohai_version: ohai_version}.to_json
    end

    ## -----
    ## Errors
    ## -----
    error do
      "I'm sorry an error occured during the process of your request. #{env['sinatra.error']}"
    end

    # 404 Error!
    not_found do
      status 404
      erb :oops
    end
  end
end

require 'app_config'
require 'ridley'
require 'ridley_ext'

# Maybe change this to ONLY expose server, then we have full access to Ridley ... could also then still add Circuit Breaker if necessary?
module ChefNetworkViewer
  # Class used to communicate with the Chef server
  class ChefAPI
    @ridley = nil

    def node
      server.node
    end
    
    def nodes
      server.node.all
    end

    def environments
      server.environment.all
    end

    def roles
      server.role.all
    end

    def partial_search(index, query = nil, attributes = [], options = {})
      server.partial_search(index, query, attributes, options)
    end
    
    def search(index, query = nil, options = {})
      server.search(index, query, options)
    end

    def server
      @ridley ||= Ridley.from_chef_config(ChefNetworkViewerSettings.chef[:client])
    end

    private :server
  end
end
